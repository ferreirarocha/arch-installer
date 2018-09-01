#wifi-menu
version=1.0
usuario=marcos
senha=12345
host=kleper1
temporario=temporario
sistema=/dev/sda1
home=/dev/sda2

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

  mkfs.ext4 $sistema
  mkfs.ext4 $home

  mount $sistema /mnt
  mkdir /mnt/home
  mount $home /mnt/home

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



  #usermod -aG libvirt $usuario
  wget -O  /etc/sudoers https://raw.githubusercontent.com/ferreirarocha/arch-installer/master/sudoers
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
  su -c " yay -S google-chrome              --noconfirm" $temporario
  su -c " yay -S firefox                    --noconfirm" $temporario
  su -c " yay -S xfce4-dockbarx-plugin-git  --noconfirm" $temporario
  su -c " yay -S ntfs-3g                    --noconfirm" $temporario
  su -c " yay -S ocs-url                    --noconfirm" $temporario
  su -c " yay -S xpdf                       --noconfirm" $temporario
  su -c " yay -S gthumb                     --noconfirm" $temporario
  su -c " yay -S gparted                    --noconfirm" $temporario
  su -c " yay -S gitkraken                  --noconfirm" $temporario
  su -c " yay -S sigil                      --noconfirm" $temporario

  su -c " yay -S kdenlive \
                 frei0r-plugins \
                 oxygen-icons \
                 breeze \
                 breeze-gtk \
                 dvdauthor \
                 kde-gtk-config
                 --noconfirm" $temporario


  rm /etc/skel/.*
  git clone  https://github.com/ferreirarocha/myconf.git /etc/skel/
  rm /etc/skel/LICENSE
  rm /etc/skel/README.md
  rm /etc/skel/.git

  useradd $usuario -m ; echo $usuario:$senha | chpasswd
  sed -i s/usuario/$usuario/g /home/$usuario/.zshrc

  chown $usuario. -Rvf /home/$usuario/*
  chown $usuario. -Rvf /home/$usuario/.*

  pacman -R virtualbox-host-dkms \
  virtualbox-sdk \
  virtualbox  --noconfirm

  pacman -R xfce4-terminal
  pacman -R ristretto
  pacman -R thunar-archive-plugin
  pacman -R thunar-volman
  pacman -R thunar-media-tags-plugin
  pacman -R thunar

  sudo sed -i /etc/lxdm/lxdm.conf \
       -e 's;^# session=/usr/bin/startlxde;session=/usr/bin/startxfce4;g'

  xdg-user-dirs-update
  chsh -s /bin/zsh $usuario
  userdel -r -f $temporario

  sed  -i s/%wheel/\#%wheel/g /etc/sudoers

  # Instalando o KAS Key Access ssh
  wget bit.ly/install-kas ; bash install-kas --install


  systemctl enable sshd
  sudo systemctl enable lxdm
  exit

else

	echo "dd"

fi

umount  /mnt/home
umount /mnt
echo -e "Arch Linux instalado reinicie o sistema"
