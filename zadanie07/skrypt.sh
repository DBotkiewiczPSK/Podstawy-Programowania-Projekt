#!/bin/bash

mkdir -p rozpakowane gotowe

7z e kopie-1.zip -orozpakowane -y -aou
7z e kopie-2.zip -orozpakowane -y -aou

for plik_zip in rozpakowane/*.zip; do
    if [ -f "$plik_zip" ]; then
        7z e "$plik_zip" -orozpakowane -y -aou
        rm "$plik_zip"
    fi
done

for plik in rozpakowane/*; do
    if [ ! -f "$plik" ]; then continue; fi

    nazwa_bazowa=$(basename -- "$plik")
    nazwa_bez_rozszerzenia="${nazwa_bazowa%.*}"
    magick "$plik" -units PixelsPerInch -density 96 -resize x720 "gotowe/${nazwa_bez_rozszerzenia}.jpg"
done

rm -f portfolio.zip 
zip -j portfolio.zip gotowe/*.jpg