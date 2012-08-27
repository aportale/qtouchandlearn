# sudo apt-get install fluidsynth fluid-soundfont-gm
for i in $(find ../src/data/audio -name "*.mid");\
do fluidsynth --fast-render=$(basename $i .mid).wav /usr/share/sounds/sf2/FluidR3_GM.sf2 $i;\
avconv -y -i $(basename $i .mid).wav -ac 1 -ab 32k $(basename $i .mid).mp3; \
avconv -y -i $(basename $i .mid).wav -ac 1 -ab 32k -acodec libvorbis $(basename $i .mid).ogg;\
done
