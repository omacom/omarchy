# Szövegkinyerés és diktálás

### Szövegkinyerés

Nyomd meg a `Super + Ctrl + PrtScr` kombinációt, hogy szövegkinyeréshez kiválassz egy területet a képernyőn. A tesseract nyílt forráskódú OCR-modell ezután gyorsan szöveggé alakítja a kiválasztást, és a vágólapra helyezi. Ezután csak meg kell nyomnod a `Super + V` kombinációt a beillesztéshez.

Ez nagyon hasznos címek kiszedéséhez képek lábléceiből vagy weboldal-fejlécekbe ágyazott telefonszámokból.

 ![text-extraction](images/text-extraction.webp)

### Diktálás

Friss telepítéseken a [Superwhisper](https://superwhisper.com/) az alapértelmezett diktálási háttérrendszer, felhős feldolgozással, offline modellletöltések nélkül. Válaszd a Superwhispert vagy a [Voxtype-ot](https://voxtype.io/) az Omarchy menüben a _Setup > Defaults > Dictation_ ponton keresztül. Egy háttérrendszer kiválasztása szükség esetén telepíti azt, és a diktálás alapértelmezettjévé teszi. A Voxtype egy alap angol modellt tölt be, amely 150MB helyet foglal; a modellt a `voxtype setup model` paranccsal cserélheted, a többi beállítást pedig a `~/.config/voxtype/config.toml` fájlban. A Superwhisper megnyitja a beállításait, hogy felhős vagy helyi feldolgozást válassz, és az OPR tartja frissen az alkalmazást.

Diktálni úgy diktálsz, hogy lenyomva tartod a `Right Alt` vagy az `F9` billentyűt, vagy a `Super + Ctrl + X` kombinációval kapcsolod, és a diktált szöveg a fókuszált beviteli területen jelenik meg. Ezek a billentyűparancsok a kiválasztott háttérrendszert használják. A Right Alt akkor is elindítja a diktálást, ha módosítóakkordban használja; ezekhez az akkordokhoz használd a Left Alt billentyűt. Olyan billentyűzetkiosztásokon, ahol a Right Alt AltGr, használd az `F9` billentyűt, hogy az AltGr elérhető maradjon gépeléshez.

Ugyanazok a billentyűparancsok mindkét háttérrendszerrel működnek. Válaszd ki a háttérrendszeredet a Setup > Defaults > Dictation pontban. A háttérrendszer-telepítő konfigurálja azt, és menti a választást. Futtasd az `omarchy default dictation` parancsot, hogy lásd, melyik van kiválasztva. A választás a `~/.config/omarchy/defaults/dictation` fájlban tárolódik. A friss telepítések automatikusan a Superwhispert választják.

Az Omarchy automatikusan betölti a kiválasztott háttérrendszer asztali integrációját. Nincs szükség Superwhisper-konfigurációra a `~/.config/hypr/` mappában.

Egyéni hozzárendelések és szkriptek használhatják az `omarchy dictation start`, `omarchy dictation stop` és `omarchy dictation toggle` parancsokat. A kiválasztott háttérrendszer kezeli a felvételt és az átírást. A Superwhisper kiválasztása letiltja a natív tartós billentyűparancsát, és natív kapcsolóját `Alt + Space`-re állítja, távol tartva az Omarchy felvételi billentyűitől. A Superwhisper legalább egy natív felvételi billentyűparancsot igényel, a megszakítási billentyűparancsa pedig elérhető marad.

További háttérrendszerek az Omarchy módosítása nélkül integrálhatók. Adj egy végrehajtható fájlt `omarchy-dictation-<backend>` néven a PATH-en, amely elfogadja a `start`, `stop` és `toggle` parancsokat, és azonnal visszatér, hiba esetén nem nulla állapotkóddal. A telepítője konfigurálja a szolgáltatót, és sikeres telepítés után meghívja az `omarchy-dictation-use <backend>` parancsot. Ez leállítja az előző háttérrendszert, és atomikusan menti a választást; a `stop` parancsnak sikeresnek kell lennie, amikor a szolgáltató üresjára vagy elérhetetlen. A háttérrendszernevek kisbetűket, számjegyeket és kötőjeleket használnak. Adj egy `omarchy-install-dictation-<backend>` fájlt a beállításhoz; az `omarchy default dictation <backend>` indítja azt. Adj hozzá Defaults menüpontot egy Omarchy menü-kiegészítőn keresztül, hogy meghívja azt a választót. Opcionális asztali integráció élhet a `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` helyen.
