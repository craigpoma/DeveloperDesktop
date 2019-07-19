#!/bin/bash 
cd /tmp 
logger DeveloperDesktop Start PrepNode 
chmod 640 /home/ec2-user/.bash* /home/ec2-user/.cshrc /home/ec2-user/.tcshrc 
chmod 640 /root/.bash* /root/.cshrc /root/.tcshrc 
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
yum -y install unzip 
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws 
rm -Rf /tmp/awscli-bundle 
ln -s /usr/local/bin/aws /bin/aws
#mkdir -p /etc/pki/some-region/certs/ cd /etc/pki/some-region/certs/ 
#cat > ca-bundle.pem <<EOF
#-----BEGIN CERTIFICATE----- 
#SOMEVALUES 
#-----END CERTIFICATE----- 
#EOF 
#chmod 644 /etc/pki/some-region/certs/ca-bundle.pem 
#chmod 755 /tmp/partition50GB_EXT4.sh /tmp/partition50GB_EXT4.sh 
while ! [ -f /tmp/completed_upload.txt ];
do
    sleep 1
done
chmod 755 /tmp/buildInspecDependancies.sh
dos2unix /tmp/buildInspecDependancies.sh
dos2unix /tmp/kitchen-cloudformation.gemspec.1
dos2unix /tmp/kitchen-cloudformation.gemspec.2
dos2unix /tmp/kitchen-cloudformation-sample.yml
chmod 644 /tmp/kitchen-cloudformation.gemspec.1 /tmp/kitchen-cloudformation.gemspec.2