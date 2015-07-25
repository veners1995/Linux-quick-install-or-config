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

installCodeGenerator()
{
	echo "sudo pacman -S --noconfirm ${1}"
}

# @brief  用菜单选择待安装的软件
# @param   第一个参数为安装软件的类型(类别)
#			其余参数为所有待安装软件的名称
# @return 全局变量choose是保存用户的选项
chooseSoftware()
{
	PS3='请输入选项：'
	echo "#安装${1}" >> continue.sh
	shift
	select choose in "$@";do
		if [ ${choose:-NONE} == 'NONE' ];then
			continue;
		elif [ ${choose} != '不安装' ];then
			installCodeGenerator ${choose} >> continue.sh
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
fi

sed -i '33d' /etc/pacman.conf >> /dev/null 2>&1
sed -i '32a Color' /etc/pacman.conf >> /dev/null 2>&1
sed -i '34d' /etc/pacman.conf >> /dev/null 2>&1
sed -i '33a TotalDownload' /etc/pacman.conf >> /dev/null 2>&1
sed -i '36d' /etc/pacman.conf >> /dev/null 2>&1
sed -i '35a VerbosePkgLists' /etc/pacman.conf >> /dev/null 2>&1
pacman -Syy > /dev/null 2>&1
sudo pacman -S --noconfirm {wget,git} > /dev/null 2>&1

reset
cat << EOF
欢迎来到Linux-quick-install-or-config.
（版本：Arch-Linux-quick-config, 2015年7月22日更新）

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
installCodeGenerator "ntfs-3g" >> continue.sh
installCodeGenerator "dosfstools" >> continue.sh
installCodeGenerator "wqy-microhei" >> continue.sh
installCodeGenerator "xorg-server" >> continue.sh
installCodeGenerator "xorg-xinit" >> continue.sh
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

chooseSoftware "Zsh" "zsh" "不安装Zsh"
if [ ${choose} == "zsh" ];then
	git clone https://github.com/robbyrussell/oh-my-zsh ~/.oh-my-zsh
	cp -rf ~/.oh-my-zsh /home/${usrnm}/.oh-my-zsh
	cp -f ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
	chsh -s /bin/zsh
	echo "cp -f ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc" >> continue.sh
	echo "echo ${usrpasswd} | chsh -s /bin/zsh" >> continue.sh
	echo >> continue.sh
fi
clear

cat << EOF
现在请您选择一个桌面环境或窗口管理器，我们当前提供：

桌面环境：Gnome、Plasma（KDE5）、Xfce4、Cinnamon、和Mate
窗口管理器：i3(wm)、Openbox、Awesome


如果没有您需要的，那么请选择不安装然后自行安装您喜欢的桌面环境（或窗口管理器）
我们还提供一些扩展包，这些将会在您选择您喜欢的桌面环境后提供选择。

EOF
read -p "请按回车继续" var
clear

read -p "在继续之前请您选择使用桌面环境还是窗口管理器：1、桌面环境。2、窗口管理器。" display

if [ ${display} == 1 ];then
	echo
	chooseSoftware '桌面环境' 'gnome' 'plasma' 'xfce4' 'cinnamon' 'mate' '不安装桌面环境'

	case ${choose} in
		gnome)
			echo "echo 'exec gnome-session' >> ~/.xinitrc" >> continue.sh
			clear
			echo "请问您是否要安装${choose}扩展包？其中包含了很多${choose}的原生软件和一些主题等"
			echo
			while true
			do
				read -n1 -p "请输入Y/N：" ge
				echo
				if [ ${ge} = Y ] || [ ${ge} = y ];then
					installCodeGenerator "gnome-extra" >> continue.sh
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
			chooseSoftware "${choose}扩展包" "xfce4-goodies" "不安装${choose}扩展包(其中包含了很多${choose}的原生软件和一些主题等)"
			
			echo >> continue.sh
			;;

		cinnamon)	
			echo "echo 'exec cinnamon-session' >> ~/.xinitrc" >> continue.sh
			echo >> continue.sh
			clear
			;;

		mate)	
			echo "echo 'exec mate-session' >> ~/.xinitrc" >> continue.sh
			clear
			chooseSoftware "${choose}扩展包" "mate-extra" "不安装${choose}扩展包(其中包含了很多${choose}的原生软件和一些主题等)"
			
			echo >> continue.sh
			;;
	esac

