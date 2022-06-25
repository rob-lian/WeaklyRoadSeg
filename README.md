# Weakly-supervised road segmentation in high resolution remote sensing images using point annotations

<p>
  <b>Abstract: </b>
Road segmentation methods based on Deep Neural Networks have achieved great success in recent years, but creating accurate pixel-wise training labels is still a boring and expensive task, especially for large-scale high-resolution remote sensing images (HRSI). Inspired by the stacked hourglass model for human joints detection, we propose a weakly-supervised road segmentation method using point annotations in this article. First, we design a patch-based DCNN model for road seeds and background points detection and train the model using point annotations. Then, in the process of road segmentation, the DCNN model detects a series of road and background points that are used to train a Support Vector Machine Classifier (SVC) for classifying each pixel into road or non-road. According to the local geometry shape of road and the inaccurate classification of SVC, a Multi-scale & Multi-direction Gabor Filter (MMGF) is put forward to estimate the road potential. Finally, the Active Contour Model based on local binary fitting energy (LBF-Snake) is introduced to extract the road regions from the inhomogeneous road potential. Qualitative and Quantitative comparisons show that our method achieves competitive results comparing to fully-supervised semantic methods on publicly available datasets.
  </p>
<p>
  Note: the paper is undergoing review.
</p>

# Dataset
We use <a href='http://www.cs.toronto.edu/~vmnih/data/'>Massachusetts Roads Dataset</a> and <a href='http://www.escience.cn/people/guangliangcheng/Datasets.html'>Google Earth</a> to evaluation the performance of our method. 

# Training Samples
The road point estimation model is trained by point annotations. To evaluate the model in application scenes, we implemented a road center point sample software , and employed 78 students to manually sample a dataset containing about 240,000 training samples. There are some of our training samples. where the ground truths are gaussians center at the road center points shown in cyan. Note that there are some samples without ground truth for no roads inside these patches.
<img src='resources/trainingsamples.png' width='100%'/>

# Some visual comparisons in training process
We set the train batch-size to 64. We display some visual comparisons between the prediction map and the groud truth, they are expressed in grid images
1. Training images
<img src='resources/training_patches.png' width='100%'>
2. Ground truth
<img src='resources/training_gt.png' width='100%'>
3. prediction visulization
<img src='resources/training_pred.png' width='100%'>

# Some prediction results infered by our road center estimation model
<p>
Exhibition of more predicted samples, in which the predicted road center points are presented in bold red diamonds. Note that there are some samples without road center points due to none roads in those patches.
<img src='resources/predictsamples.png' width='100%'/>
</p>

# Algorithm pipeline
<p>
1.	Search road seeds and background seeds using road center estimation network.
2.	Train an SVC model using the road and background seeds in Luv color space.
3.	Classify all the pixels into road and non-road using Luv color features.
4.	Road probability density estimated by MMGK.
5.	Based on the road probability map, obtain the optimal contours by iteratively minimizing the LBF energy function.
6.	Initial road segmentation according to the contours
7.	Refine road segmentation by simple post-process.
</p>
<p>
<table>
  <tr>
    <td><img src='resources/011.jpg?raw=true' width='150' /></td>
    <td><img src='resources/012.jpg?raw=true' width='150' /></td>
    <td><img src='resources/013.jpg?raw=true' width='150' /></td>
    <td><img src='resources/014.jpg?raw=true' width='150' /></td>
    <td><img src='resources/015.jpg?raw=true' width='150' /></td>
    <td><img src='resources/016.jpg?raw=true' width='150' /></td>
  </tr>
  <tr align='center'>
    <td>(a)</td>
    <td>(b)</td>
    <td>(c)</td>
    <td>(d)</td>
    <td>(e)</td>
    <td>(f)</td>
  </tr>
  <tr>
  <td colspan='6'>(a) Test image with road seeds and background seeds are shown in yellow dots and red dots respectively. (b) Pixel classification by SVC trained by the seeds, in which red and white represent road and nonroad class, respectively. (c) Road probability density estimated by Multi-scale & Multi-direction Gabor kernels. (d) Initial contours generated from seeds. (e) Road contours achieved by LBF-Snake according to road probability density. (f) Road segmentation by simple post-process.</td>
  </tr>
</table>
</p>

# Output Visualization
Exhibition of some road segmentation results on the Google Earth & Massachusetts Roads dataset.
<table>
<tr><td><img src='resources/image1.jpg?raw=true' /></td><td><img src='resources/image1_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/image2.jpg?raw=true' /></td><td><img src='resources/image2_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/image7.jpg?raw=true' /></td><td><img src='resources/image7_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/image24.jpg?raw=true' /></td><td><img src='resources/image24_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/image37.jpg?raw=true' /></td><td><img src='resources/image37_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/image45.jpg?raw=true' /></td><td><img src='resources/image45_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/image46.jpg?raw=true' /></td><td><img src='resources/image46_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/image92.jpg?raw=true' /></td><td><img src='resources/image92_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/image3.jpg?raw=true' /></td><td><img src='resources/image3_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/image8.jpg?raw=true' /></td><td><img src='resources/image8-overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/11128870_15.jpg?raw=true' /></td><td><img src='resources/11128870_15_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/11728825_15.jpg?raw=true' /></td><td><img src='resources/11728825_15_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/18328960_15.jpg?raw=true' /></td><td><img src='resources/18328960_15_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/18478930_15.jpg?raw=true' /></td><td><img src='resources/18478930_15_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/20728960_15.jpg?raw=true' /></td><td><img src='resources/20728960_15_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/20878930_15.jpg?raw=true' /></td><td><img src='resources/20878930_15_overlay.jpg?raw=true' /></td></tr>
<tr><td><img src='resources/23278915_15.jpg?raw=true' /></td><td><img src='resources/23278915_15_overlay.jpg?raw=true' /></td></tr>
</table>
Checking the results of our approach in Massachusetts roads, although there are some false positives and false negatives, we find that roads really exist in the regions of false positive (red) and no road exists in the false negative area (blue). Thus, higher scores do not necessarily mean better segmentation in Massachusetts road dataset. 

# Paper Citation
If our work has any inspiration for your research, please cite this our paper:
<pre>
  @ARTICLE{9363337,   
    author={Lian, Renbao and Huang, Liqin},  
    journal={IEEE Transactions on Geoscience and Remote Sensing},  
    title={Weakly Supervised Road Segmentation in High-Resolution Remote Sensing Images Using Point Annotations},   
    year={2022},  
    volume={60},  
    number={},  
    pages={1-13},  
    doi={10.1109/TGRS.2021.3059088}
  }
</pre>