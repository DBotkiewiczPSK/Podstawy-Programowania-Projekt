# Podstawy Programowania - Zadania Projektowe

Projekt zawiera komplet rozwiązań zadań projektowych realizowanych w ramach przedmiotu **Podstawy programowania**. Głównym celem projektu jest automatyzacja zadań administratora i programisty, masowa obróbka danych tekstowych oraz numerycznych, manipulacja plikami strukturalnymi (JSON5, CSV, SQL), a także automatyzacja przetwarzania grafiki rasterowej za pomocą języka skryptowego **Bash** oraz narzędzi z kolekcji **GNU** w środowisku **MSYS2**.

---

## 🛠️ Środowisko i Wymagania

Wszystkie skrypty i polecenia zostały opracowane oraz przetestowane w środowisku **MSYS2** (podsystem **UCRT64** / **MINGW64**). Do poprawnego uruchomienia wszystkich elementów wymagane są następujące pakiety:

* **Interpreter:** Bash (wbudowany w MSYS2)
* **Narzędzia kolekcji GNU:** `cat`, `grep`, `sed`, `awk`, `diff`, `patch`, `paste`, `column`, `tr`
* **Wersjonowanie i Sumy Kontrolne:** `git`, `md5sum`
* **Archiwizacja:** `zip`, `unzip`, `p7zip` (komenda `7z`)
* **Przetwarzanie Grafiki:** `ImageMagick` (w środowisku UCRT64: `mingw-w64-ucrt-x86_64-imagemagick`)
* **Konwersja End-of-Line (EOL):** `dos2unix`

---

## 📋 Spis i Opis Zadań Projektowych

### Zadanie 2: MSYS2 i konfiguracja środowiska
* **Opis:** Instalacja i konfiguracja środowiska MSYS2. Aktualizacja repozytoriów pakietów oraz instalacja niezbędnego oprogramowania narzędziowego za pomocą menedżera pakietów `pacman`:
    ```bash
    pacman -Syu
    pacman -S vim nano less diffutils zip unzip p7zip dos2unix patch mingw-w64-ucrt-x86_64-imagemagick
    ```

### Zadanie 3: Niesforne dane
* **Cel:** Przekształcenie pliku tekstowego `dane.txt` zawierającego ciąg liczbowy w jednej kolumnie do ustrukturyzowanej postaci trzykolumnowej (tabela ze współrzędnymi X, Y, Z), gotowej do importu do arkusza kalkulacyjnego.
* **Polecenie jednoliniowe:**
    ```bash
    { echo -e "x\ty\tz"; tr -d '\r' < dane.txt | paste - - -; } | column -t > dane-format.txt
    ```

### Zadanie 4: Dodawanie poprawek (Patching)
* **Cel:** Wykrycie różnic pomiędzy wersją oryginalną `lista.txt` a poprawioną `lista-pop.txt`, przygotowanie i automatyczne nałożenie łatki (patcha) oraz weryfikacja integralności za pomocą sum kontrolnych MD5.
* **Polecenie:**
    ```bash
    dos2unix lista.txt lista-pop.txt && diff -u lista.txt lista-pop.txt | patch lista.txt && md5sum lista.txt lista-pop.txt
    ```

### Zadanie 5: Z CSV do SQL i z powrotem
* **Część 1 (CSV -> SQL):** Wygenerowanie instrukcji `INSERT INTO` dla bazy danych na podstawie surowych pomiarów CSV z separatorem średnika.
    ```bash
    tail -n +2 steps-2sql.csv | awk -F';' '{printf "INSERT INTO stepsData (time, intensity, steps) VALUES (%s, %s, %s);\n", $1, $2, $3}' > steps.sql
    ```
* **Część 2 (SQL -> CSV + Skalowanie Czasu):** Konwersja skryptu SQL zawierającego zrzuty pomiarów z powrotem do formatu CSV wraz ze zmianą precyzji znacznika czasu Unix Epoch (obcięcie milisekund do sekund poprzez usunięcie trzech końcowych zer).
    ```bash
    echo "dateTime;steps;synced" > steps.csv && cat steps-2csv.sql | sed -E 's/.*VALUES \(([0-9]+)000, ([0-9]+), ([0-9]+)\).*/\1;\2;\3/' >> steps.csv
    ```

