#!/bin/bash

## Force to run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

## Load a configuration file if exists
load_conf_file() {
	ready=0
	while [ $ready == 0 ]; do
		if [ -f $1 ]
			then
				print_log "Using $1"
				. $1
				ready=1;
			else
				read -p "File $1 not found. Do you wish to [R]etry, [C]ontinue or [Q]uit (r/c/q)?" answer
				if [ "$answer" == 'R' -o "$answer" == 'r' ]; then
					echo "Retrying"
					ready=0;
				fi
				if [ "$answer" == 'C' -o "$answer" == 'c' ]; then
					echo "Continue"
					ready=1;
				fi
				if [ "$answer" == 'Q' -o "$answer" == 'q' ]; then
					echo "Exiting setup.."
					exit 1;
				fi
		fi
	done
}


## Print prompt and do not proceed unless user enters Y or N.
print_prompt() {
	ready=0
	while [ $ready == 0 ]; do
		read -p "Do you wish to proceed (y/n)? " answer
		if [ "$answer" == 'Y' -o "$answer" == 'y' ]; then
			ready=1
		fi
		if [ "$answer" == 'N' -o "$answer" == 'n' ]; then
			echo "Exiting setup.."
			exit 1;
		fi
	done
}

## Print log message
print_log() {
	echo -e "\n\n\t****** $1 ******"
}

## Loading configuration file
load_conf_file setup-env.conf

## Display variables to user for sanity check
echo -e "\t*************************************************"
echo -e "\t********** Ubuntu Desktop Setup Script **********"
echo -e "\t*************************************************"
echo -e "\tEnvironment Variables for the Setup:"
echo -e "\t\tSERVER_IP = $SERVER_IP"
echo -e "\t\tSUPER_USER = $SUPER_USER"
echo -e "\t\tSERVER_NAME = $SERVER_NAME"
echo -e "\t\tSERVER_DOMAIN = $SERVER_DOMAIN"
echo -e "\t\tSERVER_OTHER_NAMES = $SERVER_OTHER_NAMES"
echo -e "\t\tSSH_PORT = $SSH_PORT"
echo -e "\t\tMAILER_SMARTHOST = $MAILER_SMARTHOST"
echo -e "\t\tMAILER_PASSWORD = $MAILER_PASSWORD"
echo -e "\t\tSUPPORT_EMAIL = $SUPPORT_EMAIL"
echo -e "\t\tPACKAGES_FILE = $PACKAGES_FILE"
echo -e "\t\tPACKAGES_SCRIPT = $PACKAGES_SCRIPT"
echo -e "\t\tIPTABLES_SCRIPT = $IPTABLES_SCRIPT"
echo -e "\t*********************************************"
print_prompt


##
## System Setup
##

## Setup Repositories
print_log "Updating Repositories"
print_prompt
cp /etc/apt/sources.list /etc/apt/sources.list.default
# Enable main, restricted, universe and multiverse repositories
echo "deb http://us.archive.ubuntu.com/ubuntu/ $(lsb_release -cs) main restricted universe multiverse" | tee /etc/apt/sources.list
echo "deb-src http://us.archive.ubuntu.com/ubuntu/ $(lsb_release -cs) main restricted universe multiverse" | tee -a /etc/apt/sources.list
echo "" | tee -a /etc/apt/sources.list
echo "deb http://us.archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse" | tee -a /etc/apt/sources.list
echo "deb-src http://us.archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse" | tee -a /etc/apt/sources.list
echo "" | tee -a /etc/apt/sources.list
echo "deb http://us.archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse" | tee -a /etc/apt/sources.list
echo "deb-src http://us.archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse" | tee -a /etc/apt/sources.list
echo "" | tee -a /etc/apt/sources.list
echo "deb http://security.ubuntu.com/ubuntu $(lsb_release -cs)-security main restricted universe multiverse" | tee -a /etc/apt/sources.list
echo "deb-src http://security.ubuntu.com/ubuntu $(lsb_release -cs)-security main restricted universe multiverse" | tee -a /etc/apt/sources.list
echo "" | tee -a /etc/apt/sources.list
echo "deb http://archive.canonical.com/ubuntu $(lsb_release -cs) partner" | tee -a /etc/apt/sources.list
echo "deb-src http://archive.canonical.com/ubuntu $(lsb_release -cs) partner" | tee -a /etc/apt/sources.list
echo "" | tee -a /etc/apt/sources.list
echo "deb http://extras.ubuntu.com/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list
echo "deb-src http://extras.ubuntu.com/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list

