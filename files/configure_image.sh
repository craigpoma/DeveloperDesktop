#!/bin/sh
#
#
# | __filename__ = "configure_image.sh"
# | __author__ = "Craig Poma"
# | __copyright__ = "Craig Poma"
# | __credits__ = ["Craig Poma"]
# | __license__ = "MIT"
# | __version__ = "1.0.0"
# | __maintainer__ = "Craig Poma"
# | __status__ = "Baseline"
#
#
# This will add a GNOME GUI, Developer Tools, and Remote Desktop access with sound to
# your Linux image. Assumes you are using a SPEL Linux image that has a proper ammount
# of disk space allocated to support the addition of all of this software.
#
# SPEL Current Version as of this post for REDHAT in us-east-1
# spel-minimal-rhel-7-hvm-2021.11.1.x86_64-gp2
# AMI ID ami-09f07db1ca8f3aa50
#
# SPEL Current Version as of this post for CENTOS in us-east-1
# spel-minimal-centos-7-hvm-2021.11.1.x86_64-gp2
# AMI ID ami-0bdd497dd5eface89
#
# NOTE: Would recommend just pulling from S3, GITHUB, or shared file source. 
#       Cannot place in the initial USERDATA due to USERDATA size limit of 16k of data 
#
# sudo wget -O /root/scripts/configure_image.sh https://raw.githubusercontent.com/cpoma/DeveloperDesktop/master/files/configure_image.sh
# sudo chmod 700 /root/scripts/configure_image.sh
# echo "@reboot root /root/scripts/configure_image.sh &" | sudo tee -a /etc/crontab
#
####################################################################################
####################################################################################
####################################################################################
#
# Remove from crontab the configure_image.sh so it will not run at next boot.
#
sed -i 's/\@reboot root \/root\/scripts\/configure_image.sh \&//' /etc/crontab 
#
#
#
sudo mkdir /root/rpms
# Used to initialize image with software packages and sound drivers
# Takes @20 minutes on average to complete.
#
sudo touch /root/INSTALL_START.txt
START_TIME=$(date +%s.%N)
#
####################################################################################
# Make a default "developer" user for login
####################################################################################
sudo adduser developer
sudo usermod -aG wheel developer
####################################################################################
# No sudo on the "echo" part of below command on purpose
####################################################################################
echo "P@ssword1234" | sudo passwd --stdin developer
# sudo cat > /etc/sudoers.d/98-developer-users <<EOF
sudo bash -c 'cat > /etc/sudoers.d/98-developer-users' << EOF
# User rules for developer
developer ALL=(ALL) NOPASSWD:ALL
EOF
sudo chown root. /etc/sudoers.d/98-developer-users
sudo chmod 440 /etc/sudoers.d/98-developer-users
#
#
#
sudo systemctl disable libvirtd
sudo systemctl stop libvirtd
#
#
#
####################################################################################
# Install the IUS Rackspace partner Repo
####################################################################################
sudo rpm -import https://repo.ius.io/RPM-GPG-KEY-IUS-7
sudo yum install -y https://repo.ius.io/ius-release-el7.rpm
sudo yum repolist -y
#
#
#
####################################################################################
# Add Desktop GUI - GNOME by Default
####################################################################################
sudo yum -y groupinstall "Server with GUI"
sudo ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
#
#
####################################################################################
# Add remote connectivity over RDP
####################################################################################
sudo yum install -y tigervnc git224 nano selinux-policy
# sudo wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/x/xrdp-0.9.17-2.el7.x86_64.rpm
# sudo wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/x/xrdp-devel-0.9.17-2.el7.x86_64.rpm
# sudo wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/x/xrdp-selinux-0.9.17-2.el7.x86_64.rpm
# OPTIONAL XORG-XRDP Module
#sudo wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/x/xorgxrdp-0.2.17-2.el7.x86_64.rpm
####################################################################################
# Dynamically Grab the latest XRDP Packages from the fedoraproject.org
####################################################################################
XRDP_PACKAGES=$(curl https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/x/ | grep -Eo 'xrdp-[a-zA-Z0-9./?=_%:-]*' | sort -u)
for a_xrdp_package in $XRDP_PACKAGES
do 
  # Skipping deprecated package known to be on page	
  if [ "${a_xrdp_package}" == "xrdp-0.2.17-2.el7.x86_64.rpm" ]; then
  	continue
  fi	
  $(wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/x/${a_xrdp_package})
