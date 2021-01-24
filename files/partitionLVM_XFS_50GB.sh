#
# Author: Craig Poma
# Date: 09/21/2015
# Version: 1.0
#
# This script will create seperate partitions for:
# EBS Vol 1
#   /
#
# EBS Volume 2 (50GB)
#   /tmp
#   /home
#   /var
#   /var/tmp
#   /var/log
#   /var/log/audit
#   /var/opt
#   Swap Partition available on /dev/xvdb2
#
#
# It assumes you have an EC2 instance with a (ANY SIZE) GB Root Volume and 
# a 50GB EBS Volume available for mount on /dev/xvdb 
#
# This script uses LVM for partition management on /dev/xvdb 
#
#
# Requires that lvm2, quota, and sssd are installed
# ie: yum install lvm2 quota sssd
#
#
# The script must be run as root.
#
# The auditd service must have NO rules setup to prevent
# kernel panic bricking the node during repartition
#
#
# i.e.: auditctl -l 
# Should return "No rules"
#
#
# SELinux must be in Permissive mode
# 
# i.e. getenforce
# should return "Permissive"
#
# /etc/selinux/config should have SELINUX=permissive
#
#

# CP-RH72-BASELINE-HARDENING
# 10.1.106.251


setenforce 0

if [[ "$(id -u)" != "0" ]]; then
    echo "" 1>&2
    echo "This script must be run as root" 1>&2
    echo "" 1>&2
    echo "" 1>&2
    exit 1
fi

if [[ "$(auditctl -l)" != "No rules" ]]; then
    echo "" 1>&2
    echo "Auditd service should have NO Rules." 1>&2
    echo "" 1>&2
    echo "" 1>&2
    exit 1
fi

if [[ "$(getenforce)" != "Permissive" ]]; then
    echo "" 1>&2
    echo "SElinux should be set to Permissive" 1>&2
    echo "" 1>&2
    echo "" 1>&2
    exit 1
fi

yum install -y lvm2 quota sssd

echo -n "Repartitioning..."

if [[ -z "$(fdisk -l /dev/nvme1n1 2>/dev/null)" ]]; then
    echo "No volume /dev/nvme1n1" 1>&2
    exit 0
fi

# partition disks into xvdb1, xvdb2
( echo -e "n\np\n1\n\n+49GB\nn\np\n2\n\n\nw\n" | fdisk /dev/nvme1n1 ) 1>&2

# make xvdb8 a swap partition
( echo -e "t\n1\n8e\nt\n2\n82\nw\n" | fdisk /dev/nvme1n1 ) 1>&2

sync  1>&2
sleep 5

mkswap /dev/nvme1n1p2  1>&2
swapon /dev/nvme1n1p2

sync  1>&2
sleep 5

pvcreate /dev/nvme1n1p1
vgcreate osvolume /dev/nvme1n1p1
lvcreate --name tmp --size 2G osvolume
lvcreate --name home --size 5G osvolume
lvcreate --name var --size 10G osvolume
lvcreate --name var_tmp --size 2G osvolume
lvcreate --name var_log --size 8G osvolume
lvcreate --name var_log_audit --size 3G osvolume
lvcreate --name opt -l 100%FREE osvolume

echo "done."
echo -n "Formatting partitions..."

# format disks
mkfs.xfs /dev/osvolume/tmp 1>&2
mkfs.xfs /dev/osvolume/home 1>&2
mkfs.xfs /dev/osvolume/var 1>&2
mkfs.xfs /dev/osvolume/var_tmp 1>&2
mkfs.xfs /dev/osvolume/var_log 1>&2
mkfs.xfs /dev/osvolume/var_log_audit 1>&2
mkfs.xfs /dev/osvolume/opt 1>&2

echo "done."

