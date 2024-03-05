output "Public_ip_aws_instance_main" {
  value = aws_instance.main.*.public_ip
}

output "Private_ip_aws_instance_main" {
  value = aws_instance.main.*.private_ip
}

