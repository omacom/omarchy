# TUIs

## Lazygit

A [Lazygit](https://github.com/jesseduffield/lazygit) egy kellemes alternatíva olyasmik helyett, mint a GitHub Desktop alkalmazás, és a terminálon belül fut.

Közvetlenül is futtathatod: menj bármelyik git által kezelt könyvtárba, és futtasd a `lazygit` parancsot. Vagy futtathatod Neovimban is, ahol a `Space G G` billentyűkkel indítható.

A különböző panelek között a `Tab` billentyűvel ugrálhatsz. A Files panelen a `Space` billentyűvel jelölöd ki a fájlokat stagingre, majd a `c` billentyűvel hozhatsz létre új commitot. Az összes elérhető parancsot a `?` billentyűvel nézheted meg.

## Btop

A [Btop](https://github.com/aristocratos/btop) egy gyönyörű erőforrás-kezelő, amely mutatja a memória-, CPU-, lemez- és hálózathasználatot. Kilistázza az összes aktív folyamatot is, és lehetővé teszi azok kezelését.

Az Omarchy Activity Monitor néven hivatkozik rá, és az alkalmazásindítóból vagy a `Super + Shift + T` billentyűkkel indíthatod el. Lebegő ablakként nyílik meg, amelyet a `Super + T` billentyűkkel csempézhetsz.

## Herdr

A [Herdr](https://github.com/omacom-io/herdr) egy terminálos munkaterület-kezelő, amely munkaterületeket, lapokat és paneleket ad, és mindegyiket futva tartja egy állandó munkamenetben, amelyről leválhatsz, és amelyhez később visszatérhetsz.

Az alkalmazásindítóból vagy a `Super + Ctrl + Return` billentyűkkel indíthatod el (vagy csatlakozhatsz újra a meglévő munkamenetedhez). Az Omarchy olyan Herdr-konfigurációval érkezik, amely tükrözi a Tmux-konfigurációját, így itt is a `Ctrl + Space` a prefix billentyű. Az összes billentyűkiosztást a `Super + Ctrl + K` billentyűkkel böngészheted.

## Fastfetch

A [Fastfetch](https://github.com/fastfetch-cli/fastfetch) rendszerinformációkat mutat, például a kernel verzióját, az üzemidőt, a témát, a CPU-t, a memóriát és még sok mást. A népszerű neofetch eszköz utódja.

Az Omarchy ezt _About_ néven csomagolta be az Omarchy menübe (`Super + Space`).

## Cliamp

A [Cliamp](https://www.cliamp.stream/) egy retró terminálos zenelejátszó, amelyet a Winamp 2.x ihletett, beépített rádióállomásokkal lo-fi beatekhez. Indítsd el a `Super + Shift + Alt + M` billentyűkkel, vagy az Omarchy menüből az _Apps_ alatt. A teljes billentyűkiosztási listához nyomd meg a `?` billentyűt.

## Mi a helyzet a Wi-Fi-vel és a Bluetooth-szal?

Nem fogsz TUI-kat találni a Wi-Fi-hez és a Bluetooth-hoz — ezek a feladatok az Omarchy shellre tartoznak. Kattints a Wi-Fi ikonra a felső sávban (vagy üsd le a `Super + Ctrl + N` billentyűket) a hálózatok megtekintéséhez és a csatlakozáshoz, és kattints a Bluetooth ikonra (vagy üsd le a `Super + Ctrl + B` billentyűket) az eszközök párosításához és csatlakoztatásához. A teljes történetért lásd a [hálózatkezelés](35-networking.md) oldalt.

## Saját hozzáadása

Bármelyik terminálprogram megkaphatja a teljes alkalmazáskezelést. Menj az _Install > TUI_ menüpontra az Omarchy menüben (`Super + Space`), adj neki egy nevet, egy indítási parancsot, egy ablakstílust és egy ikont, és megjelenik az alkalmazásindítóban, mint bármelyik másik alkalmazás. Az _Remove > TUI_ alatt ismét eltávolíthatod.
