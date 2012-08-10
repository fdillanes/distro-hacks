#!/bin/sh

set -e
set -x

d=`pwd`

if test -z $1; then
	echo "need an argument"
        echo "usage: $0 user"
	return
fi
user=$1

#
./install-all-pkgs.sh

mkdir -p /home/INACYM98

cd /etc/ && git commit -asm "pre-inaes-hack-install commit"; cd $d

# ntp: stay on time
cp ntp/ntp.conf /etc/ntp.conf
/etc/init.d/ntp restart

# pam/nss: log in to windows domain
cp -r pam/*  /etc/
cp  nsswitch.conf /etc/

# samba: install and join domain
cp samba/smb.conf /etc/samba/smb.conf
net ads join -k -U $user

# restart everything
ldconfig
/etc/init.d/samba restart
/etc/init.d/winbind restart

getent passwd xaiki || echo "Warning it looks like I couldn't configure samba !"

# cups
rm -rf /etc/cups/*
cp cups/* /etc/cups
/etc/init.d/cups restart

# glib: some handy defaults
cp glib-2.0/* /usr/share/glib-2.0/schemas/
glib-compile-schemas /usr/share/glib-2.0/schemas/

# gdm3: greeter
cp -r gdm3/* /etc/gdm3/
/etc/init.d/gdm3 force-reload

# applications: ugly hacks to get windows apps runing
cp apps/*.desktop /usr/share/applications/
cp apps/*.png     /usr/share/icons/hicolor/24x24/apps/
chmod +x apps/*.sh
cp apps/hack*.sh /usr/bin/

# plymouth: boot theme
cp -a plymouth/* /usr/share/plymouth/themes/
plymouth-set-default-theme -R inaes
perl -pi -e 'm/^\s*GRUB_CMDLINE_LINUX_DEFAULT.*splash.*\"/ || s/^(\s*GRUB_CMDLINE_LINUX_DEFAULT.*)\"\S*$/\1 splash\"/' /etc/default/grub
update-grub

# nfs: mount /home
#nfsip="172.5.30.1"
#grep nfshome /etc/hosts || echo "$nfsip nfshome" >> /etc/hosts
#if grep nfshome /etc/fstab; then
#	echo "nfshome already configured" 
#else
#	perl -pi -e 's,^(.*\s+/home\s+.*)$,#removedbyhack# \1,' /etc/fstab
#	echo "nfshome:/home /home nfs defaults 0 0" >> /etc/fstab
#fi
#umount /home || true
#mount /home

cd /etc/ && git commit -asm "post-inaes-hack-install commit"; cd $d

echo "all done"
