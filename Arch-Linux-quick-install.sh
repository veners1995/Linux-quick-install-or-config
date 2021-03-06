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
	echo "Must be root."
	exit
fi

clear

cat <<- EOF
欢迎使用Linux-quick-install-or-config

在您使用本脚本之前，请先详细阅读此文章：
https://wiki.archlinux.org/index.php/Beginners%27_guide

另外本脚本当前仅支持BIOS+MBR的电脑，如果您的电脑为UEFI引导
那么很抱歉本脚本暂时不能帮助您正常安装Arch，请开启兼容模式或是自行安装Arch

如果您使用的是BIOS引导的电脑或是已经开启兼容模式，那么请按回车继续。

EOF

read var
clear

cat <<- EOF
首先，请您先确保您的已经连接网络：

如果您已经成功连接网络，请按1

如果您打算手动配置网络，请按2
(当然您也可以使用这种方式检查您的网络连接状况)

如果您打算使用wifi-menu，请按3
(此方法适用于wifi用户)
EOF

while [[ ${network} != Done ]]
do
	select network in "Done" "manual" "wireless"
	do
		break
	done

	case ${network} in
		"Done")
			systemctl restart dhcpcd.service > /dev/null 2>&1
			;;
		"manual")
			zsh
			;;
		"wireless")
			wifi-menu
			;;
		*)
			echo -e "\e[31m\e[1m选择错误，请重试。\e[0m"
	esac
done
clear

cat << EOF
现在您需要手动进行分区，我们当前并没有自动分区的功能
当您结束分区后，请按<Ctrl+D>以终止。

您可以在这里找到怎样使用命令行工具来分区
https://wiki.archlinux.org/index.php/Beginners%27_guide#Prepare_the_storage_devices


EOF
echo -e "\e[32m\e[1m提示：当您分区结束后请直接按<Ctrl+D>。您并不需要手动挂载分区。\e[0m"
zsh
clear


echo -e "很高兴您已经完成了，现在让我们来开始安装吧\n"
while true
do

	read -p "请问您有一个交换分区(swap)吗？请输入Y/n：" swap

	case ${swap} in
		Y|y)
			lsblk
			read -p "请输入该分区的“编号”，如sda5或/dev/sda5：" swappart

			if [ $(echo ${swappart} | cut -c 1-4) != /dev ];then
				swappart=/dev/${swappart}
			fi

			if [ ! -e ${swappart} ];then
				echo -e "\e[32m\e[1m此分区并不存在，请检查您的拼写并重新输入\e[0m"
			else
				break
			fi

			mkswap ${swappart} > /dev/null 2>&1
			swapoff ${swappart} > /dev/null 2>&1
			swapon ${swappart} > /dev/null 2>&1
			clear
			break
			;;
		N|n)
			break
			;;
		*)
			echo -e "\e[31m\e[1m选择错误，请重试。\e[0m"
	esac
done

while true
do
	clear
	lsblk
	read -p "现在请输入您打算安装Arch的分区：" rootpart

	if [ $(echo ${rootpart} | cut -c 1-4) != /dev ];then
		rootpart=/dev/${rootpart}
	fi

	if [ ! -e ${rootpart} ];then
		echo "This partition doesn't exists. Please check your type."
	else
		break
	fi
done


echo -en "\n请问您还有类似于home，boot之类的分区吗？请输入Y/n："

clear
while true
do
	read mountother
	case ${mountother} in
		Y|y)
			lsblk
			echo -en "\n请输入分区类型（home，boot等）："
			read othertype

			echo -en "\n现在请输入分区编号："
			read otherpath

			if [ $(echo ${otherpath} | cut -c 1-4) != /dev ];then
				otherpath=/dev/${otherpath}
			fi

			if [ ! -e ${rootpart} ];then
				echo -e "\e[32m\e[1m此分区并不存在，请检查您的拼写并重新输入\e[0m"
			else
				break
			fi

			read -p "Will mount ${otherpath} to /mnt/${othertype}. Are you sure? Y/N: " sure
			if [ ${sure} == Y ] || [ ${sure} == y ];then

				mkdir /mnt/${othertype}
				mount ${otherpath} /mnt/${othertype}
			fi
			echo -en "还有其他的分区吗？请输入Y/n："
			;;

		N|n)
			break
			;;
		*)
			echo -e "\e[31m\e[1m选择错误，请重试。\e[0m"
	esac
done

umount /mnt 2> /dev/null
clear

mount -v ${rootpart} /mnt
curl "https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&ip_version=4" -o /tmp/mirrorlist
grep Server /root/mirrorlist | sed 's/^#//g' > /etc/pacman.d/mirrorlist

pacstrap -i /mnt base base-devel
clear

echo "恭喜您安装完成了，现在我们可以开始进行一些配置了："
genfstab -U -p /mnt >> /mnt/etc/fstab

cat >> /mnt/tmp/config.sh << FileEOF
cat >>/etc/locale.gen <<- EOF
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
zh_TW.UTF-8 UTF-8
EOF


locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc



echo
read -p "请问您打算使用什么主机名：" hostnm
echo "\${hostnm}" > /etc/hostname

rm -f /etc/hosts > /dev/null 2>&1
echo "127.0.0.1       localhost.localdomain   localhost \${hostnm}" >> /etc/hosts 
echo "::1             localhost.localdomain   localhost \${hostnm}" >> /etc/hosts 



while true
do

	cat <<- EOF 


	请问您需要使用Wifi吗？请输入Y/n
	如果您需要，我们将为您安装dialog和wpa_supplicant以便使用wifi-menu)：
	EOF
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

	cat <<- EOF 


	请问您需要grub引导其他的操作系统吗？请输入Y/n
	如果您需要，我们将为您安装os-prober)：
	EOF
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
FileEOF

arch-chroot /mnt /bin/bash /tmp/config.sh
umount /mnt 2> /dev/null

reset
echo -en "\e[1;31m感谢您的使用\e[0m";echo -en "\e[1;36m安装\e[0m"; echo -e "\e[1;32m已完成！\e[0m"
echo -en "\e[1;35m请问您现在需要重启吗？请输入Y/N：\e[0m"

read reboot
if [ ${reboot} = Y ] | [ ${reboot} = y ];then
	reboot
fi
