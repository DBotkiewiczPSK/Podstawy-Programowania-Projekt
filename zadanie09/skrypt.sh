#!/bin/bash

mkdir -p kopie zarchiwizowane

unzip -o -j kopie-1.zip -d kopie
unzip -o -j kopie-2.zip -d kopie

for plik in kopie/*.zip; do
    nazwa=$(basename -- "$plik")
    rok=${nazwa:0:4}
    miesiac=${nazwa:5:2}
    
    mkdir -p "zarchiwizowane/$rok/$miesiac"
    cp "$plik" "zarchiwizowane/$rok/$miesiac/"
done
