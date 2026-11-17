for i in $(find ../originaldata/ts -name "*.ts");do lupdate -no-obsolete -locations none ../src/TouchAndLearn/database.js -ts $i;done
