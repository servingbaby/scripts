#!/bin/sh
#
# archmate.sh - Arch installation script
# Troy Engel (TE)
#
# 1. boot archlinux-<date>-dual.iso
# 2. wget -O archmate.sh http://git.io/archmate
#
# 3. bash archmate.sh amprep      (extracts 'amprep.sh')
# 4. bash archmate.sh amconf      (extracts 'amconf.sh')
#
# 5. vi amprep.sh amconf.sh       (configure)
# 6. bash amprep.sh               (optional)
# 7. arch-chroot /mnt
#
# 8. cd /root; ./archmate.sh      (in the chroot)
#
# amprep.sh is handy but not required - the idea is you can replace
# the content with your own setup to save on a lot of typing. The
# included, commented out code will mount and pacstrap, e.g.
#
# amconf.sh will be copied to /mnt/root/ with the provided code
# in amprep.sh if uncommented. Store your own variable settings in
# this file to avoid editing this script.
#
# archmate.sh expects everything mounted, pacstrap run and is being
# executed from the arch-chroot. (amprep.sh helps with those steps)

######################################################################
### BOCONF - DO NOT REMOVE OR ALTER THIS LINE
## USER VARS

# These must be changed
HOSTNAME="myhostname"
USERNAME="myusername"

# For ${USERNAME} what will be passed to useradd
#  - 'wheel' will be added to /etc/sudoers
#  - 'vboxusers' will be added dynamically
USER_PGRP="users"
USER_SGRP="wheel,storage,power,wireshark"
USER_SHLL="/bin/bash"

# Set this to true if this is a Virtualbox guest
VBOXGUEST=false

# Set this to true if this is a Virtualbox host
VBOXHOST=false

# Various date/time/locale things
ARCH_TZ="America/Chicago"
ARCH_LA="en_US"
ARCH_CP="UTF-8"
ARCH_KM="us"
ARCH_VF="latarcyrheb-sun16"

# grub mode ('bios' or 'uefi') and boot disk/partitions
GRUB_MODE="bios"
GRUB_BIOS_DISK="/dev/sda"
GRUB_UEFI_PART="/dev/sda1"

# Be careful changing this
PKG_CORE="grub linux-headers linux-lts linux-lts-headers os-prober intel-ucode"

# Can be tuned - includes all video drivers, etc.
PKG_XORG="xorg xorg-drivers xorg-xinit xorg-server-utils xorg-twm xorg-xclock xorg-utils xterm alsa-utils gnu-free-fonts mesa ttf-dejavu ttf-liberation"

# Things that get dragged in by xorg to remove
PKG_XDEL="font-misc-ethiopic xorg-fonts-100dpi xorg-fonts-75dpi"

# If VBOXGUEST=true
PKG_GVBOX="virtualbox-guest-utils virtualbox-guest-dkms virtualbox-guest-modules virtualbox-guest-modules-lts haveged"

# If VBOXHOST=true
PKG_HVBOX="virtualbox virtualbox-host-dkms virtualbox-host-modules virtualbox-host-modules-lts"

# CLI stuff
PKG_CLI="abs alsa-firmware base-devel bash-completion bc bluez bluez-firmware cadaver chrony cpio cronie cups cups-filters cups-pdf cups-pk-helper dcfldd dhclient dmidecode dnsutils duplicity ethtool expect ffmpeg freerdp gdisk git gnu-netcat id3v2 iftop ipw2100-fw ipw2200-fw iw kexec-tools lame lsof mailx mplayer mutt namcap net-tools nethogs nfs-utils nmap ntfs-3g openldap openssh p7zip parted perl-mime-lite perl-xml-simple pkgstats pwgen python-boto python-pexpect python-requests python-setuptools python-yaml python2 python2-boto python2-pexpect python2-setuptools python2-requests python2-soappy python2-yaml rdesktop rfkill rpcbind rpmextract rsync screen sharutils strace stunnel subversion sudo tcpdump tigervnc traceroute unrar unzip usb_modeswitch vim vim-systemd vlc wget whois wireshark-cli zip"

# X Desktop stuff
PKG_DWIN="accountsservice mate mate-extra mate-themes-extras lightdm-gtk2-greeter gnome-keyring gst-plugins-bad gst-plugins-ugly gstreamer0.10-base-plugins gstreamer0.10-ugly gstreamer0.10-ugly-plugins gtk-aurora-engine networkmanager networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc network-manager-applet system-config-printer systemd-ui"

