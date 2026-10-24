# Márkajelzés

Az Omarchy lehetővé teszi, hogy a céges logódat vagy személyes képedet beállítsd a rendszerindítási feloldáshoz, a képernyővédőhöz és a névjegyképernyőhöz is.

### Rendszerindítási feloldás

Az `omarchy plymouth preview` paranccsal megnézheted, hogyan nézne ki az egyéni logód és színeid. Ez egy háttérszínt, egy szövegszínt, egy logó png-t és az előnézeti kép elérési útját kapja:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Ezután alkalmazd a beállítást az `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` paranccsal, amely az SDDM bejelentkezési képernyőnek is ugyanazokat a színeket és logót adja. Ha vissza akarod vonni, használhatod az `omarchy plymouth reset` parancsot.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Képernyővédő

A képernyővédőhöz használt logót a _Stílus > Képernyővédő_ alatt változtathatod meg. Ez egy ASCII-logó, így a szöveget közvetlenül szerkesztheted, de adhatsz neki png vagy svg képet is, és átkonvertáljuk ASCII-vé. Elég jól néz ki.

 ![branding-screensaver](images/branding-screensaver.webp)

Három bejegyzés van abban a menüben:

- A **Szöveg szerkesztése** megnyitja a `~/.config/omarchy/branding/screensaver.txt` fájlt a szerkesztődben. Írj vagy illessz be, amit akarsz — ASCII-művészetet, a neved, egy illetlen szót. Ments és lépj ki, és a képernyővédő azonnal beindul, hogy láthasd.
- A **Képből beállítás** megnyit egy fájlválasztót egy png-hez vagy svg-hez, átkonvertálja ASCII-vé, és megmutatja az eredményt. A világos sziluettű logók sokkal jobban működnek, mint a fotók.
- Az **Alap visszaállítása** visszateszi az Omarchy logót.

### Névjegyképernyő

Ugyanez a három lehetőség van a _Stílus > Névjegy_ alatt arra a _Névjegy_ képernyőre, amelyet az Omarchy menüből kapsz, és azonosan működnek — a fájl a `~/.config/omarchy/branding/about.txt`, és a Névjegy ablak minden változtatás után felugrik. A Névjegy grafikát kisebb méretűre konvertáljuk, mint a képernyővédőét, mivel egy ablakba kell beleférnie, nem pedig betöltenie a kijelződ.

Amíg az ablak nyitva van, néhány másodpercenként egy zöld fénysuhanás dől végig a grafikán, majd újra mozdulatlanul hagyja. A saját grafikád is megkapja, amennyiben benne minden karakter egy oszlop széles — és minden, amit a _Képből beállítás_ létrehoz, ilyen. Az emojikból vagy dupla szélességű karakterekből felépített grafika ehelyett mozdulatlan marad, és a képernyő is így marad, ha saját fastfetch-konfigurációd van: egy mozdulatlan logó ezekben az esetekben az, hogy az animáció félrehúzódik az útból, nem pedig meghibásodik, mivel egy fénysuhanást végigcsúsztatni rajtuk a sor többi részét rossz helyre tenné.

 ![branding-about](images/branding-about.webp)

### Képek konvertálása saját kézzel

Mindkét _Képből beállítás_ lehetőség csak az `omarchy transcode ascii` parancsot hívja, amelyet közvetlenül is futtathatsz, ha irányítani akarod a konvertálást:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Ez `--width` és `--height` értéket kap termináloszlopokban és -sorokban, egy `--mode` értéket, amely vagy `braille` (az alapértelmezett és sokkal finomabb) vagy `block`, egy `--threshold` százalékot annak eldöntésére, hogy mely pixelek számítanak a logó részének, és `--invert` kapcsolót arra az esetre, ha a logód világos sötét háttéren. Ha egy konvertálás egy nagy foltként jön ki, általában a küszöbérték az a gomb, amelyet tekerni kell.

### Szavak logó helyett

Az `omarchy ascii` szöveget rajzol Delta Corps Priest 1-ben, abban a FIGlet-betűtípusban, amelyben maga az Omarchy szóvédjegy is rajzolva van, így egy képernyővédő mondhat valamit, ahelyett, hogy képet mutatna:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Argumentumként kapja a szöveget, vagy egy csővezetékből olvassa, ha egyet sem adnak neki. A betűtípus csak betűket és szóközöket hordoz — számjegyek és írásjelek nélkül rajzolták —, így minden más kikerül, és a stderr-en megnevezve, ahelyett, hogy csendben elnyelődne.
