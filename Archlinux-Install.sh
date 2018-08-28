#wifi-menu
version=1.0
usuario=marcos
senha=12345
host=kleper1

function wifi(){
cat << EOF > /etc/netctl/wlp3s1-Edivan2
  Description='Internet via Wifi do Edivan'
  Interface=wlp3s1
  Connection=wireless
  Security=wpa
  ESSID=Edivan2
  IP=dhcp
  Key=KLOpeNLibre10
EOF
  sudo  netctl enable wlp3s1-Edivan2  #statements
}

function rede-cabeada(){
cat << EOF > /etc/netctl/ens3
  Description='Rede Cabeada do laboratorio'
  Interface=ens3
  Connection=ethernet
  IP=dhcp
EOF
  sudo  netctl enable ens3
}

if [ $1 = -i ];then


  cfdisk /dev/sda

  mkfs.ext4 /dev/sda1
  mkfs.ext4 /dev/sda2

  mount /dev/sda1 /mnt
  mkdir /mnt/home
  mount /dev/sda2 /mnt/home

  pacstrap /mnt base base-devel

  genfstab -U /mnt >> /mnt/etc/fstab
  wget -P /mnt http://bit.ly/arch-installer

  arch-chroot /mnt bash arch-installer  install

elif [ $1 = install ]; then

  rede-cabeada

      if [ $2 = wifi ];then

        wifi

      fi

  rm /etc/localtime
  ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

  hwclock --systohc --utc

  sed  s/\#pt_BR.UTF-8/pt_BR.UTF-8/g  /etc/locale.gen > ds ; cp ds /etc/locale.gen

  locale-gen

  echo LANG=pt_BR.UTF-8 > /etc/locale.conf
  export LANG=pt_BR.UTF-8

  echo $host > /etc/hostname

  pacman -S grub os-prober --noconfirm

  grub-install /dev/sda

  grub-mkconfig -o /boot/grub/grub.cfg


  curl 'https://www.archlinux.org/mirrorlist/?country=BR&protocol=http&protocol=https&ip_version=4' > mirrorlist ; sed s/#Server/Server/g  mirrorlist > /etc/pacman.d/mirrorlist

  #nano  /etc/pacman.conf
  wget -P /etc/ https://raw.githubusercontent.com/ferreirarocha/arch-installer/master/pacman.conf

  pacman -Syu
  pacman -Ss

  pacman -S xorg \
  xorg-server \
  xorg-xinit \
  xfce4 \
  xfce4-goodies \
  go \
  lxdm \
  openssh \
  alsa-utils \
  pulseaudio \
  ttf-dejavu \
  ttf-droid \
  alsa-{utils,plugins,plugins,firmware} pulseaudio pulseaudio-{equalizer,alsa} \
  a52dec \
  faac \
  faad2 \
  flac \
  jasper \
  lame \
  libdca \
  libdv \
  libmad \
  libmpeg2 \
  libtheora \
  libvorbis \
  libxv \
  wavpack \
  x264 \
  xvidcore \
  vlc \
  p7zip \
  unrar \
  tar \
  unzip \
  rsync \
  p7zip \
  unrar \
  rsync \
  zsh \
  git \
  nautilus \
  screenfetch \
  xf86-video-intel \
  pavucontrol \
  alsa-firmware \
  alsa-utils \
  alsa-plugins \
  pulseaudio-alsa \
  pulseaudio \
  xdg-user-dirs \
  wget \
  archlinux-keyring --noconfirm

  useradd usertemp -m ; echo usertemp:$senha | chpasswd
  echo root:$senha | chpasswd

  gpasswd -a $usuario sys
  gpasswd -a $usuario lp
  gpasswd -a $usuario network
  gpasswd -a $usuario video
  gpasswd -a $usuario optical
  gpasswd -a $usuario storage
  gpasswd -a $usuario scanner
  gpasswd -a $usuario power
  gpasswd -a $usuario wheel
  gpasswd -a usertemp wheel

  #usermod -aG libvirt $usuario
  #sed  -i s/\#\ wheel/wheel/g /etc/sudoers ;sed  -i s/\#\ %wheel/%wheel/g /etc/sudoers
  rm /etc/sudoers*
  wget -P /etc/ https://raw.githubusercontent.com/ferreirarocha/arch-installer/master/sudoers

  mkdir -m 777 pkg
  cd /pkg
  sudo -u usertemp -H sh -c "git clone https://aur.archlinux.org/yay.git; cd yay/ ; makepkg -si --noconfirm"

  su -c " yay -S file-roller                --noconfirm" usertemp
  su -c " yay -S typora                     --noconfirm" usertemp
  su -c " yay -S tilix                      --noconfirm" usertemp
  su -c " yay -S inkscape                   --noconfirm" usertemp
  su -c " yay -S gimp                       --noconfirm" usertemp
  su -c " yay -S atom                       --noconfirm" usertemp
  su -c " yay -S mtnm                       --noconfirm" usertemp
  su -c " yay -S albert                     --noconfirm" usertemp
  su -c " yay -S libreoffice-dev-bin        --noconfirm" usertemp
  su -c " yay -S ksuperkey                  --noconfirm" usertemp
  su -c " yay -S hunspell-pt-br             --noconfirm" usertemp
  su -c " yay -S xfce4-dockbarx-plugin-git  --noconfirm" usertemp
  su -c " yay -S bind-tools                 --noconfirm" usertemp
  su -c " yay -S exfat-utils                --noconfirm" usertemp
  su -c " yay -S xdg-user-dir               --noconfirm" usertemp
  su -c " yay -S telegram-desktop-bin       --noconfirm" usertemp



  pacman -R virtualbox-host-dkms \
  virtualbox-sdk \
  virtualbox  --noconfirm


  wget http://download2266.mediafire.com/w13tfa66kagg/54ooo29q9s71ami/conf.zip
  #scp marcos@192.168.1.105:/home/marcos/conf.zip /home/marcos/
  unzip conf.zip -d /etc/skel
  #chown marcos. -Rf /home/marcos/.*


  sudo sed -i /etc/lxdm/lxdm.conf \
       -e 's;^# session=/usr/bin/startlxde;session=/usr/bin/startxfce4;g'

  useradd $usuario -m ; echo $usuario:$senha | chpasswd
  xdg-user-dirs-update
  chsh -s /bin/zsh $usuario
  userdel usertemp
  systemctl enable sshd
  sudo systemctl enable lxdm

else

	echo "dd"

fi

#umount  /mnt/home
#umount /mnt
#reboot
