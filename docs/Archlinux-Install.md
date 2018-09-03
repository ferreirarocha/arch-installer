# Parte 1 - Preparação do ambiente

```
ping google.com
```





Como pode perceber estamos usando o **sfdisk** esse tipo de particionamento é pouco convencional, e o  único motivo por tê-lo adotado nesse post   foi devido a sua simplicidade e eficácia na criação de  partições, porém você pode usar  o seu preferido, seja  cfdisk,  parted, fdisk…. e tantos outros.

```
fdisk -l
```



```
echo 'size=1GB, type=83, bootable
size=8GB, type=83 
size=11GB, type=83' | sfdisk /dev/sda
```



Optamos por utilizar o **EXT4** em todas as três partições do disco **/dev/sda**, criamos um label **-L** para  facilitar  a idenfiticação das partições numa futura manutenção.



```
mkfs.ext4 /dev/sda1 -L boot
```

```
mkfs.ext4 /dev/sda2 -L sistema
```

```
mkfs.ext4 /dev/sda3 -L usuario
```



Assim ficou nossa tabela de particionamento

|           |         |
| --------- | ------- |
| /dev/sda1 | boot    |
| /dev/sda2 | sistema |
| /dev/sda3 | usuario |



Montando as partições para utilizamos no **arch-root**


```
mount /dev/sda2 /mnt
```

```
mkdir /mnt/home /mnt/boot
```

```
mount /dev/sda1 /mnt/boot
```

```
mount /dev/sda3 /mnt/home
```



# Parte 2 - Instalação

O pacstrap instala pacotes no novo diretório raiz especificado. Se não houver pacotes especificados, o pacstrap usará o grupo "base", mas adicionaremos também o  grupo base-devel.

```
pacstrap /mnt base base-devel openssh wget
```



O genfstab gera saída adequada contendo as partições montadas acima no  arquivo /etc/fstab .

```
genfstab -U /mnt >> /mnt/etc/fstab
```



O arch-root , assim como o chroot é uma operação que muda o diretório root do processo corrente e de seus processos filhos. Um programa que é  executado em chroot em um outro diretório não pode acessar arquivos fora daquele diretório, e o diretório é chamado de "prisão chroot" .

```
arch-chroot /mnt bash
```



**Definindo a senha do root**

```
passwd root
```



Por comodidade remova o  arquivo  localtime, não se preocupe, vamos criá-lo logo em seguida com a localização específica.



```
rm /etc/localtime
```



```
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
```



```
hwclock --systohc --utc
```



### Alterando o arquivo de idioma padrão

```
sed -i s/\#pt_BR.UTF-8/pt_BR.UTF-8/g locale.gen
```



### Gerando  o  arquivo de  linguagem

```
locale-gen
```

```
echo LANG=pt_BR.UTF-8 > /etc/locale.conf
```

```
export LANG=pt_BR.UTF-8
```



### Alterando o hostname

```
echo alfabech > /etc/hostname
```



### Instalando o grub

```
pacman -S grub
```

```
grub-install /dev/sda
```

```
grub-mkconfig -o /boot/grub/grub.cfg
```



### Configurando  a rede e ssh



```
systemctl enable dhcpcd
```

```
systemctl enable sshd
```



## Configurando conta de usuário

Nesse momento criamos o usuário marcos, com permissão para  alguns grupos como vídeos,  eles são necessários para que este usuário possa utilizar a interface gráfica sem maiores problemas.



```
sudo useradd -m -G sys,lp,network,video,optical,storage,scanner,power,wheel marcos
```

```
passwd	usuario
```



Nesse momento basicamente  já temos o sistema instalado, inclusive já podemos  reiniciá-lo caso  necessário.



# Parte 3 - Pós instalação - Instalando o XFCE

![xfce4-1](Documentos/xfce4-1.png)



### **Instalando o xorg**

```
pacman -Syu	xorg xorg-server xorg-xinit
```



### **Instalando o XFCE4**

Optamos por instalar o XFCE  caso queira utilizar outro ambiente fique a vontade.

```
pacman -S xfce4 xfce4-goodies xf86-video-intel 			
```

```
pacman -S lxdm nautilus xdg-user-dirs ttf-dejavu ttf-droid 
```

```
sudo sed -i /etc/lxdm/lxdm.conf \
       -e 's;^# session=/usr/bin/startlxde;session=/usr/bin/startxfce4;g'
```

```
systemctl enable lxdm
```



# Parte 5 - Pós instalação - Reiniciando e logando no sistema

```
exit
```

```
umount /mnt
```

```
umount /mnt/home
```

```
umount /mnt/boot
```



```
reboot
```



![lxdm-login](assets/lxdm-login.png)





# Parte 4 - Pós instalação - Configurando o Pacman



### Configurando pacman

Utilizamos o sed para habilitar os repositórios multilib e multilib-testing, também  habilitamos o grupo wheel como administradores.





```
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
```

```
sed -i "/\[multilib-testing\]/,/Include/"'s/^#//' /etc/pacman.conf
```



# Parte 5 - Pós instalação - Configurando  permissão administrativa

```
sed  -i s/\# %wheel/%wheel/g /etc/sudoers
```



### Configurando mirrolist

O Reflector é um script que recupera a última lista de espelhos da página MirrorStatus, filtrar os espelhos mais atualizados, classificá-os por velocidade e sobrescreve o arquivo /etc/pacman.d/mirrorlist.



```
sudo pacman -S reflector
```

```
reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
```







# Parte 6 - Pós instalação - Instalando pulse áudio



```
pacman -Syu alsa-{utils,plugins,plugins,firmware} \
			pulseaudio pulseaudio-{equalizer,alsa}
```



# Parte 7 - Pós instalação - Instalando complementos

Instalando demais aplicações como vlc, openssh, compactadores.

```
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
```



# Parte 8 - Pós instalação - Instalando codecs

Para mais codes, visite o wiki.[^codecs]



```
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
```



# Parte 9 - Pós instalação - Instalando o Yay

Yet another Yogurt - An AUR Helper written in Go.[^yay] 

```
git clone https://aur.archlinux.org/yay.git
```

```
cd yay/
```

```
makepkg -si
```





[^codecs]: https://wiki.archlinux.org/index.php/Codecs 
[^yay]: https://github.com/Jguer/yay 