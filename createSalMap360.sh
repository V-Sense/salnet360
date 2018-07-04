#!/usr/bin/env bash
if [ -z "$1" ]
    then
        echo "No input image supplied"
        exit 0
fi

if [ -z "$2" ]
    then
        echo "No output image supplied"
        exit 0
fi


inputImage=$1
outputImage=$2
cd scripts
matlab -nodesktop -nojvm -r "createPatches($inputImage);exit"
python findSaliencyMap.py ../models/metaDataFile.json
matlab -nodesktop -nojvm -r "combinePatches($inputImage,$outputImage);exit"
cd ..