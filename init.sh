#!/bin/bash
BASE_PATH=`pwd`

YOCTOBRANCH="kirkstone"

mkdir -p target

echo "Fetching Yocto"
if [ ! -d "yocto" ]
then
    echo "Cloning Yocto repository from the Yocto Project"
    git clone -b $YOCTOBRANCH git://git.yoctoproject.org/poky yocto
else
    echo "Yocto is already there"
fi

echo "Get meta-qcom fork from github"
if [ ! -d "yocto/meta-qcom" ]
then
    echo "Cloning meta-qcom repository"
    git clone -b $YOCTOBRANCH https://github.com/Biktorgj/meta-qcom.git yocto/meta-qcom
else
    echo "Pulling latest changes from meta-qcom"
    cd yocto/meta-qcom && \
    git pull && \
    cd $BASE_PATH
fi

echo "Fetching meta-openembedded (to provide support to meta-python)"
if [ ! -d "yocto/meta-openembedded" ]
then
    echo "Adding meta-oe"
   git clone -b $YOCTOBRANCH https://github.com/openembedded/meta-openembedded.git yocto/meta-openembedded
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
    bitbake-layers add-layer ../meta-openembedded/meta-python && \
    bitbake-layers add-layer ../meta-openembedded/meta-networking
fi
cd $BASE_PATH
mkdir -p yocto/build/conf
cp tools/config/poky/rootfs.conf yocto/build/conf/
echo " Now run make without arguments to see what you can build"
