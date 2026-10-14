# Marca

Omarchy et permet definir el logotip de la teva empresa o una imatge personal tant per al desbloqueig a l'arrencada com per al salvapantalles i per a la pantalla Quant a.

### Desbloqueig a l'arrencada

Pots fer servir `omarchy plymouth preview` per veure quin aspecte tindrien el teu logotip i els teus colors personalitzats. Accepta un color de fons, un color de text, un png de logotip i una ruta per a la imatge de previsualització:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Després aplica la configuració amb `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, que també donarà a la pantalla d'inici de sessió d'SDDM els mateixos colors i logotip. Si vols revertir-ho, pots fer servir `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Salvapantalles

Pots canviar el logotip que fa servir el salvapantalles a _Estil > Salvapantalles_. És un logotip ASCII, de manera que pots editar el text directament, però també li pots passar una imatge png o svg, i la convertirem a ASCII. Queda força bé.

 ![branding-screensaver](images/branding-screensaver.webp)

En aquest menú hi ha tres opcions:

- **Edita el text** obre `~/.config/omarchy/branding/screensaver.txt` al teu editor. Escriu o enganxa el que vulguis: art ASCII, el teu nom, una paraulota. Desa i surt, i el salvapantalles s'engegarà immediatament perquè el puguis veure.
- **Des d'una imatge** obre un selector de fitxers per a un png o svg, el converteix a ASCII i te'n mostra el resultat. Els logotips amb una silueta clara funcionen molt millor que les fotografies.
- **Restableix el defecte** torna a posar el logotip d'Omarchy.

### Pantalla Quant a

Les mateixes tres opcions són a _Estil > Quant a_ per a la pantalla _Quant a_ que obtens des del menú d'Omarchy, i funcionen igual: el fitxer és `~/.config/omarchy/branding/about.txt`, i la finestra Quant a apareix després de cada canvi. L'art del Quant a es converteix a una mida més petita que el del salvapantalles, perquè ha de cabre en una finestra en comptes d'omplir tota la pantalla.

Mentre la finestra és oberta, un llamp verd travessa l'art cada pocs segons i després el torna a deixar quiet. El teu art també el rep, sempre que cada caràcter ocupi una sola columna, i tot el que produeix _Des d'una imatge_ ho fa. L'art fet amb emojis o caràcters de doble amplada, en canvi, es queda quiet, i també la pantalla si conserves una configuració de fastfetch teva: en aquests casos, un logotip quiet és l'animació fent-se a un costat més que no pas fallant, perquè fer lliscar un llamp per damunt seu faria aterrar la resta de la línia al lloc equivocat.

 ![branding-about](images/branding-about.webp)

### Convertir imatges pel teu compte

Les dues opcions _Des d'una imatge_ no fan altra cosa que cridar `omarchy transcode ascii`, que pots executar directament si vols controlar la conversió:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Accepta `--width` i `--height` en columnes i files del terminal, un `--mode` de `braille` (el per defecte, i molt més fi) o `block`, un percentatge `--threshold` per decidir quins píxels compten com a part del logotip, i `--invert` per a quan el teu logotip és clar sobre un fons fosc. Si una conversió surt com una taca, el llindar sol ser el botó que cal girar.

### Paraules en comptes d'un logotip

`omarchy ascii` dibuixa text en Delta Corps Priest 1, el tipus de lletra FIGlet amb què està dibuixat el mateix logotip d'Omarchy, de manera que un salvapantalles pot dir alguna cosa en comptes de mostrar una imatge:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Accepta el text com a arguments, o el llegeix d'una canonada si no se n'hi dona cap. El tipus de lletra només conté lletres i espais — es va dibuixar sense dígits ni puntuació —, de manera que qualsevol altra cosa es descarta i s'anomena a stderr en comptes de ser empassada en silenci.
