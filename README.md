# DeveloperDesktop
[![Build Status](https://travis-ci.com/cpoma/DeveloperDesktop.svg?branch=master)](https://travis-ci.com/cpoma/DeveloperDesktop)

This short Terraform example will deploy a Redhat 7.6 AMI, patch it with YUM, then install the nano, gcc, and gcc-gcc++ packages. Lastly, it will download the AWS-CLI bundle and install it.

## Installation

There is really no "installation" required. The package assumes you have installed Terraform version 0.12.x or greater. NOTE: The terraform packages had major updates done to them with the 0.12.x release. 

It is also assumed you have and AWS Account and know the AWS_SECRET_KEY and AWS_ACCESS_KEY_ID for your IAM user to launch the EC2 instance.

## Usage
Make sure to update the variables.tf file with the proper Subnet, Security groups, etc for your AWS account.
Update the references to ./private/CraigPomaUMUC.pem to be your path to your PEM file in the deploy.tf.json file.
To deploy the node - 
```
terraform apply -var "secret_key=YOUR_KEY_VALUE" -var "access_key=YOUR_KEY_VALUE"
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
