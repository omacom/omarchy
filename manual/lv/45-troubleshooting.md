# Problēmu novēršana

### Es salauzu savu sistēmu ar atjauninājumu!

Vispirms mēģini [atgriezt savu sistēmu](47-system-snapshots.md) uz versiju pirms nesenā atjauninājuma. Ja tas nedarbojas, izmanto `omarchy-debug`, lai dalītos ar savu problēmu #omarchy-help kanālā Discord. Un, ja arī tas neizdodas, vari pārinstalēt noklusējuma konfigurācijas un pakotnes, izmantojot `omarchy-reinstall`.

### Kāpēc dažas lietotnes manā displejā ir tik lielas?

Omarchy pieņem, ka tev ir 2x augstas izšķirtspējas displejs, tāpēc tas iestata `GDK_SCALE` uz 2, līdz izvēlies mērogu monitora panelī. Ja tev ir 1x displejs un GTK vai X11 lietotnes izskatās pārāk lielas, monitora panelī izvēlies tam 1x vai pievieno `hl.env("GDK_SCALE", "1")` failam `~/.config/hypr/monitors.lua` (un pēc tam restartē visas lietotnes, kas ir pārāk lielas). Skaties [rokasgrāmatu par monitoriem](33-monitors.md).

Spotify gadījumā vari izmantot `Ctrl + Minus`, lai samazinātu saskarni (un `Ctrl + Plus`, lai to palielinātu).

### Kāpēc visas manas Super taustiņa kombinācijas pārstāja darboties?

Dažos ASUS ROG un TUF klēpjdatoros `Fn + Super` ir viegli nepamanāma kombinācija, kas pārslēdz programmaparatūras Windows taustiņa bloķēšanu (paredzēta spēlēm, lai nejauši neizietu no spēles). Ekrānā nekas neliecina, ka tas noticis. Kamēr bloķēšana ir ieslēgta, Super vispār neko neizvada — tāpēc katra Omarchy kombinācija, kas izmanto Super, vienkārši pārstāj darboties, un izskatās, ka salūza Hyprland.

Nospied `Fn + Super` vienu reizi, pirms sāc rakņāties pa `~/.config/hypr/`, un, ja tas neatgriež Super, nospied to vēlreiz, lai neatstātu bloķēšanu ieslēgtu. Tas nav Fn-lock, kas maina tikai to, ko dara F taustiņu rinda.

### Mans Wi-Fi, Bluetooth, audio vai skārienpaliktnis vienkārši pārstāja darboties

Pirms pārstartē datoru, pamēģini atsevišķi restartēt vainīgo apakšsistēmu. Omarchy izvēlnē _Update > Hardware_ ir Wi-Fi, Bluetooth, Audio un Trackpad, un vienas no tām pārlādēšana atrisina lielāko daļu situāciju tipa "pirms piecām minūtēm vēl strādāja" — Bluetooth austiņas, kas negrib atkal pievienoties, skārienpaliktnis, kas pēc miega režīma vairs nereaģē, skaņa, kas pazuda, kad atvienoji monitoru.

### Kāpēc mani ārējie skaļruņi neskan?

Visticamāk tāpēc, ka tie nav iestatīti kā galvenā izeja. Noklikšķini uz skaļruņa ikonas joslas labajā pusē, un atvērsies skaļuma uznirstošais logs, kur vari izvēlēties izejas ierīci (un arī regulēt skaļumu katrai lietotnei atsevišķi).

### Mani klēpjdatora skaļruņi skan dīvaini

Dažos klēpjdatoros Omarchy automātiski piemēro skaļruņu regulējumu, kas koriģē iebūvēto skaļruņu frekvenču reakciju. `omarchy audio tuning status` pasaka, vai tāds ir aktīvs tavā datorā, un `omarchy audio tuning off` to izslēdz, ja labāk gribi dzirdēt skaļruņus bez apstrādes.

### Kāpēc nevaru pieteikties vai izmantot sudo ar savu paroli?

Tu droši vien to ievadīji nepareizi pārāk daudz reižu un tiki izslēgts. Ja tas notiek bloķēšanas ekrānā, vari nospiest `CTRL + ALT + F2`, lai sāktu jaunu TTY, kur vari pieteikties kā root, pēc tam palaid `faillock --reset --user [your-username]`. Tas atiestatīs bloķēšanu, un vari turpināt.

### Kāpēc neparādās 1Password autorizācijas uzvednes 1Password SSH Agent / CLI?

Tas var notikt 2 iemeslu dēļ:

Lai parādītos pilnā apstiprināšanas uzvedne, iestatījumam Settings > Advanced > Use Hardware Acceleration jābūt ieslēgtam. _Piezīme: Lai tas sāktu darboties, nepieciešama pārstartēšana._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Vai arī, ja neesi palaidis 1Password kopš datora ieslēgšanas, uzvedne neparādīsies.
