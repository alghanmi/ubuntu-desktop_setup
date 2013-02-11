#!/bin/bash

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
# Git
echo "# Git PPA" | tee /etc/apt/sources.list.d/git.list
echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/git.list
echo "deb-src http://ppa.launchpad.net/git-core/ppa/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/git.list
# Emacs24
echo "# Emacs24 Snapshot PPA" | tee /etc/apt/sources.list.d/emacs.list
echo "deb http://ppa.launchpad.net/cassou/emacs/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/emacs.list
echo "deb-src http://ppa.launchpad.net/cassou/emacs/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/emacs.list
# Medibuntu
wget -q http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list -O- | tee /etc/apt/sources.list.d/medibuntu.list 
# Google Chrome, Chromium, Talk Plugin
echo "# Google software repository" | tee /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/earth/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/talkplugin/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list
echo "deb http://ppa.launchpad.net/chromium-daily/stable/ubuntu $(lsb_release -cs) main " | tee -a /etc/apt/sources.list.d/google.list
echo "deb-src http://ppa.launchpad.net/chromium-daily/stable/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/google.list
# Virtual Box
echo "# VirtualBox Repository" | tee -a /etc/apt/sources.list.d/virtualbox.list
echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | tee -a /etc/apt/sources.list.d/virtualbox.list
# Dropbox
echo "# Dropbox" | tee /etc/apt/sources.list.d/dropbox.list
echo "deb http://linux.dropbox.com/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/dropbox.list
# MPlayer
echo "# MPlayer" | tee /etc/apt/sources.list.d/mplayer.list
echo "deb http://ppa.launchpad.net/motumedia/mplayer-daily/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/mplayer.list
echo "deb-src http://ppa.launchpad.net/motumedia/mplayer-daily/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/mplayer.list
# Handbrake
echo "# Handbrake" | tee /etc/apt/sources.list.d/handbrake.list
echo "deb http://ppa.launchpad.net/stebbins/handbrake-releases/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/handbrake.list
echo "deb-src http://ppa.launchpad.net/stebbins/handbrake-releases/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/handbrake.list
# Ubuntu-X X-Updates
echo "# Ubuntu-X X-Updates" | tee /etc/apt/sources.list.d/x-updates.list
echo "deb http://ppa.launchpad.net/ubuntu-x-swat/x-updates/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/x-updates.list
echo "deb-src http://ppa.launchpad.net/ubuntu-x-swat/x-updates/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/x-updates.list

## External Repository Keys
wget -q http://packages.medibuntu.org/medibuntu-key.gpg -O- | apt-key add -
wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O- | apt-key add -
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com E1DF1F24 #Git
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com CEC45805 #Emacs24
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 4E5E17B5 #Chromium PPA
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 5044912E #Dropbox
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 06438B87 #MPlayer
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 816950D8 #Handbrake
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com AF1CDFA9 #Ubuntu-X X-Updates

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
rm /etc/apt/sources.list.d/google-chrome.list
rm /etc/apt/sources.list.d/google-talkplugin.list
rm /etc/apt/sources.list.d/google-earth.list

##
## SuperUser Setup
##

## User Management
print_log "User management"
usermod -a -G sudo $SUPER_USER
usermod -a -G adm $SUPER_USER
usermod -a -G www-data $SUPER_USER

## GRUB TIMEOUT
sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=$GRUB_TIMEOUT/" /etc/default/grub
update-grub

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

## Lighttpd
curl https://raw.github.com/alghanmi/vps_setup/master/scripts/lighttpd-setup.sh | sed -e "s/create_site example.com/create_site $SERVER_NAME/g" > /home/$SUPER_USER/bin/lighttpd-setup.sh
chmod 755 /home/$SUPER_USER/bin/lighttpd-setup.sh
sh /home/$SUPER_USER/bin/lighttpd-setup.sh


##
## User Configuration Files
##
print_log "User specific configuration"
print_prompt

# Local & work directories
mkdir -p /home/$SUPER_USER/work/lib
mkdir -p /home/$SUPER_USER/.ssh
mkdir -p /home/$SUPER_USER/bin
mkdir -p /home/$SUPER_USER/src
mkdir -p /home/www

# Create a local SSH config file for hosts
touch /home/$SUPER_USER/.ssh/authorized_keys
chmod 600 /home/$SUPER_USER/.ssh/authorized_keys
chmod 700 /home/$SUPER_USER/.ssh

# Make GnuPG to use SHA2 in preference to SHA1
gpg --list-keys &> /dev/null
echo "" >> ~/.gnupg/gpg.conf
echo "# Use SHA2 in preference to SHA1" >> ~/.gnupg/gpg.conf
echo "personal-digest-preferences SHA256" >> ~/.gnupg/gpg.conf
echo "cert-digest-algo SHA256" >> ~/.gnupg/gpg.conf
echo "default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed" >> ~/.gnupg/gpg.conf

# Refresh GPG Keys twice a month on days 1 and 15.
crontab -u $SUPER_USER -l > $SUPER_USER.cron
echo -e "0\t0\t1,15\t*\t*\tgpg --refresh-keys" | tee -a $SUPER_USER.cron
crontab -u $SUPER_USER $SUPER_USER.cron
rm $SUPER_USER.cron

# Fix Ownership
chown $SUPER_USER:$SUPER_USER /home/$SUPER_USER/.bashrc
chown $SUPER_USER:$SUPER_USER /home/$SUPER_USER/.nanorc
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/work
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/.ssh
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/.gpg
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/bin
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/src
chown -R www-data:www-data /home/www

##
## Desktop Preferences
##
print_log "Desktop Preferences"
print_prompt

# Disable Guest Login
cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.default
echo "allow-guest=false" | tee -a /etc/lightdm/lightdm.conf


##
## Clean-up
##
print_log "Repository Cache Cleanup"
apt-get clean; apt-get autoclean; apt-get autoremove
rmdir ~/Documents/ ~/Music/ ~/Pictures/ ~/Public/ ~/Templates/ ~/Videos/
rm ~/examples.desktop
