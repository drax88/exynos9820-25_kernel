#! /bin/bash

DATE=$(TZ=GMT-8 date +"%Y%m%d-%H%M")

MODEL="Samsung galaxy S10"

DEVICE="beyond1lte"

NAME="v0idlab"

build_kernel() {
chmod +x build.py
./build.py build model=G973F name="$NAME" toolchain=system-clang

if [ -f arch/arm64/boot/Image-G973F ]
then
	echo "Kernel Successfully Compiled"
else
	echo "Kernel Compilation Failed!"
	exit

fi

}

build_image_dtbo() {
wget -q https://android.googlesource.com/platform/system/tools/mkbootimg/+archive/refs/heads/master.tar.gz -O - | tar xzf - mkbootimg.py
./mkbootimg.py --header_version=1 --os_version=11.0.0 --os_patch_level=2021-09 --board=SRPSC14B006KU --pagesize=2048 --cmdline=androidboot.selinux=permissive --base=0x10000000 --kernel_offset=0x00008000 --ramdisk_offset=0x00000000 --second_offset=0x00000000 --tags_offset=0x00000100 --kernel=arch/arm64/boot/Image-G973F -o arch/arm64/boot/G973F.img

}

generate_zip() {
# cloning anykernel

git clone https://github.com/Tkpointz/AnyKernel3.git -b exynos9820

# cloning flashable module zip

git clone https://github.com/Tkpointz/sploitpay_kernel_modules.git modules

#moving output files to flashable zip

mv arch/arm64/boot/G973F.img AnyKernel3/
mv drivers/staging/rtl8812au/88XXau.ko modules/system/lib/modules
mv drivers/staging/rtl8814au/8814au.ko modules/system/lib/modules
mv drivers/staging/rtl8188eus/8188eu.ko modules/system/lib/modules
mv drivers/staging/rtl8821CU/8821cu.ko modules/system/lib/modules



cd AnyKernel3

zip -r v0idlab-"$DATE" . -x ".git*" -x "README.md" -x "*.zip" -x "*.jar"

ZIP_FINAL="v0idlab-$DATE"

}


build_kernel
build_image_dtbo
generate_zip
