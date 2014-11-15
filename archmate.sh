#!/bin/sh
#
# archmate.sh - Arch installation script
# Troy Engel (TE)
#
# 1. boot archlinux-<date>-dual.iso
# 2. wget -O archmate.sh http://git.io/archmate
#    curl -Lo archmate.sh http://git.io/archmate
# 3. bash archmate.sh prep  (extracts 'prep.sh')
# 4. bash archmate.sh       (after 'arch-chroot /mnt')
#
# The prep.sh is handy but not required - the idea is you can replace
# the content with your own setup to save on a lot of typing.

# These must be changed
HOSTNAME="myhostname"
USERNAME="myusername"

# Set this to true if this is a Virtualbox guest
VBOXGUEST=false

### BOTOP - DO NOT REMOVE OR ALTER THIS LINE ###
## These are typically done by hand based on partitioning, etc.
#
## MBR Style
# swapon /dev/mapper/vglocal-swap
# mount /dev/mapper/vglocal-root /mnt
# mkdir /mnt/{boot,home}
# mount /dev/mapper/vglocal-home /mnt/home
# mount /dev/sda1 /mnt/boot
#
## UEFI Style
# swapon /dev/mapper/vglocal-swap
# mount /dev/mapper/vglocal-root /mnt
# mkdir /mnt/{boot,home}
# mount /dev/mapper/vglocal-home /mnt/home
# mount /dev/sda2 /mnt/boot
# mkdir /mnt/boot/efi
# mount /dev/sda1 /mnt/boot/efi
#
# cp /etc/pacman.d/mirrorlist{,.bak}
# grep -A1 "United States" /etc/pacman.d/mirrorlist.bak | grep -v "^--" > \
#   /etc/pacman.d/mirrorlist
# pacstrap /mnt base
# genfstab -p /mnt >> /mnt/etc/fstab
# cp archmate.sh /mnt/root/ && chmod +x /mnt/root/archmate.sh
#
## arch-chroot /mnt
### EOTOP - DO NOT REMOVE OR ALTER THIS LINE ###

# this will bypass the safety check for /etc/locale.conf
UNSAFE=false

# various date/time/locale things
ARCH_TZ="America/Chicago"
ARCH_LA="en_US"
ARCH_CP="UTF-8"
ARCH_KM="us"
ARCH_VF="latarcyrheb-sun16"

# grub mode ('bios' or 'uefi') and boot disk/partitions
GRUB_MODE="bios"
GRUB_BIOS_DISK="/dev/sda"
GRUB_UEFI_PART="/dev/sda1"

# be careful changing this
PKG_CORE="grub linux-headers linux-lts linux-lts-headers os-prober intel-ucode"

# can be tuned - includes all video drivers, etc.
PKG_XORG="xorg xorg-drivers xorg-xinit xorg-server-utils xorg-twm xorg-xclock xorg-utils xterm alsa-utils gnu-free-fonts mesa ttf-dejavu ttf-liberation"

# Things that get dragged in by xorg to remove
PKG_XDEL="font-misc-ethiopic xorg-fonts-100dpi xorg-fonts-75dpi"

# if VBOXGUEST=true
PKG_VBOX="virtualbox-guest-utils virtualbox-guest-dkms virtualbox-guest-modules virtualbox-guest-modules-lts"

# CLI stuff
PKG_CLI="abs alsa-firmware base-devel bash-completion bc bluez bluez-firmware cadaver cpio cronie cups cups-filters cups-pdf cups-pk-helper dcfldd dhclient dmidecode dnsutils duplicity ethtool expect ffmpeg freerdp gdisk git gnu-netcat id3v2 iftop ipw2100-fw ipw2200-fw iw kexec-tools lame lsof mailx mplayer mutt namcap net-tools nethogs nfs-utils nmap ntfs-3g ntp openldap openssh p7zip parted perl-mime-lite perl-xml-simple pkgstats pwgen python-pexpect python-setuptools python-yaml python2 python2-boto python2-pexpect python2-setuptools python2-soappy python2-yaml rdesktop rfkill rpcbind rpmextract rsync screen sharutils strace stunnel subversion sudo tcpdump tigervnc traceroute unrar unzip usb_modeswitch vim vim-systemd vlc wget whois wireshark-cli zip"

# X Desktop stuff
PKG_DWIN="mate mate-extra mate-themes-extras lightdm-gtk2-greeter gnome-keyring gst-plugins-bad gst-plugins-ugly gstreamer0.10-base-plugins gstreamer0.10-ugly gstreamer0.10-ugly-plugins gtk-aurora-engine networkmanager networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc network-manager-applet networkmanager-dispatcher-ntpd system-config-printer systemd-ui"

# GUI stuffs
PKG_XAPP="argyllcms brasero chromium easytag feh firefox flashplugin gimp gkrellm gucharmap gvfs-afc gvfs-mtp gvfs-smb libreoffice-calc libreoffice-draw libreoffice-en-US libreoffice-impress libreoffice-gnome libreoffice-writer mate-mplayer pragha pidgin pidgin-otr seahorse thunderbird tk transmission-gtk x11-ssh-askpass xchat wireshark-gtk"

