#!/bin/sh

set -e

pushd /etc && git commit -asm "pre-inaes-hack-install commit"; popd

# glib: some handy defaults
cp glib-2.0/* /usr/share/glib-2.0/schemas/
glib-compile-schemas /usr/share/glib-2.0/schemas/

# gdm3: greeter
cp gdm3/* /etc/gdm3/
/etc/init.d/gdm3 restart

# applications: ugly hacks to get windows apps runing
cp *.desktop /usr/share/applications/
chmod +x *.sh
cp hack*.sh /usr/bin/
cp -r pam/*  /etc/
cp  ntsswitch.conf /etc/
# plymouth: boot theme
cp -a plymouth/* /usr/share/plymouth/themes/
plymouth-set-default-theme -R inaes
perl -pi -e 'm/^\s*GRUB_CMDLINE_LINUX_DEFAULT.*splash.*\"/ || s/^(\s*GRUB_CMDLINE_LINUX_DEFAULT.*)\"\S*$/\1 splash\"/' /etc/default/grub
update-grub

pushd /etc && git commit -asm "post-inaes-hack-install commit"; popd
