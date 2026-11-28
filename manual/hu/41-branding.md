# Márkajelzés

Az Omarchy lehetővé teszi, hogy beállítsd a céged logóját vagy egy saját képet mind a képernyővédőhöz, mind a névjegy képernyőhöz.

### Képernyővédő

A képernyővédőhöz használt logót a _Megjelenés > Márkajelzés > Képernyővédő_ alatt módosíthatod. Ez egy ASCII logó, így közvetlenül szerkesztheted a szöveget, de adhatsz neki egy png vagy svg képet is, és mi átkonvertáljuk ASCII-vé. Elég menőn néz ki.

 ![branding-screensaver](images/branding-screensaver.webp)

Három bejegyzés van abban a menüben:

- A **Szöveg szerkesztése** megnyitja a `~/.config/omarchy/branding/screensaver.txt` fájlt a szerkesztődben. Gépelj vagy illessz be, amit csak akarsz — ASCII művészetet, a nevedet, egy csúnya szót. Ments és lépj ki, és a képernyővédő azonnal elindul, hogy lásd.
- A **Beállítás képről** megnyit egy fájlválasztót egy png vagy svg fájlhoz, átkonvertálja ASCII-vé, és megmutatja neked az eredményt. A határozott sziluettel rendelkező logók sokkal jobban működnek, mint a fotók.
- Az **Alapértelmezett visszaállítása** visszateszi az Omarchy logót.

### Névjegy képernyő

Ugyanez a három lehetőség van a _Megjelenés > Márkajelzés > Névjegy_ alatt ahhoz a _Névjegy_ képernyőhöz, amelyet az Omarchy menüből érsz el, és pontosan ugyanúgy működnek — a fájl a `~/.config/omarchy/branding/about.txt`, és a Névjegy ablak minden módosítás után felugrik. A Névjegy grafikája kisebb méretre lesz konvertálva, mint a képernyővédőé, mivel egy ablakba kell beleférnie ahelyett, hogy kitöltené a kijelződet.

Amíg az ablak nyitva van, néhány másodpercenként egy élénk fehér fénysáv dől át a grafikán, majd ismét mozdulatlanul hagyja. A saját grafikád is megkapja, feltéve, hogy minden karaktere egy oszlop széles — minden ilyen, amit a _Beállítás képről_ létrehoz. Az emojikból vagy dupla szélességű karakterekből épített grafika ehelyett mozdulatlan marad, és a képernyő is az marad, ha saját fastfetch konfigurációd van: ezekben az esetekben a mozdulatlan logó azt jelenti, hogy az animáció félreáll az útból, nem azt, hogy elromlott, mivel egy csillanás átcsúsztatása rajtuk a sor többi részét rossz helyre tenné.

 ![branding-about](images/branding-about.webp)

### Képek konvertálása saját kezűleg

Mindkét _Beállítás képről_ lehetőség csak a `omarchy transcode ascii` parancsot hívja, amelyet közvetlenül is futtathatsz, ha te akarod kézben tartani a konvertálást:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Elfogadja a `--width` és a `--height` értékét termináloszlopokban és -sorokban, egy `--mode` értéket, amely `braille` (az alapértelmezett, és sokkal finomabb) vagy `block` lehet, egy `--threshold` százalékos értéket annak eldöntésére, mely pixelek számítanak a logó részének, és az `--invert` kapcsolót arra az esetre, ha a logód világos egy sötét háttéren. Ha egy konvertálás egy pacává sikerül, általában a küszöbérték az a tekerőgomb, amelyen állítani kell.

### Szavak logó helyett

A `omarchy ascii` Delta Corps Priest 1 betűtípussal rajzol szöveget, azzal a FIGlet betűtípussal, amellyel maga az Omarchy szójel is készült, így a képernyővédő mondhat valamit ahelyett, hogy egy képet mutatna:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

A szöveget argumentumokként veszi át, vagy egy csővezetékből olvassa, ha nem adsz meg egyet sem. A betűtípus csak betűket és szóközöket tartalmaz — számjegyek és írásjelek nélkül készült —, így minden mást eldob, és az stderr felületen megnevezi, ahelyett, hogy csendben lenyelné.
