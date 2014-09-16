#Ubuntu Desktop Setup & Configuration Script
As a personal preference, I use the latest [Ubuntu](http://www.ubuntu.com/) [Long Term Support (LTS)](https://wiki.ubuntu.com/LTS) distribution for my desktop environemnt. Since I reproduce this environment on multiple machines (desktop, laptop, work, etc), it is only obvious to automate the process. This setup has been tested on [Ubuntu 14.04 LTS (Trusty Tahr)](http://releases.ubuntu.com/trusty/)

The goal is to setup a full-fledged workstation with applications for development, office productivity, basic photo/audio/video editing and entertainment.

[Canonical](http://www.canonical.com/) does not implement a great deal of changes between LTS releases in the Ubuntu environment. Therefore, you can use this configuration script with any recent release with minimum to no changes.

##TO Check
  1. Check the status of OpenVPN & Network Manager VPN Plugins
  1. https://help.ubuntu.com/community/AcrobatHowTo
  1. http://howtoubuntu.org/things-to-do-after-installing-ubuntu-14-04-trusty-tahr
```
vpnc network-manager-vpnc network-manager-openvpn
```
  1. Ruby version
  1. Dropbox PPA

##PPAs & External Repositories
  + ppa:git-core/ppa
  + ppa:nginx/stable
  + ppa:libreoffice/ppa
  + ppa:stebbins/handbrake-releases &ndash; disabled since [ubuntu official repos](http://packages.ubuntu.com/search?keywords=handbrake have latest version
  + ppa:gnome3-team/gnome3
  + [MongoDB](http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/)
  + [RabbitMQ](http://www.rabbitmq.com/install-debian.html)


Applications
------------
The complete list of packages to be installed are available in the `packages.list` file. Here is a list with the most significant applications and packages:
  + Essential Software & Services: ssh, openssl, build-essential, binutils, sudo, ntp, htop, screen, tmux & linux headers
  + Networking Applications: curl, traceroute, nmap, Filezilla
  + Web Server: nginx, Apache Tomcat (disabled by default)
  + Database Server & Apps: MySQL, MySQL Workbench & MongoDB
  + Application Message Broker: RabbitMQ
  + EMail MTA: Exim Light
  + Programming Languages & Platforms: C/C++, Perl, PHP 5, Python 2.7, Python 3, Ruby, Java (OpenJDK 7)
  + Version Control: Git, Subversion, Mercurial, bzr
  + Text Editors: Vim 7, Emacs, Gedit, Nano
  + IDEs: None (both [Eclipse](http://www.eclipse.org/), [Netbeans](https://netbeans.org/) are out of date in the official repos)
  + Disk Utilities: gParted, Zip, Rar, Ace, Wipe
  + Desktop Apps: LibreOffice, Firefox, Thunderbird, Dropbox, Shutter
  + Google Apps: Chromium, Chrome, Earth
  + Graphics & Photo: Gimp, Inkscape, dia, darktable
  + PDF Support: pdftk
  + Multimedia: ubuntu-restricted-extras et. al., mplayer, audacity, vlc, banshee, openshot, handbrake
  + LaTeX: TeXLive, TeXMaker, Ghost Script
  + Virtualization: Virtual Box
  + Fonts: liberation, arabeyes, ubuntu and MS fonts. Also the script installs Inconsolata & Inconsolata-dz.

Notable Setup Actions
---------------------
The following actions are performed by the script:
+ Set repositories to include:
	* All official main, restricted, universe, multiverse, backport and extra repositories
	* Canonical partner repositories
	* GNOME 3 PPA &ndash; 14.04LTS was shipped with an outdated GNOME
	* NginX PPA
    * Git PPA
    * MongoDB Repository
    * RabbitMQ Repository
	* VideoLan (for dvd playback)
	* Google Linux Repository
	* Virtual Box Repository
	* Dropbox
	* [**disabled**] Ubuntu X Team Updates
	* [**disabled**] Handbrake PPA
+ Install packages in `packages.list`
+ Add `$SUPER_USER` as member of `sudo`, `adm` and `www-data` groups.
+ Create a local [shared] git user account for locally hosted git repositories
+ Set Timezone
+ Set Locale (default is `en_US.UTF-8`)
+ Set iSpell wordlist (default is American English)
+ Hostname
+ DNS (inserting [Google Public DNS](https://developers.google.com/speed/public-dns/) `8.8.8.8`, `8.8.4.4`)
+ SSH Setup
	* Change port to non-standard port number
	* Explicitly add inet interface to `Listen` directive
	* Disable root login
	* Disable password login
	* Disable X11 forwarding
	* Disable PAM & DNS
	* Only allow `$SUPER_USER` to access machine via `ssh`
+ Disable *Guest Login* on greeting screen
+ Make GPG Use SHA256 instead of SHA1

How to Use
----------
Steps 0 & 1 are mainly advise on how to start the setup process. Step 2 is the 
### Step 0 - BACKUP, Backup and backup
As always, you need to backup your current system just in case something goes wrong. I, personally, like to refer to the [3-2-1 Backup Strategy](http://www.michaelcarnell.com/3-2-1-backup/): for each file you should have *3* copies on *2* different storage mediums with at least *1* off-site. 

### Step 1 - Download ISO, Prep & Install
1. Go to [Ubuntu.com](http://www.ubuntu.com/) and download the latest ISO. Unless you have a bad Internet connection, you should download the Desktop Live CD version (not the DVD). The file would be named `ubuntu-XX.XX-desktop-amd64.iso` or `ubuntu-XX.XX-desktop-i386.iso ` where _XX.XX_ is the release number, e.g. 12.04.
1. Create a Boot CD or USB drive from the ISO file. Instructions for:
	+ Boot CD: [Windows](http://www.ubuntu.com/download/help/burn-a-cd-on-windows), [OS X](http://www.ubuntu.com/download/help/burn-a-cd-on-mac-osx) or [Ubuntu](http://www.ubuntu.com/download/help/burn-a-cd-on-ubuntu)
	+ Boot USB Drive: [Windows](http://www.ubuntu.com/download/help/create-a-usb-stick-on-windows), [OS X](http://www.ubuntu.com/download/help/create-a-usb-stick-on-mac-osx) or [Ubuntu](http://www.ubuntu.com/download/help/create-a-usb-stick-on-ubuntu)
1. Boot your machine from your medium of choice and run the live CD. This may be a good time to check if the following are functioning properly in the live CD. If one is not working as expected, don't attempt to install unless you know how to fix it:
	+ Audio
	+ WiFi or Ethernet connection
	+ Proper screen resolution and colors
1. Click on the *Install Ubuntu* icon to start the installation process. You should check the following options:
	+ Download updates while installing
	+ Install this third party software
1. Pay special attention to the *Allocate Drive Space* dialog. Actions performed in this step are irreversible and non-trivial to change afterwards.

### Step 2 - Customize & Run
This script is customizable in terms of specifying machine-specific attributes such as hostname, ssh port, forwarding email, etc. Customization of the desktop is based on variables set in a file named `setup-env.conf`. Once you checkout the code or download it from github, you can run the script as follows:
```bash
# Setup configuration script
cp setup-env.conf.default setup-env.conf

# Edit configuration file to your liking
nano desktop_setup.sh

# Run the main script
chmod 755 desktop_setup.sh
./desktop_setup.sh
```

Non-Repository Applications
---------------------------
A number of important applications and/or platforms are not supported in the official Ubuntu repositories or in a trusted PPA. Therefore, these applications should be downloaded directly from their respective websites.

The [wiki pages](https://github.com/alghanmi/ubuntu-desktop_setup/wiki) for this repository hosts the details for installing and setting up each of these applications. Here is the list of applications:
+ [Eclipse](https://github.com/alghanmi/ubuntu-desktop_setup/wiki/Eclipse-Install-Guide)
+ [Skype](https://github.com/alghanmi/ubuntu-desktop_setup/wiki/Skype-Install-Guide)
+ [TrueCrypt](https://github.com/alghanmi/ubuntu-desktop_setup/wiki/TrueCrypt-Install-Guide)
+ [Android SDK](https://github.com/alghanmi/ubuntu-desktop_setup/wiki/Android-SDK-Install-Guide)
+ [Hulu Desktop](https://github.com/alghanmi/ubuntu-desktop_setup/wiki/Hulu-Desktop-Install-Guide)

Optional System Configurations
------------------------------
Some users may have application or hardware specific configuration options they would like to depoly. Here is a list of the ones I personally worked with also available through the The [wiki pages](https://github.com/alghanmi/ubuntu-desktop_setup/wiki):
+ [SSD Configuration on Linux](https://github.com/alghanmi/ubuntu-desktop_setup/wiki/SSD-Configuration-on-Linux)
+ [Git Server with Web Interface](https://github.com/alghanmi/ubuntu-desktop_setup/wiki/Git-Local-Repository-Setup-Guide)

Whats Next
----------
The following items are a kind of TODO list of what I should add to this script
+ GUI Preferences: the list of changes to the machine that can not be done with the command line
+ Incorporate configuration from my [dotfiles repository](https://github.com/alghanmi/dotfiles.conf)


Whats Missing
-------------

  + Adobe Acrobat 9 reached end of life, as such it was removed from the repository.

License
-------
See the [LICENSE](https://raw.github.com/alghanmi/vps_setup/master/LICENSE) file.
