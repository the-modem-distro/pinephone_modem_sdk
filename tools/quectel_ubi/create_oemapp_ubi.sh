#!/bin/sh


    #######################Creating Images################
    echo Erasing previous images 
    rm -rf oemapp.squashfs oemapp.ubi
    
    echo Creating OEMAPP SquashFS image
    mksquashfs ./oemapp_root_dir oemapp.squashfs  

    #######################Create UBI#####################
    echo Creating UBI
    ./ubinize -o oemapp.ubi -m 2048 -p 128KiB -s 2048  ./ubinize_oemapp_ubi.cfg
