
variable "ansible_user" {
  type        = string
  description = "Ansible user used to connect to the instance"
  default     = "ubuntu"
}
variable "ansible_ssh_private_key_file" {
  type        = string
  sensitive   = true
  description = "ssh key file to use for ansible_user"
  default     = "./key/key5.pem"
}
variable "ansible_ssh_public_key_file" {
  type        = string
  sensitive   = true
  description = "ssh public key in server authorized_keys"
  default     = "./key/key5.pub"
}
variable "ansible_host_path" {
  type        = string
  description = "path to ansible inventory host"
  default     = "./ansible/inventory/lap"
}
variable "ansible_command" {
  default     = "./ansible/playbook/install-docker.yml"
  description = "Command for container lab hosts"
}
#variable "ansible_command" {
#  default     = "./ansible/playbook/Nginx-s3.yml"
#  description = "Command for container lab hosts"
#}
#variable "ansible_command" {
#  default     = "./ansible/playbook/nginx-deploy.yml"
#  description = "Command for container lab hosts"
#}


# variable "ansible_ssh_pass" {
#   default = "Passw0rd"
# }
#
# variable "ansible_python" {
#   type        = string
#   description = "path to python executable"
#   default     = "/usr/bin/python3"
# }
# 
# variable "instance_type" {
#   default = "c7g.2xlarge"
# }
