#!/bin/bash
set -xe

function get_github_latest_release() {
	ver=$(curl --silent "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    wget "https://github.com/$1/releases/download/$ver/$2-$ver.$3"
    echo $ver
}

install_binary() {
    binpath=/usr/bin/$1
    mv $1           $binpath
    chown root:root $binpath
    chmod 0500      $binpath
    chattr +i       $binpath
    sha256sum       $binpath >> hashes.txt
}

install_service(){
	install_binary $1
	service_file=/etc/systemd/system/$1.service
	cp services/$1.service $service_file
	chattr +i              $service_file
    sha256sum              $service_file >> hashes.txt
	systemctl enable --now $1
}

function service_dnsproxy(){
	echo "Installing DNS Service"
	ver=$(get_github_latest_release AdguardTeam/dnsproxy dnsproxy-linux-amd64 tar.gz)
	tar xvf dnsproxy-linux-amd64-$ver.tar.gz 
	mv linux-amd64/dnsproxy dnsproxy
	install_service dnsproxy
	rm -rf linux-amd64
	echo '127.0.0.1' > /etc/resolv.conf
	chattr +i /etc/resolv.conf
	echo "Fully applied dnsproxy"
}
#groups wireshark libvirt video kvm
#rkhunter ufw dhcpcd macchanger kismet usbguard tlp-rdw
#iwd.config (macc)
#archstrike
#/etc
#dotfiles
