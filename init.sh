#!/bin/sh
echo "Let's build some stuff"
mkdir -p target
mkdir -p rootfs

echo "Get the source for the bootloader"
if [ ! -d "quectel_lk" ] 
then
    echo "Cloning LK repository"
    git clone https://github.com/Biktorgj/quectel_lk.git
else
    echo "Pulling latest changes from LK"
    cd quectel_lk && git pull && cd ..
fi

echo "Now get the kernel source"
if [ ! -d "quectel_eg25_kernel" ] 
then
    echo "Cloning Kernel repository"
    git clone https://github.com/Biktorgj/quectel_eg25_kernel.git
else
    echo "Pulling latest changes from the kernel"
    cd quectel_eg25_kernel && git pull && cd ..
fi

echo "We will also need the ARM toolchain"
if [ ! -d "tools/gcc-arm-none-eabi-7-2017-q4-major/" ] 
then
    wget "https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2017q4/gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2" && \
    mkdir -p tools ; \
    tar xjvf gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2 -C tools/ && \
    rm gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2
else
    echo "You already seem to have the directory in place"
fi


echo " "
echo " Now run make without arguments to see what you can build"
