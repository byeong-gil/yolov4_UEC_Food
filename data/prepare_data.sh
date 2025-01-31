#!/bin/bash

set -e

if which python3 > /dev/null; then
  PYTHON=python3
else
  PYTHON=python
fi

echo "** Install requirements"
# "gdown" is for downloading files from GoogleDrive
#pip3 install --user gdown > /dev/null

# make sure to download dataset files to "yolov4_crowdhuman/data/raw/"
#mkdir -p $(dirname $0)/raw
#pushd $(dirname $0)/raw > /dev/null

get_file()
{
  # do download only if the file does not exist
  if [[ -f $2 ]];  then
    echo Skipping $2
  else
    echo Downloading $2...
    #python3 -m gdown.cli $1
    wget $1
  fi
}

echo "** Download dataset files"
get_file http://foodcam.mobi/dataset100.zip dataset100.zip
#get_file https://drive.google.com/uc?id=17evzPh7gc1JBNvnW1ENXLy5Kr4Q_Nnla CrowdHuman_train02.zip
#get_file https://drive.google.com/uc?id=1tdp0UCgxrqy1B6p8LkR-Iy0aIJ8l4fJW CrowdHuman_train03.zip
#get_file https://drive.google.com/uc?id=18jFI789CoHTppQ7vmRSFEdnGaSQZ4YzO CrowdHuman_val.zip
# test data is not needed...
# get_file https://drive.google.com/uc?id=1tQG3E_RrRI4wIGskorLTmDiWHH2okVvk CrowdHuman_test.zip
#get_file https://drive.google.com/u/0/uc?id=1UUTea5mYqvlUObsC1Z8CFldHJAtLtMX3 annotation_train.odgt
#get_file https://drive.google.com/u/0/uc?id=10WIRwu8ju8GRLuCkZ_vT6hnNxs5ptwoL annotation_val.odgt

# unzip image files (ignore CrowdHuman_test.zip for now)
echo "** Unzip dataset files"
if [[ -f dataset100.zip ]]; then 
    echo Skipping
else
	echo Downloading dataset100.zip...
	unzip -n dataset100.zip
	mv UECFOOD100/ UECFOOD100_raw/
fi

#echo "** Create the crowdhuman-$1/ subdirectory"
#rm -rf ../crowdhuman-$1/
#mkdir ../crowdhuman-$1/
#ln Images/*.jpg ../crowdhuman-$1/

# the crowdhuman/ subdirectory now contains all train/val jpg images

echo "** Generate yolo txt files"
#cd ..
${PYTHON} food100_generate_txt.py $1
${PYTHON} food100_split_for_yolo.py $1

#popd > /dev/null

echo "** Done."
