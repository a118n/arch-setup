#!/usr/bin/env bash

set -euo pipefail

# PulseAudio fix for Scarlett 2i4
mkdir -pv ~/.config/pulse
cat <<-EOF > ~/.config/pulse/default.pa
.include /etc/pulse/default.pa

# Focusrite Scarlett 2i4 config

# Remap outputs 1&2 separately
load-module module-remap-sink sink_name=speakers sink_properties="device.description='Speakers'" remix=no master=alsa_output.usb-Focusrite_Scarlett_2i4_USB-00.analog-surround-40 channels=2 master_channel_map=front-left,front-right channel_map=front-left,front-right

# Remap outputs 3&4 separately
load-module module-remap-sink sink_name=aux sink_properties="device.description='Aux'" remix=no master=alsa_output.usb-Focusrite_Scarlett_2i4_USB-00.analog-surround-40 channels=2 master_channel_map=rear-left,rear-right channel_map=front-left,front-right

# Remap input 1 separately
load-module module-remap-source source_name=input-1 source_properties="device.description='Input 1'" master=alsa_input.usb-Focusrite_Scarlett_2i4_USB-00.analog-stereo remix=no channels=2 master_channel_map=front-left,front-left channel_map=left,right

# Remap input 2 separately
load-module module-remap-source source_name=input-2 source_properties="device.description='Input 2'" master=alsa_input.usb-Focusrite_Scarlett_2i4_USB-00.analog-stereo remix=no channels=2 master_channel_map=front-right,front-right  channel_map=left,right
EOF

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

# Install yay
cd /tmp
curl -LO https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
tar -zxvf yay.tar.gz
cd yay && makepkg -sri
rm -rfv /tmp/yay*

# Install stuff from AUR
yay -S gnome-shell-extension-dash-to-dock brave-bin visual-studio-code-bin spotify
