#wifi-menu
version=1.0
usuario=marcos
senha=12345
host=kleper1
temporario=temporario

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
  wget -c -P /mnt http://bit.ly/arch-installer

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
  a52dec \
  alsa-{utils,plugins,firmware} pulseaudio pulseaudio-{equalizer,alsa} \
  archlinux-keyring \
  faac \
  faad2 \
  flac \
  git \
  go \
  jasper \
  lame \
  libdca \
  libdv \
  libmad \
  libmpeg2 \
  libtheora \
  libvorbis \
  libxv \
  lxdm \
  nautilus \
  openssh \
  p7zip \
  pavucontrol \
  rsync \
  screenfetch \
  tar \
  ttf-dejavu \
  ttf-droid \
  unrar \
  unzip \
  vlc \
  wavpack \
  wget \
  x264 \
  xdg-user-dirs \
  xf86-video-intel \
  xfce4 \
  xfce4-goodies \
  xorg-server \
  xorg-xinit \
  xvidcore \
  zsh       --noconfirm

  useradd $temporario -m ; echo $temporario:$senha | chpasswd
  echo root:$senha | chpasswd

  gpasswd -a $usuario     sys
  gpasswd -a $usuario     lp
  gpasswd -a $usuario     network
  gpasswd -a $usuario     optical
  gpasswd -a $usuario     video
  gpasswd -a $usuario     storage
  gpasswd -a $usuario     scanner
  gpasswd -a $usuario     power
  gpasswd -a $usuario     wheel
  gpasswd -a $temporario  wheel

  #usermod -aG libvirt $usuario
  #sed  -i s/\#\ wheel/wheel/g /etc/sudoers ;sed  -i s/\#\ %wheel/%wheel/g /etc/sudoers
  wget -O  /etc/sudoers https://raw.githubusercontent.com/ferreirarocha/arch-installer/master/sudoers
  rm /home/$temporario/.config/yay/config.json
  mkdir -m 777 pkg
  cd /pkg
  sudo -u $temporario -H sh -c "git clone https://aur.archlinux.org/yay.git; cd yay/ ; makepkg -si --noconfirm"

  su -c " yay -S albert                     --noconfirm" $temporario
  su -c " yay -S atom                       --noconfirm" $temporario
  su -c " yay -S bind-tools                 --noconfirm" $temporario
  su -c " yay -S chrony                     --noconfirm" $temporario
  su -c " yay -S exfat-utils                --noconfirm" $temporario
  su -c " yay -S file-roller                --noconfirm" $temporario
  su -c " yay -S gimp                       --noconfirm" $temporario
  su -c " yay -S hunspell-pt-br             --noconfirm" $temporario
  su -c " yay -S inkscape                   --noconfirm" $temporario
  su -c " yay -S ksuperkey                  --noconfirm" $temporario
  su -c " yay -S libreoffice-dev-bin        --noconfirm" $temporario
  su -c " yay -S megasync                   --noconfirm" $temporario
  su -c " yay -S mtnm                       --noconfirm" $temporario
  su -c " yay -S telegram-desktop-bin       --noconfirm" $temporario
  su -c " yay -S tilix                      --noconfirm" $temporario
  su -c " yay -S typora                     --noconfirm" $temporario
  su -c " yay -S dropbox                    --noconfirm" $temporario
  su -c " yay -S xfce4-dockbarx-plugin-git  --noconfirm" $temporario


  pacman -R virtualbox-host-dkms \
  virtualbox-sdk \
  virtualbox  --noconfirm

  wget -c http://bit.ly/arch-conf-zip
  unzip -o /pkg/arch-conf-zip -d /home/$usuario/

  chown $usuario. -Rvf /home/$usuario/*
  chown $usuario. -Rvf /home/$usuario/.*

  sudo sed -i /etc/lxdm/lxdm.conf \
       -e 's;^# session=/usr/bin/startlxde;session=/usr/bin/startxfce4;g'

  useradd $usuario -m ; echo $usuario:$senha | chpasswd
  xdg-user-dirs-update
  chsh -s /bin/zsh $usuario
  userdel $temporario
  systemctl enable sshd
  sudo systemctl enable lxdm

else

	echo "dd"

fi

#umount  /mnt/home
#umount /mnt
#reboot
