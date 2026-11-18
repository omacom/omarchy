# Neovim

A [Neovim](https://neovim.io/) modern megvalósítása [a vi szerkesztőnek](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), amelyet Bill Joy még 1976-ban alkotott. Ez egy modális szerkesztő, ahol a beszúrási mód és a parancsmód el vannak különítve, és kissé szupererővé válik, amint az elképesztően mély billentyűparancs-készletnek csak egy részhalmazát is megtanulod. De elég meredek a tanulási görbéje is!

Ha teljesen új vagy a vim-stílusú szerkesztésben, javaslom, hogy nézd meg [ThePrimeagen Vim As Your Editor sorozatát](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) YouTube-on. Ez megtanítja az alapokat. Csak tudd, hogy a hasonló mainstream szerkesztőkkel ellentétben a vim-mel az alapvető jártasság elérése tovább fog tartani. De ha egyszer megvan, a jutalom is nagyobb.

Nos, a Neovim alapvetően végtelenül konfigurálható. Ha igazán bele akarsz merülni, saját Neovim-konfigurációt készíthetsz a nulláról. Van egy nagyszerű kurzus [Typecrafttól a Neovim nulláról történő beállításáról](https://www.youtube.com/watch?v=zHTeCSVAFNY). És [ThePrimeagennél is van egy](https://www.youtube.com/watch?v=w7i4amO_zaE).

De az Omarchy teljes Neovim-beállítással érkezik — az `omarchy-nvim` csomaggal —, amelyet szeretettel hangoltak, hogy bemutassa a legjobbakat, amelyek azonnal használhatók. Anélkül, hogy egyetlen sor konfigurációt kellene írnod! A [LazyVimre](https://www.lazyvim.org/) épül, egy Neovim-pluginokból és konfigurációkból álló disztribúcióra. Zseniális.

## LazyVim-alapok

Ahogy említettem, ebben a rövid bevezetésben nem fogom megtanítani neked a vimet, de meg tudok mutatni néhány LazyVim-alapot, és azt, hogyan mozogj benne.

Először is, a Neovimnak van a leader billentyű fogalma. Ez alapvetően az összes parancs kapuja. A LazyVim ezt a `Space` billentyűre tette. Csak nyomd meg, várj egy másodpercet, és meglátsz egy halom lehetőséget soron belül elmagyarázva, mint ez:

Íme néhány alapvető parancs, amelyeket állandóan használok:

- `Space Space` - Bármely fájl fuzzy keresése az aktuális mappában.
- `Space S G` - Minden fájl keresése grep-pel, előnézettel.
- `Space E` - A fájlfa be-/kikapcsolása.
- `Ctrl + W W` - Ugrás a fájlfa és a szerkesztő között.
- `Shift + H` - Mozgás balra a nyitott lapok között (a vim ezeket buffereknek hívja).
- `Shift + L` - Mozgás jobbra a nyitott lapok között.
- `Space B D` - Lap bezárása.
- `Space B O` - Az aktuális kivételével minden más lap bezárása.
- `Space G G` - LazyGit indítása lebegő táblában az aktuális mappából.
- `Space U W` - Lágy tördelés kapcsolása.

Amíg a fájlfában vagy (`Space E` a feltáráshoz, `Ctrl + W W` az odaugráshoz), hozzáadhatsz új fájlt az `a` billentyűvel, vagy új mappát az `A` billentyűvel. Nyomd meg a `?` billentyűt a fában az összes parancs megtekintéséhez.

Ha fel szeretnéd szedni az alap vim-nyelvet, írtam [a háromrészes szintaxisról](https://world.hey.com/dhh/wonderful-vi-a1d034d3) és arról, hogyan lehet végrehajtani azokat a beteg kombo-mozdulatokat!

Az összes lehetséges parancsot láthatod [a LazyVim Keymaps oldalán](https://www.lazyvim.org/keymaps).

## A Neovim indítása

A Neovimot a `Super + Shift + N` kombinációval indíthatod (a hozzárendelés az alapértelmezett szerkesztődet indítja, amely azonnal a Neovim), de általában könnyebb terminálból vezetni, ha odanavigálsz a mappába, amelyben dolgozni akarsz, és begépeled az `n` betűt. Az `n` a `nvim` álneve, amely alapértelmezetten az aktuális mappát nyitja meg. Egyetlen fájlt az `n myfile.txt` paranccsal nyithatsz meg.

## A Neovim használata sudo-szerkesztésekhez

Ha olyan fájlokat kell szerkesztened, amelyeket csak szuperfelhasználóként tudsz változtatni, használhatod a neovimet minden beállított pluginoddal a `sudoedit /etc/sudoers.d/00-sudo-only-file` parancs futtatásával.
