# Instance_EC2_Terraform
Infraestructura como código (IaC) para lanzar una instancia EC2 en AWS con Ubuntu Cloud9 usando Terraform.


---

## 📁 Estructura del Proyecto y Explicación Detallada del Código

Este proyecto utiliza **Terraform** para definir y desplegar infraestructura en AWS de forma declarativa. A continuación se explica el contenido y propósito de cada archivo `.tf` incluido en el repositorio.

---

### 🔧 `main.tf`

Este archivo contiene la definición principal de los recursos que serán creados en AWS.

#### 1. **Proveedor de Infraestructura**

```hcl
provider "aws" {
  region = var.aws_region
}
```

- Se especifica que se utilizará **AWS** como proveedor.
- `region = var.aws_region`: toma el valor de la variable `aws_region` definida en `variables.tf`. Esto permite elegir la región en la que se desplegará la infraestructura, facilitando portabilidad y reutilización del código.

#### 2. **Búsqueda de AMI (Amazon Machine Image)**

```hcl
data "aws_ami" "cloud9_ubuntu22" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*Cloud9Ubuntu22*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}
```

- Este bloque no **crea** un recurso, sino que busca dinámicamente una AMI existente.
- `most_recent = true`: selecciona la versión más reciente de la imagen que cumpla con los filtros.
- Primer filtro: selecciona AMIs cuyo nombre contenga `Cloud9Ubuntu22`. Esto busca una imagen basada en Ubuntu 22 creada para el entorno Cloud9.
- Segundo filtro: se asegura de que el tipo de virtualización sea `hvm` (hardware virtual machine), que es el tipo requerido por la mayoría de las instancias modernas.
- `owners = ["amazon"]`: restringe la búsqueda a imágenes oficiales publicadas por AWS.

#### 3. **Grupo de Seguridad (Security Group)**

```hcl
resource "aws_security_group" "web_sg" {
  name        = "web-sec-group"
  description = "Permite SSH y HTTP"
```

- Define un grupo de seguridad llamado `web-sec-group`.
- Este grupo controlará el tráfico de red hacia y desde la instancia EC2.

##### Reglas de Entrada (ingress)

```hcl
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
```

- Permite el acceso desde **cualquier dirección IP pública (0.0.0.0/0)**.
- Puerto 22 para conexiones SSH (acceso remoto).
- Puerto 80 para tráfico HTTP (web sin cifrar).

##### Regla de Salida (egress)

```hcl
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
```

- Permite todo el tráfico saliente sin restricciones.
- `protocol = "-1"` indica **todos los protocolos**.

#### 4. **Instancia EC2**

```hcl
resource "aws_instance" "vm" {
  ami                         = data.aws_ami.cloud9_ubuntu22.id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
```

- Crea una nueva instancia EC2 con las siguientes configuraciones:
  - `ami`: utiliza el ID de la AMI buscada anteriormente.
  - `instance_type`: tipo de instancia como `t2.micro` (tomado desde variables).
  - `key_name`: nombre del par de claves SSH para poder acceder remotamente.
  - `vpc_security_group_ids`: asocia el grupo de seguridad definido.

##### Disco Raíz

```hcl
  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp2"
  }
```

- Configura el volumen principal (root) de almacenamiento:
  - Tamaño definido por `volume_size`.
  - Tipo de volumen `gp2` (General Purpose SSD).

##### Etiquetado de la Instancia

```hcl
  tags = {
    Name = var.instance_name
  }
}
```

- Añade una etiqueta a la instancia para facilitar su identificación en la consola de AWS.

---

### 📤 `outputs.tf`

Este archivo define las salidas del proyecto, que permiten mostrar información útil al finalizar la ejecución de Terraform.

```hcl
output "instance_id" {
  description = "ID de la instancia EC2 creada"
  value       = aws_instance.vm.id
}
```
- Muestra el ID único de la instancia EC2 creada.

```hcl
output "public_ip" {
  description = "IP pública de la instancia EC2"
  value       = aws_instance.vm.public_ip
}
```
- Muestra la IP pública de la instancia (para poder conectarse vía SSH).

```hcl
output "ami_id" {
  description = "ID de la AMI utilizada"
  value       = data.aws_ami.cloud9_ubuntu22.id
}
```
- Muestra el ID de la AMI que se utilizó para lanzar la instancia.

```hcl
output "security_group_id" {
  description = "ID del Security Group asociado"
  value       = aws_security_group.web_sg.id
}
```
- Muestra el ID del grupo de seguridad creado.

---

### ⚙️ `variables.tf`

Define todas las variables utilizadas en los archivos Terraform. Cada variable tiene su descripción, tipo y un valor por defecto.

```hcl
variable "aws_region" {
  description = "La región donde se desplegará la instancia EC2"
  type        = string
  default     = "us-east-1"
}
```
- Define la región de AWS para el despliegue.

```hcl
variable "key_pair_name" {
  description = "Nombre del par de claves SSH"
  type        = string
  default     = "vockey"
}
```
- Nombre del par de claves para acceso remoto.

```hcl
variable "instance_name" {
  description = "Nombre para etiquetar la instancia"
  type        = string
  default     = "Terraform-Cloud9Ubuntu22-VM"
}
```
- Etiqueta que se asignará a la instancia.

```hcl
variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}
```
- Tipo de instancia que se desea utilizar.

```hcl
variable "volume_size" {
  description = "Tamaño del volumen raíz (GB)"
  type        = number
  default     = 20
}
```
- Define el tamaño del disco raíz en GB.

---
