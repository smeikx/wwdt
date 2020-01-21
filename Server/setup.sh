#!/bin/sh

apt update && apt upgrade && \
apt install -y \
	lua \
	mariadb \ # consider: https://downloads.mariadb.org/mariadb/repositories/#distro=Ubuntu&distro_release=eoan--ubuntu_eoan&mirror=heanet-ltd&version=10.4
	nginx \
	node \
	tmux \
	vim

# Set up Node.js
## run npm -i
## copy/symlink files to locations

# Set up Nginx
# https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04
## Adjust Firewall
## copy/symlink config files
## run at start up

# Set up MariaDB
# https://linuxize.com/post/how-to-install-mariadb-on-ubuntu-18-04/
## initialise database with init.sql
## config to use socket (in node.js, though)

