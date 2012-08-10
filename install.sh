#!/bin/sh

set -e

#pushd /etc && git commit -asm "pre-inaes-hack-install commit"; popd

# samba: install and join domain
cp samba/smb.conf /etc/samba/smb.conf
# net ads join

# ntp: stay on time
cp ntp/ntp.conf /etc/ntp.conf
/etc/init.d/ntp restart

# glib: some handy defaults
cp glib-2.0/* /usr/share/glib-2.0/schemas/
glib-compile-schemas /usr/share/glib-2.0/schemas/

# gdm3: greeter
cp -r gdm3/* /etc/gdm3/
/etc/init.d/gdm3 force-reload

# applications: ugly hacks to get windows apps runing
cp *.desktop /usr/share/applications/
chmod +x *.sh
cp hack*.sh /usr/bin/

# pam/nss: log in to windows domain
cp -r pam/*  /etc/
cp  nsswitch.conf /etc/

# plymouth: boot theme
cp -a plymouth/* /usr/share/plymouth/themes/
plymouth-set-default-theme -R inaes
perl -pi -e 'm/^\s*GRUB_CMDLINE_LINUX_DEFAULT.*splash.*\"/ || s/^(\s*GRUB_CMDLINE_LINUX_DEFAULT.*)\"\S*$/\1 splash\"/' /etc/default/grub
update-grub

# nfs: mount /home
nfsip="172.5.30.1"
grep nfshome /etc/hosts || echo "$nfsip nfshome" >> /etc/hosts
if grep nfshome /etc/fstab; then
	echo "nfshome already configured" 
else
	perl -pi -e 's,^(.*\s+/home\s+.*)$,#removedbyhack# \1,' /etc/fstab
	echo "nfshome:/home /home nfs defaults 0 0" >> /etc/fstab
fi
umount /home || true
mount /home

#pushd /etc && git commit -asm "post-inaes-hack-install commit"; popd
