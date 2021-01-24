# DeveloperDesktop
[![Build Status](https://travis-ci.com/cpoma/DeveloperDesktop.svg?branch=master)](https://travis-ci.com/cpoma/DeveloperDesktop)

This short Terraform example will deploy a Redhat AMI (7.6, 7.7, 7.8, 7.9 - you select), patch it with YUM, then install the nano, wget, gcc, and gcc-gcc++ packages. It will deploy the Gnome Desktop and Add Sublime, PyCharm, RubyMine, and VS Code. Lastly, it will download the AWS-CLI bundle and install it.

The desktop listens to a standard VNC/RDP connection over Port 3389. You can connect to the Desktop using MS Terminal Server Client (mstsc).The default user is:
 - User ID: developer (or student)
 - Password: P@ssword1234

The current build takes about 16 min. start to finish. Tested with:
 - RHEL-7.6_HVM_GA-20190128-x86_64-0-Hourly2-GP2 (ami-000db10762d0c4c05)  
 - RHEL 7.7 RHEL-7.7_HVM-20190923-x86_64-0-Hourly2-GP2 (ami-029c0fbe456d58bd1)
 - RHEL 7.8 RHEL-7.8_HVM_GA-20200225-x86_64-1-Hourly2-GP2 (ami-08e923f2f38197e46)
 - RHEL 7.9 RHEL-7.9_HVM_GA-20200917-x86_64-0-Hourly2-GP2 (ami-005b7876121b7244d)

## Installation

There is really no "installation" required. The package assumes you have installed Terraform version 0.12.x or greater. NOTE: The terraform packages had major updates done to them with the 0.12.x release. 

It is also assumed you have and AWS Account and know the AWS_SECRET_KEY and AWS_ACCESS_KEY_ID for your IAM user to launch the EC2 instance.

## Usage
Make sure to update the `variables.tf` file with the proper Subnet, Security groups, etc for your AWS account.
Update the variable `private_key_path` to  ./private/YOUR_PEM_FILE.pem to be your path to your PEM file in the `variables.tf` file.
To deploy the node - 
```
terraform apply -var "secret_key=YOUR_KEY_VALUE" -var "access_key=YOUR_KEY_VALUE"
```

To avoid placing these in the command line: You can create a /private/my_config_file.tfvars that looks something like this:
```
#
# terraform apply -var-file="./private/my_config_file.tfvars"
# terraform destroy -var-file="./private/my_config_file.tfvars"
################################################################################
# VPC / DEPLOYMENT SPECIFIC - BUT NOT NECESSARILY SENSITIVE - TO CHANGE DEFAULTS
################################################################################
hostname = "Different_Name_Than_Default_Name_Here"
private_ip_address = "Different_IP_Than_Default_IP_Here"
key_name = "Different_Key_Than_Default_Key_Here"
instance_type = "t3.2xlarge"
################################################################################
# PRIVATE VALUES - DO NOT CHECK INTO GIT OR SHARE WITH OTHERS
################################################################################
access_key = "WHATEVER_YOUR_KEY_IS_HERE"
secret_key = "WHATEVER_YOUR_KEY_IS_HERE"
```

Then, to run it you would execute (from the root of this project):

```
terraform apply -var-file="./private/my_config_file.tfvars"
```

## Contributing

See CONTRIBUTING.md

Feel free to:
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request 

## History
See CHANGES.md

## Credits
[Craig Poma](https://github.com/cpoma)

## License
Apache License 2.0