elif [ ${display} == 2 ];then
	echo
	chooseSoftware '窗口管理器' 'i3' 'openbox' 'awesome' '不安装窗口管理器'

	case ${choose} in
		i3)
			echo "echo 'exec i3' ~/.xinitrc" >> continue.sh
			echo >> continue.sh
			clear
			;;

		openbox)	
			echo "echo 'exec openbox-session' ~/.xinitrc" >> continue.sh
			echo "mkdir -p ~/.config/openbox" >> continue.sh
			echo "cp /etc/xdg/openbox/{rc.xml,menu.xml,autostart,environment} ~/.config/openbox" >> continue.sh
			echo >> continue.sh
			;;
		awesome)
			echo "echo 'exec awesome' ~/.xinitrc" >> continue.sh
			;;
	esac
fi




clear
echo "恭喜您完成了多半的配置了，现在让我们来看一下几个日常用的软件吧："
echo
echo "#安装Networkmanager网络管理器" >> continue.sh
installCodeGenerator "networkmanager" >> continue.sh
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
		echo "sudo pacman -S --noconfirm fcitx-{im,qt5,googlepinyin,configtool}" >> continue.sh
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

chooseSoftware '文本编辑器' 'gvim' 'emacs' 'gedit' 'leafpad' '不安装文本编辑器'
echo >> continue.sh

if [ ${choose} == 'gvim' ];then

cat > /home/${usrnm}/.vimrc << EOF
set nocompatible
filetype indent on
syntax enable
colorscheme murphy
set nu
set nobackup
set nowritebackup
set noswapfile
set wrapscan
set ruler
set backspace=indent,eol,start
EOF

fi
clear



cat << EOF
现在，我们来挑选一个音视播放器。本版本提供SMPlayer、mpv和VLC。


请选择您喜欢的播放器，选择smplayer请输入1，VLC请输入2。3,不安装

EOF

echo
chooseSoftware '视频播放器' 'smplayer' 'vlc' 'mpv' '不安装视频播放器' 
echo >> continue.sh
clear


cat << EOF
现在，我们可以开始安装浏览器了：我们当前提供有firefox、opera和chromium

EOF

echo
chooseSoftware '网页浏览器' 'firefox' 'opera' 'chromium' '不安装网页浏览器'
clear
if [ ${choose} == 'firefox' ];then
	chooseSoftware "Firefox的中文支持" "firefox-i18n-zh-cn" "不安装Firefox的中文支持(安装后浏览器将改为中文界面。)"
fi
installCodeGenerator "flashplugin" >> continue.sh
echo >> continue.sh
clear



cat << EOF
如果您现在是实体机安装并且是笔记本电脑而且带有触摸板的话

如果不安装这个驱动触摸板将不会工作,如果您确实是上述的情况请安装触摸板驱动：

EOF

chooseSoftware "触摸板驱动" "xf86-input-synaptics" "不安装触摸板驱动"
echo >> continue.sh


reset
mv -f continue.sh /home/${usrnm}/continue.sh
chmod 777 /home/${usrnm}/continue.sh
mv continue.sh.backup continue.sh

clear
cat << EOF
恭喜您，您已经完成了本次的配置了。
现在您可以使用logout命令注销并使用您的“${usrnm}”用户登录。
然后就可以使用./continue.sh的命令来运行刚刚生成的另一个Shell。

感谢您使用ALS。
EOF
