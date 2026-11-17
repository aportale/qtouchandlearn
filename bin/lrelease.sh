for i in $(find ../originaldata/ts -name "*.ts");do lrelease -nounfinished -removeidentical $i -qm ../src/TouchAndLearn/data/translations/$(basename $i .ts).qm;done
