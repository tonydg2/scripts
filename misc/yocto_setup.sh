#!/bin/bash

mkdir sources
cd sources
git clone https://github.com/tonydg2/meta-adghw.git
git clone https://github.com/tonydg2/meta-adglayer.git

BRANCH="rel-v2023.1"

git clone -b $BRANCH https://github.com/Xilinx/meta-openamp.git
git clone -b $BRANCH https://github.com/Xilinx/meta-openembedded.git
git clone -b $BRANCH https://github.com/Xilinx/meta-petalinux.git
git clone -b $BRANCH https://github.com/Xilinx/meta-qt5.git
git clone -b $BRANCH https://github.com/Xilinx/meta-ros.git
git clone -b $BRANCH https://github.com/Xilinx/meta-virtualization.git
git clone -b $BRANCH https://github.com/Xilinx/meta-xilinx.git
git clone -b $BRANCH https://github.com/Xilinx/meta-xilinx-tools.git
git clone -b $BRANCH https://github.com/Xilinx/poky.git

cd ..
source sources/poky/oe-init-build-env




## add layers manually
# bitbake-layers add-layer ../sources/meta-openamp




## are these 3 automatic?
#  ../sources/poky/meta \
#  ../sources/poky/meta-poky \
#  ../sources/poky/meta-yocto-bsp \



#  ../sources/meta-openembedded/meta-perl \
#  ../sources/meta-openembedded/meta-python \
#  ../sources/meta-openembedded/meta-filesystems \
#  ../sources/meta-openembedded/meta-networking \
#  ../sources/meta-openembedded/meta-gnome \
#  ../sources/meta-openembedded/meta-multimedia \
#  ../sources/meta-openembedded/meta-webserver \
#  ../sources/meta-openembedded/meta-xfce \
#  ../sources/meta-openembedded/meta-initramfs \
#  ../sources/meta-openembedded/meta-oe \
#  ../sources/meta-xilinx/meta-xilinx-core \
#  ../sources/meta-xilinx/meta-xilinx-standalone \
#  ../sources/meta-qt5 \
#  ../sources/meta-petalinux \
#  ../sources/meta-adghw \
#  ../sources/meta-ros/meta-ros-common \
#  ../sources/meta-ros/meta-ros2 \
#  ../sources/meta-ros/meta-ros2-humble \
#  ../sources/meta-xilinx/meta-microblaze \
#  ../sources/meta-openamp \
#  ../sources/meta-xilinx/meta-xilinx-bsp \
#  ../sources/meta-xilinx-tools \
#  ../sources/meta-virtualization \
#  ../sources/meta-adglayer \