## External Repositories
# Ubuntu Repositories are outdated
add-apt-repository ppa:gnome3-team/gnome3

# LibreOffice PPA (More Updates)
add-apt-repository -y ppa:libreoffice/ppa

# NginX PPA
add-apt-repository -y ppa:nginx/stable

# Git PPA
add-apt-repository -y ppa:git-core/ppa

# MongoDB
echo "#MongoDB" | tee /etc/apt/sources.list.d/mongo-db.list
echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list.d/mongo-db.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 #MongoDB

#RabbitMQ
echo "#RabbitMQ" | tee /etc/apt/sources.list.d/rabbitmq.list
echo "deb http://www.rabbitmq.com/debian/ testing main" | tee -a /etc/apt/sources.list.d/rabbitmq.list
wget -q http://www.rabbitmq.com/rabbitmq-signing-key-public.asc -O- | sudo apt-key add -

# VideoLan for libdvdcss
echo "#VideoLan" | tee /etc/apt/sources.list.d/videolan.list
echo "deb http://download.videolan.org/pub/debian/stable/ /" | tee -a /etc/apt/sources.list.d/videolan.list
echo "deb-src http://download.videolan.org/pub/debian/stable/ /" | tee -a /etc/apt/sources.list.d/videolan.list
wget -O - http://download.videolan.org/pub/debian/videolan-apt.asc|sudo apt-key add -

# Virtual Box
echo "# VirtualBox Repository" | tee -a /etc/apt/sources.list.d/virtualbox.list
echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | tee -a /etc/apt/sources.list.d/virtualbox.list
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -

# Dropbox
echo "# Dropbox" | tee /etc/apt/sources.list.d/dropbox.list
echo "deb http://linux.dropbox.com/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/dropbox.list
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 5044912E #Dropbox

# Handbrake (Video Transcoding) [disabled because no trusty package]
#add-apt-repository -y ppa:stebbins/handbrake-releases

# Ubuntu X Team PPA Updates [disabled until proved needed]
#add-apt-repository -y ppa:ubuntu-x-swat/x-updates

# Google Chrome, Chromium, Talk Plugin
echo "# Google software repository" | tee /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/earth/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/talkplugin/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list
wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O- | apt-key add -



## Update system
print_log "Package update"
apt-get update
apt-get upgrade
apt-get dist-upgrade

## Install new packages
print_log "Installing new packages"
echo -n "apt-get install " > $PACKAGES_SCRIPT
sed '/^\#/d;/^$/d' $PACKAGES_FILE | tr '\n' ' ' >> $PACKAGES_SCRIPT
chmod 755 $PACKAGES_SCRIPT
sh $PACKAGES_SCRIPT
rm $PACKAGES_SCRIPT $PACKAGES_FILE

#Install Google Earth
wget -O google-earth-stable.deb http://dl.google.com/dl/earth/client/current/google-earth-stable_current_i386.deb
dpkg -i google-earth-stable.deb
rm google-earth-stable.deb

#Clean-Up
rm -f /etc/apt/sources.list.d/google-chrome.list
rm -f /etc/apt/sources.list.d/google-talkplugin.list
rm -f /etc/apt/sources.list.d/google-earth.list

##
## SuperUser Setup
##

## User Management
print_log "User management"
usermod -a -G sudo $SUPER_USER
usermod -a -G adm $SUPER_USER
usermod -a -G www-data $SUPER_USER

## GRUB TIMEOUT -- seems to be unnecessery
#sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=$GRUB_TIMEOUT/" /etc/default/grub
#update-grub

## Mail Aliases
echo "root: root,$SUPPORT_EMAIL" | tee -a /etc/aliases
echo "$SUPER_USER: $SUPER_USER,$SUPER_USER@$SERVER_DOMAIN" | tee -a /etc/aliases
newaliases