done
sudo rpm -Uvh xrdp*
sudo mv xrdp*.rpm /root/rpms/.
sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo firewall-offline-cmd --add-port=3389/tcp
sudo firewall-cmd --permanent --add-port=3389/tcp
sudo firewall-cmd --reload
sudo chcon --type=bin_t /usr/sbin/xrdp
sudo chcon --type=bin_t /usr/sbin/xrdp-sesman
####################################################################################
# Default XRDP TCP send buffer size too low
####################################################################################
# https://github.com/neutrinolabs/xrdp/issues/1483
####################################################################################
sed -i 's/tcp_nodelay=true/tcp_nodelay=false/g' /etc/xrdp/xrdp.ini
sed -i 's/#tcp_send_buffer_bytes\=32768/tcp_send_buffer_bytes\=4194304/g' /etc/xrdp/xrdp.ini
# Increase the corresponding sysctl limit to 2x the requested buffer size
sudo sysctl -w net.core.wmem_max=8388608
####################################################################################
####################################################################################
####################################################################################
####################################################################################
# START - Customize Login Page for RDP - 1600 x 1200 Optimized
####################################################################################
# sudo yum install ImageMagick ImageMagick-devel -y
# sudo wget https://cdn.pixabay.com/photo/2017/05/10/12/41/hacker-2300772_960_720.jpg
# # sudo mogrify -format bmp hacker-2300772_960_720.jpg
# sudo convert hacker-2300772_960_720.jpg -verbose -depth 24 bg_logo.bmp
# sudo mogrify -resize 200% bg_logo.bmp
# sudo wget https://thumbs.dreamstime.com/b/cyber-security-lock-digital-screen-data-protection-business-technology-privacy-concept-172057525.jpg
# sudo convert cyber-security-lock-digital-screen-data-protection-business-technology-privacy-concept-172057525.jpg -verbose -depth 24 login_banner.bmp
# sudo mogrify -resize 800x600 login_banner.bmp
sudo wget https://raw.githubusercontent.com/cpoma/DeveloperDesktop/master/files/login_banner.bmp
sudo wget https://raw.githubusercontent.com/cpoma/DeveloperDesktop/master/files/bg_logo.bmp
sudo chmod 644 login_banner.bmp bg_logo.bmp
sudo chown root. login_banner.bmp bg_logo.bmp
sudo mv login_banner.bmp /usr/share/xrdp/login_banner.bmp
sudo mv bg_logo.bmp /usr/share/xrdp/bg_logo.bmp
rm -f hacker-2300772_960_720.jpg cyber-security-lock-digital-screen-data-protection-business-technology-privacy-concept-172057525.jpg
####################################################################################
####################################################################################
####################################################################################
CONSOLE_NAME=$(echo ${HOSTNAME^^})
# sudo cat > /etc/xrdp/xrdp.ini<<EOF
sudo bash -c 'cat > /etc/xrdp/xrdp.ini' << EOF
[Globals]
; xrdp.ini file version number
ini_version=1

; fork a new process for each incoming connection
fork=true

; ports to listen on, number alone means listen on all interfaces
; 0.0.0.0 or :: if ipv6 is configured
; space between multiple occurrences
; ALL specified interfaces must be UP when xrdp starts, otherwise xrdp will fail to start
;
; Examples:
;   port=3389
;   port=unix://./tmp/xrdp.socket
;   port=tcp://.:3389                           127.0.0.1:3389
;   port=tcp://:3389                            *:3389
;   port=tcp://<any ipv4 format addr>:3389      192.168.1.1:3389
;   port=tcp6://.:3389                          ::1:3389
;   port=tcp6://:3389                           *:3389
;   port=tcp6://{<any ipv6 format addr>}:3389   {FC00:0:0:0:0:0:0:1}:3389
;   port=vsock://<cid>:<port>
port=3389

