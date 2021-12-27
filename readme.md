Run scripts:
- 00
- arch-chroot /mnt
- 01 inside bootstrap/archbootstrap

reboot and log in.

add keyboardlayout
/etc/vconsole.conf add KEYMAP=la-latin1

configure systemd-networkd:
    /etc/systemd/network/20-wired.network
    [Match]
    Name=enp5s0

    [Network]
    DHCP=yes

    [DHCP]
    RouteMetric=10

    /etc/systemd/network/25-wireless.network
    [Match]
    Name=wlan0

    [Network]
    DHCP=yes

    [DHCP]
    RouteMetric=20

systemctl enable systemd-networkd systemd-resolved
systemctl enable sshd

install tlp ufw
systemctl enable ufw tlp

configure ufw to allow ssh conections and ignore the others
# ufw default deny
# ufw allow from 192.168.0.0/24
# ufw limit ssh
# ufw enable


add acpi_backlight=vendor to grub parameters
grub-mkconfig -o /boot/grub/grub.cfg

Enable multilib

- install display drivers:
- install mesa
- install xf86-video-amdgpu
- install vulkan-radeon
- install libva-mesa-driver
- install mesa-vdpau
- install lib32-mesa


isntall audio drivers
- install pulseaudio-alsa
- install pamixer

isntall brightness controller
- https://github.com/Ventto/lux

install xmonad
