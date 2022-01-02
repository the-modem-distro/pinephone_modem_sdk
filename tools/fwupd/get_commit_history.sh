#!/bin/bash
BASE_PATH=`pwd`



rm -rf  target/temp  ; \
mkdir -p  target/temp && \

git clone --bare https://github.com/Biktorgj/quectel_lk.git  target/temp && \
cd  target/temp && \
git log -n 5 --pretty=format:"%h%x09%an%x09%ad%x09%s" > ../changelog.log && \

cd $BASE_PATH && \
rm -rf  target/temp && \
mkdir -p  target/temp && \

git clone -b honister --bare https://github.com/Biktorgj/meta-qcom.git  target/temp && \
cd  target/temp && \
git log -n 5 --pretty=format:"%h%x09%an%x09%ad%x09%s" >> ../changelog.log && \

cd $BASE_PATH && \
rm -rf  target/temp && \
mkdir -p  target/temp && \

git clone --bare https://github.com/Biktorgj/quectel_eg25_kernel.git  target/temp && \
cd  target/temp && \
git log -n 5 --pretty=format:"%h%x09%an%x09%ad%x09%s" >> ../changelog.log && \
rm -rf  target/temp