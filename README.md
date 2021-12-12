# DeveloperDesktop
[![Build Status](https://travis-ci.com/cpoma/DeveloperDesktop.svg?branch=master)](https://travis-ci.com/cpoma/DeveloperDesktop)

This short Terraform example will deploy a Redhat AMI (7.6, 7.7, 7.8, 7.9 - you select), patch it with YUM, then install
the nano, wget, gcc, and gcc-gcc++ packages. It will deploy the Gnome Desktop and Add Sublime, PyCharm, 
RubyMine, and VS Code. Lastly, it will download the AWS-CLI bundle and install it.

There is a scripted option that uses the USERDATA part of the AMI Launch console versus using Terraform. This will
launch either a CENTOS 7.x or REDHAT 7.x image of your choice from the [STIG-Partitioned Enterprise Linux (spel)](https://github.com/plus3it/spel) project.
The scripted approach is "newer" and has sound support installed for the desktop, which is why the build takes slightly longer to deploy. 

The desktop listens to a standard VNC/RDP connection over Port 3389. You can connect to the Desktop using MS Terminal Server Client (mstsc).The default user is:
 - User ID: developer (or student)
 - Password: P@ssword1234

The current build using Terraform takes about 16 min. start to finish. Tested with:
 - RHEL-7.6_HVM_GA-20190128-x86_64-0-Hourly2-GP2 (ami-000db10762d0c4c05)  
 - RHEL 7.7 RHEL-7.7_HVM-20190923-x86_64-0-Hourly2-GP2 (ami-029c0fbe456d58bd1)
 - RHEL 7.8 RHEL-7.8_HVM_GA-20200225-x86_64-1-Hourly2-GP2 (ami-08e923f2f38197e46)
 - RHEL 7.9 RHEL-7.9_HVM_GA-20200917-x86_64-0-Hourly2-GP2 (ami-005b7876121b7244d)

The current build using the scripted USERDATA approach takes 25 min. start to finish. Tested with:
 - spel-minimal-rhel-7-hvm-2021.11.1.x86_64-gp2 (ami-09f07db1ca8f3aa50)  
 - spel-minimal-centos-7-hvm-2021.11.1.x86_64-gp2 (ami-0bdd497dd5eface89)

## Installation

There is really no "installation" required. You can do an install using Terraform or just pass in USERDATA to the AMI Launch manually.

For a Terraform based install:
* The package assumes you have installed Terraform version 0.12.x or greater. 
NOTE: The terraform packages had major updates done to them with the 0.12.x release. 

* It is also assumed you have and AWS Account and know the AWS_SECRET_KEY and AWS_ACCESS_KEY_ID for your IAM user to launch the EC2 instance.

If you are just going to the "manual route:
* Make sure to use a SPEL Linux AMI
* Use [files/part_SPEL.sh](files/part_SPEL.sh) as your USERDATA component of the AMI launch. The part_SPEL.sh has been tested with
the following SPEL linux images.
* For more info on SPEL Linux see - [STIG-Partitioned Enterprise Linux (spel)](https://github.com/plus3it/spel)

## Usage with USERDATA script approach - no software required - but requires AWS Console Access
Just add this text/script to the USERDATA section of the Launch AMI process. This field is located at the bottom of 
the Step 3: Configure Instance Details when launching an AMI.

On Step 4: Add Storage - Set the base EBS size to 100GB (base image default is 20GB).
OPTIONAL: Change Volume Type to gp3 (they are better), default is gp2.

If you don't want a 100GB volume, change to smaller or larger, but adjust values as appropriate below in the partition code.

Let the machine launch, wait about 5 min, login, and should be all configured with new volume sizes. It will reboot, then run
the configuration for the GNOME GUI, Developer tools, and add remote RDP access. This will take ~21 minutes.


## Usage with Terraform
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


