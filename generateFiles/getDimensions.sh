#!/bin/bash

# identifies file names and images dimensions
# from a given input directory and outputs a
# csv file to 'Desktop'.

# >>>>>>> Needs ImageMagick to be installed!

# Nikolaos Beer, Max-Reger-Institut, Karlsruhe, 2017.

#####################################
# path to images:					#
#####################################

inputPath=~/Desktop/EdiromImages/images

#####################################
# DO NOT CHANGE FROM HERE!			#
#####################################
outputFile=~/Desktop/EdiromImages/dimensions.csv

rm $outputFile
cd $inputPath
touch $outputFile
for i in *.jpg; do
	identify -ping -format "$i;%wx%h\n" $i >> $outputFile
done
