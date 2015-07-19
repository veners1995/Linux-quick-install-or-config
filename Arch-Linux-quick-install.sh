#!/bin/bash
#
# Copyright 2015 Guanrenfu
#
# Licensed under the Apache License, Version 2.0 (the License); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
# 
#     http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an AS IS BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 
if [ ${UID} != 0 ];then
	echo "You're not root. You need run this script as root."
fi

reset

cat << EOF
Welcome to the "Linux-quick-install-or-config".
(Version: Arch-Linux-quick-config, last change: July 18-2015)

Hey, If you want to use this script. Please read this Document frist: 
https://wiki.archlinux.org/index.php/Beginners%27_guide

And this version can only for BIOS and MBR computer.
Yeah, we'll add UEFI and GPT support, but not now. 

So if you're using a new comptuer, just press <Ctrl+C> :)
If this comptuer use BIOS and MBR, please press Enter and continue.
EOF

read null
reset

cat << EOF
First you need to check your connection: 

If you have connect to the Internet, enter 1.
If you want to connect manual, enter 2.

"If you choose this, the script will open a shell.
When you done, you should press <Ctrl+D> or enter exit.
You also could use this to check you connection."

If you want to use wireless, enter 3.

"This will use wifi-menu. If it doesn't work, please use wired or choose 2."


And if you're using wired, just enter 1.
EOF


select network in "done" "manual" "wireless"
do
	case ${network} in
		"done")
			systemctl restart dhcpcd.service > /dev/null 2>&1
			break
			;;
		"manual")
			zsh
			;;
		"wireless")
			wifi-menu
			;;
		*)
			echo "Hey, your choose is wrong. Let's try again."
	esac
done

reset

cat << EOF
Now you need to start partition. When you done, press <Ctrl+D> or enter exit.

And we don't have auto partition feature.

Here you can learn how to partition use parted, fdisk, or gdisk:
https://wiki.archlinux.org/index.php/Beginners%27_guide#Prepare_the_storage_devices

And if you have already partitioned. Don't do anything and press <Ctrl+D> or enter exit.
And please format all partition! But you don't need to mount them.
EOF

zsh
reset

echo -e "I think you've done the partition, so let's install now.\n"
read -p "Do you have a swap partition? Y/N: " swap
lsblk

case ${swap} in
	Y|y)
		read -p "Enter the path of the swap partition(Like /dev/sda5, or just sda5): " swappart
		if [ $(echo ${swappart} | cut -c 1-4) != /dev ];then
			swappart=/dev/${swappart};
		fi
		mkswap ${swappart} > /dev/null 2>&1
		swapoff ${swappart} > /dev/null 2>&1
		swapon ${swappart} > /dev/null 2>&1
		echo ""
		;;
	N|n)
		echo ""
		;;
	*)
		echo "Hey, your choose is wrong. Let's try again."
		echo ""
esac

read -p "Enter the path of your root partition: " rootpart
if [ $(echo ${rootpart} | cut -c 1-4) != /dev ];then
	rootpart=/dev/${rootpart}
fi

umount /mnt
mount ${rootpart} /mnt

curl "https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&ip_version=4" -o /root/mirrorlist
grep Server /root/mirrorlist | sed 's/^#//g' > /etc/pacman.d/mirrorlist
rm /root/mirrorlist > /dev/null 2>&1

pacstrap -i /mnt base base-devel
reset

echo "Well, install is finished, Let's do some config"
genfstab -U -p /mnt >> /mnt/etc/fstab
export rootpart ${rootpart}
mkdir /mnt/root


cat >/mnt/root/config.sh << FileEOF
#!/bin/bash
cat >>/etc/locale.gen << EOF
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
zh_TW.UTF-8 UTF-8
EOF


locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc



read -p "Wich hostname do you like?: " host
echo ${host} > /etc/hostname
grep 1 /etc/hosts > /root/hosts
echo "$(sed -n '1p' /root/hosts) ${host}" > /etc/hosts 
echo "$(sed -n '2p' /root/hosts) ${host}" > /etc/hosts 



echo -en "Do you need wireless? Y/N\n
(If you want, I'll install dialog to run wifi-menu.): "
read wireless



if [ ${wireless} = Y ] | [ ${wireless} = y ];then
	pacman -S --noconfirm dialog
fi



ifn=$(ls /sys/class/net/|grep e)
systemctl enable dhcpcd@${ifn}



read -p "Please enter your root password that you like: " rootpass
echo -e "${rootpass}\n${rootpass}"|passwd



pacman -S --noconfirm grub
pacman -S --noconfirm os-prober
grub-install --target=i386-pc --recheck $(echo "${rootpart}" | cut -c 1-8)
grub-mkconfig -o /boot/grub/grub.cfg
FileEOF


arch-chroot /mnt /bin/bash /root/config.sh

reset
echo -en "\e[1;31mThanks for use.\e[0m";echo -en "\e[1;36m Install\e[0m"; echo -e "\e[1;32m Finished.\e[0m"
echo -e "\e[1;35mDo you want reboot now? Y/N: \e[0m"

read reboot
if [ ${reboot} = Y ] | [ ${reboot} = y ];then
	reboot
fi
