#!/bin/bash

set -e

# check argument
# if [[ -z $1 || ! $1 =~ [[:digit:]]x[[:digit:]] ]]; then
#   echo "ERROR: This script requires 1 argument, \"input dimension\" of the YOLO model."
#   echo "The input dimension should be {width}x{height} such as 608x608 or 416x256.".
#   exit 1
# fi

#UECFOOD100=UECFOOD100

if [[ ! -f data/UECFOOD100/train.txt || ! -f data/UECFOOD100/test.txt ]]; then
  echo "ERROR: missing txt file in data/UECFOOD100/"
  exit 1
fi

echo "** Install requirements"
# "gdown" is for downloading files from GoogleDrive
#pip3 install --user gdown > /dev/null

echo "** Copy files for training"
ln -sf $(readlink -f data/UECFOOD100) darknet/data/
cp data/UECFOOD100.data darknet/data/
cp data/UECFOOD100.names darknet/data/
cp cfg/*.cfg darknet/cfg/

if [[ ! -f darknet/yolov4.conv.137 ]]; then
  pushd darknet > /dev/null
  echo "** Download pre-trained yolov4 weights"
  wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.conv.137
  popd > /dev/null
fi

echo "** Done."
