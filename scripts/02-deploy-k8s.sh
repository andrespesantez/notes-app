#!/bin/bash
# ============================================
# Script de Deploy - Kubernetes
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$SCRIPT_DIR/../k8s"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

echo "================================================"
echo "  Notes App - Deploy a Kubernetes"
echo "================================================"

# Obtener variables necesarias
if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo "Ingresa tu usuario de Docker Hub:"
    read -r DOCKERHUB_USERNAME
fi

# Obtener outputs de Terraform
echo ""
echo "Obteniendo configuración de Terraform..."
cd "$TERRAFORM_DIR"

EKS_CLUSTER=$(terraform output -raw eks_cluster_name 2>/dev/null || echo "notes-app-eks")
AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")
RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null || echo "")
RDS_DB_NAME=$(terraform output -raw rds_database_name 2>/dev/null || echo "notes_db")

if [ -z "$RDS_ENDPOINT" ]; then
    echo "❌ No se pudo obtener el endpoint de RDS"
    echo "   Asegúrate de haber ejecutado 01-setup-infra.sh primero"
    exit 1
fi

# Configurar kubectl
echo ""
echo "================================================"
echo "  Configurando kubectl para EKS..."
echo "================================================"
aws eks update-kubeconfig --name "$EKS_CLUSTER" --region "$AWS_REGION"

# Crear directorio temporal para manifiestos procesados
TEMP_DIR=$(mktemp -d)
cp "$K8S_DIR"/*.yaml "$TEMP_DIR/"

# Reemplazar placeholders
echo ""
echo "Procesando manifiestos..."
sed -i.bak "s|DOCKERHUB_USERNAME|$DOCKERHUB_USERNAME|g" "$TEMP_DIR"/*.yaml

# Actualizar secrets con datos de RDS
echo ""
echo "Configurando credenciales de RDS..."
RDS_HOST=$(echo "$RDS_ENDPOINT" | cut -d':' -f1)

# Solicitar password de RDS
echo "Ingresa la contraseña de RDS (db_password de terraform.tfvars):"
read -rs DB_PASSWORD

cat > "$TEMP_DIR/03-secrets.yaml" << EOF
apiVersion: v1
kind: Secret
metadata:
  name: rds-credentials
  namespace: notes-app
type: Opaque
stringData:
  DB_HOST: "$RDS_HOST"
  DB_PORT: "3306"
  DB_NAME: "$RDS_DB_NAME"
  DB_USERNAME: "notes_user"
  DB_PASSWORD: "$DB_PASSWORD"
  SPRING_DATASOURCE_URL: "jdbc:mysql://$RDS_ENDPOINT/$RDS_DB_NAME"
EOF

# Aplicar manifiestos
echo ""
echo "================================================"
echo "  Aplicando manifiestos de Kubernetes..."
echo "================================================"

echo ">>> Namespace"
kubectl apply -f "$TEMP_DIR/01-namespace.yaml"

echo ">>> RBAC (ServiceAccounts, Roles, Quotas)"
kubectl apply -f "$TEMP_DIR/02-rbac.yaml"

echo ">>> Secrets"
kubectl apply -f "$TEMP_DIR/03-secrets.yaml"

echo ">>> Storage (StorageClass, PVCs)"
kubectl apply -f "$TEMP_DIR/04-storage.yaml"

echo ">>> ConfigMaps"
kubectl apply -f "$TEMP_DIR/05-configmaps.yaml"

echo ">>> Deployments"
kubectl apply -f "$TEMP_DIR/06-backend.yaml"
kubectl apply -f "$TEMP_DIR/07-frontend.yaml"

echo ">>> ALB Ingress"
kubectl apply -f "$TEMP_DIR/09-ingress.yaml"

echo ">>> HPA (Horizontal Pod Autoscaler)"
kubectl apply -f "$TEMP_DIR/10-hpa.yaml"

echo ">>> Network Policies"
kubectl apply -f "$TEMP_DIR/11-network-policies.yaml"

echo ">>> Monitoring (PDBs)"
kubectl apply -f "$TEMP_DIR/12-monitoring.yaml"

# Limpiar
rm -rf "$TEMP_DIR"

# Esperar a que los pods estén listos
echo ""
echo "================================================"
echo "  Esperando a que los pods estén listos..."
echo "================================================"

kubectl rollout status deployment/backend -n notes-app --timeout=300s
kubectl rollout status deployment/frontend -n notes-app --timeout=300s

# Mostrar estado
echo ""
echo "================================================"
echo "  Estado del Despliegue"
echo "================================================"
echo ""
echo "=== Pods ==="
kubectl get pods -n notes-app

echo ""
echo "=== Services ==="
kubectl get svc -n notes-app

echo ""
echo "=== Ingress ==="
kubectl get ingress -n notes-app

echo ""
echo "================================================"
echo "  ✅ Despliegue completado!"
echo "================================================"
echo ""
echo "Esperando URL del ALB Ingress (puede tomar 2-3 minutos)..."
sleep 30

ALB_URL=$(kubectl get ingress notes-app-ingress -n notes-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")
echo ""
echo "🌐 URL de la aplicación: http://$ALB_URL"
echo ""
echo "Rutas disponibles:"
echo "  - Frontend: http://$ALB_URL/"
echo "  - API:      http://$ALB_URL/api/notes"
echo "  - Health:   http://$ALB_URL/actuator/health"
echo ""
echo ""
