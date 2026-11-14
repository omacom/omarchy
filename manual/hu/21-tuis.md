# TUIs

## Lazygit

A [Lazygit](https://github.com/jesseduffield/lazygit) egy elbűvölő alternatíva valami olyasmire, mint a GitHub Desktop alkalmazás, és a terminálban fut.

Futtathatod közvetlenül is: lépj be bármely git által kezelt könyvtárba, és futtasd a `lazygit` parancsot. Vagy futtathatod Neovimban is, ahol a `Space G G` billentyűkkel indítható el.

A különböző panelek között a `Tab` billentyűvel ugrálhatsz. A Files panelen a `Space` billentyűvel választod ki a fájlokat staginghez, majd a `c` billentyűvel hozhatsz létre új commitot. Az összes elérhető parancsot a `?` billentyűvel nézheted meg.

## Btop

A [Btop](https://github.com/aristocratos/btop) egy gyönyörű erőforrás-kezelő, amely megmutatja a memória-, CPU-, lemez- és hálózathasználatot. Felsorolja az összes aktív folyamatot is, és lehetőséget ad a kezelésükre.

Az Omarchy Activity Monitor néven hívja, és az alkalmazásindítóból vagy a `Super + Shift + T` megnyomásával indíthatod el. Lebegő ablakként nyílik meg, amelyet a `Super + T` billentyűkkel csempézhetsz.

## Herdr

A [Herdr](https://github.com/omacom-io/herdr) egy terminálos munkaterület-kezelő, amely munkaterületeket, lapokat és paneleket ad, és mindegyiket futva tartja egy állandó munkamenetben, amelyről leválhatsz, és amelyhez később visszatérhetsz.

A `Super + Ctrl + Return` billentyűkkel indíthatod el (vagy csatlakozhatsz vissza a meglévő munkamenetedhez). Az Omarchy olyan Herdr-konfigurációval érkezik, amely a Tmux-konfigurációját tükrözi, így itt is a `Ctrl + Space` az előtagbillentyű. Az összes billentyűkiosztást a `Super + Ctrl + K` billentyűkkel böngészheted.

## Fastfetch

A [Fastfetch](https://github.com/fastfetch-cli/fastfetch) rendszerinformációkat mutat, például a kernel verzióját, az üzemidőt, a témát, a CPU-t, a memóriát és még sok mást. A népszerű neofetch eszköz utódja.

Az Omarchy ezt _About_ néven csomagolta be az Omarchy menübe (`Super + Space`).

## Cliamp

A [Cliamp](https://www.cliamp.stream/) egy retró terminálos zenelejátszó, amelyet a Winamp 2.x ihletett, beépített rádióállomásokkal lo-fi beatekhez. Indítsd el a `Super + Shift + Alt + M` billentyűkkel, vagy az Omarchy menüből az _Apps_ alatt. A teljes billentyűkiosztási listához nyomd meg a `?` billentyűt.

## Mi a helyzet a Wi-Fi-vel és a Bluetoothszal?

Wi-Fi-hez és Bluetoothhoz nem találsz TUI-kat — ezek a feladatok az Omarchy shellre tartoznak. Kattints a Wi-Fi ikonra a felső sávban (vagy nyomd meg a `Super + Ctrl + N` billentyűket) a hálózatok megtekintéséhez és a csatlakozáshoz, és kattints a Bluetooth ikonra (vagy nyomd meg a `Super + Ctrl + B` billentyűket) az eszközök párosításához és csatlakoztatásához. A teljes történetért lásd a [hálózatkezelés](35-networking.md) oldalt.

## Saját hozzáadása

Bármely terminálprogram megkaphatja a teljes alkalmazásos kezelést. Lépj az _Install > TUI_ pontra az Omarchy menüben (`Super + Space`), adj neki nevet, indítási parancsot, ablakstílust és ikont, és megjelenik az alkalmazásindítóban, mint bármely más alkalmazás. Az _Remove > TUI_ alatt ismét eltávolíthatod.
