#!/bin/sh

apt update && apt upgrade && \
apt install -y \
	ffmpeg \
	lua5.3 \
	nginx \
	npm \
	tmux \
	vim


# Maria (10.4)

## import key
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64] http://mariadb.nethub.com.hk/repo/10.4/ubuntu eoan main'

## install server
apt update
apt install mariadb-server

## initialise database with init.sql


# Node.js (13.x)
# https://github.com/nodesource/distributions/blob/master/README.md#debian-and-ubuntu-based-distributions
curl -sL https://deb.nodesource.com/setup_13.x | bash -
sudo apt-get install -y nodejs
npm init -y
## copy/symlink files to locations


# Nginx
# https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04
echo '
# Nginx
deb http://nginx.org/packages/ubuntu/ eoan nginx
deb-src http://nginx.org/packages/ubuntu/ eoan nginx' >> /etc/apt/sources.list
apt update
apt install nginx
## Adjust Firewall
## copy/symlink config files
## run at start up

# Set up MariaDB
# https://linuxize.com/post/how-to-install-mariadb-on-ubuntu-18-04/
## config to use socket (in node.js, though)

