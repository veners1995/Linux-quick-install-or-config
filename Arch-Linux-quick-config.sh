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

mv -f continue.sh continue.sh.backup 2>> /dev/null

#将安装软件所需命令放入关联数组
declare -A softwareInstallCmd
#软件
softwareInstallCmd['gvim']='sudo pacman -S --noconfirm gvim'
softwareInstallCmd['emacs']='sudo pacman -S --noconfirm emacs'
softwareInstallCmd['gedit']='sudo pacman -S --noconfirm gedit'
softwareInstallCmd['leafpad']='sudo pacman -S --noconfirm leafpad'
softwareInstallCmd['smplayer']='sudo pacman -S --noconfirm smplayer'
softwareInstallCmd['vlc']='sudo pacman -S --noconfirm vlc'
softwareInstallCmd['mpv']='sudo pacman -S --noconfirm mpv'
softwareInstallCmd['firefox']='sudo pacman -S --noconfirm firefox'
softwareInstallCmd['opera']='sudo pacman -S --noconfirm opera'
#桌面环境
softwareInstallCmd['gnome']='sudo pacman -S --noconfirm gnome'
softwareInstallCmd['plasma']='sudo pacman -S --noconfirm plasma'
softwareInstallCmd['xfce4']='sudo pacman -S --noconfirm xfce4'
softwareInstallCmd['cinnamon']='sudo pacman -S --noconfirm {cinnamon,gnome-screenshot,mate-terminal,evince,viewnior,file-roller}'
softwareInstallCmd['mate']='sudo pacman -S --noconfirm mate'

function chooseSoftware
{
	PS3='请输入选项：'
	select choose in "$@";do
		if [ ${choose:-NONE} == 'NONE' ];then
			continue;
		elif [ ${choose} != '不安装' ];then
			echo -e ${softwareInstallCmd[${choose}]} >> continue.sh
			break
		else
			echo '#${choose}' >> continue.sh
			break
		fi
	done
}


if [ $(getconf LONG_BIT) = 64 ];then
	sed -i '92,93d' /etc/pacman.conf >> /dev/null 2>&1
	sed -i '91a Include = /etc/pacman.d/mirrorlist' /etc/pacman.conf >> /dev/null 2>&1
	sed -i '91a [multilib]' /etc/pacman.conf >> /dev/null 2>&1
	pacman -Syu --noconfirm >> /dev/null 2>&1
fi


sed -i '33d' /etc/pacman.conf >> /dev/null 2>&1
sed -i '32a Color' /etc/pacman.conf >> /dev/null 2>&1
sed -i '34d' /etc/pacman.conf >> /dev/null 2>&1
sed -i '33a TotalDownload' /etc/pacman.conf >> /dev/null 2>&1
sed -i '36d' /etc/pacman.conf >> /dev/null 2>&1
sed -i '35a VerbosePkgLists' /etc/pacman.conf >> /dev/null 2>&1

reset
cat << EOF
欢迎来到Linux-quick-install-or-config.
（版本：Arch-Linux-quick-config, 2015年7月18日更新）

首先，我们要为您创建一个普通用户（此用户为wheel用户组，可以使用sudo）

EOF


read -p "您的新用户的用户名：" usrnm

#这里使用until来智能判断用户名是否合法，感谢@鼠标乱飘 提供的命令。
until [[ "${usrnm}" =~ ^[[:lower:]] ]]
do
      	echo -e "\n用户名必须以小写英文字母开头！"
	read -p "您的新用户的用户名：" usrnm
done



read -s -p "您的新用户的密码：" usrpasswd
useradd -m -G wheel -s /bin/bash ${usrnm}
echo "${usrnm}:${usrpasswd}" | chpasswd

if [ ! -n "${usrnm}" ];then
	echo ""
else
	sed -i "73a ${usrnm} ALL=(ALL) ALL" /etc/sudoers
fi
clear



