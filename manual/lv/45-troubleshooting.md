# Problēmu novēršana

### Es sabojāju sistēmu ar atjauninājumu!

Vispirms mēģiniet [atgriezt sistēmu](47-system-snapshots.md) uz versiju pirms nesenā atjauninājuma. Ja tas nepalīdz, izmantojiet `omarchy-debug`, lai kopīgotu savu problēmu kanālā #omarchy-help Discord. Un, ja nekas no tā nepalīdz, varat pārinstalēt noklusējuma konfigurācijas un pakotnes, izmantojot `omarchy-reinstall`.

### Kāpēc dažas lietotnes manā displejā ir tik lielas?

Omarchy pieņem, ka tiek izmantots 2x augstas izšķirtspējas displejs, kam nepieciešams iestatīt `GDK_SCALE` uz 2 failā `~/.config/hypr/monitors.lua`. Taču, ja jums ir 1x displejs, varat mainīt `local omarchy_gdk_scale = 2` uz 1 (un pēc tam restartēt visas pārāk lielās lietotnes). Skatiet [rokasgrāmatu par monitoriem](33-monitors.md).

Spotify gadījumā varat izmantot `Ctrl + Minus`, lai samazinātu saskarni (un `Ctrl + Plus`, lai to palielinātu).

### Kāpēc visas manas Super taustiņa kombinācijas pārstāja darboties?

Dažos ASUS ROG un TUF klēpjdatoros `Fn + Super` ir viegli nepamanāma kombinācija, kas pārslēdz aparātprogrammatūras Windows taustiņa bloķēšanu (paredzēta spēlēm, lai jūs nejauši neizietu no spēles). Ekrānā nekas neliecina, ka tas ir noticis. Kamēr bloķēšana ir ieslēgta, Super nesūta neko — tāpēc katra Omarchy kombinācija, kas izmanto Super, vienkārši pārstāj darboties, un izskatās, ka Hyprland ir sabojājies.

Nospiediet `Fn + Super` vienu reizi, pirms sākat rakņāties `~/.config/hypr/`, un, ja tas neatgriež Super, nospiediet to vēlreiz, lai neatstātu bloķēšanu ieslēgtu. Tā nav Fn-lock, kas maina tikai to, ko dara F taustiņu rinda.

### Mans Wi-Fi, Bluetooth, audio vai skārienpaliktnis vienkārši pārstāja darboties

Pirms pārstartēšanas mēģiniet restartēt attiecīgo apakšsistēmu atsevišķi. Omarchy izvēlnē _Update > Hardware_ ir Wi-Fi, Bluetooth, Audio un Trackpad, un vienas no tām pārlādēšana atrisina lielāko daļu situāciju tipa “pirms piecām minūtēm vēl darbojās” — Bluetooth austiņas, kas vairs nepievienojas, skārienpaliktnis, kas pārstāja darboties pēc miega režīma, skaņa, kas pazuda, atvienojot monitoru.

### Kāpēc mani ārējie skaļruņi neskan?

Iespējams, tāpēc, ka tie nav iestatīti kā primārā izvade. Noklikšķiniet uz skaļruņa ikonas joslas labajā pusē, un tiks atvērts skaļuma uznirstošais logs, kurā varat izvēlēties izvades ierīci (un arī sajaukt skaļumu katrai lietotnei atsevišķi).

### Mani klēpjdatora skaļruņi skan nepareizi

Dažos klēpjdatoros Omarchy automātiski piemēro skaļruņu regulējumu, kas koriģē iebūvēto skaļruņu frekvenču reakciju. `omarchy audio tuning status` norāda, vai jūsu datorā ir aktīvs regulējums, un `omarchy audio tuning off` to izslēdz, ja vēlaties dzirdēt skaļruņus neapstrādātus.

### Kāpēc nevaru pieteikties vai izmantot sudo ar savu paroli?

Iespējams, jūs to pārāk daudz reižu ievadījāt nepareizi un tikāt bloķēts. Ja tas notiek bloķēšanas ekrānā, varat nospiest `CTRL + ALT + F2`, lai sāktu jaunu TTY, kurā varat pieteikties kā root, pēc tam palaist `faillock --reset --user [your-username]`. Tas atiestatīs bloķēšanu, un varat turpināt.

### Kāpēc neparādās mani 1Password autorizācijas uzaicinājumi 1Password SSH Agent / CLI?

Tam var būt 2 iemesli:

Lai parādītos pilnvērtīgais apstiprinājuma uzaicinājums, ir jābūt ieslēgtam Settings > Advanced > Use Hardware Acceleration. _Piezīme: Lai tas sāktu darboties, nepieciešama pārstartēšana._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Vai arī, ja kopš palaišanas neesat palaidis 1Password, uzaicinājums neparādīsies.
