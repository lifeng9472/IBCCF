IBCCF: Integrating Boundary and Center Correlation Filters for Visual Tracking with Aspect Ratio Variation
========
By Feng Li, Yingjie Yao, Peihua Li, David Zhang, Wangmeng Zuo and Ming-Hsuan Yang

Introduction
----
IBCCF is a Correlation filter (CF) based method for visual tracking. While several approaches have been proposed for scale adaptive tracking on CF-based trackers, the aspect ratio variation remains an open problem during tracking. IBCCF addresses this issue by introducing a family of 1D boundary CFs to localize the left, right, top, and bottom boundaries in videos. For more details, please refer to our paper. 

Citation
----
If you find IBCCF useful in your research, please consider citing:

@inproceedings{li2017integrating,     
  title={Integrating Boundary and Center Correlation Filters for Visual Tracking with Aspect Ratio Variation},  
  author={Li, Feng and Yao, Yingjie and Li, Peihua and Zhang, David and Zuo, Wangmeng and Yang, Ming-Hsuan},  
  booktitle={ICCVW},  
  year={2017}  
}  

Installation
----
1. Building [Matconvnet](http://www.vlfeat.org/matconvnet/) library. Please follow the [instructions](http://www.vlfeat.org/matconvnet/install/)  to build the mex files on your system.

2. Download imagenet-vgg-verydeep-19.mat file from http://www.vlfeat.org/matconvnet/models/imagenet-vgg-verydeep-19.mat and put it in the root folder './model'.

Demo
------
After successfully completing basic installation, you'll be ready to run the demo.

To run the demo, just run the 'demo.m' in the root folder. The code has been tested with Matlab 2017a on Windows 10.
