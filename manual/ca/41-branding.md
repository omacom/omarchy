# Marca

Omarchy et permet definir el logotip de la teva empresa o una imatge personal tant per al desbloqueig d'arrencada com per a l'estalvi de pantalla i la pantalla Quant a.

### Desbloqueig d'arrencada

Pots utilitzar `omarchy plymouth preview` per veure com quedarien el teu logotip i els teus colors personalitzats. Accepta un color de fons, un color de text, un png amb el logotip i una ruta per a la imatge de previsualització:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Després aplica la configuració amb `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, que també donarà els mateixos colors i logotip a la pantalla d'inici de sessió SDDM. Si vols revertir-ho, pots utilitzar `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Estalvi de pantalla

Pots canviar el logotip utilitzat per a l'estalvi de pantalla a _Appearance > Branding > Screensaver_. És un logotip ASCII, de manera que pots editar el text directament, però també pots donar-li una imatge png o svg, i la convertirem a ASCII. Queda força bé.

 ![branding-screensaver](images/branding-screensaver.webp)

Hi ha tres entrades en aquest menú:

- **Edit Text** obre `~/.config/omarchy/branding/screensaver.txt` al teu editor. Escriu o enganxa el que vulguis: art ASCII, el teu nom, una paraula grollera. Desa i surt, i l'estalvi de pantalla s'engega immediatament perquè el puguis veure.
- **Set From Image** obre un selector de fitxers per a un png o svg, el converteix a ASCII i te'n mostra el resultat. Els logotips amb una silueta clara funcionen molt millor que les fotos.
- **Restore Default** torna a posar el logotip d'Omarchy.

### Pantalla Quant a

Les mateixes tres opcions són a _Appearance > Branding > About_ per a la pantalla _About_ que obtens des del menú d'Omarchy, i funcionen de manera idèntica: el fitxer és `~/.config/omarchy/branding/about.txt`, i la finestra Quant a apareix després de cada canvi. L'art de Quant a es converteix a una mida més petita que el de l'estalvi de pantalla, ja que ha d'encaixar en una finestra en lloc d'omplir tota la pantalla.

Mentre la finestra és oberta, una llum verda travessa l'art cada pocs segons i després el torna a deixar quiet. El teu propi art també la rep, sempre que cada caràcter que conté ocupi una sola columna d'amplada: tot el que produeix _Set From Image_ ho compleix. L'art creat a partir d'emoji o de caràcters d'amplada doble es queda quiet, i el mateix passa amb la pantalla si conserves una configuració de fastfetch pròpia: un logotip quiet en aquests casos és l'animació que es fa a un costat en lloc de fallar, ja que fer lliscar una llum a través seu posaria la resta de la línia al lloc equivocat.

 ![branding-about](images/branding-about.webp)

### Convertir imatges tu mateix

Totes dues opcions _Set From Image_ només criden `omarchy transcode ascii`, que pots executar directament si vols tenir control sobre la conversió:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Accepta `--width` i `--height` en columnes i files de terminal, un `--mode` de `braille` (el predeterminat, i molt més fi) o `block`, un percentatge `--threshold` per decidir quins píxels compten com a part del logotip, i `--invert` per quan el teu logotip és clar sobre un fons fosc. Si una conversió surt com una taca, el llindar sol ser el paràmetre que cal ajustar.

### Paraules en lloc d'un logotip

`omarchy ascii` dibuixa text en Delta Corps Priest 1, la font FIGlet en què està dibuixat el mateix logotip textual d'Omarchy, de manera que un estalvi de pantalla pot dir alguna cosa en lloc de mostrar una imatge:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Accepta el text com a arguments, o el llegeix d'una canonada quan no se'n dona cap. La font conté només lletres i espais — es va dibuixar sense dígits ni puntuació —, de manera que qualsevol altra cosa es descarta i s'anomena a stderr en lloc d'empassar-s'ho en silenci.
