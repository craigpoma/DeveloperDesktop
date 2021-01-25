#!/bin/bash 
#
logger TERRAFORM_INSTALL Start Chef Install # Remove this from running on successive boots 
#
# Remove from crontab the chef_install.sh so it will not run at next boot.
#
sed -i 's/\@reboot root \/root\/chef_install.sh \&//' /etc/crontab 
#
# Set a known Directory path to start 
#
cd /tmp 
#
# Fix some known files with bad/insecure permissions by default
#
chmod 640 /home/ec2-user/.bash* /home/ec2-user/.cshrc /home/ec2-user/.tcshrc 
chmod 640 /root/.bash* /root/.cshrc /root/.tcshrc 
chown root. /root/chef_install.sh
chmod 750 /root/chef_install.sh
rm -Rf /tmp/terraform_*.sh
rm -Rf /root/.cache
#
# Fix EC2-USER to have proper password expire times
# If you do this, you must set a password for the EC2-USER - otherwise - you will lock out the EC2-USER
#chage -m 7 ec2-user
#chage -M 60 ec2-user
#
# Add the default AWS DNS Server to fix a false positive for only one nameserver
# You will now have the subnet provided DNS resolver via DHCP and this DNS Server
#
echo nameserver 169.254.169.253 >> /etc/resolv.conf
chmod 755 /tmp/buildInspecDependancies.sh
dos2unix /tmp/buildInspecDependancies.sh
sudo /tmp/buildInspecDependancies.sh
sudo yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
sudo yum -y install sublime-text
sudo mkdir /usr/local/share/backgrounds/
sudo cp /tmp/defaultBackground.png /usr/local/share/backgrounds/defaultBackground.png
sudo chmod 644 /usr/local/share/backgrounds/defaultBackground.png
wget -O /tmp/pycharm-community-2020.2.5.tar.gz https://download.jetbrains.com/python/pycharm-community-2020.2.5.tar.gz
sudo cp /tmp/pycharm.desktop /usr/share/applications/pycharm.desktop
sudo chmod 644 /usr/share/applications/pycharm.desktop
sudo tar xfz /tmp/pycharm-community-2020.2.5.tar.gz -C /opt/
sudo chown -R ${var.default_user_name}. /opt/pycharm-community-2020.2.5/
yum -y install @development
#
# Install Latest GIT
#
sudo cat > /etc/yum.repos.d/WANdisco-git.repo << EOF
[WANdisco-git]
name=WANdisco Git
baseurl=http://opensource.wandisco.com/rhel/\$releasever/git/\$basearch
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-WANdisco
EOF
sudo rpm --import http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
sleep 10
sudo yum install git
#
# Upgrade to Python 3.8.7
#
sudo yum install -y gcc openssl-devel bzip2-devel libffi-devel
wget -O /tmp/Python-3.8.7.tgz https://www.python.org/ftp/python/3.8.7/Python-3.8.7.tgz
sudo tar -C /opt -xzf /tmp/Python-3.8.7.tgz
sudo cat > /root/python_replace.sh << EOF
cd /opt/Python-3.8.7/
configure --prefix=/usr --enable-optimizations --with-ensurepip=install
make altinstall
echo "alias python='/bin/python3.8'" >> /root/.bashrc 
echo "alias python='/bin/python3.8'" >> /home/developer/.bashrc 
echo "alias python='/bin/python3.8'" >> /etc/skel/.bashrc 
EOF
chmod 755 /root/python_replace.sh
sudo /root/python_replace.sh 
#
#
logger TERRAFORM_INSTALL DONE - Scan Results stored in /root/ScanResults
wall chef_install.sh completed at Script $(date +%Y%m%d-%H-%M-%S-%s)
reboot now
exit 

#
#
#
#  EXIT EARLY - Below will join you to a CHEF server and run some scans (not required for generic install)
#
#