echo
echo "#安装必要组件" >> continue.sh
echo "sudo pacman -S --noconfirm wget" >> continue.sh
echo "sudo pacman -S --noconfirm git" >> continue.sh
echo "sudo pacman -S --noconfirm ntfs-3g" >> continue.sh
echo "sudo pacman -S --noconfirm dosfstools" >> continue.sh
echo "sudo pacman -S --noconfirm wqy-microhei" >> continue.sh
echo "sudo pacman -S --noconfirm xorg-server" >> continue.sh
echo "sudo pacman -S --noconfirm xorg-xinit" >> continue.sh
echo "cp /etc/X11/xinit/xinitrc ~/.xinitrc" >> continue.sh
echo "sed -i '\$d' ~/.xinitrc" >> continue.sh
echo >> continue.sh



echo "请问您是否想安装Yaourt？Yaourt作为pacman的一个外壳增加了对AUR的支持。"

while true
do
	read -n1 -p "请输入Y或N：" yaourt
	echo
	if [ ${yaourt} = Y ] || [ ${yaourt} = y ];then
		echo "#安装Yaourt" >> continue.sh
		echo "mkdir yaourt" >> continue.sh
		echo "cd yaourt" >> continue.sh
		echo >> continue.sh
		
		echo "##安装依赖：package-query" >> continue.sh
		echo "wget https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz" >> continue.sh
		echo "tar zxf package-query.tar.gz" >> continue.sh
		echo "cd package-query" >> continue.sh
		echo "yes|makepkg -si" >> continue.sh
		echo "cd .." >> continue.sh
		echo >> continue.sh
		
		echo "##开始安装Yaourt" >> continue.sh
		echo "wget https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz" >> continue.sh
		echo "tar zxf yaourt.tar.gz" >> continue.sh
		echo "cd yaourt" >> continue.sh
		echo "yes|makepkg -si" >> continue.sh
		echo "cd .." >> continue.sh
		echo "rm -rf yaourt" >> continue.sh
		echo >> continue.sh
		break
	elif [ ${yaourt} = N ] || [ ${yaourt} = n ];then
		echo "#不安装Yaourt" >> continue.sh
		break
	fi
done
clear



echo "请问您是否想安装Zsh？Zsh拥有比默认的Bash更加方便的设置与外观。"

while true
do
	read -n1 -p "请输入Y或N：" zsh
	echo

	if [ ${zsh} = Y ] || [ ${zsh} = y ];then
		echo "#安装zsh" >> continue.sh
		pacman -S --noconfirm zsh
		git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
		cp -rf ~/.oh-my-zsh /home/${usrnm}/.oh-my-zsh
		cp -f ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
		chsh -s /bin/zsh
		echo "cp -f ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc" >> continue.sh
		echo "chsh -s /bin/zsh" >> continue.sh
		echo >> continue.sh
		break
	elif [ ${zsh} = N ] || [ ${zsh} = n ];then
		echo "#不安装Zsh" >> continue.sh
		break
	fi
done
clear



cat << EOF
现在请您选择一个桌面环境：我们默认提供Gnome、Plasma（KDE5）、Xfce4、Cinnamon、和Mate

如果没有您需要的（如窗口管理器，我们将在下个版本添加）或是您不需要桌面环境
那么请选择不安装然后自行安装您喜欢的桌面环境（或窗口管理器）


我们还提供一些扩展包，这些将会在您选择您喜欢的桌面环境后提供选择。

EOF



read -p "请按回车继续"  var
clear
echo "现在，请选择一个桌面环境：1、gnome  2、plasma  3、xfce4  4、cinnamon  5、mate。  6、不安装"
echo
echo "#安装桌面环境" >> continue.sh



echo
chooseSoftware 'gnome' 'plasma' 'xfce4' 'cinnamon' 'mate' '不安装桌面环境'
#choose为保存用户选项的全局变量，定义于chooseSoftware函数中


