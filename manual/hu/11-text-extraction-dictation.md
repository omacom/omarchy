# Szövegkivonatolás és diktálás

### Szövegkivonatolás

Üsd le a `Super + Ctrl + PrtScr` billentyűkombinációt egy képernyőterület kijelöléséhez szövegkivonatoláshoz. A tesseract nyílt forráskódú OCR-modell ezután gyorsan szöveggé alakítja a kijelölést, és a vágólapra helyezi. Ezután csak le kell ütnöd a `Super + V` kombinációt a beillesztéshez.

Ez nagyon hasznos címek kinyeréséhez képek láblécéből vagy weboldalak címsoraiba ágyazott telefonszámokhoz.

 ![text-extraction](images/text-extraction.webp)

### Diktálás

Friss telepítéseknél a [Superwhisper](https://superwhisper.com/) az alapértelmezett diktálási backend, amely felhős feldolgozást használ offline modellletöltések nélkül. Válaszd a Superwhisper vagy a [Voxtype](https://voxtype.io/) lehetőséget az Omarchy menü _Beállítás > Alapértelmezések > Diktálás_ pontjában. Egy backend kiválasztása szükség esetén telepíti azt, és alapértelmezetté teszi a diktáláshoz. A Voxtype egy alap angol modellt tölt be, amely 150MB helyet foglal; a modellt a `voxtype setup model` paranccsal, az egyéb beállításokat pedig a `~/.config/voxtype/config.toml` fájlon keresztül módosíthatod. A Superwhisper megnyitja a beállításait a felhős vagy helyi feldolgozás kiválasztásához, és az OPR tartja naprakészen az alkalmazást.

Úgy diktálhatsz, hogy lenyomva tartod a `Right Alt` billentyűt, vagy az `Alt + Space` kombinációval kapcsolod be és ki, és a lediktált szöveg megjelenik a fókuszban lévő beviteli mezőben. Ezek a gyorsbillentyűk a kiválasztott backendet használják. A Right Alt akkor is elindítja a diktálást, ha módosítóbillentyű-kombináció részeként használod; az ilyen kombinációkhoz használd a Left Alt billentyűt. Azokon a billentyűzetkiosztásokon, ahol a Right Alt az AltGr, használd az `Alt + Space` kombinációt, hogy az AltGr elérhető maradjon gépeléshez. Azok a telepítések, amelyek azelőtt készültek, hogy az Alt + Space lett volna az alapértelmezett, megtartják az `F9` billentyűt a push-to-talk funkcióhoz és a `Super + Ctrl + X` kombinációt a ki- és bekapcsoláshoz, hozzáadva a `~/.config/hypr/bindings.lua` fájlhoz; távolítsd el őket onnan, hogy visszaadd ezeket a billentyűket az alkalmazásoknak.

Ugyanazok a gyorsbillentyűk mindkét backenddel működnek. Válaszd ki a backendedet a Beállítás > Alapértelmezések > Diktálás pontban. A backend telepítője beállítja azt, és elmenti a kiválasztást. Futtasd az `omarchy default dictation` parancsot, hogy lásd, melyik van kiválasztva. A kiválasztás a `~/.config/omarchy/defaults/dictation` fájlba kerül mentésre. A friss telepítések automatikusan a Superwhispert választják.

Az Omarchy automatikusan betölti a kiválasztott backend asztali integrációját. Nincs szükség Superwhisper-beállításra a `~/.config/hypr/` könyvtárban.

Az egyéni billentyűkötések és szkriptek használhatják az `omarchy dictation start`, az `omarchy dictation stop` és az `omarchy dictation toggle` parancsokat. A kiválasztott backend kezeli a rögzítést és az átírást. A Superwhisper kiválasztása letiltja annak natív nyomva tartós gyorsbillentyűjét, és a natív ki- és bekapcsolást a `Ctrl + Alt + Space` kombinációra állítja, elkülönítve azt az Omarchy rögzítési billentyűitől. A Superwhisper legalább egy natív rögzítési gyorsbillentyűt igényel, és a megszakítási gyorsbillentyűje elérhető marad.

További backendek az Omarchy módosítása nélkül integrálhatók. Adj meg egy `omarchy-dictation-<backend>` nevű végrehajtható fájlt a PATH útvonalon, amely elfogadja a `start`, a `stop` és a `toggle` argumentumot, azonnal visszatér, hiba esetén pedig nem nulla állapotkóddal lép ki. A telepítője beállítja a szolgáltatót, és sikeres beállítás után meghívja az `omarchy-dictation-use <backend>` parancsot. Ez leállítja az előző backendet, és atomikusan elmenti a kiválasztást; a `stop` parancsnak akkor is sikeresnek kell lennie, ha a szolgáltató tétlen vagy nem elérhető. A backendnevek kisbetűket, számjegyeket és kötőjeleket használnak. A beállításhoz adj meg egy `omarchy-install-dictation-<backend>` fájlt; az `omarchy default dictation <backend>` indítja el azt. Adj hozzá egy Alapértelmezések menübejegyzést egy Omarchy menübővítményen keresztül az adott választó meghívásához. Az opcionális asztali integráció a `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` fájlban kaphat helyet.
