#!/bin/bash

cwd=$(pwd)

BRANCH="rel-v2023.2"

cd sources/meta-openamp
git checkout $BRANCH
cd ../meta-openembedded
git checkout $BRANCH
cd ../meta-petalinux
git checkout $BRANCH
cd ../meta-qt5
git checkout $BRANCH
cd ../meta-ros
git checkout $BRANCH
cd ../meta-virtualization
git checkout $BRANCH
cd ../meta-xilinx
git checkout $BRANCH
cd ../meta-xilinx-tools
git checkout $BRANCH
cd ../poky
git checkout $BRANCH

cd $cwd
