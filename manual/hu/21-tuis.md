# TUIs

## Lazygit

A [Lazygit](https://github.com/jesseduffield/lazygit) egy kellemes alternatíva valami olyasmire, mint a GitHub Desktop alkalmazás, és a terminálban fut.

Közvetlenül is futtathatod: menj bármelyik git által kezelt könyvtárba, és futtasd a `lazygit` parancsot. Vagy futtathatod a Neovimban is, ahol a `Space G G` billentyűkombinációval indítható.

A különböző panelek között a `Tab` billentyűvel ugrálhatsz. A Files panelen a `Space` segítségével választod ki a fájlokat stagingelésre, majd a `c` billentyűvel hozhatsz létre új commitot. Az összes elérhető parancsot a `?` billentyűvel nézheted meg.

## Btop

A [Btop](https://github.com/aristocratos/btop) egy gyönyörű erőforrás-kezelő, amely megmutatja a memória-, CPU-, lemez- és hálózathasználatot. Felsorolja az összes aktív folyamatot is, és lehetővé teszi azok kezelését.

Az Omarchy Activity Monitornak hívja, és az alkalmazásindítóból vagy a `Super + Shift + T` billentyűkombinációval indíthatod. Lebegő ablakként nyílik meg, amelyet a `Super + T` billentyűkombinációval csempézhetsz.

## Herdr

A [Herdr](https://github.com/omacom-io/herdr) egy terminálos munkaterület-kezelő, amely munkaterületeket, lapokat és paneleket ad, és mindegyiket futva tartja egy állandó munkamenetben, amelyről leválhatsz, és amelyhez később visszatérhetsz.

Az alkalmazásindítóból vagy a `Super + Ctrl + Return` billentyűkombinációval indíthatod el (vagy csatlakozhatsz vissza a meglévő munkamenetedhez). Az Omarchy olyan Herdr-konfigurációval érkezik, amely tükrözi a Tmux-konfigurációját, így a prefix billentyű itt is a `Ctrl + Space`. Az összes billentyűkiosztást a `Super + Ctrl + K` billentyűkombinációval böngészheted.

## Fastfetch

A [Fastfetch](https://github.com/fastfetch-cli/fastfetch) rendszerinformációkat mutat, például a kernel verzióját, az üzemidőt, a témát, a CPU-t, a memóriát és még sok mást. Ez a népszerű neofetch eszköz utódja.

Az Omarchy ezt _Rendszer > Névjegy_ néven csomagolta be az Omarchy menübe (`Super + Space`).

## Cliamp

A [Cliamp](https://www.cliamp.stream/) egy retró terminálos zenelejátszó, amelyet a Winamp 2.x ihletett, beépített rádióállomásokkal lo-fi beatekhez. A `Super + Shift + Alt + M` billentyűkombinációval vagy az Omarchy menü _Alkalmazások_ pontja alól indíthatod. A teljes billentyűkiosztási listához nyomd meg a `?` billentyűt.

## Mi a helyzet a Wi-Fi-vel és a Bluetooth-szal?

Nem fogsz TUI-kat találni a Wi-Fi-hez és a Bluetooth-hoz — ezek a feladatok az Omarchy shellhez tartoznak. Kattints a Wi-Fi ikonra a felső sávban (vagy nyomd meg a `Super + Ctrl + N` billentyűkombinációt) a hálózatok megtekintéséhez és a csatlakozáshoz, és kattints a Bluetooth ikonra (vagy nyomd meg a `Super + Ctrl + B` billentyűkombinációt) az eszközök párosításához és csatlakoztatásához. A teljes történetért lásd a [hálózatkezelés](35-networking.md) oldalt.

## Saját hozzáadása

Bármelyik terminálprogram megkaphatja a teljes alkalmazáskezelést. Menj a _Telepítés > TUI_ pontra az Omarchy menüben (`Super + Space`), adj neki nevet, indítóparancsot, ablakstílust és ikont, és megjelenik az alkalmazásindítóban, mint bármelyik másik alkalmazás. A _Eltávolítás > TUI_ pont alatt ismét eltávolíthatod.