case ${choose} in
gnome)
	echo "echo 'exec gnome-session' >> ~/.xinitrc" >> continue.sh
	clear
	echo "请问您是否要安装${choose}扩展包？其中包含了很多${choose}的原生软件和一些主题等（建议安装）"
	echo
	while true
	do
		read -n1 -p "请输入Y/N：" ge
		echo
		if [ ${ge} = Y ] || [ ${ge} = y ];then
			echo "sudo pacman -S --noconfirm gnome-extra" >> continue.sh
			break
		elif [ ${ge} = N ] || [ ${ge} = n ];then
			break
		fi
	done
	echo >> continue.sh
;;

plasma)	
	echo "echo 'exec startkde' >> ~/.xinitrc" >> continue.sh
	echo >> continue.sh
;;

xfce4)	
	echo "echo 'exec startxfce4' >> ~/.xinitrc" >> continue.sh
	echo >> continue.sh
	clear
	echo "请问您是否要安装${choose}扩展包？其中包含了很多${choose}的原生软件和一些主题等（建议安装）"
	echo
	while true
	do
		read -n1 -p "请输入Y/N：" ge
		echo
		if [ ${ge} = Y ] || [ ${ge} = y ];then
			break
			echo "sudo pacman -S --noconfirm xfce4-goodies" >> continue.sh
		elif [ ${ge} = N ] || [ ${ge} = n ];then
			break
		fi
	done
	echo >> continue.sh
;;

cinnamon)	
	echo "echo 'exec cinnamon-session' >> ~/.xinitrc" >> continue.sh
	clear
	echo >> continue.sh
;;

mate)	
	echo "echo 'exec mate-session' >> ~/.xinitrc" >> continue.sh
	clear
	echo "请问您是否要安装${choose}扩展包？其中包含了很多${choose}的原生软件和一些主题等（建议安装）"
	echo
	while true
	do
		read -n1 -p "请输入Y/N：" ge
		echo
		if [ ${ge} = Y ] || [ ${ge} = y ];then
			echo "sudo pacman -S  --noconfirm mate-extra" >> continue.sh
			break
		elif [ ${ge} = N ] || [ ${ge} = n ];then
			break
		fi
	done
	echo >> continue.sh
	break
;;
esac




clear
echo "恭喜您完成了多半的配置了，现在让我们来看一下几个日常用的软件吧："
echo
echo "#安装Networkmanager网络管理器" >> continue.sh
echo "sudo pacman -S --noconfirm networkmanager" >> continue.sh
echo "sudo systemctl enable NetworkManager" >> continue.sh
echo "sudo systemctl start NetworkManager" >> continue.sh
echo >> continue.sh

cat << EOF
首先，我们要为您安装中文输入法。

本版本仅支持fcitx框架+Googlepinyin输入法

但是如果您习惯使用Ibus或是五笔输入法（以及其他的如搜狗输入法等）的话请不要安装。


所以，请根据您的需求输入Y/N。

EOF


while true
do
	read -n1 -p "请输入Y/N：" fci
	echo
	if [ ${fci} = Y ] || [ ${fci} = y ];then
		echo "#安装中文输入法" >> continue.sh
		echo "sudo pacman -S --noconfirm fcitx" >> continue.sh
		echo "sudo pacman -S --noconfirm fcitx-im" >> continue.sh
		echo "sudo pacman -S --noconfirm fcitx-qt5" >> continue.sh
		echo "sudo pacman -S --noconfirm fcitx-googlepinyin" >> continue.sh
		echo "sudo pacman -S --noconfirm fcitx-configtool" >> continue.sh
		echo >> continue.sh
		break
	elif [ ${fci} = N ] || [ ${fci} = n ];then
		echo "#不安装中文输入法" >> continue.sh
		echo
		break
	fi
done
clear



cat << EOF
您现在可以选择一个自己熟悉的文本编辑器了，我们共提供了4款编辑器：分别是emacs、gvim、gedit和leafpad。

