# food100_generate_bbox_file.py
#
# Read each food100 class image directory 'bb_info.txt' and create individual bbox files.
#
# This script creats a data directory named 'UECFOOD100' with images and corresponding labels. 
# 
# Inputs:
# UECFOOD100_raw/
# |- 1/
#    |- bb_info.txt
#    |- *.jpg
# ...
# |- 100/
# |- food100.data
# |_ food100.names
#
# Outputs:
# UECFOOD100_raw/  - same as the input
# UECFOOD100/
# |- *.jpg
# |- *.txt
#
#

import os
from PIL import Image

# modify the directories and class file to fit
datapath = 'UECFOOD100_raw'
targetpath = 'UECFOOD100'
classfilename = 'food100.names'

def convert_yolo_bbox(img_size, box):
    # img_bbox file is [0:img] [1:left X] [2:bottom Y] [3:right X] [4:top Y]
    dw = 1./img_size[0]
    dh = 1./img_size[1]
    x = (int(box[1]) + int(box[3]))/2.0
    y = (int(box[2]) + int(box[4]))/2.0
    w = abs(int(box[3]) - int(box[1]))
    h = abs(int(box[4]) - int(box[2]))
    x = x*dw
    w = w*dw
    y = y*dh
    h = h*dh
    # Yolo bbox is center x, y and width, height
    return (x,y,w,h)

def generate_bbox_file(datapath, targetpath, classid):
    print('class %d...' %(classid))
    dataDir = os.path.join(datapath, str(classid))
    targetDir = os.path.join(targetpath)
    bb_filename = os.path.join(dataDir, 'bb_info.txt')

    with open(bb_filename) as fp:
        for line in fp.readlines():
            # img_bbox file is [0:img] [1:left X] [2:bottom Y] [3:right X] [4:top Y]
            img_bbox = line.strip('\n').split(' ')
            if img_bbox[0] != 'img':
                #print('Processing image %s.jpg...' %(img_bbox[0]))
                origin_imagefilename = os.path.join(dataDir, img_bbox[0]+'.jpg')
                img_filename = os.path.join(targetDir, img_bbox[0]+'.jpg')
                if not os.path.exists(img_filename):
                    os.system('cp %s %s' %(origin_imagefilename, targetDir))

                yolo_label_filename = os.path.join(targetDir, img_bbox[0]+'.txt')
                with open(yolo_label_filename, 'a') as f:
                    img = Image.open(img_filename)
                    yolo_bbox = convert_yolo_bbox(img.size, img_bbox)
                    if (yolo_bbox[2] > 1) or (yolo_bbox[3] > 1):
                        print("image %s bbox is " %(img_filename) + ' '.join(map(str, yolo_bbox)))
                    f.write(str(classid-1) + ' ' + ' '.join(map(str, yolo_bbox)) + '\n')
                    img.close()
                    f.close()
        fp.close()


def main():
    targetDir = os.path.join(targetpath)
    data_filename = os.path.join(targetpath, 'food100.data')
    names_filename = os.path.join(targetpath, 'food100.names')
    # Generate UECFOOD100
    if os.path.exists(targetDir):
        os.system('rm -rf %s' %(targetDir))
    os.makedirs(targetDir)
    
    for id in range(1, 101):
        generate_bbox_file(datapath, targetpath, id)


if __name__ == '__main__':
    main()
