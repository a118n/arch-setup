#!/usr/bin/env bash

set -euo pipefail

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

# Install flatpak apps
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --assumeyes flathub com.valvesoftware.Steam


# Install yay
cd /tmp
curl -LO https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
tar -zxvf yay.tar.gz
cd yay
makepkg -sri --noconfirm
rm -rfv /tmp/yay*

# Install stuff from AUR
yay -S --noconfirm microsoft-edge-dev-bin visual-studio-code-bin spotify # gnome-shell-extension-dash-to-dock brave-bin

# Clean unnecessary desktop entries
sudo rm -f /usr/share/applications/avahi-discover.desktop
sudo rm -f /usr/share/applications/bssh.desktop
sudo rm -f /usr/share/applications/bvnc.desktop
sudo rm -f /usr/share/applications/htop.desktop
sudo rm -f /usr/share/applications/lstopo.desktop
sudo rm -f /usr/share/applications/nm-connection-editor.desktop
sudo rm -f /usr/share/applications/qv4l2.desktop
sudo rm -f /usr/share/applications/qvidcap.desktop
sudo rm -f /usr/share/applications/vim.desktop

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
