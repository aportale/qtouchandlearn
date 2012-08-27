for i in $(find ../originaldata/abcmidi -name "*.abc");do abc2midi $i -o ../src/data/audio/$(basename $i .abc).mid;done