; 'port' above should be connected to with vsock instead of tcp
; use this only with number alone in port above
; prefer use vsock://<cid>:<port> above
use_vsock=false

; regulate if the listening socket use socket option tcp_nodelay
; no buffering will be performed in the TCP stack
tcp_nodelay=false

; regulate if the listening socket use socket option keepalive
; if the network connection disappear without close messages the connection will be closed
tcp_keepalive=true

; set tcp send/recv buffer (for experts)
tcp_send_buffer_bytes=4194304
#tcp_send_buffer_bytes=32768
#tcp_recv_buffer_bytes=32768

; security layer can be 'tls', 'rdp' or 'negotiate'
; for client compatible layer
security_layer=tls

; minimum security level allowed for client for classic RDP encryption
; use tls_ciphers to configure TLS encryption
; can be 'none', 'low', 'medium', 'high', 'fips'
crypt_level=fips

; X.509 certificate and private key
; openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 365
certificate=
key_file=

; set SSL protocols
; can be comma separated list of 'SSLv3', 'TLSv1', 'TLSv1.1', 'TLSv1.2', 'TLSv1.3'
ssl_protocols=TLSv1.2, TLSv1.3
; set TLS cipher suites
tls_ciphers=HIGH:!ADH:!SHA1

; concats the domain name to the user if set for authentication with the separator
; for example when the server is multi homed with SSSd
#domain_user_separator=@

; The following options will override the keyboard layout settings.
; These options are for DEBUG and are not recommended for regular use.
#xrdp.override_keyboard_type=0x04
#xrdp.override_keyboard_subtype=0x01
#xrdp.override_keylayout=0x00000409

; Section name to use for automatic login if the client sends username
; and password. If empty, the domain name sent by the client is used.
; If empty and no domain name is given, the first suitable section in
; this file will be used.
autorun=

allow_channels=true
allow_multimon=true
bitmap_cache=true
bitmap_compression=true
bulk_compression=true
#hidelogwindow=true
max_bpp=32
new_cursors=true
; fastpath - can be 'input', 'output', 'both', 'none'
use_fastpath=both
; when true, userid/password *must* be passed on cmd line
#require_credentials=true
; when true, the userid will be used to try to authenticate
#enable_token_login=true
; You can set the PAM error text in a gateway setup (MAX 256 chars)
#pamerrortxt=change your password according to policy at http://url

;
; colors used by windows in RGB format
;
blue=009cb5
grey=dedede
#black=000000
#dark_grey=808080
#blue=08246b
#dark_blue=08246b
#white=ffffff
#red=ff0000
#green=00ff00
#background=626c72

;
; configure login screen
;

; Login Screen Window Title
ls_title=Login to Developer Desktop (${CONSOLE_NAME})

; top level window background color in RGB format
#ls_top_window_bg_color=009cb5
# MAKE PAGE BACKGROUND BLACK
ls_top_window_bg_color=000000

; width and height of login screen
;
; The default height allows for about 5 fields to be comfortably displayed
; above the buttons at the bottom. To display more fields, make <ls_height>
; larger, and also increase <ls_btn_ok_y_pos> and <ls_btn_cancel_y_pos>
; below
;
#ls_width=350
#ls_height=430
ls_width=800
ls_height=440

; login screen background color in RGB format
ls_bg_color=dedede

; optional background image filename (bmp format).
ls_background_image=/usr/share/xrdp/bg_logo.bmp

; logo
; full path to bmp-file or file in shared folder
ls_logo_filename=/usr/share/xrdp/login_banner.bmp
ls_logo_x_pos=0
ls_logo_y_pos=0
#ls_logo_x_pos=55
#ls_logo_y_pos=50

; for positioning labels such as username, password etc
ls_label_x_pos=30
ls_label_width=65

; for positioning text and combo boxes next to above labels
ls_input_x_pos=110
ls_input_width=210

; y pos for first label and combo box
ls_input_y_pos=350

; OK button
ls_btn_ok_x_pos=360
ls_btn_ok_y_pos=360
ls_btn_ok_width=85
ls_btn_ok_height=30

; Cancel button
ls_btn_cancel_x_pos=360
ls_btn_cancel_y_pos=400
ls_btn_cancel_width=85
ls_btn_cancel_height=30

