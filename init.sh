#!/bin/sh
BASE_PATH=`pwd`
mkdir -p target
mkdir -p rootfs

echo "Get the source for the bootloader"
if [ ! -d "quectel_lk" ]
then
    echo "Cloning LK repository"
    git clone https://github.com/Biktorgj/quectel_lk.git
else
    echo "Pulling latest changes from LK"
    cd quectel_lk && \
    git pull && \
    cd $BASE_PATH
fi

echo "Fetching Yocto"
if [ ! -d "yocto" ]
then
    echo "Cloning Yocto repository from the Yocto Project"
    git clone git://git.yoctoproject.org/poky yocto && \
    cd yocto && \
    git checkout tags/yocto-3.1 -b my-yocto-3.1
    cd $BASE_PATH
else
    echo "Yocto is already there"
fi

echo "Get meta-qcom fork from github"
if [ ! -d "yocto/meta-qcom" ]
then
    echo "Cloning meta-qcom repository"
    git clone https://github.com/Biktorgj/meta-qcom.git yocto/meta-qcom
else
    echo "Pulling latest changes from the kernel"
    cd yocto/meta-qcom && \
    git pull && \
    cd $BASE_PATH
fi

echo "Fetching meta-python2 from OpenEmbedded"
if [ ! -d "yocto/meta-python2" ]
then
    echo "Adding meta-python2"
    git clone git://git.openembedded.org/meta-python2 yocto/meta-python2
fi

echo "Fetching meta-openembedded (to provide support to meta-python2)"
if [ ! -d "yocto/meta-openembedded" ]
then
    echo "Adding meta-oe"
   # git clone git://git.openembedded.org/meta-openembedded yocto/meta-openembedded
   git clone https://github.com/openembedded/meta-openembedded.git yocto/meta-openembedded
fi

echo "Getting the ARM toolchain to be able to compile LK"
if [ ! -d "tools/gcc-arm-none-eabi-7-2017-q4-major/" ]
then
    wget "https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2017q4/gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2" && \
    mkdir -p tools ; \
    tar xjvf gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2 -C tools/ && \
    rm gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2
fi

echo "Setting up yocto initial configuration. Build path will be "$BASE_PATH/yocto/build
cd $BASE_PATH/yocto
if [ ! -d "build" ]
then
    echo "Initializing poky and copying the configuration file"
    source $BASE_PATH/yocto/oe-init-build-env $BASE_PATH/yocto/build && \
    cp ../../tools/config/poky/rootfs.conf conf/ && \
    bitbake-layers add-layer ../meta-qcom  && \
    bitbake-layers add-layer ../meta-openembedded/meta-oe && \
    bitbake-layers add-layer ../meta-openembedded/meta-networking && \
    bitbake-layers add-layer ../meta-python2
    # Build the toolchain on init so we have the tools ready to do other stuff
    bitbake meta-toolchain
fi

echo " Now run make without arguments to see what you can build"
