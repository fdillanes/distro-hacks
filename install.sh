#!/bin/sh

set -e

pushd /etc && git commit -asm "pre-inaes-hack-install commit"; popd
cp glib-2.0/* /usr/share/glib-2.0/schemas/
glib-compile-schemas /usr/share/glib-2.0/schemas/
cp *.desktop /usr/share/applications/
chmod +x *.sh
cp hack*.sh /usr/bin/
cp -r pam/*  /etc/
pushd /etc && git commit -asm "post-inaes-hack-install commit"; popd
