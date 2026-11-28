# Imatge de marca

Omarchy et permet establir el logotip de la teva empresa o una imatge personal tant per al protector de pantalla com per a la pantalla Quant a.

### Protector de pantalla

Pots canviar el logotip utilitzat per al protector de pantalla a _Aparença > Imatge de marca > Protector de pantalla_. És un logotip ASCII, així que pots editar el text directament, però també li pots passar una imatge png o svg, i la convertirem a ASCII. Queda força xulo.

 ![branding-screensaver](images/branding-screensaver.webp)

Hi ha tres entrades en aquell menú:

- **Edita el text** obre `~/.config/omarchy/branding/screensaver.txt` al teu editor. Escriu o enganxa el que vulguis — art ASCII, el teu nom, una paraulota. Desa i surt, i el protector de pantalla s'inicia immediatament perquè el puguis veure.
- **Estableix des d'una imatge** obre un selector de fitxers per a un png o svg, el converteix a ASCII i te'n mostra el resultat. Els logotips amb una silueta clara funcionen molt millor que les fotos.
- **Restaura el predeterminat** torna a posar el logotip d'Omarchy.

### Pantalla Quant a

Les mateixes tres opcions són a _Aparença > Imatge de marca > Quant a_ per a la pantalla _Quant a_ que obtens des del menú d'Omarchy, i funcionen exactament igual — el fitxer és `~/.config/omarchy/branding/about.txt`, i la finestra Quant a apareix després de cada canvi. L'art de Quant a es converteix a una mida més petita que la del protector de pantalla, perquè ha d'encaixar en una finestra en lloc d'omplir tota la pantalla.

Mentre la finestra és oberta, una banda de llum blanca brillant travessa l'art en diagonal cada pocs segons i després el torna a deixar quiet. La teva pròpia art també la rep, sempre que cada caràcter que conté ocupi una sola columna — tot el que produeix _Estableix des d'una imatge_ ho compleix. L'art construïda amb emoji o caràcters de doble amplada es queda quieta, en canvi, i la pantalla també si mantens una configuració pròpia de fastfetch: un logotip quiet en aquests casos és que l'animació es fa a un costat en lloc de fallar, perquè fer lliscar un reflex per sobre seu faria que la resta de la línia acabés al lloc equivocat.

 ![branding-about](images/branding-about.webp)

### Convertir imatges pel teu compte

Les dues opcions d'_Estableix des d'una imatge_ només criden `omarchy transcode ascii`, que pots executar directament si vols tenir control sobre la conversió:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Accepta `--width` i `--height` en columnes i files del terminal, un `--mode` de `braille` (el predeterminat, i molt més fi) o `block`, un `--threshold` percentual per decidir quins píxels compten com a part del logotip, i `--invert` per quan el teu logotip és clar sobre un fons fosc. Si una conversió surt com una taca, el llindar sol ser el paràmetre que cal ajustar.

### Paraules en lloc d'un logotip

`omarchy ascii` dibuixa text amb Delta Corps Priest 1, la font FIGlet amb què es dibuixa la mateixa marca textual d'Omarchy, així que un protector de pantalla pot dir alguna cosa en lloc de mostrar una imatge:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Pren el text com a arguments, o el llegeix des d'una canonada quan no se n'hi passa cap. La font només inclou lletres i espais — es va dibuixar sense xifres ni signes de puntuació —, així que qualsevol altra cosa es descarta i s'indica per stderr en lloc d'empassar-s'ho en silenci.
