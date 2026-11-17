for i in $(find ../originaldata/abcmidi -name "*.abc");do abc2midi $i -o ../src/TouchAndLearn/data/audio/$(basename $i .abc).mid;done
