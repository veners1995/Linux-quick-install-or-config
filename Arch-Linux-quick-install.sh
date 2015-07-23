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
while true
do

	read -p "Do you have a swap partition? Y/N: " swap

	case ${swap} in
		Y|y)
			lsblk
			read -p "Enter the path of the swap partition: " swappart

			if [ $(echo ${swappart} | cut -c 1-4) != /dev ];then
				swappart=/dev/${swappart}
			fi

			if [ ! -e ${swappart} ];then
				echo "This partition doesn't exists. Please check your type."
			else
				break
			fi

			mkswap ${swappart} > /dev/null 2>&1
			swapoff ${swappart} > /dev/null 2>&1
			swapon ${swappart} > /dev/null 2>&1
			reset
			break
			;;
		N|n)
			break
			;;
		*)
			echo "Hey, your choose is wrong. Let's try again."
	esac
done

while true
do
	clear
	lsblk
	read -p "Enter the path of your root partition: " rootpart

	if [ $(echo ${rootpart} | cut -c 1-4) != /dev ];then
		rootpart=/dev/${rootpart}
	fi

	if [ ! -e ${rootpart} ];then
		echo "This partition doesn't exists. Please check your type."
	else
		break
	fi
done

echo -n "Do you have other partitions that need mount?(such as /home, /boot, etc.) Y/N: "

while true
do
	read mountother
	case ${mountother} in
		Y|y)
			lsblk
			echo -en "\nPlease enter the type of the partition that you want to mount(home、boot...): "
			read othertype

			echo -en "\nNow enter the path: "
			read otherpath

			if [ $(echo ${otherpath} | cut -c 1-4) != /dev ];then
				otherpath=/dev/${otherpath}
			fi

			if [ ! -e ${rootpart} ];then
				echo "This partition doesn't exists. Please check your type."
			else
				break
			fi

			read -p "Will mount ${otherpath} to /mnt/${othertype}. Are you sure? Y/N: " sure
			if [ ${sure} == Y ] || [ ${sure} == y ];then

				mkdir /mnt/${othertype}
				mount ${otherpath} /mnt/${othertype}
			fi
			echo -en " Do you have the other partitions that need mount? Y/N: "
			;;

		N|n)
			break
			;;
		*)
			echo -n "Hey, your choose is wrong. Let's try again: "
	esac
done

umount /mnt 2> /dev/null
mount -v ${rootpart} /mnt

curl "https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&ip_version=4" -o /root/mirrorlist
grep Server /root/mirrorlist | sed 's/^#//g' > /etc/pacman.d/mirrorlist
rm /root/mirrorlist > /dev/null 2>&1

pacstrap -i /mnt base base-devel
reset

echo "Well, install is finished, Let's do some config"
genfstab -U -p /mnt >> /mnt/etc/fstab
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



echo
read -p "Wich hostname would you like?: " hostnm
echo "\${hostnm}" > /etc/hostname

rm -f /etc/hosts > /dev/null 2>&1
echo "127.0.0.1       localhost.localdomain   localhost \${hostnm}" >> /etc/hosts 
echo "::1             localhost.localdomain   localhost \${hostnm}" >> /etc/hosts 



while true
do

echo -en "\n\nDo you need wireless? Y/N\n
(If you want, I'll install dialog and wpa_supplicant to run wifi-menu.): "
	read wireless

	case \${wireless} in
		Y|y)
			pacman -S --noconfirm dialog wpa_supplicant
			break
			;;
		N|n)
			break
			;;
		*)
			echo "Hey, your choose is wrong. Let's try again."
			;;
	esac
done




systemctl enable dhcpcd@\$(ls /sys/class/net/ | grep e)


echo -en "\nPlease enter your root password that you like: "

read -s rootpass
echo "root:\${rootpass}" | chpasswd


pacman -S --noconfirm grub


while true
do

echo -en "\n\nDo you need grub boot other system? Y/N\n
(If you want, I'll install os-prober): "
	read bootothersys

	case \${bootothersys} in
		Y|y)
			pacman -S --noconfirm os-prober
			break
			;;
		N|n)
			break
			;;
		*)
			echo "Hey, your choose is wrong. Let's try again."
			;;
	esac
done



grub-install --target=i386-pc --recheck $(echo "${rootpart}" | cut -c 1-8)
grub-mkconfig -o /boot/grub/grub.cfg
rm /root/*
FileEOF


arch-chroot /mnt /bin/bash /root/config.sh
umount /mnt 2> /dev/null
reset
echo -en "\e[1;31mThanks for use.\e[0m";echo -en "\e[1;36m Install\e[0m"; echo -e "\e[1;32m Finished.\e[0m"
echo -en "\e[1;35mDo you want reboot now? Y/N: \e[0m"

read reboot
if [ ${reboot} = Y ] | [ ${reboot} = y ];then
	reboot
fi