#
# Fix SELinux Context
# semanage login -a -s user_u __default__
#
# 
# Get Some S3 Authentication Certs if grabbing data from S3 with an IAM role
# 
#!/bin/sh
# cd /root
# curl -s -O http://169.254.169.254/latest/meta-data/iam/security-credentials/TerraformDeploy
# export AWS_ACCESS_KEY_ID=$(grep AccessKeyId /root/TerraformDeploy | cut -d: -f 2 | cut -d\" -f 2 )
# export AWS_SECRET_ACCESS_KEY=$(grep SecretAccessKey /root/TerraformDeploy | cut -d: -f 2 | cut -d\" -f 2 )
# export AWS_SECURITY_TOKEN=$(grep Token /root/TerraformDeploy | cut -d: -f 2 | cut -d\" -f 2 )
# export AWS_CA_BUNDLE=/etc/pki/us-east-1/certs/ca-bundle.pem
# rm -Rf /root/TerraformDeploy
export AWS_DEFAULT_REGION=us-east-1
#
# Set Hostname and naming resolution for the chef server
# Chef requires DNS or hostname resolution 
#
hostnamectl set-hostname baseline_rhel7_7_ami # Add Host to the /etc/hosts file 
echo 10.1.104.87 	chefmanage2 >> /etc/hosts 
echo 10.1.111.119 	chefslavel-2 >> /etc/hosts 
echo 10.1.111.121 	chefslavel-3 >> /etc/hosts 
#
# Set Up Custom ENVARS - Proxy and JAVA_HOME
# Proxy may not be required. 
#
cat > /etc/profile.d/custom.sh <<EOF
#!/bin/sh 
umask 027 
export JAVA_HOME=/usr/java/default 
export http_proxy=http://10.0.1.10:3128/
export https_proxy=https://10.0.1.10:3128/
EOF
# 
# Add the custom.sh ENVARS to your enviroment for this execution 
# 
source /etc/profile.d/custom.sh
#
# Set a known Directory path to start 
#
cd /tmp
# Get Chef Client and Install 
#/usr/local/bin/aws s3 cp s3://Software/chef-14.1.12-1.e17.x86 64.rpm ./chef-14.1.12-1.e17.x86 64.rpm 
yum -y install ./chef-14.13.11-1.el7.x86_64.rpm
#
# Get JDK from S3
# 
#/usr/local/bin/aws s3 cp S3://Software/jdk-8u181-1inux-x64.rpm ./jdk-8u181-1inux-x64.rpm 
#
# Install some required packages 
#
yum -y install unzip zip nano tree dos2unix 
#
# Set a known Directory path to start 
#
cd /tmp
# 
# Bootstrap Node into Chef 
# 
logger TERRAFORM_INSTALL Start Bootstrap and Hardening of Node 
mkdir -p /etc/chef 
mkdir -p /var/lib/chef 
mkdir -p /var/log/chef 
# 
# Setup Validation Key for Organization 
# 
# NOT A REAL KEY :-)
cat > /etc/chef/innotech-validator.pem <<EOF 
RSA Key HERE
EOF
# 
# Setup runlist 
# 
cat > /etc/chef/first-boot.json <<EOF 
{run_list: [recipe[baseline]]} 
EOF
# 
# Setup client.rb 
# 
cat > /etc/chef/client.rb <<EOF
log_location STDOUT 
validation_client_name innotech-validator
validation_key /etc/chef/innotech-validator.pem 
chef_server_url https://chefmanage2/organizations/innotech 
#node_name chefslavel-2 
ssl_verify_mode :verify_none 
fips true 
require chef/version 
chef_version = ::Chef::VERSION.split (.) 
unless chef_version[0].to_i > 12 || (chef_version[0].to_i == 12 && chef_version[1].to_i >= 8) 
  raise FIPS Mode requested but not supported by this client 
