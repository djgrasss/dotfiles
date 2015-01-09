#!/bin/bash

[ $(echo -e 'YES\nNO' | dmenu -sb '#ff6600' -fn \
'-*-*-*-*-*-*-16-*-*-*-*-*-*-*' -i -p "Do you really want to exit? This \
will end your session") = "YES" ] && i3-msg exit