[Logging]
; Note: Log levels can be any of: core, error, warning, info, debug, or trace
LogFile=xrdp.log
LogLevel=INFO
EnableSyslog=true
#SyslogLevel=INFO
#EnableConsole=false
#ConsoleLevel=INFO
#EnableProcessId=false

[LoggingPerLogger]
; Note: per logger configuration is only used if xrdp is built with
; --enable-devel-logging
#xrdp.c=INFO
#main()=INFO

[Channels]
; Channel names not listed here will be blocked by XRDP.
; You can block any channel by setting its value to false.
; IMPORTANT! All channels are not supported in all use
; cases even if you set all values to true.
; You can override these settings on each session type
; These settings are only used if allow_channels=true
rdpdr=true
rdpsnd=true
drdynvc=true
cliprdr=true
rail=true
xrdpvr=true
tcutils=true

; for debugging xrdp, in section xrdp1, change port=-1 to this:
#port=/tmp/.xrdp/xrdp_display_10


;
; Session types
;

; Some session types such as Xorg, X11rdp and Xvnc start a display server.
; Startup command-line parameters for the display server are configured
; in sesman.ini. See and configure also sesman.ini.
#[Xorg]
#name=Xorg
#lib=libxup.so
#username=ask
#password=ask
#ip=127.0.0.1
#port=-1
#code=20

[Xvnc]
name=Xvnc
lib=libvnc.so
username=ask
password=ask
ip=127.0.0.1
port=-1
#xserverbpp=24
#delay_ms=2000
; Disable requested encodings to support buggy VNC servers
; (1 = ExtendedDesktopSize)
#disabled_encodings_mask=0
; Use this to connect to a chansrv instance created outside of sesman
; (e.g. as part of an x11vnc console session). Replace '0' with the
; display number of the session
#chansrvport=DISPLAY(0)

; Generic VNC Proxy
; Tailor this to specific hosts and VNC instances by specifying an ip
; and port and setting a suitable name.
#[vnc-any]
#name=vnc-any
#lib=libvnc.so
#ip=ask
#port=ask5900
#username=na
#password=ask
#pamusername=asksame
#pampassword=asksame
#pamsessionmng=127.0.0.1
#delay_ms=2000

; Generic RDP proxy using NeutrinoRDP
; Tailor this to specific hosts by specifying an ip and port and setting
; a suitable name.
#[neutrinordp-any]
#name=neutrinordp-any
; To use this section, you should build xrdp with configure option
; --enable-neutrinordp.
#lib=libxrdpneutrinordp.so
#ip=ask
#port=ask3389
#username=ask
#password=ask
; Uncomment the following lines to enable PAM authentication for proxy
; connections.
#pamusername=ask
#pampassword=ask
#pamsessionmng=127.0.0.1
; Currently NeutrinoRDP doesn't support dynamic resizing. Uncomment
; this line if you're using a client which does.
#enable_dynamic_resizing=false
; By default, performance settings requested by the RDP client are ignored
; and chosen by NeutrinoRDP. Uncomment this line to allow the user to
; select performance settings in the RDP client.
#perf.allow_client_experiencesettings=true
; Override any experience setting by uncommenting one or more of the
; following lines.
#perf.wallpaper=false
#perf.font_smoothing=false
#perf.desktop_composition=false
#perf.full_window_drag=false
#perf.menu_anims=false
#perf.themes=false
#perf.cursor_blink=false
; By default NeutrinoRDP supports cursor shadows. If this is giving
; you problems (e.g. cursor is a black rectangle) try disabling cursor
; shadows by uncommenting the following line.
#perf.cursor_shadow=false
; By default, NeutrinoRDP uses the keyboard layout of the remote RDP Server.
; If you want to tell the remote the keyboard layout of the RDP Client,
; by uncommenting the following line.
#neutrinordp.allow_client_keyboardLayout=true
; The following options will override the remote keyboard layout settings.
; These options are for DEBUG and are not recommended for regular use.
#neutrinordp.override_keyboardLayout_mask=0x0000FFFF
#neutrinordp.override_kbd_type=0x04
#neutrinordp.override_kbd_subtype=0x01
#neutrinordp.override_kbd_fn_keys=12
#neutrinordp.override_kbd_layout=0x00000409

