iconSizes="60 76 40 29 57 72 29 50"
iconSvg=../src/touchandlearn.svg
outputPath=../src/ios

for i in $iconSizes;\
do singleDensity=`echo "$i * 72 / 96" | bc -l`;\
singleDensityPng=$outputPath/icon_$i.png;\
doubleDensity=`echo "$singleDensity * 2" | bc -l`;\
doubleDensityPng=$outputPath/icon_$i@2x.png;\
convert -density $singleDensity $iconSvg $singleDensityPng;\
optipng $singleDensityPng;\
convert -density $doubleDensity $iconSvg $doubleDensityPng;\
optipng $doubleDensityPng;\
done
