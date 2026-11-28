# Imatge de marca

Omarchy et permet definir el logotip de la teva empresa o una imatge personal tant per al desbloqueig d'arrencada, com per al protector de pantalla i la pantalla Quant a.

### Desbloqueig d'arrencada

Pots fer servir `omarchy plymouth preview` per veure com quedarien el teu logotip i els teus colors personalitzats. Accepta un color de fons, un color de text, un png amb el logotip i una ruta per a la imatge de previsualització:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

A continuació, aplica la configuració amb `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, que també donarà a la pantalla d'inici de sessió SDDM els mateixos colors i el mateix logotip. Si vols revertir-ho, pots fer servir `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Protector de pantalla

Pots canviar el logotip que fa servir el protector de pantalla a _Aparença > Imatge de marca > Protector de pantalla_. És un logotip en ASCII, o sigui que pots editar el text directament, però també li pots donar una imatge png o svg, i la convertirem a ASCII. Queda força xulo.

 ![branding-screensaver](images/branding-screensaver.webp)

Aquest menú té tres entrades:

- **Edita el text** obre `~/.config/omarchy/branding/screensaver.txt` al teu editor. Escriu o enganxa el que vulguis: art ASCII, el teu nom, una paraulota. Desa i surt, i el protector de pantalla s'engega immediatament perquè el puguis veure.
- **Defineix des d'una imatge** obre un selector de fitxers per a un png o un svg, el converteix a ASCII i te'n mostra el resultat. Els logotips amb una silueta clara funcionen molt millor que les fotos.
- **Restaura el valor predeterminat** torna a posar el logotip d'Omarchy.

### Pantalla Quant a

Les mateixes tres opcions són a _Aparença > Imatge de marca > Quant a_ per a la pantalla _Quant a_ que obtens des del menú d'Omarchy, i funcionen exactament igual: el fitxer és `~/.config/omarchy/branding/about.txt`, i la finestra Quant a apareix després de cada canvi. La imatge del Quant a es converteix a una mida més petita que la del protector de pantalla, perquè ha d'encabir-se en una finestra en lloc d'omplir-te tota la pantalla.

Mentre la finestra és oberta, una franja de llum blanca brillant passa inclinada per sobre de la imatge cada pocs segons i després la torna a deixar quieta. La teva imatge també la rep, sempre que tots els caràcters que la formen ocupin una sola columna d'amplada: tot el que produeix _Defineix des d'una imatge_ ho compleix. En canvi, la imatge feta amb emoji o caràcters d'amplada doble es queda quieta, i també ho fa la pantalla si tens una configuració de fastfetch pròpia: en aquests casos, un logotip quiet és l'animació fent-se a un costat en lloc de fallar, perquè fer lliscar una lluentor per sobre d'ells faria que la resta de la línia anés a parar al lloc equivocat.

 ![branding-about](images/branding-about.webp)

### Convertir imatges tu mateix

Totes dues opcions de _Defineix des d'una imatge_ simplement criden `omarchy transcode ascii`, que pots executar directament si vols tenir control sobre la conversió:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Accepta `--width` i `--height` en columnes i files del terminal, un `--mode` que pot ser `braille` (el predeterminat, i molt més fi) o `block`, un percentatge `--threshold` per decidir quins píxels compten com a part del logotip, i `--invert` per quan el teu logotip és clar sobre un fons fosc. Si una conversió surt com una taca informe, normalment és el llindar el que has d'ajustar.

### Paraules en lloc d'un logotip

`omarchy ascii` dibuixa text amb Delta Corps Priest 1, el tipus de lletra FIGlet amb què està dibuixat el mateix logotip textual d'Omarchy, de manera que un protector de pantalla pot dir alguna cosa en lloc de mostrar una imatge:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Accepta el text com a arguments, o el llegeix d'una canonada quan no se n'hi dona cap. El tipus de lletra només inclou lletres i espais — es va dibuixar sense dígits ni puntuació —, de manera que qualsevol altra cosa es descarta i s'anomena a stderr en lloc d'empassar-s'ho en silenci.
