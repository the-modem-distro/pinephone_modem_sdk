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
    cd quectel_lk && git pull && cd ..
fi
if [ ! -d "poky" ]
then
    echo "Cloning Yocto repository from the Yocto Project"
    git clone git://git.yoctoproject.org/poky yocto && cd yocto && git checkout tags/yocto-3.1 -b my-yocto-3.1
else
    echo "Yocto is already there"
fi
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
echo "Get meta-python2 from OpenEmbedded"
cd $CURRENT_PATH
if [ ! -d "yocto/meta-python2" ]
then
    echo "Adding meta-python2"
    git clone git://git.openembedded.org/meta-python2 yocto/meta-python2
fi
cd $CURRENT_PATH
if [ ! -d "yocto/meta-openembedded" ]
then
    echo "Adding meta-oe"
    git clone git://git.openembedded.org/meta-openembedded yocto/meta-openembedded
fi

cd $CURRENT_PATH
if [ ! -d "build" ]
then
    echo "Initializing poky and copying the configuration file"
    source yocto/oe-init-build-env && cp ../tools/config/poky/local.conf conf/ && bitbake-layers add-layer ../yocto/meta-qcom  && bitbake-layers add-layer ../yocto/meta-openembedded/meta-oe && bitbake-layers add-layer ../yocto/meta-python2
fi

cd $CURRENT_PATH
echo "Now get the kernel source"
if [ ! -d "poky/kernel/linux-3.18" ]
then
    echo "Cloning Kernel repository"
    git clone https://github.com/Biktorgj/quectel_eg25_kernel.git yocto/kernel/linux-3.18
else
    echo "Pulling latest changes from the kernel"
    cd poky/kernel/linux-3.18 && git pull && cd ..
fi

echo " "
echo " Now run make without arguments to see what you can build"
