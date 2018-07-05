# salnet360
Repository for implementation of **salnet360** in Caffe.

**salnet360** creates a visual attention map for omni-directional/360 images.
 
For more details on the model refer to ["SalNet360: Saliency maps for omni-directional images with CNN"](https://www.sciencedirect.com/science/article/pii/S0923596518304685) 

### Model and Parameter Files
The model and parameters files in _models_ directory.

**vsenseSalNet360Deploy.prototxt** is the file that defines the network model and 
**vsenseSalNet360Final_iter_12000.caffemodel** has the optimized parameters we found using the training method mentioned
in the paper.

### Creating an saliency map for omni-directional image
createSalMap360.sh \<inputImage> \<outputImage> 
 