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

