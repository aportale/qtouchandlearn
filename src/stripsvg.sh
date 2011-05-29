#!/bin/bash
for svgfile in data/*.svg
do
    for idprefix in "path" "rect" "use"
    do
        regexp=s/id=\\\"${idprefix}[0-9-]*\\\"//
        cat ${svgfile} | sed ${regexp} > ${svgfile}_
        mv -f ${svgfile}_ ${svgfile}
    done
    cat ${svgfile} | sed 's/  / /' > ${svgfile}_
    mv -f ${svgfile}_ ${svgfile}
done
