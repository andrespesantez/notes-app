# Notes App - Despliegue en AWS EKS

## 📋 Objetivos de la Práctica

Esta implementación cumple con los siguientes objetivos:

1. **Configurar y administrar clústeres de Kubernetes**: Clúster EKS con 2 nodos worker gestionados
2. **Automatizar despliegues mediante controladores**: Deployments con HPA para escalabilidad automática
3. **Implementar políticas de seguridad y supervisión**: RBAC, NetworkPolicies, SecurityContext, PDBs

---

## 🔧 Requisitos Previos

### 1. Cuenta de AWS

Si no tienes cuenta de AWS:
1. Ve a [https://aws.amazon.com/](https://aws.amazon.com/)
2. Click en "Crear una cuenta de AWS"
3. Completa el registro (requiere tarjeta de crédito)
4. Activa el **Free Tier** para minimizar costos

### 2. Crear Usuario IAM para Terraform

> ⚠️ **IMPORTANTE**: Nunca uses la cuenta root para operaciones diarias.

#### Paso 1: Crear Usuario IAM

```bash
# Ir a IAM Console: https://console.aws.amazon.com/iam/

# O usando AWS CLI (si ya tienes acceso):
aws iam create-user --user-name terraform-admin
```

#### Paso 2: Crear Política Personalizada

Ir a **IAM → Policies → Create Policy** y usar el JSON aws_policy_terraform.json:

Guardar como: `NotesAppTerraformPolicy`

#### Paso 3: Adjuntar Política al Usuario

```bash
# Desde IAM Console: Users → terraform-admin → Add permissions → Attach policies
# Seleccionar: NotesAppTerraformPolicy

# O con CLI:
aws iam attach-user-policy \
  --user-name terraform-admin \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/NotesAppTerraformPolicy
```

#### Paso 4: Crear Access Keys

```bash
# Desde IAM Console: Users → terraform-admin → Security credentials → Create access key
# Seleccionar: "Command Line Interface (CLI)"

# O con CLI:
aws iam create-access-key --user-name terraform-admin
```

> 📝 **Guarda** el `Access Key ID` y `Secret Access Key` - solo se muestran una vez.

### 3. Instalar Herramientas

```bash
# macOS
brew install awscli terraform kubectl helm

# Linux (Ubuntu/Debian)
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip && sudo mv terraform /usr/local/bin/

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 4. Configurar AWS CLI

```bash
aws configure
```

Ingresar:
```
AWS Access Key ID: AKIA...............
AWS Secret Access Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Default region name: us-east-1
Default output format: json
```

### 5. Verificar Configuración

```bash
# Verificar identidad
aws sts get-caller-identity

# Debería mostrar:
# {
#     "UserId": "AIDA...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/terraform-admin"
# }

# Verificar herramientas
terraform version
kubectl version --client
helm version
```

### 6. Configurar GitHub Secrets (para CI/CD)

En tu repositorio de GitHub: **Settings → Secrets and variables → Actions**

| Secret | Valor | Descripción |
|--------|-------|-------------|
| `AWS_ACCESS_KEY_ID` | `AKIA...` | Access Key del usuario IAM |
| `AWS_SECRET_ACCESS_KEY` | `xxxx...` | Secret Key del usuario IAM |
| `DOCKERHUB_USERNAME` | tu-usuario | Usuario de Docker Hub |
| `DOCKERHUB_TOKEN` | xxxx | Token de Docker Hub |

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                           VPC (10.0.0.0/16)                            │  │
│  │                                                                        │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │                    Public Subnets                                │  │  │
│  │  │              ┌─────────────────────┐                             │  │  │
│  │  │              │      AWS ALB        │◄──── Internet               │  │  │
│  │  │              │  (Ingress Controller)│     (Route 53 opcional)    │  │  │
│  │  │              └──────────┬──────────┘                             │  │  │
│  │  └─────────────────────────┼───────────────────────────────────────┘  │  │
│  │                            │                                           │  │
│  │  ┌─────────────────────────┼───────────────────────────────────────┐  │  │
│  │  │                Private Subnets                                   │  │  │
│  │  │     ┌───────────────────┼───────────────────┐                   │  │  │
│  │  │     │            EKS Cluster (2 nodos)      │                   │  │  │
│  │  │     │  ┌─────────┐      │      ┌─────────┐  │                   │  │  │
│  │  │     │  │  Node 1 │      │      │  Node 2 │  │                   │  │  │
│  │  │     │  │         │◄─────┴─────►│         │  │                   │  │  │
│  │  │     │  │┌───────┐│             │┌───────┐│  │                   │  │  │
│  │  │     │  ││Backend││  /api/*     ││Backend││  │                   │  │  │
│  │  │     │  │└───────┘│             │└───────┘│  │                   │  │  │
│  │  │     │  │┌────────┐             │┌────────┐  │                   │  │  │
│  │  │     │  ││Frontend│  /*         ││Frontend│  │                   │  │  │
│  │  │     │  │└────────┘             │└────────┘  │                   │  │  │
│  │  │     │  └─────────┘             └─────────┘  │                   │  │  │
│  │  │     └───────────────────┬───────────────────┘                   │  │  │
│  │  └─────────────────────────┼───────────────────────────────────────┘  │  │
│  │                            │                                           │  │
│  │  ┌─────────────────────────┼───────────────────────────────────────┐  │  │
│  │  │              Database Subnets                                    │  │  │
│  │  │              ┌──────────▼──────────┐                            │  │  │
│  │  │              │    AWS RDS MySQL    │                            │  │  │
│  │  │              │    (Gestionado)     │                            │  │  │
│  │  │              └─────────────────────┘                            │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                 │
│  │   Docker Hub   │  │   CloudWatch   │  │    Route 53    │                 │
│  │   (Imágenes)   │  │    (Logs)      │  │   (DNS opt.)   │                 │
│  └────────────────┘  └────────────────┘  └────────────────┘                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ✅ Tareas Implementadas

| Tarea | Implementación | Archivos |
|-------|----------------|----------|
| **Creación del clúster** | EKS con 2 nodos t3.medium | `terraform/main.tf` |
| **Cargas de trabajo** | Deployments (backend, frontend) | `k8s/06-07-*.yaml` |
| **Servicios y balanceadores** | ClusterIP + ALB Ingress | `k8s/09-ingress.yaml` |
| **Redes** | VPC, Subnets, NetworkPolicies | `terraform/main.tf`, `k8s/11-*.yaml` |
| **Almacenamiento** | StorageClass (EBS), PVCs | `k8s/04-storage.yaml` |
| **Seguridad** | RBAC, SecurityContext, Quotas | `k8s/02-rbac.yaml` |
| **Escalabilidad** | HPA (CPU-based) | `k8s/10-hpa.yaml` |
| **Alta disponibilidad** | PodDisruptionBudgets | `k8s/12-monitoring.yaml` |
| **Multi-ambiente** | Kustomize overlays (staging, qa) | `k8s/overlays/` |

---

## 📁 Estructura del Proyecto

```
notes-app/
├── .github/workflows/
│   ├── docker-push.yml      # CI: Build y push a Docker Hub
│   └── deploy-eks.yml       # CD: Deploy a EKS
├── terraform/
│   ├── main.tf              # VPC + EKS + RDS + ALB Controller
│   └── terraform.tfvars.example
├── k8s/
│   ├── 01-namespace.yaml    # Namespace
│   ├── 02-rbac.yaml         # ServiceAccounts, Roles, Quotas
│   ├── 03-secrets.yaml      # Credenciales RDS
│   ├── 04-storage.yaml      # StorageClass, PVCs
│   ├── 05-configmaps.yaml   # Configuración
│   ├── 06-backend.yaml      # Deployment + Service
│   ├── 07-frontend.yaml     # Deployment + Service
│   ├── 09-ingress.yaml      # ALB Ingress (routing)
│   ├── 10-hpa.yaml          # Horizontal Pod Autoscaler
│   ├── 11-network-policies.yaml  # Políticas de red
│   ├── 12-monitoring.yaml   # PDBs
│   ├── kustomization.yaml   # Base Kustomize
│   └── overlays/            # Ambientes (staging, qa)
│       ├── staging/
│       └── qa/
├── scripts/
│   ├── 01-setup-infra.sh    # Crear infraestructura
│   ├── 02-deploy-k8s.sh     # Desplegar aplicación
│   └── 03-destroy.sh        # Destruir todo
├── backend/                 # Spring Boot API
└── frontend/                # Next.js App
```

---

## 🚀 Guía de Despliegue

### Prerrequisitos

```bash
# macOS
brew install awscli terraform kubectl

# Configurar AWS CLI
aws configure
```

### Opción 1: Despliegue Manual

```bash
# 1. Configurar variables
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Editar con tus valores

# 2. Crear infraestructura (15-20 min)
cd ../scripts
./01-setup-infra.sh

# 3. Desplegar aplicación
./02-deploy-k8s.sh
```

### Opción 2: CI/CD Automático

El pipeline se activa automáticamente:
1. Push a `main` → `docker-push.yml` construye imágenes
2. Éxito → `deploy-eks.yml` despliega a EKS

**Secrets requeridos en GitHub:**
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

---

## 🔐 Seguridad Implementada

### RBAC (Role-Based Access Control)
- ServiceAccount dedicado por componente
- Roles con mínimos privilegios
- ResourceQuotas para limitar recursos del namespace

### Network Policies
- **Default Deny**: Todo tráfico bloqueado por defecto
- Reglas específicas:
  - Internet → Nginx (puerto 80)
  - Nginx → Frontend (puerto 3000)
  - Nginx → Backend (puerto 8080)
  - Frontend → Backend (puerto 8080)
  - Backend → RDS (puerto 3306)

### SecurityContext
- `runAsNonRoot: true` (donde es posible)
- `allowPrivilegeEscalation: false`
- `capabilities.drop: ALL`
- Sistema de archivos de solo lectura donde aplica

### Límites de Recursos
```yaml
LimitRange:
  - Container max: 2 CPU, 2Gi RAM
  - Container min: 50m CPU, 64Mi RAM
  
ResourceQuota:
  - Total: 8 CPU, 8Gi RAM
  - Max pods: 20
```

---

## 📈 Escalabilidad

### Horizontal Pod Autoscaler
| Componente | Min | Max | Trigger |
|------------|-----|-----|---------|
| Backend | 2 | 5 | CPU > 70% |
| Frontend | 2 | 4 | CPU > 70% |

### Cluster Autoscaler
- Nodos: 2-4 (t3.medium)
- Escalado automático según demanda

---

## 📊 Monitoreo

- **PodDisruptionBudgets**: Garantizan mínimo 1 pod disponible durante actualizaciones
- **Health Checks**: Readiness y Liveness probes en todos los pods
- **CloudWatch**: Logs del clúster EKS

---

## 🌐 Multi-Ambiente con Kustomize

La infraestructura soporta múltiples ambientes usando Kustomize overlays:

```bash
# Desplegar en producción (base)
kubectl apply -k k8s/

# Desplegar en staging
kubectl apply -k k8s/overlays/staging/

# Desplegar en QA
kubectl apply -k k8s/overlays/qa/
```

### Diferencias por Ambiente

| Característica | Producción | Staging | QA |
|---------------|------------|---------|-----|
| Namespace | notes-app | notes-app-staging | notes-app-qa |
| Backend replicas | 2-5 (HPA) | 1-2 | 1-2 |
| Frontend replicas | 2-4 (HPA) | 1-2 | 1-2 |
| ALB Ingress | ✅ | ✅ | ✅ |

---

## 💰 Costos Estimados (us-east-1)

| Recurso | Especificación | Costo/mes |
|---------|---------------|-----------|
| EKS Control Plane | Gestionado | ~$72 |
| EC2 Nodes | 2x t3.medium | ~$60 |
| RDS MySQL | db.t3.micro | ~$15 |
| ALB | Application LB | ~$22 |
| NAT Gateway | 1x | ~$32 |
| EBS | ~10GB | ~$1 |
| **Total** | | **~$202** |

---

## 🗑️ Limpieza

```bash
./scripts/03-destroy.sh
```

⚠️ **Importante**: Asegúrate de eliminar los recursos de Kubernetes antes de destruir la infraestructura para evitar ALBs huérfanos.

---

## 📚 Comandos Útiles

```bash
# Ver estado del clúster
kubectl get nodes

# Ver todos los recursos
kubectl get all -n notes-app

# Ver logs de un pod
kubectl logs -f deployment/backend -n notes-app

# Ver Network Policies
kubectl get networkpolicies -n notes-app

# Obtener URL del ALB Ingress
kubectl get ingress -n notes-app -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'

# Ver estado del ALB Controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Escalar manualmente
kubectl scale deployment backend --replicas=3 -n notes-app

# Ver eventos del Ingress
kubectl describe ingress notes-app-ingress -n notes-app

# Ver HPA status
kubectl get hpa -n notes-app

# Port forward para debugging local
kubectl port-forward svc/backend 8080:8080 -n notes-app
kubectl port-forward svc/frontend 3000:80 -n notes-app
```

---

## 🔧 Troubleshooting

### El ALB no se crea
```bash
# Verificar logs del ALB Controller
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Verificar anotaciones del Ingress
kubectl describe ingress notes-app-ingress -n notes-app
```

### Pods no inician
```bash
# Ver eventos
kubectl get events -n notes-app --sort-by='.lastTimestamp'

# Ver descripción del pod
kubectl describe pod <pod-name> -n notes-app
```

### Problemas de conexión a RDS
```bash
# Verificar secret
kubectl get secret rds-credentials -n notes-app -o yaml

# Probar conexión desde un pod
kubectl run mysql-test --rm -it --image=mysql:8.0 -n notes-app -- \
  mysql -h <rds-endpoint> -u admin -p
```

---

## 👥 Autores

- Proyecto: UNIR - Máster DevOps
- Actividad: Contenedores y Kubernetes