# GUI stuff
PKG_XAPP="argyllcms brasero chromium easytag feh firefox flashplugin gimp gkrellm gucharmap gvfs-afc gvfs-mtp gvfs-smb hunspell-en hyphen-en libreoffice-fresh pragha pidgin pidgin-otr seahorse thunderbird tk transmission-gtk x11-ssh-askpass xchat wireshark-gtk"

# Where we'll log all actions (in the chroot)
ACTLOG="/root/archmate.log"

# Which file will override all settings (in the chroot)
AMCONF="/root/amconf.sh"

### EOCONF - DO NOT REMOVE OR ALTER THIS LINE
######################################################################

######################################################################
### BOPREP - DO NOT REMOVE OR ALTER THIS LINE ###
## These are typically done by hand based on partitioning, etc.
#
## Common
# swapon /dev/mapper/vglocal-swap
# mount /dev/mapper/vglocal-root /mnt
# mkdir /mnt/{boot,home}
# mount /dev/mapper/vglocal-home /mnt/home
#
## MBR Style
# mount /dev/sda1 /mnt/boot
#
## UEFI Style
# mount /dev/sda2 /mnt/boot
# mkdir /mnt/boot/efi
# mount /dev/sda1 /mnt/boot/efi
#
## Pacstrap
# pacstrap /mnt base --noprogressbar 2>&1 | tee -a pacstrap.log
# genfstab -p /mnt >> /mnt/etc/fstab
# cp archmate.sh /mnt/root/ && chmod +x /mnt/root/archmate.sh
# cp pacstrap.log /mnt/root/
# [ -f "amprep.sh" ] && cp amprep.sh /mnt/root/
# [ -f "amconf.sh" ] && cp amconf.sh /mnt/root/
#
## arch-chroot /mnt
### EOPREP - DO NOT REMOVE OR ALTER THIS LINE ###
######################################################################

######################################################################
## EXTRACTION

# this will save the top part of this script to "amprep.sh" - handy
# if you wget this script from a boot ISO and want to save the
# pre-prepared stuff for use that is not done on purpose
if [[ "$1" == "amprep" ]] && [[ -f "archmate.sh" ]]; then
  echo
  echo "== Creating amprep.sh and exiting =="
  echo
  sed -n '/^### BOPREP/,/^### EOPREP/p' archmate.sh > amprep.sh
  exit 2
fi

# this will save the top part of this script to "amconf.sh" - handy
# if you want to avoid editing this script
if [[ "$1" == "amconf" ]] && [[ -f "archmate.sh" ]]; then
  echo
  echo "== Creating amconf.sh and exiting =="
  echo
  sed -n '/^### BOCONF/,/^### EOCONF/p' archmate.sh > amconf.sh
  exit 2
fi

######################################################################
## FUNCTIONS

# if a config exists, read it in
[ -f "${AMCONF}" ] && source "${AMCONF}"

# trap our signals
function error_exit {
  echo "Trapped a kill signal, exiting."
  exit 99
}
trap error_exit SIGHUP SIGINT SIGTERM

# handy exit function
function myexit() {
  echo "$1"
  exit 1
}

# run action, log output, return exit code
# - passing in 'sed' should be avoided
# - functions can only return 0..254
# -- set a global to check as needed
_ACTRET=0
function logact() {
  local ACTION
  ACTION="$*"
  ${ACTION} 2>&1 | tee -a ${ACTLOG}
  _ACTRET=${PIPESTATUS[0]}
  return ${_ACTRET}
}

######################################################################
## ERROR CHECKING

# this will bypass the safety check for /etc/locale.conf (debugging)
UNSAFE=false

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

######################################################################
## MISC SETUP

# we'll store cookies here -- allows this script to run in stages
[[ ! -d /root/.archmate ]] && mkdir /root/.archmate

# cleaner code below ('#' 70 times)
_BAR=$(printf '#%.0s' {1..70})

######################################################################
## STAGES

## LOG START ##
_DTS=$(date)
logact echo -e "\n${_BAR}\n${_BAR}\n## Started: ${_DTS}\n${_BAR}\n${_BAR}"

## STAGE 1 ##
logact echo -e "\n${_BAR}\n## Stage 1: Performing initial setup\n${_BAR}"

