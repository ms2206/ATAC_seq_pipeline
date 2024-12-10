#!/bin/bash
# Playing with tokenizing
# AL03Dec2024

x="1 2 3"

echo "Tokenizing (without quotation marks)"

for i in $x
do
    echo $i
done

echo "No tokenizing (with quotation marks)"

for i in "$x"
do
    echo $i
done

echo "Done"
date