# this will save the top part of this script to "prep.sh" - handy
# if you wget this script from a boot ISO and want to save the
# pre-prepared stuff for use that is not done on purpose
if [[ "$1" == "prep" ]] && [[ -f "archmate.sh" ]]; then
  echo
  echo "== Creating prep.sh and exiting =="
  echo
  sed -n '/^### BOTOP/,/^### EOTOP/p' archmate.sh > prep.sh
  exit 2
fi

##############
## BEGIN MAGIC

# handy exit function
function myexit() {
  echo "$1"
  exit 1
}

# did you edit this script?
if [[ "${HOSTNAME}" == "myhostname" ]] || [[ "${USERNAME}" == "myusername" ]]
then
  myexit "Edit HOSTNAME and USERNAME in this script first - exiting."
fi
# did you arch-chroot?
if [[ -f /mnt/etc/fstab ]]; then
  myexit "Did you arch-chroot? Found /mnt/etc/fstab - exiting."
fi
# did you pacstrap?
if [[ ! -f /etc/arch-release ]]; then
  myexit "This doesn't look like Arch, no /etc/arch-release - exiting."
fi
# is this a live system?
if [[ -f /etc/locale.conf ]]; then
  if [[ ! ${UNSAFE} ]]; then
    myexit "This looks like a live system, found /etc/locale.conf - exiting."
  fi
fi

# we'll store cookies here -- allows this script to run in stages
[[ ! -d /root/.archmate ]] && mkdir /root/.archmate

## STAGE 1 ##
echo
echo "== Stage 1: Performing initial setup =="

if [[ ! -f /root/.archmate/stage-1.done ]]; then
  # Language etc.
  export LANG="${ARCH_LA}.${ARCH_CP}"
  echo "${ARCH_LA}.${ARCH_CP} ${ARCH_CP}" >> /etc/locale.gen
  locale-gen
  cat << EOF > /etc/locale.conf
LANG="${ARCH_LA}.${ARCH_CP}"
LC_COLLATE="C"
EOF

  cat << EOF > /etc/vconsole.conf
KEYMAP="${ARCH_KM}"
FONT="${ARCH_VF}"
EOF

  # time/date
  ln -s /usr/share/zoneinfo/${ARCH_TZ} /etc/localtime
  hwclock --systohc --utc
  echo ${HOSTNAME} > /etc/hostname
  hostname ${HOSTNAME}

  touch /root/.archmate/stage-1.done
else
  echo " - /root/.archmate/stage-1.done found, skipping."
fi

## STAGE 2 ##
echo
echo "== stage 2: Installing select core packages =="

if [[ ! -f /root/.archmate/stage-2.done ]]; then
  pacman -Sy --noconfirm
  [[ $? -ne 0 ]] && myexit "pacman error - exiting."
  pacman -S --noconfirm ${PKG_CORE}
  [[ $? -ne 0 ]] && myexit "pacman error - exiting."

  touch /root/.archmate/stage-2.done
else
  echo " - /root/.archmate/stage-2.done found, skipping."
fi

# Prevent the screen going blank during install
setterm -powersave off -powerdown 0 -blank 0

## STAGE 3 ##
echo
echo "== Stage 3: Setting up GRUB and the kernels =="

if [[ ! -f /root/.archmate/stage-3.done ]]; then
  # add lvm2 hook
  sed -i.bak -r 's/^HOOKS=(.*)block(.*)/HOOKS=\1block lvm2\2/g' \
    /etc/mkinitcpio.conf
  mkinitcpio -p linux
  mkinitcpio -p linux-lts

  # GRUB our way
  sed -i.bak -r -e 's/^GRUB_DEFAULT=(.*)/#GRUB_DEFAULT=\1/g' \
    -e 's/^GRUB_CMDLINE_LINUX_DEFAULT=(.*)/#GRUB_CMDLINE_LINUX_DEFAULT=\1/g' \
    -e 's/^GRUB_SAVEDEFAULT=(.*)/#GRUB_SAVEDEFAULT=\1/g' /etc/default/grub
  cat << 'EOF' >> /etc/default/grub
GRUB_DEFAULT=saved
GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_SAVEDEFAULT="true"
GRUB_DISABLE_SUBMENU=y
EOF
  if [[ "${GRUB_MODE}" == "bios" ]]; then
    grub-install --target=i386-pc --recheck ${GRUB_BIOS_DISK}
  elif [[ "${GRUB_MODE}" == "uefi" ]]; then
    pacman -S --noconfirm dosfstools efibootmgr
    [[ $? -ne 0 ]] && myexit "pacman error - exiting."
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck --debug
    mkdir -p /boot/efi/EFI/boot
    cp -a /boot/efi/EFI/arch_grub/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
  fi
  grub-mkconfig -o /boot/grub/grub.cfg
  ROOT_PART=$(grub-probe --target=device /)
  ROOT_UUID=$(grub-probe --device ${ROOT_PART} --target=fs_uuid)
  grub-set-default "gnulinux-linux-advanced-${ROOT_UUID}"

  touch /root/.archmate/stage-3.done
