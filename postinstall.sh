#!/usr/bin/env bash

# Enable localtime & NTP (Windows Dualboot)
timedatectl set-local-rtc 1
timedatectl set-ntp true

# Configure monitor for GNOME & GDM
cat <<-EOF > ~/.config/monitors.xml
<monitors version="2">
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1</scale>
      <primary>yes</primary>
      <monitor>
        <monitorspec>
          <connector>DP-1</connector>
          <vendor>DEL</vendor>
          <product>DELL S3220DGF</product>
          <serial>8VQM4W2</serial>
        </monitorspec>
        <mode>
          <width>2560</width>
          <height>1440</height>
          <rate>164.05659484863281</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
EOF
sudo cp ~/.config/monitors.xml /var/lib/gdm/.config/monitors.xml
sudo chown gdm:gdm /var/lib/gdm/.config/monitors.xml

# Install paru
cd /tmp
curl -LO https://aur.archlinux.org/cgit/aur.git/snapshot/paru.tar.gz
tar -zxvf paru.tar.gz
cd paru
makepkg -sri --noconfirm
rm -rfv /tmp/paru*

# Install stuff from AUR
paru -S --noconfirm visual-studio-code-bin spotify corectrl

# Clean unnecessary desktop entries
chmod +x cleanup.sh && ./cleanup.sh

# Clean orphans
pacman -Qttdq | sudo pacman -Rscn --noconfirm -

# Clean cache
rm -rfv ~/.cache/*
rm -rfv ~/.cargo

# Reset app grid to alphabetical default
gsettings set org.gnome.shell app-picker-layout "[]"

# Fontconfig
sudo ln -sfv /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
sudo ln -sfv /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sudo ln -sfv /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
# Need to copy Windows fonts to work
mkdir -p ~/.config/fontconfig
cat <<-EOF > ~/.config/fontconfig/fonts.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
       <alias binding="same">
         <family>Helvetica</family>
         <accept>
         <family>Arial</family>
         </accept>
       </alias>
       <alias binding="same">
         <family>Times</family>
         <accept>
         <family>Times New Roman</family>
         </accept>
       </alias>
       <alias binding="same">
         <family>Courier</family>
         <accept>
         <family>Courier New</family>
         </accept>
       </alias>
</fontconfig>
EOF

# Copy configs
cp -fv .vimrc ~/.vimrc
mkdir -pv ~/.config/mpv
cp -fv mpv.conf ~/.config/mpv/mpv.conf
