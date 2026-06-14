#!/bin/bash

PLIK_WYNIKOWY="galeria.html"
SZABLON="galeria/index.html" 

sed '/<body>/q' "$SZABLON" | sed 's|height: auto;|aspect-ratio: 4 / 3; object-fit: cover;|g' > "$PLIK_WYNIKOWY"

cat <<EOF >> "$PLIK_WYNIKOWY"
<h2>Dumb Image Gallery</h2>
<h4>Foo Bar GraphiC DesigneR</h4>
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