#!/bin/bash
#      __            __   __       
#|__/ |__) \ /  /\  |__) /  ` |__| 
#|  \ |  \  |  /~~\ |  \ \__, |  | 
#
#Author:Burak Baris
#Website:krygeNNN.github.io


bash /mnt/root/KryArch/banner.sh
echo "-------------------------------------------------"
echo " * Do you want to create a swap partition - y/N ?"
echo "-------------------------------------------------"
read -p ">> " SWP
case $SWP in
    1|y|Y|Yes|YES|yes)
        echo " * Declare the swap partition size. Minimum 512MB, Maximum 8GB Recommended."
        read -p "Enter as MegaBytes >> " SWPMB
        dd if=/dev/zero of=/swapfile bs=1M count=$SWPMB status=progress 
        chmod 600 /swapfile
        mkswap /swapfile
        echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
        swapon -a
esac
clear

cores=$(grep -c ^processor /proc/cpuinfo)
sudo sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=-j${cores}/g" /etc/makepkg.conf 
sudo sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T ${cores} -z -)/g" /etc/makepkg.conf
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 3/' /etc/pacman.conf
sed -i '/#\[multilib\]/s/^#//' /etc/pacman.conf
sed -i '/\[multilib\]/{n;s/^#//;}' /etc/pacman.conf
#'/\[multilib\]/,/Include/s/^#//'
pacman -Sy --noconfirm




echo "-------------------------------------------------"
echo " Downloading and configuring networking packages."
echo "-------------------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable NetworkManager
clear


echo "------------------------------"
echo " * Create a password for root."
echo "------------------------------"
passwd root
clear


echo "------------------------"
echo " * Specify the hostname."
echo "------------------------"
sleep 0.1
read -p "Hostname >> " hostname
echo "hostname='${hostname}'" >> env.conf
clear


echo "-----------------"
echo " * Create a user."
echo "-----------------"
sleep 0.1
read -p "Username >> " username
echo "username='${username}'" >> env.conf
useradd -m -g users -G wheel -s /bin/bash $username 
clear


echo "----------------------------------------"
echo " * Create a password for user $username: "
echo "----------------------------------------"
passwd $username
clear


locale-gen
hwclock --systohc
timedatectl --no-ask-password set-timezone GB
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-keymap us
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
clear


echo "-------------------------------------------"
echo " Installing and setting up GRUB bootloader. "
echo "-------------------------------------------"

pacman -Sy grub efibootmgr dosfstools os-prober mtools --noconfirm --needed
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg
clear


echo "--------------------------------"
echo -e " * Select your CPU manufacturer.\n--------------------------------\n1-AMD\n2-INTEL\n3-Skip"
echo "--------------------------------"
sleep 0.1
read -p ">>" CPU
case $CPU in

  1|AMD|amd|Amd)
    pacman -S amd-ucode --noconfirm 
    ;;

  2|INTEL|intel|Intel)
    pacman -S intel-ucode --noconfirm
    ;;
  *)
    echo "Skipping..."
    ;;
esac
clear


echo "--------------------------------"
echo -e " * Select your GPU manufacturer.\n--------------------------------\n1-AMD or INTEL\n2-NVIDIA\n3-VM\n4-Skip"
echo "--------------------------------"
sleep 0.1
read -p ">>" GPU
case $GPU in

  1|AMD|amd|Amd|Intel|INTEL|intel)
    pacman -S mesa xorg-server --noconfirm 
    ;;

  2|NVIDIA|nvidia|Nvidia)
    pacman -S nvidia xorg-server --noconfirm
    ;;
  3|vm|VM|Vm)
    pacman -S virtualbox-guest-utils xf86-video-vmware xorg-server --noconfirm
    clear
    echo "-----------------------------------"
    echo " * Are you using VirtualBox - y/N ?"
    echo "-----------------------------------"
    read -p ">> " inpt
    if [[ $inpt == "y" ]]
    then
        systemctl enable vboxservice
    fi
    ;;
  *)
    echo "Skipping..."
    ;;
esac
clear
