# TUI-k

## Lazygit

A [Lazygit](https://github.com/jesseduffield/lazygit) egy remek alternatíva például a GitHub Desktop alkalmazással szemben, és a terminálban fut.

Futtathatod közvetlenül: menj bármelyik git által kezelt könyvtárba, és futtasd a `lazygit` parancsot. Vagy futtathatod a Neovimon belül is, ahol a `Space G G` kombinációval indítható.

A különböző panelek között a `Tab` billentyűvel lépkedsz. A Files panelben a `Space` billentyűvel választasz ki fájlokat stage-eléshez, majd a `c` billentyűvel hozol létre új commitot. Az összes elérhető parancsot a `?` billentyűvel nézheted meg.

## Btop

A [Btop](https://github.com/aristocratos/btop) egy gyönyörű erőforráskezelő, amely mutatja a memória-, CPU-, lemez- és hálózathasználatot. Kilistázza az összes aktív folyamatot is, és lehetővé teszi azok kezelését.

Az Omarchy Activitynek hívja, és a `Super + Ctrl + T` kombinációval indítod. Lebegő ablakként nyílik, amelyet a `Super + T` kombinációval mozaikolhatsz.

## Herdr

A [Herdr](https://github.com/omacom-io/herdr) egy terminálos munkaterület-kezelő, amely munkaterületeket, lapokat és paneleket ad, és mindegyiket egy tartós munkamenetben tartja futva, amelyből leválaszthatsz, és később visszatérhetsz hozzá.

A `Super + Ctrl + Return` kombinációval indítod el (vagy csatolod vissza magad a meglévő munkamenetedhez). Az Omarchy olyan Herdr-konfigurációt szállít, amely tükrözi a Tmux-konfigurációját, így itt is a `Ctrl + Space` a prefixbillentyű. Az összes billentyűkiosztást a `Super + Ctrl + K` kombinációval böngészheted.

## Fastfetch

A [Fastfetch](https://github.com/fastfetch-cli/fastfetch) rendszerinformációkat mutat: kernelverziót, üzemidőt, témát, CPU-t, memóriát és egyebeket. A népszerű neofetch eszköz utódja.

Az Omarchy _About_ néven csomagolta az Omarchy menüben (`Super + Space`).

## Cliamp

A [Cliamp](https://www.cliamp.stream/) egy retró terminálos zenelejátszó, amelyet a Winamp 2.x ihletett, kiegészítve beépített lo-fi rádióadókkal. Indítsd a `Super + Shift + Alt + M` kombinációval, vagy az Omarchy menü _Apps_ pontjából. Nyomd meg a `?` billentyűt a teljes billentyűkiosztási listához.

## Mi a helyzet a Wi-Fivel és a Bluetoothszal?

Wi-Fihez és Bluetoothhoz nem találsz TUI-kat — ezek a feladatok az Omarchy shellre tartoznak. Kattints a Wi-Fi ikonra a felső sávban (vagy nyomd meg a `Super + Ctrl + W` kombinációt) a hálózatok megtekintéséhez és a csatlakozáshoz, és kattints a Bluetooth ikonra (vagy nyomd meg a `Super + Ctrl + B` kombinációt) az eszközök párosításához és csatlakoztatásához. A teljes történetért lásd a [networking](35-networking.md) részt.

## Saját hozzáadása

Bármilyen terminálprogram megkaphatja a teljes alkalmazáskezelést. Menj az Omarchy menü (`Super + Space`) _Install > TUI_ pontjához, adj neki nevet, indítóparancsot, ablakstílust és ikont, és megjelenik az alkalmazásindítóban, mint bármelyik másik alkalmazás. Ismét eltávolíthatod az _Remove > TUI_ alatt.
