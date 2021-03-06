#!/bin/bash
function MYECHO(){
  echo -e "\033[44;37m$1\033[0m"
}

function usage(){
  MYECHO "usage: ./setup.sh for CentOS 7 & Debian 9"
}

function CheckYes(){
  condition=-100
  while (( $condition==-100 ))
  do
    echo -n "$1"
    read -t 5 in
    case $in in
    Yes|yes|Y|y|"") condition=1 ;;
    No|no|N|n) condition=0 ;;
    *) ;;
    esac
  done
  if [ $condition -eq 1 ]; then return 1;
  else return 0;
  fi
}

# init
source /etc/os-release

case "$ID $VERSION_ID" in
'centos 7')
    __CASE__=1
    __PKG__="sudo yum"
    ;;
'fedora 27')    # 本脚本不再维护此方案
    __CASE__=2
    __PKG__="sudo dnf"
    ;;
'ubuntu 16.04') # 本脚本不再维护此方案
    __CASE__=3
    __PKG__="sudo apt"
    ;;
'debian 9')
    __CASE__=4
    __PKG__="sudo apt"
    ;;
*)
    MYECHO "本机的系统不受支持"
    usage
    exit 1
    ;;
esac

__CUR__=$(cd `dirname $0`; pwd)

MYECHO "# ---------- 开始 配置 ---------- #"

## 0 自定义命令别名
echo "source ~/.ljc_alias" >> ~/.ljcrc
echo "source ~/.ljcrc" >> ~/.bashrc

## 1 配置环境变量
echo 'export PATH=$PATH:/home/$(whoami)/X:/home/$(whoami)/X/Program/Script' >> ~/.ljcrc
mkdir -p /home/$(whoami)/X/Program
mv Script /home/$(whoami)/X/Program
chmod 755 /home/$(whoami)/X/Program/Script/*

## 2 配置开机启动脚本
if [ $__CASE__ = 1 ]; then
sudo sh -c "echo \"#!/bin/bash
#chkconfig:2345 80 30
#description:ljc_init

/home/$(whoami)/X/Program/Script/ljc_init.sh\" > /etc/init.d/ljc_init.sh"
elif [ $__CASE__ = 4 ]; then
sudo sh -c "echo \"#!/bin/bash
### BEGIN INIT INFO
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

/home/$(whoami)/X/Program/Script/ljc_init.sh\" > /etc/init.d/ljc_init.sh"
fi
sudo chmod 755 /etc/init.d/ljc_init.sh

if [ $__CASE__ = 1 ]; then
  sudo chkconfig --add ljc_init.sh
elif [ $__CASE__ = 4 ]; then
  sudo update-rc.d ljc_init.sh defaults
fi

## 3 配置 共享文件夹 for CentOS7
if [ $__CASE__ = 1 ]; then
  CheckYes "不配置 共享文件夹?(y/n 默认不配置):"
  if [ $? = 0 ]; then
    sudo mkdir /mnt/hgfs
    echo 'sudo vmhgfs-fuse .host:/ /mnt/hgfs -o subtype=vmhgfs-fuse,allow_other' >> /home/$(whoami)/X/Program/Script/ljc_init.sh
    sudo vmhgfs-fuse .host:/ /mnt/hgfs -o subtype=vmhgfs-fuse,allow_other
  fi
fi

## 4 挂载磁盘 & 虚拟磁盘
# 安装 nbd 模块 for CentOS7
if [ $__CASE__ = 1 ]; then
  sudo mv nbd.ko1 /lib/modules/$(uname -r)/kernel/drivers/block/nbd.ko
  sudo depmod -a
fi
# 安装 qemu for Debian9
if [ $__CASE__ = 4 ]; then
  sudo apt install -y qemu-utils qemu-block-extra
fi
# 开机加载 nbd 模块
sudo sh -c "echo 'nbd' > /etc/modules-load.d/nbd.conf"
sudo sh -c "echo 'options nbd max_part=16' > /etc/modprobe.d/nbd.conf"
sudo modprobe nbd max_part=16
# 设置挂载点
sudo mkdir -p /media/will/{Data,NTFS,X}

## 5 检测 ssh 无密码登录, 并输一遍 yes
ssh localhost
