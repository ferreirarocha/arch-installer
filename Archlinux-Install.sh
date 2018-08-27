#wifi-menu
usuario=marcos
senha=12345
host=kleper

if [ $1 = pre-install ];then
cat << EOF > /etc/netctl/wlp3s1-Edivan2
  Description='Automatically generated profile by wifi-menu'
  Interface=wlp3s1
  Connection=wireless
  Security=wpa
  ESSID=Edivan2
  IP=dhcp
  Key=KLOpeNLibre10
EOF

  cd /etc/netctl
  sudo  netctl start wlp3s1-Edivan2


  cfdisk /dev/sda

  mkfs.ext4 /dev/sda1
  mkfs.ext4 /dev/sda2

  mount /dev/sda1 /mnt
  mkdir /mnt/home
  mount /dev/sda2 /mnt/home

  pacstrap /mnt base base-devel

  genfstab -U /mnt >> /mnt/etc/fstab
  wget -P /mnt http://bit.ly/arch-installer

  arch-chroot /mnt

elif [ $1 = install ]; then
cat << EOF > /etc/netctl/ens3
  Description='A basic dhcp ethernet connection'
  Interface=ens3
  Connection=ethernet
  IP=dhcp
EOF

  cd /etc/netctl
  sudo  netctl start ens3

  rm /etc/localtime
  ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

  hwclock --systohc --utc

  sed  s/\#pt_BR.UTF-8/pt_BR.UTF-8/g  /etc/locale.gen > ds ; cp ds /etc/locale.gen

  locale-gen

  echo LANG=pt_BR.UTF-8 > /etc/locale.conf
  export LANG=pt_BR.UTF-8

  echo $host > /etc/hostname

  pacman -S grub --noconfirm

  grub-install /dev/sda

  grub-mkconfig -o /boot/grub/grub.cfg


  curl 'https://www.archlinux.org/mirrorlist/?country=BR&protocol=http&protocol=https&ip_version=4' > mirrorlist ; sed s/#Server/Server/g  mirrorlist > /etc/pacman.d/mirrorlist

  #nano  /etc/pacman.conf
  wget -P /etc/ https://raw.githubusercontent.com/ferreirarocha/arch-installer/master/pacman.conf

  pacman -Syu

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
  archlinux-keyring --noconfirm

  useradd $usuario -m ; echo $usuario:$senha | chpasswd
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
  #usermod -aG libvirt $usuario


  mkdir -m 777 pkg
  cd pkg
  sudo -u marcos -H sh -c "git clone https://aur.archlinux.org/yay.git; cd yay/ ; makepkg -si --noconfirm"

  su -c " yay -S file-roller \
  libreoffice-dev-bin \ksuperkey \
  typora \
  tilix \
  inkscape \
  gimp \
  atom \
  hunspell-pt-br \
  mtnm \
  xfce4-dockbarx-plugin-git \
  bind-tools \
  exfat-utils \
  xdg-user-dir \
  exfat-fuse \
  albert --noconfirm " marcos

  pacman -R virtualbox-host-dkms \
  virtualbox-sdk \
  virtualbox  --noconfirm


  xdg-user-dirs-update
  chsh -s /bin/zsh $usuario
  scp marcos@192.168.1.105:/home/marcos/conf.zip /home/marcos/
  unzip /home/marcos/conf.zip -d /home/marcos/
  chown marcos. -Rf /home/marcos/.*


  sudo sed -i /etc/lxdm/lxdm.conf \
       -e 's;^# session=/usr/bin/startlxde;session=/usr/bin/startxfce4;g'


  systemctl enable sshd
  sudo systemctl enable lxdm

else

	echo "dd"

fi
