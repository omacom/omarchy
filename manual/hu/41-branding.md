# Arculat

Az Omarchy lehetővé teszi, hogy beállítsd a céged logóját vagy egy személyes képet a rendszerindítási feloldáshoz, a képernyővédőhöz és a Névjegy képernyőhöz is.

### Rendszerindítási feloldás

Az `omarchy plymouth preview` paranccsal megnézheted, hogyan nézne ki az egyéni logód és a színeid. Egy háttérszínt, egy szövegszínt, egy logó png-t és az előnézeti kép elérési útját várja:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Ezután alkalmazd a beállítást az `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` paranccsal, amely az SDDM bejelentkezési képernyőnek is ugyanazokat a színeket és logót adja. Ha vissza akarod állítani, használhatod az `omarchy plymouth reset` parancsot.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Képernyővédő

A képernyővédőhöz használt logót a _Megjelenés > Arculat > Képernyővédő_ alatt módosíthatod. Ez egy ASCII logó, így közvetlenül szerkesztheted a szöveget, de megadhatsz neki egy png vagy svg képet is, és mi átkonvertáljuk ASCII-vé. Elég jól néz ki.

 ![branding-screensaver](images/branding-screensaver.webp)

Három bejegyzés van abban a menüben:

- **Szöveg szerkesztése** megnyitja a `~/.config/omarchy/branding/screensaver.txt` fájlt a szerkesztődben. Írj vagy illessz be, amit csak akarsz — ASCII művet, a nevedet, egy durva szót. Ments és lépj ki, és a képernyővédő azonnal elindul, hogy megnézhesd.
- **Beállítás képből** megnyit egy fájlválasztót egy png vagy svg fájlhoz, ASCII-vé konvertálja, és megmutatja az eredményt. A jól kivehető sziluettel rendelkező logók sokkal jobban működnek, mint a fotók.
- **Alapértelmezett visszaállítása** visszateszi az Omarchy logót.

### Névjegy képernyő

Ugyanez a három lehetőség érhető el a _Megjelenés > Arculat > Névjegy_ alatt az Omarchy menüből elérhető _Névjegy_ képernyőhöz, és pontosan ugyanúgy működnek — a fájl a `~/.config/omarchy/branding/about.txt`, és a Névjegy ablak minden módosítás után felugrik. A Névjegy grafikája kisebb méretre lesz konvertálva, mint a képernyővédőé, mivel egy ablakba kell beleférnie ahelyett, hogy kitöltené az egész kijelzőt.

Amíg az ablak nyitva van, néhány másodpercenként egy élénk fehér fénysáv dől végig a grafikán, majd újra mozdulatlanul hagyja. A saját grafikád is megkapja, amíg minden karaktere egy oszlop széles — minden, amit a _Beállítás képből_ létrehoz, ilyen. Az emojikból vagy dupla szélességű karakterekből készült grafikák ehelyett mozdulatlanok maradnak, és a képernyő is az marad, ha saját fastfetch configod van: a mozdulatlan logó ezekben az esetekben azt jelenti, hogy az animáció félreáll az útból, nem pedig hogy hibázik, mivel ha egy csillanást csúsztatna végig rajtuk, a sor többi része rossz helyre kerülne.

 ![branding-about](images/branding-about.webp)

### Képek konvertálása saját kezűleg

Mindkét _Beállítás képből_ lehetőség csak az `omarchy transcode ascii` parancsot hívja meg, amelyet közvetlenül is futtathatsz, ha te akarod irányítani a konvertálást:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

`--width` és `--height` értéket vár termináloszlopokban és -sorokban, egy `--mode` értéket, amely `braille` (az alapértelmezett, és sokkal finomabb) vagy `block` lehet, egy `--threshold` százalékértéket annak eldöntéséhez, hogy mely pixelek számítanak a logó részének, és `--invert` kapcsolót arra az esetre, amikor a logód világos sötét háttéren. Ha egy konvertálás egy pacává áll össze, általában a küszöbérték az a tekerő, amelyhez nyúlni kell.

### Szavak logó helyett

Az `omarchy ascii` a Delta Corps Priest 1 betűtípussal rajzol szöveget, azzal a FIGlet fonttal, amellyel maga az Omarchy szóvédjegy is készült, így a képernyővédő mondhat valamit ahelyett, hogy képet mutatna:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

A szöveget argumentumként várja, vagy egy pipe-ból olvassa, ha nem adsz meg egyet sem. A font csak betűket és szóközöket tartalmaz — számjegyek és írásjelek nélkül rajzolták —, így minden mást eldob, és nevén nevez a stderr-en, ahelyett hogy csendben lenyelné.
