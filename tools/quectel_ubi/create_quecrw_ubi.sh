#!/bin/sh

    #######################Creating Images################
    echo Erasing previous images quecrw.ubifs quectelrw.ubi

    rm -rf quecrw.ubifs quecrw.ubi
    
    echo Creating quecrw UBIFS image
    mkfs.ubifs -r ./quecrw_dir -o quecrw.ubifs -m 2048 -e 126976 -c 1073 -F
	
	#######################Create UBI#####################
    echo Creating quectelrw UBI
    ./ubinize -o quectelrw.ubi -m 2048 -p 128KiB -s 2048 ./ubinize_quecrw_ubi.cfg
