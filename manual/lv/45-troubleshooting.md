# Problēmu novēršana

### Es sabojāju savu sistēmu ar atjauninājumu!

Vispirms mēģiniet [atgriezt sistēmu](47-system-snapshots.md) uz versiju pirms nesenā atjauninājuma. Ja tas nelīdz, izmantojiet `omarchy-debug`, lai dalītos ar savu problēmu Discord kanālā #omarchy-help. Un, ja tas viss nelīdz, varat pārinstalēt noklusējuma konfigurācijas un pakotnes ar `omarchy-reinstall`.

### Kāpēc dažas lietotnes manā displejā ir tik lielas?

Omarchy pieņem 2x augstas izšķirtspējas displeju, kam failā `~/.config/hypr/monitors.lua` jāiestata `GDK_SCALE` uz 2. Bet, ja esat uz 1x displeja, varat mainīt `local omarchy_gdk_scale = 2` uz 1 (un pēc tam pārstartēt jebkuru pārāk lielo lietotni). Skatiet [rokasgrāmatu par monitoriem](33-monitors.md).

Spotify varat izmantot `Ctrl + Minus`, lai samazinātu UI (un `Ctrl + Plus`, lai padarītu to lielāku).

### Mans Wi-Fi, Bluetooth, audio vai skārienpaliktnis pēkšņi pārstāja darboties

Pirms pārstartējat, mēģiniet atsevišķi pārstartēt vainīgo apakšsistēmu. Omarchy izvēlnē sadaļā _Atjaunināt > Aparatūra_ ir Wi-Fi, Bluetooth, Audio un Skārienpaliktnis, un viena no tiem pārlādēšana atrisina lielāko daļu situāciju „tas pirms piecām minūtēm strādāja“ — Bluetooth austiņas, kas atkal nepievienojas, skārienpaliktnis, kas pēc apturēšanas nomira, skaņa, kas pazuda, atvienojot monitoru.

### Kāpēc mani ārējie skaļruņi neskan?

Iespējams, tāpēc, ka tie nav iestatīti kā galvenā izvade. Noklikšķiniet skaļruņa ikonu joslas labajā pusē, un atvērsies skaļuma uznirstošais logs, kur varat izvēlēties izvades ierīci (un arī miksēt skaļumu katrai lietotnei atsevišķi).

### Mani klēpjdatora skaļruņi skan nepareizi

Dažos klēpjdatoros Omarchy automātiski lieto skaļruņu noskaņojumu, kas koriģē iebūvēto skaļruņu frekvences raksturlīkni. `omarchy audio tuning status` pasaka, vai jūsu iekārtā kāds ir aktīvs, un `omarchy audio tuning off` to izslēdz, ja labāk vēlaties klausīties skaļruņus neapstrādātus.

### Kāpēc nevaru pieteikties vai sudo ar savu paroli?

Iespējams, ievadījāt to nepareizi pārāk daudz reižu un tikāt izslēgts. Ja tas notiek bloķēšanas ekrānā, varat nospiest `CTRL + ALT + F2`, lai startētu jaunu TTY, kur varat pieteikties kā root, pēc tam palaist `faillock --reset --user [your-username]`. Tas atiestatīs bloķēšanu, un jūs varat turpināt.

### Kāpēc manas 1Password autorizācijas uzvednes 1Password SSH Agent / CLI nerādās?

Tas var notikt 2 iemeslu dēļ:

Lai bagātīgā apstiprinājuma uzvedne parādītos, ir jāieslēdz Settings > Advanced > Use Hardware Acceleration. _Piezīme: lai tas sāktu darboties, vajadzīga pārstartēšana._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Vai, ja kopš sāknēšanas neesat palaidis 1Password, uzvedne neparādīsies.
