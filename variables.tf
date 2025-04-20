variable "aws_region" {
  description = "La región donde se desplegará la instancia EC2"
  type        = string
  default     = "us-east-1"
}

variable "key_pair_name" {
  description = "Nombre del par de claves SSH"
  type        = string
  default     = "vockey"
}

variable "instance_name" {
  description = "Nombre para etiquetar la instancia"
  type        = string
  default     = "Terraform-Cloud9Ubuntu22-VM"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "volume_size" {
  description = "Tamaño del volumen raíz (GB)"
  type        = number
  default     = 20
}
