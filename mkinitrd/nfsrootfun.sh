#!/bin/bash
############################################################################
# Copyright (C) 2007 Lawrence Livermore National Security, LLC
# Produced at Lawrence Livermore National Laboratory.
# Written by Jim Garlick <garlick@llnl.gov>.
# UCRL-CODE-235119
# 
# This file is part of nfsroot, a network root file system utility.
# 
# nfsroot is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# nfsroot is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along
# with nfsroot; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA.
############################################################################
# You should set prog before sourcing nfsrootfun.sh
if [ -z "${prog}" ]; then
   prog=unknown
fi

# List modules that specified module depends on
#   Usage: nrf_depmod modpath
nrf_depmod ()
{
   modinfo $1 | awk '/depends/ {gsub(",", " "); sub($1 FS FS "*",""); print}'
   return $?
}

# Test if module is loaded
#   Usage: nrf_modloaded modname
nrf_modloaded ()
{
   lsmod | grep -q "^$1[[:space:]]"
   return $?
}

# Load a module and its dependencies
#   Usage: nrf_modprobe moddir modname [options]
nrf_modprobe () 
{
   local moddir=$1 mod=$2
   shift;shift
   local modpath dep opts=$*
   local retval=0

   modpath=$(find ${moddir} -name ${mod}.ko)
   if [ -z "$modpath" ]; then
      echo "${prog}: module ${mod} not found" >&2
      retval=1
   else
      # ignore any errors loading dependent modules and let insmod fail below
      for dep in $(nrf_depmod $modpath); do
         nrf_modprobe $moddir $dep 
      done
      if ! nrf_modloaded $mod; then
         insmod $modpath $opts
         retval=$?
      fi   
   fi
   return $retval
}

# Return mac address of specified device
#   Usage: nrf_mac2eth ethN
nrf_eth2mac () 
{
   ifconfig $1 | awk '/HWaddr/ {print $NF}'
   return $?
}

# Return device associated with specified mac address
#   Usage: nrf_eth2mac mac
nrf_mac2eth ()
{
   ifconfig -a | awk "/$1/ {print \$1}"
   return $?
}

# Extract boot mac address from 'BOOTIF' environment var/kernel param.
#   Usage: nrf_bootmac
nrf_bootmac ()
{
   # Format is BOOTIF=01-xx-xx-xx-xx-xx-xx (leading 01 indicates ethernet hw)
   if [ -z "${BOOTIF}" ]; then
      . /proc/cmdline
   fi
   if [ -z "${BOOTIF}" ]; then
      echo "${prog}: BOOTIF is not set" >&2
      return 1
   fi
   if [ ${#BOOTIF} != 20 ]; then
      echo "${prog}: BOOTIF was truncated" >&2
      return 1
   fi 
   echo ${BOOTIF} | awk '{sub(/^01-/, ""); gsub(/-/, ":"); print toupper($0)}'
   return 0
}

# Query dhcp server for eth0 and set ipconf_ env variables.
# Requires /var/run, /var/lib/dhcp.
#   Usage: nrf_dhcp
nrf_ipconf_dhcp ()
{
   local request=root-path,subnet-mask,broadcast-address,host-name,routers
   local pidfile=/var/run/dhclient.pid
   local line
   local try=0
  
   while [ -z "${ipconf_ip_address}" ]; do
      try=$(($try+1))
      if [ $try -gt 5 ]; then
         echo "${prog}: aborting DHCP request after $(($try-1)) tries" >&2
         return 1
      fi
      if [ $try -gt 1 ]; then
         sleep 10
         echo "${prog}: retrying DHCP request (try ${try})" >&2
      fi
      for line in $(dhclient -q -sf /bin/printenv -R $request eth0); do
         local key=$(echo $line | awk -F= '{print $1}')
         local val=$(echo $line | awk -F= '{print $2}')
         case ${key} in
            new_ip_address)
   	       export ipconf_ip_address=$val
               ;;
            new_subnet_mask)
               export ipconf_subnet_mask=$val
               ;;
            new_root_path)
               export ipconf_root_path=$val
               ;;
            new_routers)  # XXX handle more than one
               export ipconf_router=$val
               ;;
            new_host_name)
               export ipconf_hostname=$val
               ;;
            new_broadcast_address)
               export ipconf_broadcast=$val
               ;;
            new_network_number|new_dhcp_server_identifier) # ignore
               ;;
         esac
      done
      [ -f ${pidfile} ] && kill -15 $(< ${pidfile}) >/dev/null 2>&1
   done
   for line in $(printenv | grep ipconf_); do
      echo "$prog: $line" >&2
   done
   return 0  
}

