#!/bin/bash

PWD=`pwd`

# Copies .gitconfig
if [ -f ~/.gitconfig ];
then
	rm ~/.gitconfig
fi

ln -s $PWD/gitconfig ~/.gitconfig
ln -s ~/Dropbox/Pictures/Git\ Shots ~/.gitshots

# Installs my git hooks
sudo ln -s $PWD/git/hooks/post-commit /usr/local/share/git-core/templates/hooks/post-commit

if [ `uname` == 'Darwin' ];
then
	# Installs Homebrew
	if [ `which brew` == '' ];
	then
		ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
		mkdir -p ~/Library/LaunchAgents
	fi

	# Gets our `brew` on
	brew install bash-completion git htop imagemagick imagesnap macvim memcached multitail mysql nginx nmap redis ssh-copy-id wget flex_sdk

	cp /usr/local/Cellar/memcached/1.4.14/homebrew.mxcl.memcached.plist ~/Library/LaunchAgents/
	launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.memcached.plist

	cp /usr/local/Cellar/mysql/5.5.27/homebrew.mxcl.mysql.plist ~/Library/LaunchAgents/
	launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

	# Initializes MySQL
	mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp

	# `brew`s up some PHP 5.3
	brew tap josegonzalez/homebrew-php
	brew tap homebrew/dupes

	# Backs up the stock OSX version of PHP
	if [ ! -f /usr/libexec/apache2/libphp5.so.orig ];
	then
		sudo mv /usr/libexec/apache2/libphp5.so /usr/libexec/apache2/libphp5.so.orig
	fi

	brew remove php53

	# Installs PHP as an Apache module
	brew install php53 --with-mysql
	sudo cp /usr/local/Cellar/php53/5.3.16/libexec/apache2/libphp5.so /usr/libexec/apache2/libphp5.so
	brew remove php53

	# Installs PHP for Nginx (via FPM)
	brew install php53 --with-fpm --with-mysql
	cp /usr/local/Cellar/php53/5.3.16/homebrew-php.josegonzalez.php53.plist ~/Library/LaunchAgents/
	launchctl load -w ~/Library/LaunchAgents/homebrew-php.josegonzalez.php53.plist

	# Gets PHP how we like it
	brew install php53-apc php53-imagick php53-mcrypt php53-memcache

	# Clears out the old .bash_profile
	if [ -f ~/.bash_profile ];
	then
		rm ~/.bash_profile
	fi

	# Adds paths and custom .bashrc
	echo "
export PATH=\"$PWD/git/scripts:/usr/local/Cellar/flex_sdk/4.6.0.23201/libexec/bin:$PATH\"

if [ -f $PWD/bashrc ] && ! shopt -oq posix;
then
	. $PWD/bashrc
fi

if [ -f `brew --prefix`/etc/bash_completion ];
then
	. `brew --prefix`/etc/bash_completion
fi
" >> ~/.bash_profile

else
	# TODO Add prompts so I can run pieces of the set up

	# Adds some third party repos
	sudo add-apt-repository ppa:tiheum/equinox          # Faenza Icons
	sudo add-apt-repository ppa:tualatrix/ppa           # Ubuntu Tweak
	sudo add-apt-repository ppa:webupd8team/gnome3      # WebUpd8 Gnome Extensions
	sudo add-apt-repository ppa:otto-kesselgulasch/gimp # Gimp 2.8

	# Updates the package list
	sudo apt-get update

	# Gets rid of some bullshit packages
	#sudo apt-get --purge autoremove appmenu-gtk appmenu-gtk3 zeitgeist gwibber gnome-screensaver banshee

	# Installs CLI apps
	sudo apt-get install vim ssh multitail htop iotop tmux

	# Installs desktop environment
	sudo apt-get install gnome-shell gnome-tweak-tool faenza-icon-theme network-manager-openconnect-gnome gnome-sushi gnome-shell-extensions-mediaplayer gnome-shell-extensions-noa11y gnome-shell-classic-systray gnome-shell-message-notifier gnome-shell-extension-notesearch

	# Installs non-CLI apps
	sudo apt-get install gnome-agave gimp inkscape tomboy rhythmbox chromium-browser shutter ubuntu-tweak vim-gnome

	# Installs my dev stack
	sudo apt-get install git-core ruby1.8-dev nginx apache2 php5 php5-cgi php5-cli php-pear php5-suhosin psmisc spawn-fcgi mysql-server php5-mysql redis-server memcached php5-memcache php5-memcached php5-gd php5-curl php5-imagick exim4-daemon-light

	# TODO Installs my server stack

	# Configures some stuff
	sudo a2enmod expires rewrite ssl
	sudo service apache2 restart

	# Clears out the old .bashrc
	if [ -f ~/.bashrc ];
	then
		rm ~/.bashrc
	fi

	# Grabs the skeleton .bashrc
	cp /etc/skel/.bashrc ~/.bashrc

	# Adds paths and custom .bashrc
	echo "
export PATH=\"$PWD/git/scripts:$PATH\"

if [ -f $PWD/bashrc ] && ! shopt -oq posix; then
	. $PWD/bashrc
fi" >> ~/.bashrc

	# Removes the existing scripts
	if [ -d ~/.gnome2/nautilus-scripts ];
	then
		rm ~/.gnome2/nautilus-scripts -rf
	fi

	# Symlinks back to our scripts
	ln -s $PWD/nautilus-scripts ~/.gnome2/nautilus-scripts
fi

./vim.sh

echo; echo "SETUP COMPLETE!!~!"