sync  1>&2
sleep 5
echo -n "Moving /tmp partition..."
mkdir /mnt/tmp
mount /dev/osvolume/tmp /mnt/tmp
(cd /tmp; tar --ignore-failed-read --ignore-command-error -cpf - ./* ) | (cd /mnt/tmp; tar -xpf - )
mv /tmp/.ICE-unix /mnt/tmp/.
umount /mnt/tmp
rmdir /mnt/tmp
cd /tmp
rm -rf *
cd /
echo "done."

echo -n "Moving /home partition..."
mkdir /mnt/home
mount /dev/osvolume/home /mnt/home
(cd /home; tar --ignore-failed-read --ignore-command-error -cpf - ./* ) | (cd /mnt/home; tar -xpf - )
umount /mnt/home
rmdir /mnt/home
cd /home
rm -rf *
cd /
echo "done."

echo -n "Moving /var/tmp partition..."
mkdir /mnt/vartmp
mount /dev/osvolume/var_tmp /mnt/vartmp
(cd /var/tmp; tar --ignore-failed-read --ignore-command-error -cpf - ./* ) | (cd /mnt/vartmp; tar -xpf - )
umount /mnt/vartmp
rmdir /mnt/vartmp
cd /var/tmp
rm -rf *
cd /
echo "done."

echo -n "Moving /var/log/audit  partition..."
mkdir /mnt/audit
mount /dev/osvolume/var_log_audit /mnt/audit
(cd /var/log/audit; tar --ignore-failed-read --ignore-command-error -cpf - ./* ) | (cd /mnt/audit; tar -xpf - )
umount /mnt/audit
rmdir /mnt/audit
cd /var/log/audit
rm -rf *
cd /
echo "done."

echo -n "Moving /var/log  partition..."
mkdir /mnt/log
mount /dev/osvolume/var_log /mnt/log
(cd /var/log; tar --ignore-failed-read --ignore-command-error -cpf - ./* ) | (cd /mnt/log; tar -xpf - )
umount /mnt/log
rmdir /mnt/log
cd /var/log
rm -rf *
cd /
echo "done."


echo -n "Moving /var  partition..."
mkdir /mnt/var
mount /dev/osvolume/var /mnt/var
(cd /var; tar --ignore-failed-read --ignore-command-error -cpf - ./* ) | (cd /mnt/var; tar -xpf - )
umount /mnt/var
rmdir /mnt/var
cd /var
rm -rf *

echo -n "Moving /opt  partition..."
mkdir /mnt/opt
mount /dev/osvolume/opt /mnt/opt
(cd /opt; tar --ignore-failed-read --ignore-command-error -cpf - ./* ) | (cd /mnt/opt; tar -xpf - )
umount /mnt/opt
rmdir /mnt/opt
cd /opt
rm -rf *
echo "done."


sed -i 's/\/dev\/shm                tmpfs   defaults/\/dev\/shm                tmpfs   defaults,nodev,nosuid,noexec/' /etc/fstab
sed 's/^[ \t]*//' << 'EOF' >> /etc/fstab
        
        /dev/osvolume/tmp              /tmp            xfs    defaults,nodev,nosuid,noexec,usrquota,grpquota   0   0
        /dev/osvolume/home             /home           xfs    defaults,nodev,nosuid,usrquota,grpquota          0   0
        /dev/osvolume/var              /var            xfs    defaults,nodev,nosuid                            0   0
        /dev/osvolume/tmp              /var/tmp        xfs    defaults,nodev,nosuid,noexec                     0   0
        /dev/osvolume/var_log          /var/log        xfs    defaults,nodev,nosuid                            0   0
        /dev/osvolume/var_log_audit    /var/log/audit  xfs    defaults,nodev,nosuid                            0   0
        /dev/osvolume/opt	           /opt	           xfs    defaults,nodev,nosuid                            0   0
   	    /dev/nvme1n1p2                 swap            swap   defaults                                        0   0
EOF
    
mount /tmp
mount /home
mount /var
mount /var/tmp
mount /var/log
mount /var/log/audit
mount /opt
quotacheck -cug /home
quotacheck -cug /tmp

#
# Must be run due to SELinux. System will not boot if you don't 
# run these restorecon commands.
#
restorecon -vr /tmp
restorecon -vr /home
restorecon -vr /var
restorecon -vr /var/tmp
restorecon -vr /var/log
restorecon -vr /var/log/audit
restorecon -vr /opt
restorecon -vr /
mount -a

echo " "
echo " "
echo "Reboot the server NOW. The disk changes have been made, but the server must be rebooted to complete "
echo "the install/modifications."
echo " "
echo " "

# curl -O http://169.254.169.254/latest/meta-data/iam/security-credentials/S3_USER
# export AWS_ACCESS_KEY_ID="$(grep  "AccessKeyId" S3_USER | cut -d: -f 2 | cut -d\" -f 2 )" 
# export AWS_SECRET_ACCESS_KEY="$(grep SecretAccessKey S3_USER | cut -d: -f 2 | cut -d\" -f 2 )"
# export AWS_SECURITY_TOKEN="$(grep Token S3_USER | cut -d: -f 2 | cut -d\" -f 2 )"
# #export  AWS_CA_BUNDLE=/etc/pki/some-region/certs/ca-bundle.pem  
# export AWS_DEFAULT_REGION=us-east-1
# /usr/local/bin/aws s3 cp s3://Release_08_10_2018/chef install.sh  /root/chef_install.sh 
# chmod 755 /tmp/chef_install.sh 
# mv /tmp/chef_install.sh  /root/chef_install.sh 
# echo "@reboot root /root/chef_install.sh &" >> /etc/crontab 
logger AnAINSTALL End Drive Partitioning
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
Exec="/home/developer/start_rubymine.sh" %f
Comment=The Drive to Develop
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-rubymine
EOF
chown root. /usr/share/applications/rubymine_local.desktop
chmod 644 /usr/share/applications/rubymine_local.desktop
reboot now

