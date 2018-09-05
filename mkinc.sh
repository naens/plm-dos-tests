#!/bin/zsh

# generates nasm .inc files from pl/m .ext files

for f in *.ext
do
    n=${f:r}
    echo -n extern > $n.inc
    grep ':' $f | sed -e 's/:.*$/, \\/' -e 's/^/\t/' >> $n.inc
done