# Mount an nfs partition, retrying forever
#   Usage: nrf_mount server:path mountpt options
nrf_nfsmount ()
{
   if [ ! -d $2 ]; then
      echo "${prog}: mount point $2 does not exist" >&2
   else 
      while ! grep -q $1 /proc/mounts ; do
         mount -n -t nfs -o $3 $1 $2
         grep -q $1 /proc/mounts || sleep 10
      done
   fi
   return 0
} 

# List kernel modules for all nics present in pci space
#   Usage: nrf_ethmods moddir driver [driver ...]
nrf_ethmods ()
{
   local pcimap mod map vd slots

   pcimap=$1/modules.pcimap
   if ! [ -r ${pcimap} ]; then
      echo "${prog}: could not read ${pcimap}" >&2
      return 1
   fi
   shift
   for mod in $*; do
      slots=""
      for map in $(awk "/^${mod} / { print \$2 \":\" \$3 }" ${pcimap}); do
         vd=$(echo ${map} | sed -e 's/0x0000//g') # vendor:device
         if lspci -n | grep -q ${vd}; then
            slots=$(echo ${slots} $(lspci -n | grep ${vd} | cut -d' ' -f1))
         fi
      done
      if [ -n "${slots}" ]; then
         echo "${prog}: found ${mod} device(s) at ${slots}" >&2
         echo ${mod}
      fi
   done
   return 0
}
   
# List all nics using /proc/net/dev
#   Usage: nrf_ethdevs
nrf_ethdevs ()
{
   echo $(awk '/eth.*:/ {sub(/:.*/, ""); print $1}' /proc/net/dev)
   return $?
}

# Reorder eth devices so eth0 has the requested mac address.
#   Usage: nrf_fixeth0 mac
nrf_fixeth0()
{
   local oldeth=$(nrf_mac2eth $1)
   if [ -z "${oldeth}" ]; then
      echo "${prog}: no ethernet device has MAC address $1" >&2
      return 1
   fi
   if [ "${oldeth}" != "eth0" ]; then
      # assumes eths are assigned sequentially from zero
      local -a ethdevs=($(nrf_ethdevs)) || return 1
      local tmpeth="eth${#ethdevs[*]}"

      echo "${prog}: eth0->${tmpeth}" >&2
      nameif ${tmpeth} $(nrf_eth2mac eth0) || return 1

      echo "${prog}: ${oldeth}->eth0" >&2
      nameif eth0 $1 || return 1

      echo "${prog}: ${tmpeth}->${oldeth}" >&2
      nameif ${oldeth} $(nrf_eth2mac $tmpeth) || return 1
   else
      echo "${prog}: eth0 came up with the right mac address" >&2
   fi
   return 0
}

# Discover cdrom device
#   Usage: nrf_findcdrom
nrf_findcdrom ()
{
   local dev

   # usb
   if [ -d /proc/scsi/usb-storage ]; then
      echo /dev/scd0
      return 0
   fi
   # ide
   for dev in $(find /proc/ide -type l); do
      if grep -q cdrom ${dev}/media; then
         echo /dev/$(basename $dev)
         return 0
      fi
   done
   return 1
}

# Install named kernel modules and dependencies
#   Usage: nrf_copykmod imanrfr srcmoddir mod [mod...]
nrf_copykmod ()
{
   local imanrfr=$1 srcmoddir=$2
   local dep module destmoddir=$imanrfr/lib/modules
   shift; shift

   for module in $*; do
      if ! [ -f ${destmoddir}/${module}.ko ]; then
         find ${srcmoddir} -name "${module}.ko" -exec install {} $destmoddir \;
         if [ -f ${destmoddir}/${module}.ko ]; then
            for dep in $(nrf_depmod ${destmoddir}/${module}.ko); do
               nrf_copykmod ${imanrfr} ${srcmoddir} ${dep}
            done
         else
            echo "${prog}: warning: ${module} not found" >&2
         fi
      fi
   done 
   return 0
}

