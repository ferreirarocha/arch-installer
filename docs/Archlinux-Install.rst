.. _header-n0:

Parte 1 - Preparação do ambiente
================================

.. code:: 

   ping google.com

Como pode perceber estamos usando o **sfdisk** esse tipo de
particionamento é pouco convencional, e o único motivo por tê-lo adotado
nesse post foi devido a sua simplicidade e eficácia na criação de
partições, porém você pode usar o seu preferido, seja cfdisk, parted,
fdisk…. e tantos outros.

.. code:: 

   fdisk -l

.. code:: 

   echo 'size=1GB, type=83, bootable
   size=8GB, type=83 
   size=11GB, type=83' | sfdisk /dev/sda

Optamos por utilizar o **EXT4** em todas as três partições do disco
**/dev/sda**, criamos um label **-L** para facilitar a idenfiticação das
partições numa futura manutenção.

.. code:: 

   mkfs.ext4 /dev/sda1 -L boot

.. code:: 

   mkfs.ext4 /dev/sda2 -L sistema

.. code:: 

   mkfs.ext4 /dev/sda3 -L usuario

Assim ficou nossa tabela de particionamento

+-----------+---------+
|           |         |
+===========+=========+
| /dev/sda1 | boot    |
+-----------+---------+
| /dev/sda2 | sistema |
+-----------+---------+
| /dev/sda3 | usuario |
+-----------+---------+

Montando as partições para utilizamos no **arch-root**

.. code:: 

   mount /dev/sda2 /mnt

.. code:: 

   mkdir /mnt/home /mnt/boot

.. code:: 

   mount /dev/sda1 /mnt/boot

.. code:: 

   mount /dev/sda3 /mnt/home

.. _header-n38:

Parte 2 - Instalação
====================

O pacstrap instala pacotes no novo diretório raiz especificado. Se não
houver pacotes especificados, o pacstrap usará o grupo "base", mas
adicionaremos também o grupo base-devel.

.. code:: 

   pacstrap /mnt base base-devel openssh wget

O genfstab gera saída adequada contendo as partições montadas acima no
arquivo /etc/fstab .

.. code:: 

   genfstab -U /mnt >> /mnt/etc/fstab

O arch-root , assim como o chroot é uma operação que muda o diretório
root do processo corrente e de seus processos filhos. Um programa que é
executado em chroot em um outro diretório não pode acessar arquivos fora
daquele diretório, e o diretório é chamado de "prisão chroot" .

.. code:: 

   arch-chroot /mnt bash

**Definindo a senha do root**

.. code:: 

   passwd root

Por comodidade remova o arquivo localtime, não se preocupe, vamos
criá-lo logo em seguida com a localização específica.

.. code:: 

   rm /etc/localtime

.. code:: 

   ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

.. code:: 

   hwclock --systohc --utc

.. _header-n59:

Alterando o arquivo de idioma padrão
------------------------------------

.. code:: 

   sed -i s/\#pt_BR.UTF-8/pt_BR.UTF-8/g locale.gen

.. _header-n62:

Gerando o arquivo de linguagem
------------------------------

.. code:: 

   locale-gen

.. code:: 

   echo LANG=pt_BR.UTF-8 > /etc/locale.conf

.. code:: 

   export LANG=pt_BR.UTF-8

.. _header-n67:

Alterando o hostname
--------------------

.. code:: 

   echo alfabech > /etc/hostname

.. _header-n70:

Instalando o grub
-----------------

.. code:: 

   pacman -S grub

.. code:: 

   grub-install /dev/sda

.. code:: 

   grub-mkconfig -o /boot/grub/grub.cfg

.. _header-n75:

Configurando a rede e ssh
-------------------------

.. code:: 

   systemctl enable dhcpcd

.. code:: 

   systemctl enable sshd

.. _header-n80:

Configurando conta de usuário
-----------------------------

Nesse momento criamos o usuário marcos, com permissão para alguns grupos
como vídeos, eles são necessários para que este usuário possa utilizar a
interface gráfica sem maiores problemas.

