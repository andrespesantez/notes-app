#!/bin/bash
# ============================================
# Script de Destroy - Limpiar todo
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

echo "================================================"
echo "  Notes App - Destruir Infraestructura"
echo "================================================"
echo ""
echo "⚠️  ADVERTENCIA: Esto eliminará:"
echo "   - Cluster EKS y todos los pods"
echo "   - Base de datos RDS (¡datos perdidos!)"
echo "   - VPC y todos los recursos de red"
echo "   - ALB creado por Ingress Controller"
echo ""
echo "¿Estás seguro? Escribe 'destroy' para confirmar:"
read -r confirmation

if [ "$confirmation" != "destroy" ]; then
    echo "Operación cancelada"
    exit 0
fi

# Obtener configuración del cluster
echo ""
echo "Obteniendo configuración del cluster..."
cd "$TERRAFORM_DIR"

EKS_CLUSTER=$(terraform output -raw eks_cluster_name 2>/dev/null || echo "notes-app-eks")
AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")

# Intentar configurar kubectl
echo ""
echo "Configurando kubectl..."
aws eks update-kubeconfig --name "$EKS_CLUSTER" --region "$AWS_REGION" 2>/dev/null || true

# IMPORTANTE: Eliminar Ingress primero para que ALB Controller elimine el ALB
echo ""
echo "================================================"
echo "  Paso 1: Eliminar Ingress (ALB)"
echo "================================================"
echo "Eliminando Ingress para que el ALB Controller limpie el ALB..."
kubectl delete ingress --all -n notes-app --ignore-not-found=true 2>/dev/null || true

# Esperar a que el ALB se elimine
echo "Esperando 30 segundos para que el ALB se elimine..."
sleep 30

# Eliminar otros recursos de Kubernetes
echo ""
echo "================================================"
echo "  Paso 2: Eliminar recursos de Kubernetes"
echo "================================================"
echo "Eliminando deployments, services, etc..."
kubectl delete deployment --all -n notes-app --ignore-not-found=true 2>/dev/null || true
kubectl delete service --all -n notes-app --ignore-not-found=true 2>/dev/null || true
kubectl delete hpa --all -n notes-app --ignore-not-found=true 2>/dev/null || true
kubectl delete pdb --all -n notes-app --ignore-not-found=true 2>/dev/null || true
kubectl delete networkpolicy --all -n notes-app --ignore-not-found=true 2>/dev/null || true
kubectl delete pvc --all -n notes-app --ignore-not-found=true 2>/dev/null || true

# Eliminar el namespace
echo "Eliminando namespace notes-app..."
kubectl delete namespace notes-app --ignore-not-found=true 2>/dev/null || true

# Esperar un poco más
echo "Esperando 15 segundos..."
sleep 15

# Destruir infraestructura con Terraform
echo ""
echo "================================================"
echo "  Paso 3: Destruir infraestructura con Terraform"
echo "================================================"
cd "$TERRAFORM_DIR"
terraform destroy -auto-approve

echo ""
echo "================================================"
echo "  ✅ Infraestructura eliminada completamente"
echo "================================================"
echo ""
echo "Recursos eliminados:"
echo "  - Cluster EKS"
echo "  - Nodos EC2"
echo "  - Base de datos RDS"
echo "  - VPC, Subnets, NAT Gateway"
echo "  - ALB (via Ingress Controller)"
echo "  - Security Groups"
echo ""