; You can override the common channel settings for each session type
#channel.rdpdr=true
#channel.rdpsnd=true
#channel.drdynvc=true
#channel.cliprdr=true
#channel.rail=true
#channel.xrdpvr=true
EOF
####################################################################################
# END - Customize Login Page for RDP
####################################################################################
####################################################################################
####################################################################################
####################################################################################
sudo chown root. /etc/xrdp/xrdp.ini
sudo chmod 644 /etc/xrdp/xrdp.ini
sudo service xrdp restart
#
#
# SET SERVER TIMEZONE TO UTC
#
sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime

####################################################################################
# SET USER DEFAULT TIME ZONE TO EST
####################################################################################
sudo mkdir -p /etc/skel
sudo chmod 755 /etc/skel
# sudo echo "TZ='US/Eastern'; export TZ" >> /etc/skel/.profile
echo "TZ='US/Eastern'; export TZ" | sudo tee -a /etc/skel/.profile > /dev/null
sudo chmod 644 /etc/skel/.profile
#
#
#
sudo mkdir -p /opt/projects/common-data/scripts/
#
#
#
# sudo cat > /opt/projects/common-data/scripts/generic-banner.desktop<<EOF
sudo bash -c 'cat > /opt/projects/common-data/scripts/generic-banner.desktop' << EOF
[Desktop Entry]
Name=Generic Banner
Comment=Generic Banner
Exec=/opt/projects/common-data/scripts/generic-banner.sh
Type=Application
Categories=
X-GNOME-Autostart-enabled=true
Terminal=false
EOF
sudo chmod 644 /opt/projects/common-data/scripts/generic-banner.desktop 
sudo cp /opt/projects/common-data/scripts/generic-banner.desktop /etc/xdg/autostart/generic-banner.desktop
#
#
#
# sudo sudo cat > /opt/projects/common-data/scripts/generic-banner.sh<<EOF
sudo bash -c 'cat > /opt/projects/common-data/scripts/generic-banner.sh' << EOF
#!/bin/bash
#
# Determine Last RDP Session time for the user
#
LOGFILE="\${HOME}/.generic_login"
if [ -f \${LOGFILE} ]; then
  LAST_LOGIN=\$( tail -1 \${LOGFILE} )
else
  LAST_LOGIN="Last login not found."
fi

#
# Save this login to the RDP Login file
#
NOW=\$( date +"%Y/%m/%d %H:%M:%S %Z" )
echo \${NOW} >> \${LOGFILE}


#
# Display the Banner Popup
#
zenity --warning --height=200 --width=400 --title "Generic Banner" --text="<span font='12'>You consent to monitoring on this Information System. \n\nLast Login: \${LAST_LOGIN}</span>" --ok-label="AGREE"
EOF
#
sudo chmod 755 /opt/projects/common-data/scripts/generic-banner.sh 
#
#
#
#
#sudo cat >> /etc/dconf/db/local.d/01-banner-message <<EOF
sudo bash -c 'cat > /etc/dconf/db/local.d/01-banner-message' << EOF
[org/gnome/login-screen]
banner-message-enable=true

banner-message-text='You consent to monitoring on this Information System.'
EOF
sudo chmod 644 /etc/dconf/db/local.d/01-banner-message
# OpenSCAP settings need the Symbolic Link
sudo ln -s /etc/dconf/db/local.d/01-banner-message /etc/dconf/db/gdm.d/00-security-settings
sudo rm -f /etc/dconf/db/local
sudo dconf update

#sudo cat >> /etc/dconf/db/local.d/00-screensaver <<EOF
sudo bash -c 'cat > /etc/dconf/db/local.d/00-screensaver' << EOF
[org/gnome/desktop/screensaver]
# Set this to true to lock the screen when the screensaver activates
lock-enabled=true

# Add the setting to enable screensaver locking after 15 minutes of inactivity
idle-activation-enabled=true

# Add the setting to enable session locking when a screensaver is activated:
lock-delay=uint32 5

