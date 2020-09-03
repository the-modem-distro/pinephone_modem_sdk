#!/bin/sh
echo "Let's build some stuff"
CURRENT_PATH=`pwd`
echo "Current Path is " $CURRENT_PATH
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
    cd ..
fi
echo "Fetching Yocto"
if [ ! -d "yocto" ]
then
    echo "Cloning Yocto repository from the Yocto Project"
    git clone git://git.yoctoproject.org/poky yocto && cd yocto && git checkout tags/yocto-3.1 -b my-yocto-3.1
else
    echo "Yocto is already there"
fi

echo "Fetching meta-qcom"
cd $CURRENT_PATH
echo "Get meta-qcom fork from github"
if [ ! -d "yocto/meta-qcom" ]
then
    echo "Cloning Kernel repository"
    git clone https://github.com/Biktorgj/meta-qcom.git yocto/meta-qcom
else
    echo "Pulling latest changes from the kernel"
    cd yocto/meta-qcom && git pull && cd .. && cd ..
fi

echo "Fetching meta-python2 from OpenEmbedded"
cd $CURRENT_PATH
if [ ! -d "yocto/meta-python2" ]
then
    echo "Adding meta-python2"
    git clone git://git.openembedded.org/meta-python2 yocto/meta-python2
fi

echo "Fetching meta-openembedded (to provide support to meta-python2)"
cd $CURRENT_PATH
if [ ! -d "yocto/meta-openembedded" ]
then
    echo "Adding meta-oe"
    git clone git://git.openembedded.org/meta-openembedded yocto/meta-openembedded
fi

echo "Setting up yocto initial configuration. Build path will be "$CURRENT_PATH/yocto/build
cd $CURRENT_PATH/yocto
if [ ! -d "build" ]
then
    echo "Initializing poky and copying the configuration file"
    source $CURRENT_PATH/yocto/oe-init-build-env $CURRENT_PATH/yocto/build && \
    cp ../../tools/config/poky/local.conf conf/ && \
    bitbake-layers add-layer ../meta-qcom  && \
    bitbake-layers add-layer ../meta-openembedded/meta-oe && \
    bitbake-layers add-layer ../meta-python2
fi

echo " "
echo " Now run make without arguments to see what you can build"
