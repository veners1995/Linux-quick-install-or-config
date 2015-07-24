# Linux quick install or config

欢迎来到Linux quick install or config。<br>
我们致力于开发开源简单的Linux快速安装（或配置）的Shell脚本。<br>

## Tips

release文件夹内存放的是稳定版本的脚本，推荐大家使用<br>
主目录下的为测试用的脚本，功能更新、更全。但是可能会有一些bug。<br>
大家可以*谨慎使用*，我们也欢迎大家帮忙测试。如果测试没有bug可以告诉我们。<br>


## Installation 

#### Kali Linux quick config

由于KaliLinux自带git，所以git clone是最方便的：<br>
在您联网的时候，复制下面这些代码到终端：<br>
```
git clone --depth=1 https://github.com/Guanrenfu/Linux-quick-install-or-config
cd Linux-quick-install-or-config/KLS
chmod +x KaliLinuxShell.sh
./KaliLinuxShell.sh
```
然后您无需操作，只需要等待完成即可。然后您就可以享受您的Kali了。<br>

#### Arch Linux quick config

当您安装ArchLinux完成后，先确认可以联网，然后在tty输入这些：<br>

```
pacman -S git fbterm wqy-microhei 
fbterm
```
（上面注意空格）
此时会进入一个虚拟终端，前面输入的将被清空。<br>
现在tty就可以正常显示中文了，之后输入这些：<br>
```
git clone --depth=1 https://github.com/Guanrenfu/Linux-quick-install-or-config
cd Linux-quick-install-or-config/release
./Arch-Linux-quick-config.sh
```
好了，之后根据提示做就可以了。<br>

#### Arch Linux quick install

由于当前此脚本仅有英文版，所以如果您的英文不是很好请对照翻译。<br>
您可以将这个程序使用U盘或是git、wget、curl等方式拷贝到ArchLive并简单的执行。<br>

### 请注意！所有的脚本都需要root权限执行！ 