.. code:: 

   sudo useradd -m -G sys,lp,network,video,optical,storage,scanner,power,wheel marcos

.. code:: 

   passwd	usuario

Nesse momento basicamente já temos o sistema instalado, inclusive já
podemos reiniciá-lo caso necessário.

.. _header-n88:

Parte 3 - Pós instalação - Instalando o XFCE
============================================

.. figure:: /home/marcos/docs/Documentos/xfce4-1.png
   :alt: 

.. _header-n91:

**Instalando o xorg**
---------------------

.. code:: 

   pacman -Syu	xorg xorg-server xorg-xinit

### **Instalando o XFCE4**

Optamos por instalar o XFCE caso queira utilizar outro ambiente fique a
vontade.

.. code:: 

   pacman -S xfce4 xfce4-goodies xf86-video-intel 			

.. code:: 

   pacman -S lxdm nautilus xdg-user-dirs ttf-dejavu ttf-droid 

.. code:: 

   sudo sed -i /etc/lxdm/lxdm.conf \
          -e 's;^# session=/usr/bin/startlxde;session=/usr/bin/startxfce4;g'

.. code:: 

   systemctl enable lxdm

.. _header-n101:

Parte 5 - Pós instalação - Reiniciando e logando no sistema
===========================================================

.. code:: 

   exit

.. code:: 

   umount /mnt

.. code:: 

   umount /mnt/home

.. code:: 

   umount /mnt/boot

.. code:: 

   reboot

.. figure:: /home/marcos/docs/assets/lxdm-login.png
   :alt: 

.. _header-n112:

Parte 4 - Pós instalação - Configurando o Pacman
================================================

.. _header-n114:

Configurando pacman
-------------------

Utilizamos o sed para habilitar os repositórios multilib e
multilib-testing, também habilitamos o grupo wheel como administradores.

.. code:: 

   sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

.. code:: 

   sed -i "/\[multilib-testing\]/,/Include/"'s/^#//' /etc/pacman.conf

.. _header-n121:

Parte 5 - Pós instalação - Configurando permissão administrativa
================================================================

.. code:: 

   sed  -i s/\# %wheel/%wheel/g /etc/sudoers

.. _header-n124:

Configurando mirrolist
----------------------

O Reflector é um script que recupera a última lista de espelhos da
página MirrorStatus, filtrar os espelhos mais atualizados, classificá-os
por velocidade e sobrescreve o arquivo /etc/pacman.d/mirrorlist.

.. code:: 

   sudo pacman -S reflector

.. code:: 

   reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

.. _header-n132:

Parte 6 - Pós instalação - Instalando pulse áudio
=================================================

.. code:: 

   pacman -Syu alsa-{utils,plugins,plugins,firmware} \
   			pulseaudio pulseaudio-{equalizer,alsa}

.. _header-n136:

Parte 7 - Pós instalação - Instalando complementos
==================================================

Instalando demais aplicações como vlc, openssh, compactadores.

.. code:: 

   pacman -Syu openssh \
   			exfat-utils \
     			vlc \
     			tar \
     			unzip \
     			p7zip \
     			unrar \
     			rsync \
     			file-roller \
     			go \
     			git
     			screenfetch \
     			archlinux-keyring

.. _header-n140:

Parte 8 - Pós instalação - Instalando codecs
============================================

Para mais codes, visite o wiki. [1]_

.. code:: 

   pacman -Syu a52dec \
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
   			xvidcore

.. _header-n145:

Parte 9 - Pós instalação - Instalando o Yay
===========================================

Yet another Yogurt - An AUR Helper written in Go. [2]_

.. code:: 

   git clone https://aur.archlinux.org/yay.git

.. code:: 

   cd yay/

.. code:: 

   makepkg -si

.. [1]
   https://wiki.archlinux.org/index.php/Codecs

.. [2]
   https://github.com/Jguer/yay