end 
EOF
# 
# Join to Chef Server and Harden it 
# 
unset https_proxy
unset http_proxy
/usr/bin/chef-client -j /etc/chef/first-boot.json --environment prod 
logger TERRAFORM_INSTALL End Bootstrap and Hardening of Node
#
# Load new Audit Rules 
#
auditctl -R /etc/audit/rules.d/audit.rules 
logger TERRAFORM_INSTALL Begin various scans - Scan Results stored in /root/ScanResults 
#
# Organize /root
#
mkdir /root/scripts 
chmod 750 /root/scripts
mv /root/*.sh /root/scripts/.
rm -Rf /root/original-ks.cfg
rm -Rf /root/anaconda-ks.cfg
#############################################################################
# Prep for DISA SCAP Scan
# RUN AS A REBOOT SCRIPT - CHEF WILL REBOOT SERVER AFTER BOOTSTRAP COMPLETES
#############################################################################
# You will note that I switch the version of Redhat to: 
#  Red Hat Enterprise Linux Server release 7.6 (Maipo)
# Then, scan and revert back to:
#  Red Hat Enterprise Linux Server release 7.7 (Maipo)
#
# The release 7.7 isn't defined in the SCAP content as supported
# and causes some tests to fail - falsely - so we are tricking
# SCAP until the content is updated to know about Redhat 7.7.
#
# The node should be on Redhat 7.7 because the Terraform deployment will 
# upgrade the node to Redhat 7.7
#
#############################################################################
#
cat > /root/scripts/scc_install.sh <<EOF
#!/bin/bash 
sed -i 's/\@reboot root \/root\/scripts\/scc_install.sh \&//' /etc/crontab 
/root/cron/chef-cron.sh
cd /root/DISA
unzip scc-5.2.1_rhel7_x86_64_bundle.zip
chown -R root. /root/DISA
chmod -R 750 /root/DISA
cd /root/DISA/scc-5.2.1_rhel7_x86_64/
rpm -Uvh scc-5.2.1.rhel7.x86_64.rpm
mkdir -p /root/ScanResults/DISASCAP/
chmod -R 750 /root/ScanResults
chmod -R 750 /root/ScanResults/DISASCAP/
echo Red Hat Enterprise Linux Server release 7.6 (Maipo) > /etc/redhat-release
/opt/scc/cscc -u /root/ScanResults/DISASCAP/
echo Red Hat Enterprise Linux Server release 7.7 (Maipo) > /etc/redhat-release
chmod 644 /etc/redhat-release
chmod -R 750 /root/ScanResults/DISASCAP/
chown -R root. /root/ScanResults/DISASCAP/
EOF
chmod 700 /root/scripts/scc_install.sh
echo @reboot root /root/scripts/scc_install.sh & | sudo tee -a /etc/crontab
#
#############################################################################
# OPENSCAP Scans for post hardening values - 
# RUN AS A REBOOT SCRIPT - CHEF WILL REBOOT SERVER AFTER BOOTSTRAP COMPLETES
#############################################################################
# See this if running against CentOS - https://gist.github.com/gregelin/f94ba31f004ca4acea87
# Basically - repoint the --cpe /usr/share/xml/scap/ssg/content/ssg-rhel7-cpe-dictionary.xml part
# in the scan commands.
#
# To Get Profile values:
# oscap info /usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml
#
cat > /root/scripts/openscap_scan.sh <<EOF
#!/bin/bash 
sed -i 's/\@reboot root \/root\/scripts\/openscap_scan.sh \&//' /etc/crontab
/root/cron/chef-cron.sh
mkdir -p /root/ScanResults/OpenSCAP/
cd /root/ScanResults/OpenSCAP/
export SCRIPT_TIMESTAMP=\$(date +%Y%m%d-%H-%M-%S-%s)
oscap xccdf eval --profile stig-rhel7-disa --results /root/ScanResults/OpenSCAP/\$(hostname)-scap-stig-rhel7-disa-results-\${SCRIPT_TIMESTAMP}-after.xml --report /root/ScanResults/OpenSCAP/\$(hostname)-scap-report-stig-rhel7-disa-\${SCRIPT_TIMESTAMP}-after.html --oval-results --cpe /usr/share/xml/scap/ssg/content/ssg-rhel7-cpe-dictionary.xml  /usr/share/xml/scap/ssg/content/ssg-rhel7-xccdf.xml
oscap xccdf eval --profile C2S --results /root/ScanResults/OpenSCAP/\$(hostname)-scap-stig-C2S-results-\${SCRIPT_TIMESTAMP}-after.xml --report /root/ScanResults/OpenSCAP/\$(hostname)-scap-report-C2S-\${SCRIPT_TIMESTAMP}-after.html --oval-results --cpe /usr/share/xml/scap/ssg/content/ssg-rhel7-cpe-dictionary.xml  /usr/share/xml/scap/ssg/content/ssg-rhel7-xccdf.xml
oscap oval eval --results /root/ScanResults/OpenSCAP/\$(hostname)-oval-results-\${SCRIPT_TIMESTAMP}-after.xml --report /root/ScanResults/OpenSCAP/\$(hostname)-oval-report-\${SCRIPT_TIMESTAMP}-after.html /usr/share/xml/scap/ssg/content/ssg-rhel7-oval.xml
# oscap xccdf eval --profile stig-rhel7-disa --results /root/ScanResults/OpenSCAP/\$(hostname)-scap-stig-rhel7-disa-results-\$(date +%Y%m%d).xml --report /root/ScanResults/OpenSCAP/\$(hostname)-scap-report-stig-rhel7-disa-\$(date +%Y%m%d)-after.html --oval-results --cpe /usr/share/xml/scap/ssg/content/ssg-rhel7-cpe-dictionary.xml  /usr/share/xml/scap/ssg/content/ssg-rhel7-xccdf.xml
# oscap xccdf eval --profile C2S --results /root/ScanResults/OpenSCAP/\$(hostname)-scap-stig-C2S-results-\$(date +%Y%m%d).xml --report /root/ScanResults/OpenSCAP/\$(hostname)-scap-report-C2S-\$(date +%Y%m%d)-after.html --oval-results --cpe /usr/share/xml/scap/ssg/content/ssg-rhel7-cpe-dictionary.xml  /usr/share/xml/scap/ssg/content/ssg-rhel7-xccdf.xml
# oscap oval eval --results /root/ScanResults/OpenSCAP/\$(hostname)-oval-results-\$(date +%Y%m%d).xml --report /root/ScanResults/OpenSCAP/\$(hostname)-oval-report-\$(date +%Y%m%d).html /usr/share/xml/scap/ssg/content/ssg-rhel7-oval.xml
chmod -R 750 /root/ScanResults
chmod -R 750 /root/ScanResults/OpenSCAP/
chown -R root. /root/ScanResults/OpenSCAP/
EOF
chmod 700 /root/scripts/openscap_scan.sh
echo @reboot root /root/scripts/openscap_scan.sh & | sudo tee -a /etc/crontab
#
# Host the SCAN Results (1) time to a Python Based HTTP Server on port 8000
#
cat > /root/scripts/scan_results_http_server.sh <<EOF
#!/bin/bash 
sed -i 's/\@reboot root \/root\/scripts\/scan_results_http_server.sh \&//' /etc/crontab
#firewall-cmd --permanent --add-port=8000/tcp
firewall-cmd --add-port=8000/tcp
firewall-cmd --reload
iptables -I INPUT 7 -p tcp --dport 8000 -m state --state NEW -j ACCEPT
#service iptables save
mkdir -p /root/ScanResults/
chmod -R 750 /root/ScanResults
cd /root/ScanResults
python -m SimpleHTTPServer 8000 &
EOF
chmod 700 /root/scripts/scan_results_http_server.sh
echo @reboot root /root/scripts/scan_results_http_server.sh & | sudo tee -a /etc/crontab
#
# To Generate an automated fixer script based on the OpenSCAP findings
#  #script_timestamp=$(date +%Y%m%d-%H-%M-%S-%s)
#  export RESULTID=$(grep TestResult $(hostname)-scap-stig-rhel7-disa-results-$script_timestamp.xml | awk -F\ '{ print $2 }')
#  oscap xccdf generate fix --result-id $RESULTID --output automatic_fixer.sh $(hostname)-scap-stig-rhel7-disa-results-$script_timestamp.xml
#
#############################################################################
# INSPEC Scans for post hardening values 
#############################################################################
#
# If you have access to the INSPEC inspec-profile-disa_stig-el7 Profile
# You can install the CHEKDK or CHEF Workstation software and run the scan
# locally. 
#
# mkdir -p /root/ScanResults/INSPEC/
# inspec exec ./inspec-profile-disa_stig-el7  --input-file=./inspec-profile-disa_stig-el7/attributes.yml --reporter=cli json:/root/ScanResults/INSPEC/inspec-os-hardenrun.json | ./inspec-profile-disa_stig-el7/tools/ansi2html.sh --bg=dark > /root/ScanResults/INSPEC/inspec-os-hardenrun.html 
# chmod -R 750 /root/ScanResults/INSPEC/
# chown -R root. /root/ScanResults/INSPEC/
#
# If you a would like to do a remote scan you can from the node
# with the software installed:
#
# export TARGET_IP=10.1.111.119
# export SSH_KEY=/root/awskeys/Onboarding-NVA.pem
# inspec exec ./inspec-profile-disa_stig-el7 --input-file=./inspec-profile-disa_stig-el7/attributes.yml --reporter=cli -t ssh://ec2-user@${TARGET_IP} --sudo -i $SSH_KEY
#
mkdir -p /home/developer/.config
chmod 750 /home/developer/.config/monitors.xml
chown developer. /home/developer/.config
sudo -u developer dconf write /org/gnome/desktop/screensaver/lock-enabled false
cat > /home/developer/.config/monitors.xml  <<EOF
<monitors version=2>
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1</scale>
      <primary>yes</primary>
      <monitor>
        <monitorspec>
          <connector>VNC-0</connector>
          <vendor>unknown</vendor>
          <product>unknown</product>
          <serial>unknown</serial>
        </monitorspec>
        <mode>
          <width>1920</width>
          <height>1080</height>
          <rate>60</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
EOF
chown developer. /home/developer/.config/monitors.xml
chmod 640 /home/developer/.config/monitors.xml


#
# Configure RubyMine to be launched as ROOT from the 
# Desktop Menu
#
cat > /home/developer/start_rubymine.sh <<EOF
#!/bin/sh
sudo /opt/RubyMine-2020.3.1/bin/rubymine.sh &
EOF
chown developer. /home/developer/start_rubymine.sh
chmod 755 /home/developer/start_rubymine.sh

cat > /etc/sudoers.d/98-developer-users <<EOF
# User rules for developer
developer ALL=(ALL) NOPASSWD:ALL
EOF
chown root. /etc/sudoers.d/98-developer-users
chmod 440 /etc/sudoers.d/98-developer-users

cat > /usr/share/applications/rubymine_local.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=RubyMine(root)
Icon=/opt/RubyMine-2020.3.1/bin/rubymine.png
Exec=/home/developer/start_rubymine.sh %f
Comment=The Drive to Develop
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-rubymine
EOF
chown root. /usr/share/applications/rubymine_local.desktop
chmod 644 /usr/share/applications/rubymine_local.desktop

logger TERRAFORM_INSTALL DONE - Scan Results stored in /root/ScanResults
wall chef_install.sh completed at Script $(date +%Y%m%d-%H-%M-%S-%s)
#############################################################################
# Perms to Clean up
#############################################################################
# rpm --setperms chef-14.13.11-1.el7.x86_64
# rpm --setugids chef-14.13.11-1.el7.x86_64
# rpm --setperms kernel-3.10.0-957.21.3.el7.x86_64
# rpm --setugids kernel-3.10.0-957.21.3.el7.x86_64
# rpm --setperms cronie-anacron-1.4.11-23.el7.x86_64
# rpm --setugids cronie-anacron-1.4.11-23.el7.x86_64
# rpm --setperms rootfiles-8.1-11.el7.noarch
# rpm --setugids rootfiles-8.1-11.el7.noarch
# rpm --setperms ca-certificates-2018.2.22-70.0.el7_5.noarch
# rpm --setugids ca-certificates-2018.2.22-70.0.el7_5.noarch
# rpm --setperms audit-2.8.5-4.el7.x86_64
# rpm --setugids audit-2.8.5-4.el7.x86_64
# rpm --setperms ntp-4.2.6p5-29.el7.x86_64
# rpm --setugids ntp-4.2.6p5-29.el7.x86_64
