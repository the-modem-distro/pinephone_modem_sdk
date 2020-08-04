#!/bin/sh

    #######################Creating Images################
    echo Erasing previous images oemlog.ubifs oemdata.ubifs oemrw.ubi

    rm -rf oemdata.ubifs oemlog.ubifs oemrw.ubi
    
    echo Creating OEMDATA UBIFS image
    ./mkfs.ubifs -r ./oemdata_root_dir -o oemdata.ubifs -m 2048 -e 126976 -c 1073 -F
	
	 echo Creating OEMDLOG UBIFS image
    ./mkfs.ubifs -r ./oemlog_root_dir -o oemlog.ubifs -m 2048 -e 126976 -c 1073 -F
	
	#######################Create UBI#####################
    echo Creating oemdata UBI
    ./ubinize -o oemrw.ubi -m 2048 -p 128KiB -s 2048 ./ubinize_oemrw_ubi.cfg
