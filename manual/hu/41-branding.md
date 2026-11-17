# Arculat

Az Omarchy lehetővé teszi, hogy vállalati logót vagy személyes képet állíts be a rendszerindítási feloldáshoz, a képernyővédőhöz és a névjegy képernyőhöz is.

### Rendszerindítási feloldás

A `omarchy plymouth preview` paranccsal megnézheted, hogyan nézne ki az egyéni logód és színeid. Egy háttérszínt, egy szövegszínt, egy logo png-t és az előnézeti kép elérési útját várja:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Ezután alkalmazd a beállítást a `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` paranccsal, amely az SDDM bejelentkezési képernyőnek is ugyanazokat a színeket és logót adja. Ha vissza akarod vonni, használd a `omarchy plymouth reset` parancsot.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Képernyővédő

A képernyővédőhöz használt logót a _Megjelenés > Arculat > Képernyővédő_ alatt változtathatod meg. Ez egy ASCII-logó, így a szöveget közvetlenül szerkesztheted, de adhatsz neki png vagy svg képet is, mi pedig átalakítjuk ASCII-vé. Elég menőn néz ki.

 ![branding-screensaver](images/branding-screensaver.webp)

Három bejegyzés van abban a menüben:

- A **Szöveg szerkesztése** megnyitja a `~/.config/omarchy/branding/screensaver.txt` fájlt a szerkesztődben. Írj vagy illessz be, amit csak akarsz — ASCII-művészetet, a nevedet, egy trágár szót. Ments és lépj ki, és a képernyővédő azonnal elindul, hogy megnézhesd.
- A **Beállítás képből** megnyit egy fájlválasztót egy png vagy svg fájlhoz, átalakítja ASCII-vé, és megmutatja az eredményt. A jól kivehető sziluettel rendelkező logók sokkal jobban működnek, mint a fotók.
- Az **Alapértelmezett visszaállítása** visszateszi az Omarchy logót.

### Névjegy képernyő

Ugyanez a három lehetőség található a _Megjelenés > Arculat > Névjegy_ alatt az Omarchy menüből elérhető _Névjegy_ képernyőhöz, és azonos módon működnek — a fájl a `~/.config/omarchy/branding/about.txt`, és a Névjegy ablak minden módosítás után felugrik. A névjegy grafikája kisebb méretre van átalakítva, mint a képernyővédőé, mivel egy ablakba kell beleférnie ahelyett, hogy kitöltené a kijelződet.

Amíg az ablak nyitva van, néhány másodpercenként egy zöld csillanás suhan át a grafikán, majd ismét mozdulatlanul hagyja. A saját grafikád is megkapja ezt, feltéve, hogy minden karaktere egy oszlop széles — minden, amit a _Beállítás képből_ létrehoz, ilyen. Az emojikból vagy dupla szélességű karakterekből épített grafikák ehelyett mozdulatlanok maradnak, és a képernyő is mozdulatlan marad, ha saját fastfetch konfigurációt tartasz meg: a mozdulatlan logó ezekben az esetekben azt jelenti, hogy az animáció félreáll az útból, nem pedig azt, hogy meghibásodott, mivel egy csillanás átcsúsztatása rajtuk a sor többi részét rossz helyre tenné.

 ![branding-about](images/branding-about.webp)

### Képek átalakítása saját kezűleg

Mindkét _Beállítás képből_ lehetőség csak a `omarchy transcode ascii` parancsot hívja, amelyet közvetlenül is futtathatsz, ha te akarod irányítani az átalakítást:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Fogad `--width` és `--height` értéket termináloszlopokban és -sorokban, egy `--mode` értéket, amely vagy `braille` (az alapértelmezett, és sokkal finomabb) vagy `block`, egy `--threshold` százalékot annak eldöntésére, hogy mely képpontok számítanak a logó részének, és `--invert` kapcsolót arra az esetre, ha a logód világos egy sötét háttéren. Ha egy átalakítás pacává válik, általában a küszöbérték az a gomb, amelyen tekerni kell.

### Szavak logó helyett

A `omarchy ascii` Delta Corps Priest 1 betűtípussal rajzol szöveget, abban a FIGlet betűtípusban, amellyel maga az Omarchy szóvédjegy is készült, így a képernyővédő mondhat valamit ahelyett, hogy képet mutatna:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

A szöveget argumentumként fogadja, vagy egy csővezetékből olvassa, ha nem adsz meg egyet sem. A betűtípus csak betűket és szóközöket tartalmaz — számjegyek és írásjelek nélkül rajzolták — így minden más kimarad, és a stderr felületén megnevezésre kerül ahelyett, hogy csendben lenyelné.
