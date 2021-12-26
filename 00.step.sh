#!/usr/bin/env bash

BASEDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

ENVFILE=$BASEDIR/environment
source $ENVFILE
cat $ENVFILE

echo ""

timedatectl set-ntp true
loadkeys la-latin1

pacman -Syy

lsblk

sgdisk --zap-all $ARCH_DEVICE

sgdisk -n 1:0:+256M -t 1:ef00 -c 1:partition1 $ARCH_DEVICE
sgdisk -i 1 $ARCH_DEVICE

sgdisk -n 2:0:0 -t 2:8e00 -c 2:partition2 $ARCH_DEVICE
sgdisk -i 2 $ARCH_DEVICE

lsblk

sync && sleep 5

ARCH_DEVICE1=$(readlink -f /dev/disk/by-partlabel/partition1 2>&1)
ARCH_DEVICE2=$(readlink -f /dev/disk/by-partlabel/partition2 2>&1)

rm -rf $BASEDIR/environment.partitions
echo "ARCH_DEVICE1=$ARCH_DEVICE1" >> $BASEDIR/environment.partitions
echo "ARCH_DEVICE2=$ARCH_DEVICE2" >> $BASEDIR/environment.partitions
cat $BASEDIR/environment.partitions

cryptsetup luksFormat $ARCH_DEVICE2

cryptsetup open $ARCH_DEVICE2 $ARCH_PVNAME

pvcreate /dev/mapper/$ARCH_PVNAME
vgcreate $ARCH_VGNAME /dev/mapper/$ARCH_PVNAME
lvcreate -l 100%FREE $ARCH_VGNAME -n $ARCH_LVNAME

lsblk

mkfs.fat -F32 $ARCH_DEVICE1
mkfs.ext4 /dev/$ARCH_VGNAME/$ARCH_LVNAME

mount /dev/$ARCH_VGNAME/$ARCH_LVNAME /mnt
mkdir -p /mnt/boot
mount $ARCH_DEVICE1 /mnt/boot

pacstrap /mnt \
         base base-devel cups dmenu efibootmgr \
         emacs firefox git grub iwd libxss \
         linux linux-firmware linux-headers \
         lvm2 maim mesa nitrogen openssh os-prober picom \
         reflector stow vim \
         xclip xorg-server xorg-apps xorg-xinit xorg-xmessage xorg-xauth \
         pkgconf libx11 libxft libxinerama libxrandr libxss

genfstab -U /mnt >> /mnt/etc/fstab

rsync -avP $BASEDIR /mnt/bootstrap
         
