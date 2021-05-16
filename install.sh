#!/usr/bin/env bash

set -euo pipefail

# Preliminary stuff
setfont ter-132b
iwctl --passphrase pYq4RQmT station wlan0 connect MGTS_GPON5_51EF
sleep 10
timedatectl set-ntp true

# Partitioning
# p1 - EFI; p2 - swap; p3 - root
# TODO: make disk partitioning automatic
# cfdisk /dev/nvme1n1
mkfs.fat -F32 /dev/nvme1n1p1
mkswap /dev/nvme1n1p2
mkfs.ext4 -F /dev/nvme1n1p3

# Mounting
mount /dev/nvme1n1p3 /mnt
mkdir /mnt/efi
mount /dev/nvme1n1p1 /mnt/efi
swapon /dev/nvme1n1p2

# Sort mirrors and install system
reflector --verbose --sort rate --save /etc/pacman.d/mirrorlist
# sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacstrap /mnt base base-devel linux linux-firmware grub efibootmgr amd-ucode man-db man-pages texinfo terminus-font htop vim curl git lsof bash-completion ttf-cascadia-code xf86-video-amdgpu mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver mesa-vdpau ntfs-3g networkmanager baobab bluez gdm gnome-shell gnome-terminal gedit gnome-tweaks eog evince file-roller gnome-keyring gnome-backgrounds gnome-calculator gnome-calendar gnome-clocks gnome-control-center gnome-disk-utility gnome-remote-desktop gnome-screenshot gnome-system-monitor gnome-user-share gnome-weather gnome-shell-extensions gvfs gvfs-mtp gvfs-smb nautilus sushi mpv pipewire-alsa pipewire-jack pipewire-pulse lollypop telegram-desktop transmission-gtk xdg-user-dirs-gtk xdg-desktop-portal xdg-desktop-portal-gtk youtube-dl qemu libvirt iptables-nft dnsmasq bridge-utils edk2-ovmf virt-manager discord docker steam

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Configure pacman
arch-chroot /mnt sed -i 's/#Color/Color/' /etc/pacman.conf
arch-chroot /mnt sed -i 's/#TotalDownload/TotalDownload/' /etc/pacman.conf
arch-chroot /mnt sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
arch-chroot /mnt sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

# Configure timezone and locale
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
arch-chroot /mnt timedatectl set-timezone Europe/Moscow
# arch-chroot /mnt hwclock --systohc
arch-chroot /mnt timedatectl set-local-rtc 1
arch-chroot /mnt timedatectl set-ntp true
arch-chroot /mnt sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8"  > /mnt/etc/locale.conf

# Configure console font
echo "FONT=ter-132b" > /mnt/etc/vconsole.conf

# Configure hostname
echo "Obelisk" > /mnt/etc/hostname
echo "127.0.0.1    localhost" >> /mnt/etc/hosts
echo "::1    localhost" >> /mnt/etc/hosts
echo "127.0.1.1    Obelisk.local    Obelisk" >> /mnt/etc/hosts

# Install GRUB
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id="Arch Linux"
# Disable CPU mitigations
arch-chroot /mnt sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& mitigations=off/' /etc/default/grub
# Enable full AMD GPU control
arch-chroot /mnt sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& amdgpu.ppfeaturemask=0xffffffff/' /etc/default/grub
# Configure GRUB resolution
arch-chroot /mnt sed -i 's/GRUB_GFXMODE=auto/GRUB_GFXMODE=2560x1440x32,1920x1080x32,auto/' /etc/default/grub

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Fix GDM not starting after boot (Enable early KMS)
arch-chroot /mnt sed -i 's/^MODULES=([^)]*/&amdgpu/' /etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -P

# Add user and change passwords
arch-chroot /mnt useradd -m -G wheel,docker -s /bin/bash -c "Daniel Allen" dallen
arch-chroot /mnt passwd dallen
arch-chroot /mnt passwd

# Allow wheel group to use sudo
arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Enable TRIM
arch-chroot /mnt systemctl enable fstrim.timer

# Enable necessary services
arch-chroot /mnt systemctl enable NetworkManager.service
arch-chroot /mnt systemctl enable gdm.service
arch-chroot /mnt systemctl enable bluetooth.service
arch-chroot /mnt systemctl enable libvirtd.service
arch-chroot /mnt systemctl enable docker.service

# Unmount and reboot
umount -R /mnt
reboot