[org/gnome/desktop/session]
# Set the lock time out to 900 seconds before the session is considered idle
idle-delay=uint32 900
EOF
sudo chmod 644 /etc/dconf/db/local.d/00-screensaver
sudo ln -s /etc/dconf/db/local.d/00-screensaver /etc/dconf/db/local.d/00-security-settings
sudo rm -f /etc/dconf/db/local
sudo dconf update
sudo mkdir -p /etc/dconf/db/local.d/locks
#sudo cat >> /etc/dconf/db/local.d/locks/session <<EOF
sudo bash -c 'cat > /etc/dconf/db/local.d/locks/session' << EOF
# Lock desktop screensaver settings
/org/gnome/desktop/screensaver/idle-activation-enabled
/org/gnome/desktop/session/idle-delay
/org/gnome/desktop/screensaver/lock-delay
/org/gnome/desktop/screensaver/lock-enabled
EOF
# OpenSCAP settings need the Symbolic Link
sudo ln -s /etc/dconf/db/local.d/locks/session /etc/dconf/db/local.d/locks/00-security-settings-lock
sudo rm -f /etc/dconf/db/local
sudo chmod 644 /etc/dconf/db/local.d/locks/session
sudo dconf update

#sudo cat >> /etc/dconf/db/local.d/01-background <<EOF
sudo bash -c 'cat > /etc/dconf/db/local.d/01-background' << EOF
[org/gnome/desktop/background]

# GSettings key names and their corresponding values
picture-uri='file:///usr/local/share/backgrounds/defaultBackground.png'
picture-options='stretched'
primary-color='000000'
secondary-color='FFFFFF'
EOF
sudo chmod 644 /etc/dconf/db/local.d/01-background
sudo mkdir /usr/local/share/backgrounds/
sudo wget -O /tmp/defaultBackground.png https://github.com/cpoma/DeveloperDesktop/raw/master/files/defaultBackground.png
sudo mv /tmp/defaultBackground.png /usr/local/share/backgrounds/defaultBackground.png
sudo chmod 644 /usr/local/share/backgrounds/defaultBackground.png
sudo dconf update

#sudo cat >> /etc/dconf/db/local.d/00-disable-CAD <<EOF
sudo bash -c 'cat > /etc/dconf/db/local.d/00-disable-CAD' << EOF
[org/gnome/settings-daemon/plugins/media-keys]
logout=''
EOF
sudo rm -f /etc/dconf/db/local
sudo chmod 644 /etc/dconf/db/local.d/locks/session
sudo dconf update
#sudo cat > /etc/dconf/db/local.d/00-smartcards<<EOF
sudo bash -c 'cat > /etc/dconf/db/local.d/00-smartcards' << EOF
[org/gnome/login-screen]
enable-smartcard-authentication=false
EOF
sudo chmod 644 /etc/dconf/db/local.d/00-smartcards
sudo rm -f /etc/dconf/db/local
sudo dconf update

#sudo cat > /etc/gdm/custom.conf <<EOF
sudo bash -c 'cat > /etc/gdm/custom.conf' << EOF
# GDM configuration storage

[daemon]
# Configure the operating system to not allow an unattended or automatic logon to the system via a graphical user interface.
AutomaticLoginEnable=false

# Configure the operating system to not allow an unrestricted account to log on to the system via a graphical user interface.
TimedLoginEnable=false

# Trigger Greeter
Greeter=/usr/libexec/gdmlogin

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
#Enable=true

[greeter]
DefaultWelcome=false
Welcome='You consent to monitoring on this Information System.'
RemoteWelcome='You consent to monitoring on this Information System.'
EOF
sudo chmod 644 /etc/gdm/custom.conf
sudo rm -f /etc/dconf/db/local
sudo dconf update
#
# Disable the Gnome First Login Question/Config
#
# sudo echo "X-GNOME-Autostart-enabled=false" >> /etc/xdg/autostart/gnome-initial-setup-first-login.desktop
echo "X-GNOME-Autostart-enabled=false" | sudo tee -a /etc/xdg/autostart/gnome-initial-setup-first-login.desktop > /dev/null
#
# Configure AutoStart to "trust" added desktop icons
#
#sudo cat >> /etc/xdg/autostart/desktop-truster.desktop <<EOF
sudo bash -c 'cat > /etc/xdg/autostart/desktop-truster.desktop' << EOF
[Desktop Entry]
Name=Desktop-Truster
Comment=Autostarter to trust all desktop files
Exec=/opt/projects/common-data/scripts/desktop-truster.sh
Type=Application
EOF
sudo chmod 644 /etc/xdg/autostart/desktop-truster.desktop

