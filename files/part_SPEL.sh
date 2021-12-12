#!/bin/sh
#
# | __filename__ = "part_SPEL.sh"
# | __author__ = "Craig Poma"
# | __copyright__ = "Craig Poma"
# | __credits__ = ["Craig Poma"]
# | __license__ = "MIT"
# | __version__ = "1.0.0"
# | __maintainer__ = "Craig Poma"
# | __status__ = "Baseline"
#
#
# Used to resize the LVM Volumes on a STIG-Partitioned Enterprise Linux (spel) Image.
# See https://github.com/plus3it/spel for more information about SPEL Linux
#
# Usage: 
#        Just add this text/script to the USERDATA section of the Launch AMI process. This
#        field is located at the bottom of the Step 3: Configure Instance Details when 
#        launching an AMI.
#
#        On Step 4: Add Storage - Set the base EBS size to 100GB (base image default is 20GB).
#                   OPTIONAL: Change Volume Type to gp3 (they are better), default is gp2.
#                   If you don't want a 100GB volume, change to smaller or larger, but adjust
#                   values as appropriate below in the partition code.
#
#        Let the machine launch, wait about 5 min, login, and should be all configured with
#        new volume sizes.
#
# Current Version as of this post for REDHAT in us-east-1
# spel-minimal-rhel-7-hvm-2021.11.1.x86_64-gp2
# AMI ID ami-09f07db1ca8f3aa50
#
# Current Version as of this post for CENTOS in us-east-1
# spel-minimal-centos-7-hvm-2021.11.1.x86_64-gp2
# AMI ID ami-0bdd497dd5eface89
#
# Assumes you set the base EBS size to 100GB (base image default is 20GB).
# The last partition to extend is / so, by shrinking the 100Gb size you 
# shrink / by that ammont. At 100GB, the / volume is 48GB.
# Resulting filesystem looks like the below:
#
# Filesystem                       Size  Used Avail Use% Mounted on
# devtmpfs                          16G     0   16G   0% /dev
# tmpfs                             16G     0   16G   0% /dev/shm
# tmpfs                             16G  532K   16G   1% /run
# tmpfs                             16G     0   16G   0% /sys/fs/cgroup
# /dev/mapper/VolGroup00-rootVol    48G  1.9G   44G   5% /
# tmpfs                             16G  8.0K   16G   1% /tmp
# /dev/nvme0n1p1                   453M  149M  277M  35% /boot
# /dev/mapper/VolGroup00-varVol     25G   74M   24G   1% /var
# /dev/mapper/VolGroup00-homeVol   4.9G  4.1M  4.7G   1% /home
# /dev/mapper/VolGroup00-logVol    4.9G   17M  4.7G   1% /var/log
# /dev/mapper/VolGroup00-auditVol  9.8G   37M  9.2G   1% /var/log/audit
# tmpfs                            3.1G     0  3.1G   0% /run/user/1000

sudo mkdir /root/scripts
sudo cat >  /root/scripts/partdrive.sh<<EOF
#!/bin/sh

# Assumes you are using a NITRO-base EC2 instance (i.e. C5/C5d/C5n, M5/M5d/M5n/M5dn, R5/R5d/R5n/R5dn, T3, and P3dn )
# NITRO Instances use /dev/nvme#n# for disk volumes
( echo -e "d\n2\nn\np\n\n\n\nw\n" | fdisk /dev/nvme0n1 ) 1>&2
# Set the partition as LVM
( echo -e "t\n2\n8e\nw\n" | fdisk /dev/nvme0n1 ) 1>&2

sync
partprobe
pvresize /dev/sda12
sync
partprobe
# 10GB /var/log/audit
lvextend -L10G /dev/mapper/VolGroup00-auditVol
resize2fs /dev/mapper/VolGroup00-auditVol
# 5GB /var/log
lvextend -L5G /dev/mapper/VolGroup00-logVol
resize2fs /dev/mapper/VolGroup00-logVol
# 25GB /var
lvextend -L25G /dev/mapper/VolGroup00-varVol
resize2fs /dev/mapper/VolGroup00-varVol
# 5GB /home
lvextend -L5G /dev/mapper/VolGroup00-homeVol
resize2fs /dev/mapper/VolGroup00-homeVol
# 100% of what is left add to /
lvextend -l 100%FREE /dev/mapper/VolGroup00-rootVol
resize2fs /dev/mapper/VolGroup00-rootVol
EOF
#
sudo chmod 700 /root/scripts/partdrive.sh
sudo /root/scripts/partdrive.sh
#
#
sudo yum install nano -y
# sudo wget -O /root/scripts/configure_image.sh https://raw.githubusercontent.com/cpoma/DeveloperDesktop/master/files/configure_image.sh
sudo wget -O /root/scripts/configure_image.sh https://raw.githubusercontent.com/cpoma/DeveloperDesktop/script_gui/files/configure_image.sh
sudo chmod 700 /root/scripts/configure_image.sh
echo "@reboot root /root/scripts/configure_image.sh &" | sudo tee -a /etc/crontab
reboot now
#
#