if [[ ! -f /root/.archmate/stage-1.done ]]; then
  # Language etc.
  export LANG="${ARCH_LA}.${ARCH_CP}"
  echo "${ARCH_LA}.${ARCH_CP} ${ARCH_CP}" >> /etc/locale.gen
  logact locale-gen
  cat << EOF > /etc/locale.conf
LANG="${ARCH_LA}.${ARCH_CP}"
LC_COLLATE="C"
EOF

  cat << EOF > /etc/vconsole.conf
KEYMAP="${ARCH_KM}"
FONT="${ARCH_VF}"
EOF

  # time/date
  logact ln -s /usr/share/zoneinfo/${ARCH_TZ} /etc/localtime
  logact hwclock --systohc --utc
  echo ${HOSTNAME} > /etc/hostname
  logact hostname ${HOSTNAME}

  touch /root/.archmate/stage-1.done
else
  logact echo " - /root/.archmate/stage-1.done found, skipping."
fi

## STAGE 2 ##
logact echo -e "\n${_BAR}\n## Stage 2: Installing core packages\n${_BAR}"

if [[ ! -f /root/.archmate/stage-2.done ]]; then
  logact pacman -Sy --noconfirm --noprogressbar
  [[ $? -ne 0 ]] && myexit "pacman error - exiting."
  logact pacman -S --noconfirm --noprogressbar ${PKG_CORE}
  [[ $? -ne 0 ]] && myexit "pacman error - exiting."

  touch /root/.archmate/stage-2.done
else
  logact echo " - /root/.archmate/stage-2.done found, skipping."
fi

# Prevent the screen going blank during install
setterm -powersave off -powerdown 0 -blank 0

## STAGE 3 ##
logact echo -e "\n${_BAR}\n## Stage 3: Setting up GRUB and kernels\n${_BAR}"

if [[ ! -f /root/.archmate/stage-3.done ]]; then
  # add lvm2 hook
  sed -i.bak -r 's/^HOOKS=(.*)block(.*)/HOOKS=\1block lvm2\2/g' \
    /etc/mkinitcpio.conf
  logact mkinitcpio -p linux
  logact mkinitcpio -p linux-lts

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
    logact grub-install --target=i386-pc --recheck ${GRUB_BIOS_DISK}
  elif [[ "${GRUB_MODE}" == "uefi" ]]; then
    logact pacman -S --noconfirm --noprogressbar dosfstools efibootmgr
    [[ $? -ne 0 ]] && myexit "pacman error - exiting."
    logact grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck --debug
    logact mkdir -p /boot/efi/EFI/boot
    logact cp -a /boot/efi/EFI/arch_grub/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
  fi
  logact grub-mkconfig -o /boot/grub/grub.cfg
  ROOT_PART=$(grub-probe --target=device /)
  ROOT_UUID=$(grub-probe --device ${ROOT_PART} --target=fs_uuid)
  logact grub-set-default "gnulinux-linux-advanced-${ROOT_UUID}"

  touch /root/.archmate/stage-3.done
else
  logact echo " - /root/.archmate/stage-3.done found, skipping."
fi

## STAGE 4 ##
logact echo -e "\n${_BAR}\n## Stage 4: Installing Xorg and Virtualbox\n${_BAR}"

if [[ ! -f /root/.archmate/stage-4.done ]]; then

  # base X.org
  logact pacman -S --noconfirm --noprogressbar ${PKG_XORG}
  [[ $? -ne 0 ]] && myexit "pacman error - exiting."

  # Virtualbox Host
  if [[ $VBOXHOST == true ]]; then
    logact echo "Installing Virtualbox Host..."
    logact pacman -S --noconfirm --noprogressbar ${PKG_HVBOX}
    [[ $? -ne 0 ]] && myexit "pacman error - exiting."
    cat << 'EOF' > /etc/modules-load.d/vboxhost.conf
vboxdrv
EOF
    USER_SGRP="${USER_SGRP},vboxusers"
    logact systemctl enable dkms.service
  fi

  # Virtualbox Guest
  if [[ $VBOXGUEST == true ]]; then
    logact echo "Installing Virtualbox Guest..."
    logact pacman -S --noconfirm --noprogressbar ${PKG_GVBOX}
    [[ $? -ne 0 ]] && myexit "pacman error - exiting."
    cat << 'EOF' > /etc/modules-load.d/vboxguest.conf
vboxguest
vboxsf
vboxvideo
EOF
    logact systemctl enable dkms.service
    logact systemctl enable vboxservice.service
    logact systemctl enable haveged.service
  fi

  touch /root/.archmate/stage-4.done
