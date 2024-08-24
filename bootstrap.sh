#!/bin/bash
set -xe

#   #   #
#=======#
#=|=|=|=#
 #=#=#=#
  #=#=#
  ##=##
  #####


lock_file(){
    file=$1
    chattr +i $file
    sha256sum $file >> hashes.txt
}

install_base(){	
	apk update
	setup-xorg-base

	apk add virt-manager libvirt libvirt-daemon libvirt-daemon-openrc qemu qemu-modules qemu-system-x86_64 qemu-img

	apk add dbus polkit
	apk add pulseaudio pulseaudio-openrc pavucontrol
	apk add i3wm i3status i3lock dmenu xterm font-terminus feh
	apk add lightdm lightdm-gtk-greeter
	apk add xf86-video-amdgpu xf86-video-nouveau
	apk add xf86-input-evdev  xf86-input-synaptics xf86-input-libinput xf86-input-mtrack
	apk add tlp-rdw
	apk add keepassxc
	apk add git go

	rc-update add lightdm
	rc-update add polkit
	rc-update add pulseaudio
	rc-update add libvirtd
	rc-update add dbus
	rc-update add tlp

	addgroup $1 polkit
	addgroup $1 libvirt
	addgroup $1 kvm
	addgroup $1 video
	addgroup $1 audio
	addgroup $1 input
	echo vfio >> /etc/modules # Fuck a jeep in the ass
}

install_binary() {
	echo "install_binary:" $1
    binpath=/usr/bin/$1
    mv $1            $binpath
    chown root:root  $binpath
    chmod 0500       $binpath
    lock_file        $binpath
}

install_service(){
	echo "install_service:"  $1
	install_binary           $1
	service_file=/etc/init.d/$1
	cp services/$1           $service_file
	lock_file                $service_file
	rc-update add            $1
	rc-service               $1 start
}


service_dnsproxy(){
	go install github.com/AdguardTeam/dnsproxy@latest
	mv ~/go/bin/dnsproxy .
	install_service dnsproxy
	echo '127.0.0.1' > /etc/resolv.conf
	lock_file          /etc/resolv.conf
	echo "service_dnsproxy: Success"
}

install_base user # Change user here
service_dnsproxy