#sudo cat >> /opt/projects/common-data/scripts/desktop-truster.sh <<EOF
sudo bash -c 'cat > /opt/projects/common-data/scripts/desktop-truster.sh' << EOF
#!/bin/bash
# Wait for nautilus-desktop
while ! pgrep -f 'nautilus-desktop' > /dev/null; do
 sleep 1
done
if [ ! -f ~/Desktop/google-chrome.desktop ]; then
  # File not found
  # Copy over SKEL Icon
 cp -f /etc/skel/Desktop/google-chrome.desktop ~/Desktop/.
fi

# Trust all desktop files
for i in ~/Desktop/*.desktop; do
 [ -f "\${i}" ] || break
 gio set "\${i}" "metadata::trusted" yes
 gio set "\${i}" "metadata::trusted" true
done
# Restart nautilus, so that the changes take effect (otherwise we would have to press F5)
# killall nautilus-desktop && nautilus-desktop &
# Remove X from this script, so that it won't be executed next time
# chmod -x \${0}
EOF
sudo chmod 755 /opt/projects/common-data/scripts/desktop-truster.sh
#
#
#
#
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
sudo yum -y install ./google-chrome-stable_current_*.rpm
sudo mv google-chrome-stable_current_*.rpm /root/rpms/.
#
# Assumes Chrome is installed here at this point. I will now place the Chrome Icon
# in the Skel folder to make it show up on all user's desktops.
#
sudo mkdir /etc/skel/Desktop
sudo chmod 755 /etc/skel/Desktop
sudo cp /usr/share/applications/google-chrome.desktop /etc/skel/Desktop/google-chrome.desktop
sudo chmod 755 /etc/skel/Desktop/google-chrome.desktop
sudo chown root. /etc/skel/Desktop/google-chrome.desktop
#
#
#
####################################################################################
# Install PyCharm for Python Development
####################################################################################
wget -O /tmp/pycharm.tar.gz https://download-cdn.jetbrains.com/python/pycharm-community-2021.1.3.tar.gz
sudo tar -C /opt -xzvf /tmp/pycharm.tar.gz 
sudo mv /opt/pycharm-community-2021.1.3 /opt/pycharm
sudo chmod -R 755 /opt/pycharm
# sudo cat >> /opt/pycharm/pycharm.desktop <<EOF
sudo bash -c 'cat > /opt/pycharm/pycharm.desktop' << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm
Icon=/opt/pycharm/bin/pycharm.png
Exec="/opt/pycharm/bin/pycharm.sh" %f
Comment=The Drive to Develop
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-pycharm
EOF
sudo cp /opt/pycharm/pycharm.desktop /usr/share/applications/pycharm.desktop
sudo chmod 644 /usr/share/applications/pycharm.desktop
#
#
#
####################################################################################
# Install Sublime Text and Sublime Merge for Development
####################################################################################
sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
sudo yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
sudo yum -y install sublime-text
sudo yum -y install sublime-merge
#
#
#
####################################################################################
# Update whole OS for all packages at this point
####################################################################################
sudo yum -y update 
#
#
#
####################################################################################
# START - Build the RDP Sound Drivers
####################################################################################
# Builds and deploys the following files. Once the files are build for your 
# OS Release / XRDP Version - they can just be copied on like servers to 
# enable sound. 
# /usr/lib64/pulse-10.0/modules/module-xrdp-sink.so
# /usr/lib64/pulse-10.0/modules/module-xrdp-sink.la
# /usr/lib64/pulse-10.0/modules/module-xrdp-source.so
# /usr/lib64/pulse-10.0/modules/module-xrdp-source.la
####################################################################################
cat >> /tmp/add_rdp_sound.sh<<EOF
#!/bin/sh
cd /tmp
####################################################################################
# --skip-broken will ignore that I installed Git 2.2.4 (git224) from the IUS 
# Rackspace partner repo versus using the default OLD repo version of git v1.8
####################################################################################
yum -y groupinstall "Development Tools" --skip-broken
yum -y install rpmdevtools yum-utils nasm
rpmdev-setuptree
yum -y install pulseaudio pulseaudio-libs pulseaudio-libs-devel 
####################################################################################
# webrtc-audio-processing-devel required for Redhat Install to Build Sound 
####################################################################################
yum -y install webrtc-audio-processing webrtc-audio-processing-devel 
yum-builddep -y pulseaudio
#
yumdownloader --source pulseaudio
rpm --install pulseaudio*.src.rpm
rpmbuild -bb --noclean /root/rpmbuild/SPECS/pulseaudio.spec
#
git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
cd pulseaudio-module-xrdp
./bootstrap && ./configure PULSE_DIR=/root/rpmbuild/BUILD/pulseaudio-10.0
make
make install
EOF
sudo mv /tmp/add_rdp_sound.sh /root/scripts/add_rdp_sound.sh
sudo chmod 700 /root/scripts/add_rdp_sound.sh
sudo chown root. /root/scripts/add_rdp_sound.sh
sudo /root/scripts/add_rdp_sound.sh
#
####################################################################################
# END - Build the RDP Sound Drivers
####################################################################################
#
#
#
####################################################################################
# START - Install Sound Encoders
####################################################################################
####################################################################################
# Some instructions I DID NOT FOLLOW:
#                              https://trac.ffmpeg.org/wiki/CompilationGuide/Centos
####################################################################################
####################################################################################
# Some possible pre-req packages for the encoders to build properly
####################################################################################
cat >> /tmp/add_sound_encoders.sh<<EOF
# OpenAL Soft is a cross-platform software implementation of the OpenAL 3D audio API
sudo wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/o/openal-soft-1.16.0-3.el7.x86_64.rpm
# Libass is a portable library for SSA/ASS subtitles rendering.
sudo wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/l/libass-0.13.4-6.el7.x86_64.rpm
# The schroedinger project provides libraries for the Dirac video codec created by BBC Research
sudo wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/s/schroedinger-1.0.11-4.el7.x86_64.rpm
sudo rpm -Uvh openal-soft-1.16.0-3.el7.x86_64.rpm
sudo rpm -Uvh libass-0.13.4-6.el7.x86_64.rpm
sudo rpm -Uvh schroedinger-1.0.11-4.el7.x86_64.rpm
sudo rm -f openal-soft-1.16.0-3.el7.x86_64.rpm libass-0.13.4-6.el7.x86_64.rpm schroedinger-1.0.11-4.el7.x86_64.rpm 
#
####################################################################################
# Build FFMPEG from source
####################################################################################
cd /tmp
wget https://ffmpeg.org/releases/ffmpeg-4.4.1.tar.gz
tar -xzvf ffmpeg-4.4.1.tar.gz
cd ffmpeg-4.4.1/
./configure
make
make install
ln -s /usr/local/bin/ffmpeg /usr/bin/ffmpeg
ln -s /usr/local/bin/ffprobe /usr/bin/ffprobe
sudo ffmpeg -version
sudo ffmpeg -encoders
EOF
sudo mv /tmp/add_sound_encoders.sh /root/scripts/add_sound_encoders.sh 
sudo chmod 700 /root/scripts/add_sound_encoders.sh
sudo chown root. /root/scripts/add_sound_encoders.sh
sudo /root/scripts/add_sound_encoders.sh
####################################################################################
# END - Install Sound Encoders
####################################################################################
#
#
#
sudo systemctl disable libvirtd
sudo systemctl stop libvirtd
#
#
#
sudo touch /root/INSTALL_DONE.txt
duration=$(echo "$(date +%s.%N) - $START_TIME" | bc)
execution_time=`printf "%.2f seconds" $duration`
echo "Script configure_image.sh Execution Time: $execution_time" >> /tmp/RUN_DURATION.txt
sudo mv /tmp/RUN_DURATION.txt /root/RUN_DURATION.txt 
#
sudo reboot now
#
#