其中，emacs和gvim属于专业编辑器。如果您对其不了解不要选择，而gedit和leafpad更加简单易用，大家可以随意挑选。


现在，请像刚才选择桌面环境那样选择文本编辑器吧：1、gvim  2、emace 3、gedit 4、leafpad  5、不安装

EOF

echo "#安装文本编辑器" >> continue.sh

chooseSoftware 'gvim' 'emacs' 'gedit' 'leafpad' '不安装文本编辑器'
echo >> continue.sh

if [ ${choose} == 'gvim' ];then
	mv -f /etc/vimrc /etc/vimrc.backup 2> /dev/null
	echo "set nocompatible" > /etc/vimrc
	echo "set nu" >> /etc/vimrc
	echo "filetype indent on" >> /etc/vimrc
	echo "syntax enable" >> /etc/vimrc
	echo "colorscheme murphy" >> /etc/vimrc
	echo "set nobackup" >> /etc/vimrc
	echo "set nowritebackup" >> /etc/vimrc
	echo "set noswapfile" >> /etc/vimrc
	echo "set wrapscan" >> /etc/vimrc
	echo "set ruler" >> /etc/vimrc
	echo "set backspace=indent,eol,start" >> /etc/vimrc
fi
clear



cat << EOF
现在，我们来挑选一个音视播放器。本版本提供SMPlayer、mpv和VLC。


请选择您喜欢的播放器，选择smplayer请输入1，VLC请输入2。3,不安装

EOF

echo "#安装视频播放器" >> continue.sh

echo
chooseSoftware 'smplayer' 'vlc' '不安装视频播放器' 'mpv'
echo >> continue.sh
clear



cat << EOF
现在，我们可以开始安装浏览器了：我们当前提供有firefox和opera


还是像刚才一样：1、firefox  2、opera 3、不安装

EOF



echo "#安装网页浏览器" >> continue.sh
echo "sudo pacman -S --noconfirm flashplugin" >> continue.sh

echo
chooseSoftware 'firefox' 'opera' '不安装网页浏览器'
clear
if [ ${choose} == 'firefox' ];then
	echo "请问您是否要安装Firefox的中文支持？安装后浏览器将改为中文界面。"
	echo
	read -n1 -p "请输入Y/N：" chs
	if [ ${chs} = Y ] || [ ${chs} = y ];then
		echo "sudo pacman -S --noconfirm firefox-i18n-zh-cn" >> continue.sh
	fi
fi
echo >> continue.sh
clear



cat << EOF
如果您现在是实体机安装并且是笔记本电脑而且带有触摸板的话

如果不安装这个驱动触摸板将不会工作,如果您确实是上述的情况请安装触摸板驱动：


EOF

while true
do
	read -n1 -p "请输入Y/N：" syna
	
	if [ ${syna} = Y ] || [ ${syna} = y ];then
		echo "#安装触摸板驱动" >> continue.sh
		echo "sudo pacman -S --noconfirm  xf86-input-synaptics" >> continue.sh
		echo >> continue.sh
		break
	fi

	if [ ${syna} = N ] || [ ${syna} = n ];then
		echo "#不安装触摸板驱动"
		break
	fi
done

reset
mv -f continue.sh /home/${usrnm}/continue.sh
chmod 777 /home/${usrnm}/continue.sh
mv continue.sh.backup continue.sh
rm -rf /var/log/*
rm -rf /var/tmp/*
rm -rf /tmp/*
rm -rf `ls | grep -v "man"` > /dev/null 2>&1
#清理一些垃圾文件

clear
cat << EOF
恭喜您，您已经完成了本次的配置了。
现在您可以使用logout命令注销并使用您的“${usrnm}”用户登录。
然后就可以使用./continue.sh的命令来运行刚刚生成的另一个Shell。

感谢您使用ALS。
EOF
