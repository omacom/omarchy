# Neovim

A [Neovim](https://neovim.io/) a [vi szerkesztő](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) modern megvalósítása, amelyet Bill Joy alkotott meg még 1976-ban. Ez egy modális szerkesztő, ahol a beszúrási mód és a parancsmód különválik, és egyfajta szuperképesség, amint elsajátítod akár csak egy részét is a hihetetlenül mély billentyűparancs-készletnek. De azért elég meredek a tanulási görbéje is!

Ha teljesen új vagy a vim-stílusú szerkesztésben, ajánlom, hogy nézd meg [ThePrimeagen Vim As Your Editor sorozatát](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) a YouTube-on. Az megtanítja neked az alapokat. Csak tudd, hogy a hasonlóbb, elterjedtebb szerkesztőkkel ellentétben tovább fog tartani, amíg alapszintű jártasságra teszel szert a vimben. De ha egyszer sikerül, a megtérülés is nagyobb.

A Neovim alapvetően végtelenül konfigurálható. Ha tényleg meg akarsz őrülni, létrehozhatod a saját Neovim-konfigurációdat a nulláról. Van egy remek tanfolyam Typecrafttól [a Neovim beállításáról a nulláról](https://www.youtube.com/watch?v=zHTeCSVAFNY). És [ThePrimeagennek is van egy](https://www.youtube.com/watch?v=w7i4amO_zaE).

De az Omarchy egy teljes Neovim-beállítással érkezik — az `omarchy-nvim` csomaggal —, amelyet szeretettel hangoltak úgy, hogy dobozból kivéve megmutassa a legjobbat abból, ami lehetséges. Anélkül, hogy egyetlen sor konfigurációt is írnod kellene! A [LazyVimre](https://www.lazyvim.org/) épül, amely Neovim-pluginok és -konfigurációk disztribúciója. Fantasztikus.

## A LazyVim alapjai

Ahogy említettem, ebben a rövid bevezetőben nem foglak megtanítani vimre, de meg tudom mutatni a LazyVim néhány alapját, és azt, hogyan igazodj el benne.

Először is, a Neovimban létezik a leader billentyű fogalma. Ez alapvetően az összes parancs kapuja. A LazyVim ezt a `Space` billentyűre állította. Csak nyomd meg, várj egy másodpercet, és egy csomó lehetőséget fogsz látni soron belül elmagyarázva, így:

Íme néhány alapvető parancs, amelyet állandóan használok:

- `Space Space` - Bármely fájl fuzzy keresése az aktuális könyvtárban.
- `Space S G` - Keresés az összes fájlban grep segítségével, előnézettel.
- `Space E` - A fájlfa be-/kikapcsolása.
- `Ctrl + W W` - Ugrás a fájlfa és a szerkesztő között.
- `Shift + H` - Lépés balra a megnyitott lapok között (a vim buffereknek hívja őket).
- `Shift + L` - Lépés jobbra a megnyitott lapok között.
- `Space B D` - Lap bezárása.
- `Space B O` - Az összes többi lap bezárása az aktuális kivételével.
- `Space G G` - A LazyGit indítása lebegő panelen az aktuális könyvtárból.
- `Space U W` - A lágy sortörés be-/kikapcsolása.

Amikor a fájlfában vagy (`Space E` a megjelenítéséhez, `Ctrl + W W` az odaugráshoz), új fájlt az `a`, új könyvtárat pedig az `A` billentyűvel adhatsz hozzá. Nyomd meg a `?` billentyűt a fában az összes parancs megtekintéséhez.

Ha el akarod sajátítani az alapvető vim nyelvet, írtam [a háromrészes szintaxisról](https://world.hey.com/dhh/wonderful-vi-a1d034d3) és arról, hogyan hozhatod össze azokat a durva kombómozdulatokat!

Az összes lehetséges parancsot a [LazyVim Keymaps oldalán](https://www.lazyvim.org/keymaps) láthatod.

## A Neovim indítása

A `Super + Shift + N` elindítja az alapértelmezett szerkesztődet, amely új telepítéseken a Plain; válaszd a Neovimot a _Setup > Defaults > Editor_ alatt, hogy helyette a Neovim induljon. De általában egyszerűbb terminálból vezérelni: navigálj abba a könyvtárba, amelyben dolgozni szeretnél, és írd be, hogy `n`. Az `n` az `nvim` aliasa, amely alapértelmezetten a jelenlegi könyvtárat nyitja meg. Egyetlen fájlt az `n myfile.txt` paranccsal nyithatsz meg.

## A Neovim használata sudo szerkesztésekhez

Ha olyan fájlokat kell szerkesztened, amelyeket csak szuperfelhasználóként módosíthatsz, futtasd a `sudoedit /etc/sudoers.d/00-sudo-only-file` parancsot. Ez az alapértelmezett szerkesztődet nyitja meg, ezért állítsd be a Neovimot a _Setup > Defaults > Editor_ alatt, ha ott is azt szeretnéd használni az összes pluginoddal.