## Housekeeping
mkdir /home/$SUPER_USER/bin
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/bin
# Groups
addgroup developers
usermod -a -G www-data $SUPER_USER
usermod -a -G vboxusers $SUPER_USER
usermod -a -G developers $SUPER_USER
usermod -a -G developers www-data

##
## System Configuration
##

# Install Inconsolata font (and variants)
mkdir -p /usr/share/fonts/opentype
curl --silent http://www.levien.com/type/myfonts/Inconsolata.otf -o /usr/share/fonts/opentype/Inconsolata.otf
curl --silent http://media.nodnod.net/Inconsolata-dz.otf.zip | zcat  > /usr/share/fonts/opentype/Inconsolata-dz.otf

# Font Cache
print_log "Font Cache"
fc-cache -fv

# DVD Playback setup
print_log "CSS for DVD Playback"
/usr/share/doc/libdvdread4/install-css.sh


## Machine Locale Details
print_log "Setup Timezone"
dpkg-reconfigure tzdata
print_log "Setup Locales"
locale-gen $SERVER_LOCALE
update-locale LANG=$SERVER_LOCALE
dpkg-reconfigure locales
print_log "Selecting Default Worldlist"
select-default-wordlist

## Alternatives
print_log "Updating alernatives"
ln -sf /bin/bash /bin/sh
update-alternatives --config editor
update-alternatives --config x-www-browser
update-alternatives --config ruby
update-alternatives --config gem
# Update java alternatives to use latest installed jdk
update-java-alternatives -s $(update-java-alternatives -l | tail -1 | awk '{ print $1 }')

## Hardware Sensors
print_log "Detect Hardware Sensors - Add Modules to /etc/modules"
sensors-detect

## Hostname
print_log "HostName configuration"
#echo "$SERVER_NAME.$SERVER_DOMAIN" | tee /etc/hostname
echo "$SERVER_NAME" | tee /etc/hostname
hostname -F /etc/hostname

## DNS Name Servers
print_log "DNS Configuration"
echo "nameserver 8.8.8.8" | tail -a /etc/resolvconf/resolv.conf.d/tail
echo "nameserver 8.8.4.4" | tail -a /etc/resolvconf/resolv.conf.d/tail
service networking restart

## SSH Configuration
print_log "SSH Configuration"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.default
sed -i "s/Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i -e 's/^PermitRootLogin yes/PermitRootLogin no/' -e 's/^PermitEmptyPasswords yes/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i 's/^X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
sed -i 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
sed -i 's/^UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
echo "" | tee -a /etc/ssh/sshd_config
echo "# Permit only specific users" | tee -a /etc/ssh/sshd_config
echo "AllowUsers $SUPER_USER" | tee -a /etc/ssh/sshd_config
service ssh restart

## Email Configuration using Exim
print_log "Exim configuration"
cp /etc/exim4/update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf.default
sed -i -e "s/^dc_eximconfig_configtype='.*'/dc_eximconfig_configtype='smarthost'/" \
    -e "s/^dc_other_hostnames='.*'/dc_other_hostnames=''/" \
    -e "s/^dc_smarthost='.*'/dc_smarthost='$MAILER_SMARTHOST'/" \
    -e "s/^dc_readhost=='.*'/dc_readhost=='$SERVER_NAME.$SERVER_DOMAIN'/" \
    -e "s/^dc_hide_mailname='.*'/dc_hide_mailname='false'/"  /etc/exim4/update-exim4.conf.conf
echo "$SERVER_NAME.$SERVER_DOMAIN" | tee /etc/mailname
echo "*:$MAILER_EMAIL:$MAILER_PASSWORD" | tee -a /etc/exim4/passwd.client
unset MAILER_PASSWORD
update-exim4.conf
service exim4 restart
# Sending Test Email
echo "Hello World! From $USER on $(hostname) sent to $SUPER_USER" | mail -s "Hello World from $(hostname)" $SUPER_USER

## Disable Tomcat by default
print_log "Stopping & Disabling Tomcat"
service tomcat7 stop
update-rc.d -f tomcat7 disable