# Create initramfs with directory structure.  Echo name to stdout.
# Set the TMPDIR environment variable to influence mktemp behavior.
#   Usage: nrf_createrd
nrf_createrd ()
{
   local i destdir

   if [ $(id -u) != 0 ]; then
      echo "${prog}: root is required to run mknod" >&2
      return 1
   fi

   destdir=$(mktemp -t -d initrd.XXXXXX)
   if [ -n "$destdir" ]; then
      mkdir -p $destdir/bin
      mkdir -p $destdir/etc
      mkdir -p $destdir/var/lib/dhcpd
      mkdir -p $destdir/var/run
      mkdir -p $destdir/dev
      mkdir -p $destdir/lib/modules
      mkdir -p $destdir/proc
      mkdir -p $destdir/sys
      mkdir -p $destdir/sysroot
      mkdir -p $destdir/mnt
      ln -s bin $destdir/sbin
      ln -s lib $destdir/lib64

      mknod $destdir/dev/console c 5 1
      mknod $destdir/dev/null c 1 3
      mknod $destdir/dev/ram b 1 1
      for i in $(seq 0 4) ; do
         mknod $destdir/dev/tty$i c 4 $i
      done
      ln -s tty0 $destdir/dev/systty
      mknod $destdir/dev/hda b 3 0
      mknod $destdir/dev/hdb b 3 64
      mknod $destdir/dev/hdc b 22 0
      mknod $destdir/dev/hdd b 22 64
      mknod $destdir/dev/scd0 b 11 0
   fi

   echo $destdir
   return 0
}

# Copy an executable and shared libraries it needs
#   Usage: nrf_copyexec imanrfr bin [bin...]
nrf_copyexec ()
{
   local destbin=$1/bin destlib=$1/lib
   local name bin lib
   shift

   mkdir -p $destbin $destlib
   for name in $* ; do
      bin=$(which $name 2>/dev/null | tail -1)
      if [ -z "$bin" ] ; then
         echo "${prog}: warning: $name not found" >&2
      else
         install $bin $destbin
         if ( file $bin | grep -qv statically ) ; then
            for lib in $(ldd $bin | grep -v "not a dynamic executable" | awk -F"=> " '{print $NF}' | sed "s/ (.*//" | sort | uniq) ; do
               name=`basename $lib`
               if ! [ -f $destlib/$name ]; then
                  if ! [ -f $lib ]; then
                     echo "${prog}: warning: $name not found" >&2
                  else
                     install $lib $destlib
                  fi
               fi
           done
        fi
      fi
   done
   return 0
}

# Copy file to image and make executable.
#   Usage: nrf_copyfile imanrfr srcfile dstfile
nrf_copyfile ()
{
   imanrfr=$1 srcfile=$2 dstfile=$3

   install ${srcfile} ${imanrfr}/${dstfile}
   chmod +x ${imanrfr}/${dstfile}
   return $?
}

# Create 'init.cfg' for init to source.
# Each line consists of key=value pairs passed in as arguemnts.
#   Usage: nrf_configrd imanrfr key=val [key=val...]
nrf_configrd ()
{
   local cfgfile=$1/init.cfg
   shift

   echo "# This file was created by nrf_configrd" >$cfgfile
   while [ $# -gt 0 ]; do
      echo "$1" >>$cfgfile
      shift
   done
   return 0
}

# Create initramfs image from imanrfr, and remove imanrfr (unless -n)
#   Usage: nrf_completerd [-n] imagedir outfile
nrf_completerd ()
{
   local noremove
   if [ "$1" = "-n" ]; then
      noremove=true
      shift
   fi
   local ret bytes imagedir=$1 outfile=$2

   (cd ${imagedir} && find . | cpio --quiet -c -o -B) | gzip > ${outfile}
   ret=$?
   if [ $ret != 0 ] || [ -n "$noremove" ] ; then
      echo "${prog}: keeping $imagedir intact" >&2
   else
      rm -rf $imagedir
   fi
   bytes=$(stat -c "%s" ${outfile})
   echo "${prog}: ${outfile}: $(($bytes/1048576))MB." >&2

   return $ret
}
