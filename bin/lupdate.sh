for i in $(find ../originaldata/ts -name "*.ts");do lupdate -no-obsolete -locations none ../src/qml/touchandlearn/database.js -ts $i;done