else
  logact echo " - /root/.archmate/stage-4.done found, skipping."
fi

## STAGE 5 ##
logact echo -e "\n${_BAR}\n## Stage 5: Installing all other packages\n${_BAR}"

if [[ ! -f /root/.archmate/stage-5.done ]]; then
  logact pacman -S --noconfirm --noprogressbar ${PKG_CLI} ${PKG_DWIN} ${PKG_XAPP}
  [[ $? -ne 0 ]] && myexit "pacman error - exiting."

  logact pacman -Rnu --noconfirm ${PKG_XDEL}
  [[ $? -ne 0 ]] && myexit "pacman error - exiting."

  # clean up a little
  logact pacman -Sc --noconfirm

  logact mv /etc/lightdm/lightdm-gtk-greeter.conf{,.bak}
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
  logact glib-compile-schemas /usr/share/glib-2.0/schemas/

  touch /root/.archmate/stage-5.done
else
  logact echo " - /root/.archmate/stage-5.done found, skipping."
fi

## STAGE 6 ##
logact echo -e "\n${_BAR}\n## Stage 6: User Setup\n${_BAR}"

if [[ ! -f /root/.archmate/stage-6.done ]]; then
  logact echo -e "\n== Setting root password =="
  passwd root

  logact echo -e "\n== Adding user ${USERNAME} =="
  logact useradd -m -g ${USER_PGRP} -G ${USER_SGRP} -s ${USER_SHLL} ${USERNAME}
  passwd ${USERNAME}
  echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

  ## AUR setup as a user later
  if [[ ! -f "/home/${USERNAME}/aur_setup.sh" ]]; then
    logact echo -e "\n== Creating /home/${USERNAME}/aur_setup.sh =="
    cat << 'EOF' > /home/${USERNAME}/aur_setup.sh
mkdir builds
cd builds/
curl -L -O https://aur.archlinux.org/packages/co/cower/cower.tar.gz
curl -L -O https://aur.archlinux.org/packages/pa/pacaur/pacaur.tar.gz
tar -zxvf cower.tar.gz 
tar -zxvf pacaur.tar.gz 
cd cower
makepkg -s --skippgpcheck
sudo pacman -U cower-*.pkg.tar.xz 
cd ../pacaur
makepkg -s
sudo pacman -U pacaur-*.pkg.tar.xz
pacaur -S --noconfirm downgrade duply chromium-pepper-flash networkmanager-dispatcher-chrony petrified
EOF
    chown ${USERNAME}:users /home/${USERNAME}/aur_setup.sh
  fi
  touch /root/.archmate/stage-6.done
else
  logact echo " - /root/.archmate/stage-6.done found, skipping."
fi

## STAGE 7 ##
logact echo -e "\n${_BAR}\n## Stage 7: Enabling system services\n${_BAR}"

if [[ ! -f /root/.archmate/stage-7.done ]]; then

  if [[ ! -f /etc/iptables/iptables.rules ]] && \
     [[ -f /etc/iptables/simple_firewall.rules ]]; then
    logact cp /etc/iptables/simple_firewall.rules /etc/iptables/iptables.rules
  fi
  sed -i.bak 's/^#SystemMaxUse=/SystemMaxUse=50M/g' /etc/systemd/journald.conf
  logact systemctl enable lightdm.service
  logact systemctl enable NetworkManager.service
  logact systemctl enable cronie.service
  logact systemctl enable iptables.service
  logact systemctl enable sshd.service
  logact systemctl enable org.cups.cupsd.service
  logact systemctl enable chrony.service
  logact systemctl enable bluetooth.service
  logact systemctl enable accounts-daemon.service
  logact systemctl disable dhcpcd.service

  touch /root/.archmate/stage-7.done
else
  logact echo " - /root/.archmate/stage-7.done found, skipping."
fi

## LOG FINISH ##
_DTS=$(date)
logact echo -e "\n${_BAR}\n${_BAR}\n## Finished: ${_DTS}\n${_BAR}\n${_BAR}"

logact echo -e "Typical next steps:\n"
logact echo "# configure /etc/chrony.conf to set offline mode (laptop)"
logact echo "# alsamixer (change base levels to ~50%)"
logact echo -e "\n# exit (the chroot)\n# umount -R /mnt\n# reboot\n"

exit 0

