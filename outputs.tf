/*------------------------------------------------------------------------------
Outputs defined here
------------------------------------------------------------------------------*/

#output "eip_address" {
# description = "Elastic IP Address"
#  value       = "${aws_eip.base.public_ip}"
#}

output "public_ip_address" {
  description = "Public IP Address. Dynamic"
  value       = aws_instance.base.public_ip
}

output "private_ip_address" {
  description = "Private IP Address. Also Dynamic"
  value       = aws_instance.base.private_ip
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.base.id
}

output "instance_state" {
  description = "Instance State. Running/Not"
  value       = aws_instance.base.instance_state
}

output "dns_name" {
  description = "Public DNS Name"
  value       = aws_instance.base.public_dns
}

output "key_name" {
  description = "AWS key name used"
  value       = aws_instance.base.key_name
}

output "ami_default_user" {
  description = "AMI Default Login"
  value       = var.ami_default_user
}

output "poc" {
  description = "Instance POC"
  value       = var.poc
}

output "CLAP_OFF" {
  description = "Clapper OFF State"
  value       = var.clap_off
}

output "CLAP_ON" {
  description = "Clapper ON State"
  value       = var.clap_on
}

