/*------------------------------------------------------------------------------
Variable definitions here
------------------------------------------------------------------------------*/
#  skip_credentials_validation = true
#  skip_region_validation = true
#  skip_requesting_account_id = true
#  skip_get_ec2_platforms = true

variable "region" {
  description = "The AWS region"
  default     = "us-east-1"
}

# #############################################################################
# spel-minimal-rhel-7-hvm-2021.11.1.x86_64-gp2 (ami-09f07db1ca8f3aa50)  
# spel-minimal-centos-7-hvm-2021.11.1.x86_64-gp2 (ami-0bdd497dd5eface89)
# #############################################################################
 
variable "ami" {
  description = "The AMIs to use"
#  default     = "ami-09f07db1ca8f3aa50" # spel-minimal-rhel-7-hvm-2021.11.1.x86_64-gp2
  default     = "ami-0bdd497dd5eface89" # spel-minimal-centos-7-hvm-2021.11.1.x86_64-gp2
}

# #############################################################################
# Default m5.2xlarge server
# #############################################################################
variable "instance_type" {
  description = "Instance Spec"
  default     = "m5.2xlarge"
}

variable "hostname" {
  description = "The instance hostname"
  default     = "DeveloperDesktop"
}

variable "ami_default_user" {
  description = "Default AMI login"
  default     = "maintuser"
}

# #############################################################################
# Update to match your key name and path
# #############################################################################
variable "key_name" {
  description = "SSH key"
  default     = "SDEV400_Fall2021_2"
}

variable "private_key_path" {
  description = "Private Key Path for Connection"
  default     = "./private/YOUR_AWS_PRIVATE_SERVER_PEM.pem"
}

# #############################################################################
# Update to match your subnet
# #############################################################################
variable "subnet_id" {
  description = "Subnet for Instance"
  default     = "subnet-e87371e6"
}

# #############################################################################
# Update to match your Security Group IDs
# #############################################################################
variable "vpc_security_group_ids" {
  description = "Security Groups for Instance"
  default     = ["sg-aef8cbb6"]
}

# #############################################################################
# Update to match your private IP desired or comment out to make dynamic
# We are using the private_ip_address in the deploy.json file.
# If you comment this out, you will need to update the var.private_ip_address reference to
# be aws_instance.base.public_ip
# i.e. 
# "host" : "${var.private_ip_address}"
# CHANGE TO:
# "host" : "${aws_instance.base.public_ip}"
# #############################################################################
variable "private_ip_address" {
  description = "Private IP Address. Also Dynamic"
  default     = "172.31.69.84"
}

# #############################################################################
# Update to make your TAG relevant to you as the Author/POC
# #############################################################################
variable "poc" {
  description = "Point of Contact"
  default     = "Craig Poma"
}

# #############################################################################
# Used by auto-shutdown script
# #############################################################################
variable "clap_on" {
  description = "Clapper ON Parameters - ON weekdays 7am"
  default     = "0 7 * * 1-5 *"
}

variable "clap_off" {
  description = "Clapper OFF Parameters - OFF weekdays 10pm"
  default     = "0 22 * * 1-5 *"
}

variable "default_user_name" {
  description = "Default Desktop Username"
  default     = "developer"
}

variable "default_user_password" {
  description = "Default Desktop Password"
  default     = "P@ssword1234"
}

# #############################################################################
# OPTIONAL ROLE DATA CAN BE ATTACHED AT CREATION
# #############################################################################
variable "aws_iam_instance_profile_name" {
  description = "Role Name"
  default     = "S3_USER"
}

variable "aws_iam_instance_profile_role_arn" {
  description = "Profile Role ARN"
  default     = "arn:aws:iam::12345678910:role/S3_USER"
}

variable "aws_iam_instance_profile_arn" {
  description = "Profile ARN"
  default     = "arn:aws:iam::12345678910:instance-profile/S3_USER"
}

# #############################################################################
# THINGS TO PASS IN ON COMMAND LINE
# terraform apply -var "secret_key=YOUR_KEY_VALUE" -var "access_key=YOUR_KEY_VALUE"
# #############################################################################
variable "access_key" {
  description = "The AWS access key"
  default     = "YOUR_KEY_HERE"
}

variable "secret_key" {
  description = "The AWS secret key"
  default     = "YOUR_KEY_HERE"
}

