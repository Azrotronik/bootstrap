#!/bin/bash
set -xe

#   #   #
#=======#
#=|=|=|=#
 #=#=#=#
  #=#=#
  ##=##
  #####

get_github_latest_release() {
    ver=$(curl --silent "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
	echo $ver
    wget "https://github.com/$1/releases/download/$ver/$2-$ver.$3"
    echo $ver
}

lock_file(){
    file=$1
    chattr +i $file
    sha256sum $file >> hashes.txt
}

install_binary() {
	echo "install_binary:" $1
    binpath=/usr/bin/$1
    mv $1           $binpath
    chown root:root $binpath
    chmod 0500      $binpath
    lock_file       $binpath
}

install_service(){
	echo "install_service:" $1
	install_binary          $1
	service_file=/etc/systemd/system/$1.service
	cp services/$1.service $service_file
	lock_file              $service_file
	systemctl enable --now $1
}

install_yay(){
	ver=$(get_github_latest_release Jguer/yay tar.gz)
	tar xvf yay_$ver.tar.gz
	
}

service_dnsproxy(){
	ver=$(get_github_latest_release AdguardTeam/dnsproxy dnsproxy-linux-amd64 tar.gz)
	tar xvf dnsproxy-linux-amd64-$ver.tar.gz 
	mv linux-amd64/dnsproxy dnsproxy
	install_service dnsproxy
	rm -rf linux-amd64
	echo '127.0.0.1' > /etc/resolv.conf
	lock_file          /etc/resolv.conf
	echo "service_dnsproxy: Success"
}
#groups wireshark libvirt video kvm
#rkhunter ufw dhcpcd macchanger kismet usbguard tlp-rdw
#wpa_supp+dhcpcd-gtk.config (macc)
#archstrike repo
#/etc
#dotfiles
###ICECAT!!!
