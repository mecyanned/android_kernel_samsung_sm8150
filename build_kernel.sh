#!/bin/bash

export ARCH=arm64
mkdir -p out

# 1. Setup KernelSU-Next for legacy kernel (Android 4.9)
rm -rf KernelSU-Next drivers/kernelsu
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy

# 2. Map KernelSU-Next into drivers/kernelsu if not already placed correctly
if [ -d "KernelSU-Next/kernel" ]; then
  mv KernelSU-Next/kernel drivers/kernelsu
  rm -rf KernelSU-Next
elif [ -d "KernelSU-Next-next/kernel" ]; then
  mv KernelSU-Next-next/kernel drivers/kernelsu
  rm -rf KernelSU-Next-next
fi

BUILD_CROSS_COMPILE=$(pwd)/toolchain/gcc-cfp/gcc-cfp-single/aarch64-linux-android-4.9/bin/aarch64-linux-android-
KERNEL_LLVM_BIN=$(pwd)/toolchain/llvm-arm-toolchain-ship/10.0/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE a82xq_kor_skt_defconfig
make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE 

cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image