else
  echo " - /root/.archmate/stage-3.done found, skipping."
fi

## STAGE 4 ##
echo
echo "== Stage 4: Installing base Xorg =="

if [[ ! -f /root/.archmate/stage-4.done ]]; then
  pacman -S --noconfirm ${PKG_XORG}
  [[ $? -ne 0 ]] && myexit "pacman error - exiting."

  if [[ $VBOXGUEST == true ]]; then
    echo "Installing Virtualbox guest..."
    pacman -S --noconfirm ${PKG_VBOX}
    [[ $? -ne 0 ]] && myexit "pacman error - exiting."
    cat << 'EOF' > /etc/modules-load.d/virtualbox.conf
vboxguest
vboxsf
vboxvideo
EOF
    systemctl -q enable vboxservice
  fi

  touch /root/.archmate/stage-4.done
else
  echo " - /root/.archmate/stage-4.done found, skipping."
fi

## STAGE 5 ##
echo
echo "== Stage 5: Installing all other packages =="

if [[ ! -f /root/.archmate/stage-5.done ]]; then
  pacman -S --noconfirm ${PKG_CLI} ${PKG_DWIN} ${PKG_XAPP}
  [[ $? -ne 0 ]] && myexit "pacman error - exiting."

  pacman -Rnu --noconfirm ${PKG_XDEL}
  [[ $? -ne 0 ]] && myexit "pacman error - exiting."

  # clean up a little
  pacman -Sc --noconfirm

  mv /etc/lightdm/lightdm-gtk-greeter.conf{,.bak}
  cat << 'EOF' > /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
background=#152233
theme-name=TraditionalOk
font-name=Sans 10
xft-antialias=true
xft-hintstyle=none
xft-rgba=rgb
EOF

  cat << 'EOF' > /usr/share/glib-2.0/schemas/mate-background.gschema.override
[org.mate.background]
color-shading-type='solid'
picture-options='centered'
picture-filename=''
primary-color='#152233'
secondary-color='#000000'
EOF
  glib-compile-schemas /usr/share/glib-2.0/schemas/

  touch /root/.archmate/stage-5.done
else
  echo " - /root/.archmate/stage-5.done found, skipping."
fi

## STAGE 6 ##
echo
echo "== Stage 6: User Setup =="

if [[ ! -f /root/.archmate/stage-6.done ]]; then
  echo
  echo "== Setting root password =="
  passwd root

  echo
  echo "== Adding user ${USERNAME} =="
  useradd -m -g users -G wheel,storage,power,wireshark -s /bin/bash ${USERNAME}
  passwd ${USERNAME}
  echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

  ## AUR setup as a user later
  if [[ ! -f "/home/${USERNAME}/aur_setup.sh" ]]; then
    cat << 'EOF' > /home/${USERNAME}/aur_setup.sh
mkdir builds
cd builds/
curl -L -O https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
curl -L -O https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
tar -zxvf package-query.tar.gz 
tar -zxvf yaourt.tar.gz 
cd package-query
makepkg -s
sudo pacman -U package-query-*.pkg.tar.xz 
cd ../yaourt
makepkg -s
sudo pacman -U yaourt-*.pkg.tar.xz 
yaourt -S --noconfirm downgrade duply chromium-pepper-flash libpurple-meanwhile deb2targz petrified
EOF
  fi
  touch /root/.archmate/stage-6.done
else
  echo " - /root/.archmate/stage-6.done found, skipping."
fi

## STAGE 7 ##
echo
echo "== Stage 7: Enabling system services =="

if [[ ! -f /root/.archmate/stage-7.done ]]; then

  if [[ ! -f /etc/iptables/iptables.rules ]] && \
     [[ -f /etc/iptables/simple_firewall.rules ]]; then
    cp /etc/iptables/simple_firewall.rules /etc/iptables/iptables.rules
  fi
  sed -i.bak 's/^#SystemMaxUse=/SystemMaxUse=50M/g' /etc/systemd/journald.conf
  systemctl -q enable lightdm.service
  systemctl -q enable NetworkManager.service
  systemctl -q enable cronie.service
  systemctl -q enable iptables.service
  systemctl -q enable sshd.service
  systemctl -q enable org.cups.cupsd.service
  systemctl -q enable ntpd.service
  systemctl -q disable dhcpcd.service

  touch /root/.archmate/stage-7.done
else
  echo " - /root/.archmate/stage-7.done found, skipping."
fi

echo
echo "All done - normal next steps:"
echo
echo "# alsamixer"
echo "# exit"
echo "# umount -R /mnt"
echo "# reboot"
echo

exit 0