## Secure MySQL
print_log "Securing MySQL"
mysql_secure_installation

## Paper Size Configuration
print_log "Configure paper size for default priting & LaTeX"
print_prompt
dpkg-reconfigure libpaper1
texconfig-sys

## iptables
curl https://raw.github.com/alghanmi/vps_setup/master/scripts/iptables-setup.sh | sed -e s/^SERVER_IP=.*/SERVER_IP=\"$SERVER_IP\"/ -e s/^SSH_PORT=.*/SSH_PORT=\"$SSH_PORT\"/ - > /home/$SUPER_USER/bin/iptables-setup.sh
chmod 755 /home/$SUPER_USER/bin/iptables-setup.sh
sh /home/$SUPER_USER/bin/iptables-setup.sh


##
## User Configuration Files
##
print_log "User specific configuration"
print_prompt

# Remove privacy issues & ads from Ubuntu
wget -q -O - https://fixubuntu.com/fixubuntu.sh | bash
gsettings set com.canonical.Unity.Lenses disabled-scopes "['more_suggestions-amazon.scope', 'more_suggestions-u1ms.scope', 'more_suggestions-populartracks.scope', 'music-musicstore.scope', 'more_suggestions-ebay.scope', 'more_suggestions-ubuntushop.scope', 'more_suggestions-skimlinks.scope']"

# View active username in panel
gsettings set com.canonical.indicator.session show-real-name-on-panel true

# Local & work directories
mkdir -p /home/$SUPER_USER/work/lib
mkdir -p /home/$SUPER_USER/.ssh
mkdir -p /home/$SUPER_USER/bin
mkdir -p /home/$SUPER_USER/src
mkdir -p /home/www

# Create a local SSH config file for hosts
mkdir /home/$SUPER_USER/.ssh
touch /home/$SUPER_USER/.ssh/authorized_keys
chmod 600 /home/$SUPER_USER/.ssh/authorized_keys
chmod 700 /home/$SUPER_USER/.ssh

# Make GnuPG to use SHA2 in preference to SHA1
su - $SUPER_USER -c 'gpg --list-keys &> /dev/null'
echo "" | tee -a /home/$SUPER_USER/.gnupg/gpg.conf
echo "# Use SHA2 in preference to SHA1" | tee -a /home/$SUPER_USER/.gnupg/gpg.conf
echo "personal-digest-preferences SHA256" | tee -a /home/$SUPER_USER/.gnupg/gpg.conf
echo "cert-digest-algo SHA256" | tee -a /home/$SUPER_USER/.gnupg/gpg.conf
echo "default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed" | tee -a /home/$SUPER_USER/.gnupg/gpg.conf

# Refresh GPG Keys twice a month on days 1 and 15.
crontab -u $SUPER_USER -l > $SUPER_USER.cron
echo -e "0\t0\t1,15\t*\t*\tgpg --refresh-keys" | tee -a $SUPER_USER.cron
crontab -u $SUPER_USER $SUPER_USER.cron
rm $SUPER_USER.cron

#nano editor configuration files
find /usr/share/nano/ -name "*.nanorc" -print | sed -e 's/^\(.*\)$/include "\1"/g' >> /home/$SUPER_USER/.nanorc

# Fix Ownership
chown $SUPER_USER:$SUPER_USER /home/$SUPER_USER/.bashrc
chown $SUPER_USER:$SUPER_USER /home/$SUPER_USER/.nanorc
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/work
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/.ssh
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/.gnupg
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/bin
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/src
chown -R www-data:www-data /home/www

##
## Desktop Preferences
##
print_log "Desktop Preferences"
print_prompt

# Disable Guest Login
touch /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
echo "" | tee -a /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
echo "Remove Guest Login" | tee -a /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
echo "allow-guest=false" | tee -a /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf


##
## Clean-up
##
print_log "Repository Cache Cleanup"
apt-get -f install; apt-get clean; apt-get autoclean; apt-get autoremove
rmdir ~/Documents/ ~/Music/ ~/Pictures/ ~/Public/ ~/Templates/ ~/Videos/
rm ~/examples.desktop
