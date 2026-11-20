# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) üdítő alternatívája például a GitHub Desktop alkalmazásnak, és a terminálban fut.

Közvetlenül is futtathatod: menj bármelyik git által kezelt könyvtárba, és futtasd a `lazygit` parancsot. Vagy futtathatod Neovimban is, ahol a `Space G G` billentyűkombinációval indítható.

A különböző panelek között a `Tab` billentyűvel ugrálhatsz. A Files panelen a `Space` billentyűvel választhatsz ki fájlokat stage-elésre, majd a `c` billentyűvel hozhatsz létre új commitot. Az összes elérhető parancsot a `?` billentyűvel nézheted meg.

## Btop

[Btop](https://github.com/aristocratos/btop) egy gyönyörű erőforrás-kezelő, amely mutatja a memória-, CPU-, lemez- és hálózathasználatot. Felsorolja az összes aktív folyamatot is, és lehetővé teszi azok kezelését.

Az Omarchy Activity Monitor néven hivatkozik rá, és az alkalmazásindítóból vagy a `Super + Shift + T` billentyűkombinációval indíthatod. Lebegő ablakként nyílik meg, amelyet a `Super + T` billentyűkombinációval csempézhetsz.

## Herdr

[Herdr](https://herdr.dev) egy terminálos munkaterület-kezelő, amely munkaterületeket, füleket és paneleket ad, és mindegyiket futva tartja egy állandó munkamenetben, amelyről leválhatsz, majd később visszatérhetsz hozzá.

Az alkalmazásindítóból vagy a `Super + Ctrl + Return` billentyűkombinációval indíthatod el (vagy csatlakozhatsz vissza a meglévő munkamenetedhez). Az Omarchy olyan Herdr-konfigurációval érkezik, amely tükrözi a Tmux configját, így itt is a `Ctrl + Space` a prefix billentyű. Az összes billentyűkiosztást a `Super + Ctrl + K` billentyűkombinációval böngészheted.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) rendszerinformációkat mutat, például a kernel verzióját, az üzemidőt, a témát, a CPU-t, a memóriát és még sok mást. A népszerű neofetch eszköz utódja.

Az Omarchy ezt _Rendszer > Névjegy_ néven csomagolta be az Omarchy menübe (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) egy retró terminálos zenelejátszó, amelyet a Winamp 2.x ihletett, beépített rádióállomásokkal lo-fi beatekhez. Indítsd a `Super + Shift + Alt + M` billentyűkombinációval, vagy az Omarchy menüből az _Alkalmazások_ alatt. A teljes billentyűkiosztási listáért nyomd meg a `?` billentyűt.

## Mi a helyzet a Wi-Fi-vel és a Bluetoothszal?

Wi-Fi-hez és Bluetoothhoz nem találsz TUI-kat — ezek a feladatok az Omarchy shellre tartoznak. Kattints a Wi-Fi ikonra a felső sávban (vagy nyomd meg a `Super + Ctrl + N` billentyűkombinációt) a hálózatok megtekintéséhez és a csatlakozáshoz, és kattints a Bluetooth ikonra (vagy nyomd meg a `Super + Ctrl + B` billentyűkombinációt) az eszközök párosításához és csatlakoztatásához. A teljes történetért lásd a [hálózatkezelés](35-networking.md) oldalt.

## Saját hozzáadása

Bármelyik terminálprogram megkaphatja a teljes alkalmazáskezelést. Menj az Omarchy menüben (`Super + Space`) a _Telepítés > TUI_ pontra, adj neki nevet, indítási parancsot, ablakstílust és ikont, és megjelenik az alkalmazásindítóban, mint bármely más alkalmazás. Az _Eltávolítás > TUI_ alatt ismét eltávolíthatod.
