#!env python
# -*- coding: utf-8 -*-

'''将文件夹里的宝贝详情页面图片（750*），调整大小成600*，符合淘宝手机端端要求
   用法: 将脚本文件复制到要生成缩略图的文件夹，双击执行，会生成新的文件夹img600，新图片都在img600里面
'''

from PIL import Image
import glob
import os

# 遍历当前目录，对所有图片大小为750*的图片，生成600*的图片
newdir = 'img_shouji'
for img in glob.glob('*.png'):
	print img
	im = Image.open(img)
	#if im.size[0] < 750:
	if im.size[0] == 750:
		imnew = im.resize((600, int(im.size[1] * im.size[1]/float(im.size[0]))))
		if not os.path.exists(newdir):
			os.mkdir(newdir)

		newimg = os.path.join(newdir, '600_'+img)
		print newimg
		imnew.save(newimg)
	


