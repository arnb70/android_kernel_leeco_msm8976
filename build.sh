#!/bin/bash

# Custom build script for Elindir Kernel

# Constants
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
cyan='\033[0;36m'
yellow='\033[0;33m'
blue='\033[0;34m'
default='\033[0m'

# Define variables
KERNEL_DIR=$PWD
Anykernel_DIR=$KERNEL_DIR/AnyKernel3/
DATE=$(date +"%d%m%Y")
TIME=$(date +"-%H.%M.%S")
KERNEL_NAME="PureCAF+"
DEVICE="-COOL1-"
FINAL_ZIP="$KERNEL_NAME""$DEVICE""$DATE""$TIME"

BUILD_START=$(date +"%s")

# Cleanup before
rm -rf $Anykernel_DIR/*zip
rm -rf $Anykernel_DIR/Image.gz-dtb
rm -rf out/arch/arm64/boot/Image
rm -rf out/arch/arm64/boot/Image.gz
rm -rf out/arch/arm64/boot/Image.gz-dtb

# Export few variables
export KBUILD_BUILD_USER="Arnab"
export KBUILD_BUILD_HOST="aws"
export CROSS_COMPILE=/home/ubuntu/arnb/kernel/gcc/gcc-linaro-6.4.1-2017.08-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
export ARCH="arm64"
export USE_CCACHE=1

echo -e "$green***********************************************"
echo  "           Compiling Graphene Kernel                    "
echo -e "***********************************************"

# Finally build it
mkdir -p out && make O=out clean && make O=out mrproper
make O=out lineage_c106_defconfig
make O=out -j6

echo -e "$yellow***********************************************"
echo  "                 Zipping up                    "
echo -e "***********************************************"

# Create the flashable zip
cp out/arch/arm64/boot/Image.gz-dtb $Anykernel_DIR
cd $Anykernel_DIR
zip -r9 $FINAL_ZIP.zip * -x .git README.md *placeholder

echo -e "$cyan***********************************************"
echo  "            Cleaning up the mess created               "
echo -e "***********************************************$default"

# Cleanup again
cd ../
rm -rf $Anykernel_DIR/Image.gz-dtb
rm -rf out/arch/arm64/boot/Image
##rm -rf out/arch/arm64/boot/dts/qcom/msm8976-mtp-cool.dtb
rm -rf out/arch/arm64/boot/Image.gz
rm -rf out/arch/arm64/boot/Image.gz-dtb
make O=out clean && make O=out mrproper

# Build complete
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$green Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$default"