### Zadanie 6: Marudny tłumacz (Modyfikacja plików JSON5)
* **Część 1 (Dublowanie i komentowanie linii):** Przygotowanie szablonu dla tłumacza poprzez podwojenie linii z kluczami i zakomentowanie pierwszej z nich.
    ```bash
    sed '/:/ { s/^\([[ :space: ]]*\)\(.*\)/\1\/\/ \2\n\1\2/ }' en-7.2.json5 > pl-7.2.json5
    ```
* **Część 2 (Izolacja nowych fraz do tłumaczenia):** Porównanie wersji językowej `en-7.2.json5` z nowszą wersją `en-7.4.json5`, identyfikacja nowo dodanych kluczy i wyciągnięcie pełnych linii zawierających te frazy.
    ```bash
    grep -f <(comm -13 <(grep -oE '"[^"]+":' en-7.2.json5 | sort) <(grep -oE '"[^"]+":' en-7.4.json5 | sort)) en-7.4.json5 > pl-7.4.json5
    ```

### Zadanie 7: Fotografik gamoń (Masowe przetwarzanie obrazów)
* **Cel:** Automatyczne rozpakowanie archiwów głównych i zagnieżdżonych, masowa zmiana formatu graficznego na JPG, wymuszenie rozdzielczości 96x96 DPI, przeskalowanie wysokości obrazu do 720 pikseli z zachowaniem proporcji oraz ponowna kompresja.
* **Skrypt automatyzujący (`zadanie8/skrypt.sh`):**
    ```bash
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
    ```

### Zadanie 8: Wszędzie te PDF-y (Generowanie portfolio)
* **Cel:** Wygenerowanie pliku PDF w formacie A4 do druku, zawierającego 8 fotografii na stronę w siatce 2x4 (dwie kolumny, cztery wiersze) wraz z automatycznym podpisaniem każdego zdjęcia nazwą pliku źródłowego.
    ```bash
    magick montage -density 96 -page A4 -tile 2x4 -geometry +20+20 -label '%f' gotowe/*.jpg portfolio_A4.pdf
    ```

### Zadanie 9: Porządki w kopiach zapasowych
* **Cel:** Uporządkowanie płaskiej struktury setek rozpakowanych plików archiwów ZIP (o nazwach w formacie `YYYY-MM-DD.zip`) do hierarchicznego drzewa katalogów: `rok/miesiac/`.
* **Skrypt automatyzujący (`zadanie9/skrypt.sh`):**
    ```bash
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
    ```

### Zadanie 10: Galeria dla grafika (Generator HTML)
* **Cel:** Dynamiczne wygenerowanie responsywnej galerii internetowej HTML na podstawie przetworzonych plików graficznych przy użyciu istniejącego szablonu strony.
* **Skrypt automatyzujący (`zadanie10/skrypt.sh`):**
    ```bash
    #!/bin/bash
    PLIK_WYNIKOWY="galeria.html"
    SZABLON="galeria/index.html"

    sed '/<\/body>/q' "$SZABLON" | sed 's|height: auto;|aspect-ratio: 4 / 3; object-fit: cover;|g' > "$PLIK_WYNIKOWY"

    cat <<EOF >> "$PLIK_WYNIKOWY"
    <h2>Dumb Image Gallery</h2>
    <h4>Foo Bar Graphic Designer</h4>
    EOF

    for plik in gotowe/*.jpg; do
        if [ ! -f "$plik" ]; then continue; fi
        nazwa=$(basename -- "$plik")
        
        cat <<EOF >> "$PLIK_WYNIKOWY"
    <div class="responsive">
    <div class="gallery">
      <a target="_blank" href="gotowe/$nazwa">
        <img src="gotowe/$nazwa">
      </a>
      <div class="desc">$nazwa</div>
    </div>
    </div>
    EOF
    done

    cat <<EOF >> "$PLIK_WYNIKOWY"
    <div class="clearfix"></div>
    </body>
    </html>
    EOF
    ```
---