iconSizes="29 40 57 60 72 76"
iconSvg=../src/ios/AppIcon.svg
outputPath=../src/ios

function generatePng() {
    convert -density $1 $iconSvg $2;\
    optipng $2;\
}

for i in $iconSizes;\
do singleDensity=`echo "$i * 72 / 96" | bc -l`;\
doubleDensity=`echo "$singleDensity * 2" | bc -l`;\
prefix=AppIcon${i}x${i};\
generatePng $singleDensity $outputPath/${prefix}.png;\
generatePng $doubleDensity $outputPath/${prefix}@2x.png;\
generatePng $singleDensity $outputPath/${prefix}~ipad.png;\
generatePng $doubleDensity $outputPath/${prefix}@2x~ipad.png;\
done

# Icon of the WebAssembly page on the iOS Home Screen (60x60@3x). Inkscape renders the SVG
# directly at the given pixel size.
inkscape -w 180 -h 180 -o ../src/wasm/apple-touch-icon.png $iconSvg
optipng ../src/wasm/apple-touch-icon.png
