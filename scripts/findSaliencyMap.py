import argparse
import array
import caffe
import json
import numpy as np
import scipy

from PIL import Image


def parseInputMetaDataFile(metaDataFileName):
    with open(metaDataFileName) as metaData:
        jsonData = json.loads(metaData.read())
        return jsonData


def preprocessRGBInput(imageFileName, metaData):
    image = Image.open(imageFileName)
    outputImageSize = metaData["output"]["width"], metaData["output"]["height"]
    image = image.resize(outputImageSize, Image.ANTIALIAS)
    if image.mode != "RGB":
        image = image.convert("RGB")
    imageArr = np.array(image, dtype=np.float32)
    imageMean = (100, 110, 118)
    imageScale = 0.0078431372549
    imageArr -= np.array(imageMean)
    imageArr *= imageScale
    imageArr = imageArr.transpose((2, 0, 1))

    return imageArr


def preprocessSphInput(sphericalCoordsFileName, metaData):
    binaryData = open(sphericalCoordsFileName, 'rb')
    (width, height) = metaData["output"]["width"],metaData["output"]["height"]
    sizeArr = array.array('H')
    sizeArr.fromfile(binaryData, 1)
    sphCoordsArr = array.array('f')
    sphCoordsArr.fromfile(binaryData, 2*sizeArr[0]*sizeArr[0])
    sphCoordsArr = np.array(sphCoordsArr).reshape(2, sizeArr[0], sizeArr[0])
    sphCoordsArr[1] %= 2*np.pi
    sphCoordsArr[1] -= np.pi
    sphCoordsArr[1] /= np.pi
    sphCoordsArr[0] /= (np.pi/2)
    resizedArr = np.zeros((2, height, width))
    resizedArr[0] = scipy.misc.imresize(sphCoordsArr[0], (height, width), interp='cubic', mode='F')
    resizedArr[1] = scipy.misc.imresize(sphCoordsArr[1], (height, width), interp='cubic', mode='F')
    return resizedArr


def preprocessInput(imageFileName, sphericalCoordsFileName, metaData):
    rgbArr = preprocessRGBInput(imageFileName, metaData)
    sphCoordsArr = preprocessSphInput(sphericalCoordsFileName, metaData)
    return rgbArr, sphCoordsArr


def postprocessOutput(caffeNet):
    outputArr = caffeNet.blobs['deconv2_1'].data[0, 0]
    outputArr = np.squeeze(np.array(outputArr))
    outputArr *= 128
    outputArr += 31
    outputArr = np.clip(outputArr, 0, 255)
    return outputArr


def findSaliency(net, imgFileName, sphFileName, outputFileName, args):
    metaData = parseInputMetaDataFile(args.metadata)
    (rgbArr, sphericalCoordsArr) = preprocessInput(imgFileName, sphFileName, metaData)
    net.blobs['rgb'].reshape(1, *rgbArr.shape)
    net.blobs['rgb'].data[...] = rgbArr
    net.blobs['sphericalCoords'].reshape(1, *sphericalCoordsArr.shape)
    net.blobs['sphericalCoords'].data[...] = sphericalCoordsArr
    net.forward()
    outputArr = postprocessOutput(net)
    imageOutput = Image.fromarray(outputArr)
    imageOutput = imageOutput.resize([500, 500], Image.ANTIALIAS)
    imageOutput = imageOutput.convert("L")
    print(imageOutput.mode)
    imageOutput.save(outputFileName)


parser = argparse.ArgumentParser()
parser.add_argument('metadata', help='image file name with path')
args = parser.parse_args()
caffe.set_mode_gpu()
net = caffe.Net('../models/vsenseSalNet360Deploy.prototxt', '../models/vsenseSalNet360Final_iter_12000.caffemodel', caffe.TEST)


findSaliency(net, 'tmp/Patch1.png', 'tmp/PatchSC1.bin', 'tmp/PatchSaliency1.png', args)
findSaliency(net, 'tmp/Patch2.png', 'tmp/PatchSC2.bin', 'tmp/PatchSaliency2.png', args)
findSaliency(net, 'tmp/Patch3.png', 'tmp/PatchSC3.bin', 'tmp/PatchSaliency3.png', args)
findSaliency(net, 'tmp/Patch4.png', 'tmp/PatchSC4.bin', 'tmp/PatchSaliency4.png', args)
findSaliency(net, 'tmp/Patch5.png', 'tmp/PatchSC5.bin', 'tmp/PatchSaliency5.png', args)
findSaliency(net, 'tmp/Patch6.png', 'tmp/PatchSC6.bin', 'tmp/PatchSaliency6.png', args)
