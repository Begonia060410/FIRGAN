# FIRGAN: High-Fidelity Infrared–Visible Image Fusion for Detection Tasks

High-Fidelity Infrared–Visible Image Fusion for Detection Tasks

# Abstract 

Infrared-visible image fusion aims to generate informative representations for both visual perception and downstream vision tasks. However, existing methods often prioritize visual quality while overlooking task adaptability, optimization efficiency, and effective spatial-frequency representation learning. To address these issues, we propose FIR-GAN, a detection-oriented multimodal fusion framework that jointly optimizes fusion quality and detection-relevant feature representation. Specifically, a Statistical Frequency Feature Module (SFFM) is introduced to exploit MSCN-derived statistical priors for adaptive spectrum enhancement. A Dual-branch Fusion Network is designed to collaboratively model local structural details and global semantic dependencies through complementary CNN and Transformer branches. In addition, an IQA-guided optimization strategy performs quality-aware patch selection to improve training efficiency and robustness. Extensive experiments on public infrared-visible fusion datasets demonstrate that the proposed method achieves competitive visual quality and quantitative performance while providing more discriminative representations for downstream detection tasks. These results verify the effectiveness of the proposed framework for detection-oriented multimodal fusion. 


<img width="2431" height="563" alt="1" src="https://github.com/user-attachments/assets/71cd1c81-fb73-4801-b82c-2eb70c01dda0" />
Fig. 1 Visual comparison of different image fusion algorithms


<img width="1303" height="1193" alt="FIR_Frame-v2" src="https://github.com/user-attachments/assets/1302a6c5-f69a-4bf4-9647-bbb563db5d4a" />
Fig. 2 Overall architecture of FIR-GAN.

# DOI 

A permanent archived version with DOI is available at: https://doi.org/10.5281/zenodo.20289024.

# Running Note

- # *Train*
  *1.  Change the ir and vis path in ./python/train in line 115-116, data_dir_ir and data_dir_vi.The real path of cropped vis img is data_dir_vi+img_crop and data_dir_vi+label_crop.The real path of cropped ir img is data_dir_ir+img_crop and data_dir_ir+label_crop*
  
  *2.  `python ./python/main.py`*

- # *Test*
  *1.  Prepare test dataset in ./Test_ir and ./Test_vi*
  
  *2.  RGB image*
   `python test_color.py`
  
  *2.  Gray image*
  `python test_gray.py`

# Test images and Weight files
The Baidu Pan links for the test images, fused images, and weight files are:

FIR_GAN: Url: https://pan.baidu.com/s/1-Qr8eMiidPbjExQxTgjMiA?pwd=6ce6  passage: 6ce6
  
# Citation
If this work has been helpful to you, please cite the following code: 

@article{FIRGAN2026,

title={High-Fidelity Infrared–Visible Image Fusion for Detection Tasks},

author={Wang, Huiji and Huang, Dandan and Liu, Zhi and Han, Zhichao and Wang, Xingzhao and Fan, Jian and Zhang, Rui}

journal={The Visual Computer},

year={2026}

}
