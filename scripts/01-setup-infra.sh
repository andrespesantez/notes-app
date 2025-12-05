#!/bin/bash
# ============================================
# Script de Setup - Infraestructura AWS
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

echo "================================================"
echo "  Notes App - Setup de Infraestructura AWS"
echo "================================================"

# Verificar requisitos
echo ""
echo "Verificando requisitos..."

command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform no está instalado"; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI no está instalado"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl no está instalado"; exit 1; }

echo "✅ Todos los requisitos están instalados"

# Verificar credenciales AWS
echo ""
echo "Verificando credenciales AWS..."
aws sts get-caller-identity > /dev/null || { echo "❌ Credenciales AWS no configuradas"; exit 1; }
echo "✅ Credenciales AWS válidas"

# Verificar terraform.tfvars
if [ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
    echo ""
    echo "⚠️  No existe terraform.tfvars"
    echo "   Copiando desde terraform.tfvars.example..."
    cp "$TERRAFORM_DIR/terraform.tfvars.example" "$TERRAFORM_DIR/terraform.tfvars"
    echo ""
    echo "❗ IMPORTANTE: Edita terraform/terraform.tfvars con tus valores antes de continuar"
    echo "   - db_password: Contraseña segura para RDS"
    echo "   - dockerhub_username: Tu usuario de Docker Hub"
    exit 1
fi

echo ""
echo "================================================"
echo "  Paso 1: Inicializar Terraform"
echo "================================================"
cd "$TERRAFORM_DIR"
terraform init

echo ""
echo "================================================"
echo "  Paso 2: Plan de Terraform"
echo "================================================"
terraform plan -out=tfplan

echo ""
echo "================================================"
echo "  ¿Deseas aplicar el plan? (y/n)"
echo "================================================"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo "Aplicando infraestructura (esto puede tomar 15-20 minutos)..."
    terraform apply tfplan
    
    echo ""
    echo "================================================"
    echo "  Infraestructura creada exitosamente!"
    echo "================================================"
    echo ""
    terraform output
else
    echo "Operación cancelada"
    exit 0
fi
