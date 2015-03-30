#!/bin/sh

type getarg >/dev/null  >&1 || . /lib/dracut-lib.sh

PATH=/usr/sbin:/usr/bin:/sbin:/bin

[ -z "$1" ] && exit 1
[ -z "$2" ] && exit 1
[ -z "$3" ] && exit 1

# root is in the form root=9nbd:srv:imgpath[:fstype[:rootflags[:nbdopts]]]

# nbdopts:
# keyboot=path will copy keys from srv:path into kernel keyring
# auth=munge will bootstrap munge
# privport works with server export of noauth,privport

netif="$1"
nroot="$2"
NEWROOT="$3"

echo "nroot is $nroot"

# If it's not nbd we don't continue
[ "${nroot%%:*}" = "nbd9" ] || return

nroot=${nroot#nbd9:}
nbdserver=${nroot%%:*}; nroot=${nroot#*:}
nbdpath=${nroot%%:*}; nroot=${nroot#*:}
nbdfstype=${nroot%%:*}; nroot=${nroot#*:}
nbdflags=${nroot%%:*}
nbdopts=${nroot#*:}

if [ "$nbdopts" = "$nbdflags" ]; then
    unset nbdopts
fi
if [ "$nbdflags" = "$nbdfstype" ]; then
    unset nbdflags
fi
if [ "$nbdfstype" = "$nbdpath" ]; then
    unset nbdfstype
fi
if [ -z "$nbdfstype" ]; then
    nbdfstype=auto
fi

echo "nbdserver is $nbdserver"
echo "nbdpath os $nbdpath"


# look through the flags and see if any are overridden by the command line
# FIXME: rewrite!
nbdflags=${nbdflags},
while [ -n "$nbdflags" ]; do
    f=${nbdflags%%,*}
    nbdflags=${nbdflags#*,}
    if [ -z "$f" ]; then
        break
    fi
    if [ "$f" = "ro" -o "$f" = "rw" ]; then
        nbdrw=$f
        continue
    fi
    fsopts=${fsopts:+$fsopts,}$f
done

getarg ro && nbdrw=ro
getarg rw && nbdrw=rw
fsopts=${fsopts:+$fsopts,}${nbdrw}

# XXX better way to wait for the device to be made?
i=0
while [ ! -b /dev/9nbd0 ]; do
    [ $i -ge 20 ] && exit 1
    if [ $UDEVVERSION -ge 143 ]; then
        udevadm settle --exit-if-exists=/dev/9nbd0
    else
        sleep 0.1
    fi
    i=$(($i + 1))
done

# Handle keyboot=path
# Load everything present in path (base64'ed) into the kernel keyring 
# Presumes path is exported with noauth,privport
keyboot() {
    local srv=$1
    local dir=$2
    local key

    for key in `diodls -p -s $srv -a $dir`; do
        diodcat -p -s $srv -a $dir $key | base64 | keyctl padd user $key @u
    done
}

# Handle auth=munge
# The purpose is to be able to use auth=munge with 9nbd
# Presumes keyboot with a key named munge.key
# This whole mess can be avoided by simply exporting root with noauth,privport
mungeboot() {
    local srv=$1
    local keyid=`keyctl search @u user munge.key`

    keyctl pipe $keyid | base64 -d >/tmp/munge.key
    chmod 600 /tmp/munge.key
    mkdir -p /var/run/munge /var/lib/munge /var/log/munge
    dioddate -S -s $srv # avoid rewound cred errors
    munged --key /tmp/munge.key
    echo "create user munge * |/usr/bin/munge" >/etc/request-key.conf
}

# Parse nbdopts and find any that require special handling
for arg in `arg_split $nbdopts ,`; do
    case $arg in 
        keyboot=*) # FIXME: delete arg from $nbdopts as it isn't one
            keyboot $nbdserver `arg_n $arg = 1`
            ;;
        auth=munge)
            mungeboot $nbdserver
            ;;
    esac     
done


# If we didn't get a root= on the command line, then we need to
# add the udev rules for mounting the nbd0 device
# New way
if [ "$root" = "block:/dev/root" -o "$root" = "dhcp" ]; then
    printf 'KERNEL=="9nbd0", ENV{DEVTYPE}=="disk", ENV{MAJOR}=="252", ENV{MINOR}=="0", SYMLINK+="root"\n' >> /etc/udev/rules.d/99-nbd9-root.rules
    udevadm control --reload
    type write_fs_tab >/dev/null 2>&1 || . /lib/fs-lib.sh
    write_fs_tab /dev/root "$nbdfstype" "$fsopts"
    wait_for_dev -n /dev/root

    if [ -z "$DRACUT_SYSTEMD" ]; then
        printf '/bin/mount %s\n' \
             "$NEWROOT" \
             > $hookdir/mount/01-$$-9nbd.sh
    fi
fi

echo "mount.diod --9nbd-attach $nbdserver:$nbdpath /dev/9nbd0"
mount.diod --9nbd-attach $nbdserver:$nbdpath /dev/9nbd0 || exit 1

# NBD doesn't emit uevents when it gets connected, so kick it
echo change > /sys/block/9nbd0/uevent
udevadm settle
need_shutdown
exit 0
