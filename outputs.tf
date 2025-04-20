output "instance_id" {
  description = "ID de la instancia EC2 creada"
  value       = aws_instance.vm.id
}

output "public_ip" {
  description = "IP pública de la instancia EC2"
  value       = aws_instance.vm.public_ip
}

output "ami_id" {
  description = "ID de la AMI utilizada"
  value       = data.aws_ami.cloud9_ubuntu22.id
}

output "security_group_id" {
  description = "ID del Security Group asociado"
  value       = aws_security_group.web_sg.id
}
