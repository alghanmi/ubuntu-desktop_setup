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
# Emacs24
echo "# Emacs24 Snapshot PPA" | tee /etc/apt/sources.list.d/emacs.list
echo "deb http://ppa.launchpad.net/cassou/emacs/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/emacs.list
echo "deb-src http://ppa.launchpad.net/cassou/emacs/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/emacs.list
# Medibuntu
wget -q http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list -O- | tee /etc/apt/sources.list.d/medibuntu.list 
# Google Chrome, Chromium, Talk Plugin
echo "# Google software repository" | tee /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/deb/ stable non-free main" | tee -a /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list
echo "deb http://dl.google.com/linux/talkplugin/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list
echo "deb http://ppa.launchpad.net/chromium-daily/stable/ubuntu $(lsb_release -cs) main " | tee -a /etc/apt/sources.list.d/google.list
echo "deb-src http://ppa.launchpad.net/chromium-daily/stable/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/google.list
# Virtual Box
echo "# VirtualBox Repository" | tee -a /etc/apt/sources.list.d/virtualbox.list
echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib non-free" | tee -a /etc/apt/sources.list.d/virtualbox.list
# Dropbox
echo "# Dropbox" | tee /etc/apt/sources.list.d/dropbox.list
echo "deb http://linux.dropbox.com/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/dropbox.list
# SABNZBd Plus
echo "# SABnzbd" | tee -a /etc/apt/sources.list.d/sabnzbd.list
echo "deb http://ppa.launchpad.net/jcfp/ppa/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/sabnzbd.list
echo "deb-src http://ppa.launchpad.net/jcfp/ppa/ubuntu $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/sabnzbd.list
# Handbrake (TODO: fix hack once precise package is available)
echo "# Handbrake" | tee /etc/apt/sources.list.d/handbrake.list
echo "deb http://ppa.launchpad.net/stebbins/handbrake-releases/ubuntu oneiric main" | tee -a /etc/apt/sources.list.d/handbrake.list
echo "deb-src http://ppa.launchpad.net/stebbins/handbrake-releases/ubuntu oneiric main" | tee -a /etc/apt/sources.list.d/handbrake.list

## External Repository Keys
wget -q http://packages.medibuntu.org/medibuntu-key.gpg -O- | apt-key add -
wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O- | apt-key add -
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com CEC45805 #Emacs24
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 4E5E17B5 #Chromium PPA
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 5044912E #Dropbox
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 4BB9F05F #SABnzbd
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 816950D8 #Handbrake

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


##
## SuperUser Setup
##

## User Management
print_log "User management"
usermod -a -G sudo $SUPER_USER
usermod -a -G adm $SUPER_USER
usermod -a -G www-data $SUPER_USER

## Mail Aliases
echo "root: root,$SUPPORT_EMAIL" | tee -a /etc/aliases
echo "$SUPER_USER: $SUPER_USER,$SUPER_USER@$SERVER_DOMAIN" | tee -a /etc/aliases
newaliases

## Housekeeping
mkdir /home/$SUPER_USER/bin
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/bin
# Groups
addgroup subversion
usermod -a -G www-data $SUPER_USER
usermod -a -G vboxusers $SUPER_USER
usermod -a -G subversion $SUPER_USER
usermod -a -G subversion www-data

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
update-alternatives --config java
update-alternatives --config x-www-browser
ln -s /usr/lib/jvm/java-7-openjdk-amd64/ /usr/lib/java

## Hostname
print_log "HostName configuration"
#echo "$SERVER_NAME.$SERVER_DOMAIN" | tee /etc/hostname
echo "$SERVER_NAME" | tee /etc/hostname
hostname -F /etc/hostname

## DNS Name Servers
print_log "DNS Configuration"
sed -i '1i\
nameserver 8.8.8.8\
nameserver 8.8.4.4' /etc/resolv.conf
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
    -e "s/^dc_hide_mailname='.*'/dc_hide_mailname='false'/"  /etc/exim4/update-exim4.conf.conf
echo "$SERVER_NAME.$SERVER_DOMAIN" | tee /etc/mailname
echo "*:$MAILER_EMAIL:$MAILER_PASSWORD" | tee -a /etc/exim4/passwd.client
unset MAILER_PASSWORD
update-exim4.conf
service exim4 restart
# Sending Test Email
echo "Hello World! From $USER on $(hostname) sent to $SUPER_USER" | mail -s "Hello World from $(hostname)" $SUPER_USER

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

# Local & work directories
mkdir -p /home/$SUPER_USER/work/eclipse/api
mkdir -p /home/$SUPER_USER/.ssh
mkdir -p /home/$SUPER_USER/svn
mkdir -p /home/$SUPER_USER/bin
mkdir -p /home/$SUPER_USER/src
mkdir -p /home/svn
mkdir -p /home/www

# Updates to .bashrc
print_log "SuperUser bashrc updates"
sed -i 's/#alias \(.*\)grep=/alias \1grep=/g' /home/$SUPER_USER/.bashrc
sed -i -e 's/\#force_color_prompt=/force_color_prompt=/' -e '/unset color_prompt force_color_prompt/i\
\n# Change prompt color for remote users\
if [ -n \"\$SSH_CLIENT\" ]; then\
    PS1='\''\${debian_chroot:+(\$debian_chroot)}\\[\\033[01;31m\\]\\u@\\h:\\[\\033[01;31m\\]\\w >\\[\\033[00m\\] '\''\
fi' /home/$SUPER_USER/.bashrc
cat src/dot.bashrc >> /home/$SUPER_USER/.bashrc

# Create a local SSH config file for hosts
touch /home/$SUPER_USER/.ssh/authorized_keys
chmod 600 /home/$SUPER_USER/.ssh/authorized_keys
chmod 700 /home/$SUPER_USER/.ssh
#TODO:.ssh/config file

# Make GnuPG to use SHA2 in preference to SHA1
gpg --version &> /dev/null
echo "" >> ~/.gnupg/gpg.conf
echo "# Use SHA2 in preference to SHA1" >> ~/.gnupg/gpg.conf
echo "personal-digest-preferences SHA256" >> ~/.gnupg/gpg.conf
echo "cert-digest-algo SHA256" >> ~/.gnupg/gpg.conf
echo "default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed" >> ~/.gnupg/gpg.conf

# Nano Syntax Highlight
find /usr/share/nano/ -name "*.nanorc" -print | sed -e 's/^\(.*\)$/include "\1"/g' >> /home/$SUPER_USER/.nanorc

# Fix Ownership
chown $SUPER_USER:$SUPER_USER /home/$SUPER_USER/.bashrc
chown $SUPER_USER:$SUPER_USER /home/$SUPER_USER/.nanorc
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/work
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/.ssh
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/bin
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/svn
chown -R $SUPER_USER:$SUPER_USER /home/$SUPER_USER/src
chown -R www-data:www-data /home/www
chown -R www-data:subversion /home/svn

##
## Desktop Preferences
##
print_log "Desktop Preferences"
print_prompt

# Disable Guest Login
cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.default
echo "allow-guest=false" | tee -a /etc/lightdm/lightdm.conf
service lightdm restart


##
## Clean-up
##
print_log "Repository Cache Cleanup"
apt-get clean; apt-get autoclean; apt-get autoremove
rmdir ~/Documents/ ~/Downloads/ ~/Music/ ~/Pictures/ ~/Public/ ~/Templates/ ~/Videos/
rm ~/examples.desktop
