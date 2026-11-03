# Problēmu novēršana

### Es salauzu savu sistēmu ar atjauninājumu!

Vispirms mēģini [atgriezt sistēmu](47-system-snapshots.md) uz versiju pirms nesenā atjauninājuma. Ja tas nepalīdz, izmanto `omarchy-debug`, lai dalītos ar savu problēmu #omarchy-help kanālā Discord. Un, ja nekas no tā nepalīdz, vari pārinstalēt noklusējuma konfigurācijas un pakotnes, izmantojot `omarchy-reinstall`.

### Kāpēc dažas lietotnes manā ekrānā ir tik lielas?

Omarchy pieņem, ka tev ir 2x augstas izšķirtspējas ekrāns, tāpēc tā iestata `GDK_SCALE` uz 2, līdz monitora panelī izvēlies mērogu. Ja tev ir 1x ekrāns un GTK vai X11 lietotnes izskatās pārāk lielas, izvēlies tam 1x monitora panelī vai pievieno `hl.env("GDK_SCALE", "1")` failam `~/.config/hypr/monitors.lua` (un pēc tam restartē jebkuru lietotni, kas ir pārāk liela). Skaties [rokasgrāmatu par monitoriem](33-monitors.md).

Spotify gadījumā vari izmantot `Ctrl + Minus`, lai samazinātu saskarni (un `Ctrl + Plus`, lai to palielinātu).

### Kāpēc visas manas Super taustiņa kombinācijas pārstāja darboties?

Dažos ASUS ROG un TUF klēpjdatoros `Fn + Super` ir viegli nepamanāma kombinācija, kas pārslēdz programmaparatūras Windows taustiņa bloķēšanu (paredzēta spēlēm, lai tu nejauši nepamestu spēli). Nekas ekrānā neliecina, ka tas ir noticis. Kamēr bloķēšana ir ieslēgta, Super neizdod vispār neko — tāpēc katra Omarchy kombinācija, kas izmanto Super, vienkārši pārstāj darboties, un izskatās, ka Hyprland ir salūzis.

Nospied `Fn + Super` vienu reizi, pirms sāc rakņāties pa `~/.config/hypr/`, un, ja tas neatgriež Super, nospied to vēlreiz, lai neatstātu bloķēšanu ieslēgtu. Tā nav Fn-lock, kas maina tikai to, ko dara F taustiņu rinda.

### Mans Wi-Fi, Bluetooth, audio vai skārienpaliktnis vienkārši pārstāja darboties

Pirms pārstartē datoru, mēģini restartēt attiecīgo apakšsistēmu atsevišķi. Omarchy izvēlnē _Update > Hardware_ ir Wi-Fi, Bluetooth, Audio un Trackpad, un vienas no tām pārlādēšana novērš lielāko daļu situāciju „tas darbojās pirms piecām minūtēm” — Bluetooth austiņas, kas nevēlas atkārtoti savienoties, skārienpaliktnis, kas pārstāja darboties pēc miega režīma, skaņa, kas pazuda, kad atvienoji monitoru.

### Kāpēc mani ārējie skaļruņi nespēlē?

Iespējams, tāpēc, ka tie nav iestatīti kā galvenā izeja. Noklikšķini uz skaļruņa ikonas joslas labajā pusē, un tiks atvērts skaļuma uznirstošais logs, kur vari izvēlēties izvades ierīci (un arī miksēt skaļumu katrai lietotnei atsevišķi).

### Mana klēpjdatora skaļruņi skan nepareizi

Dažos klēpjdatoros Omarchy automātiski piemēro skaļruņu skaņojumu, kas koriģē iebūvēto skaļruņu frekvences reakciju. `omarchy audio tuning status` parāda, vai tavā datorā tāds ir aktīvs, un `omarchy audio tuning off` to izslēdz, ja labprātāk dzirdētu skaļruņus bez apstrādes.

### Kāpēc nevaru pieteikties vai izmantot sudo ar savu paroli?

Iespējams, tu to pārāk daudz reižu ievadīji nepareizi un tiki bloķēts. Ja tas notiek bloķēšanas ekrānā, vari nospiest `CTRL + ALT + F2`, lai palaistu jaunu TTY, kur vari pieteikties kā root, pēc tam palaist `faillock --reset --user [your-username]`. Tas atiestatīs bloķējumu, un viss būs kārtībā.

### Mana parole tiek pieņemta, bet es atgriežos pieteikšanās ekrānā

Bojāts sesijas vides fails var neļaut darbvirsmai palaisties pat tad, ja parole ir pareiza. To īpaši vērts pārbaudīt pēc `~/.config/uwsm/env.d/` rediģēšanas.

Nospied `Ctrl + Alt + F2`, piesakies ar savu parasto lietotājvārdu un paroli un pārbaudi pašreizējās sāknēšanas lietotāja žurnālu:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Meklē kļūdu, kas nosauc vienu no taviem vides failiem, piemēram, `bad substitution`, tieši pirms ziņojuma, ka env izvades atzīme netika atrasta. Pirms mēģini pieteikties vēlreiz, pārvieto šo failu ārpus `env.d`. Piemēram, ja kļūda nosauc `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM izlaiž failu ar sintakses kļūdu, bet fatāla kļūda, kas parādās tikai faila izpildes laikā, piemēram, `bad substitution`, joprojām var neļaut darbvirsmai palaisties. Sistēmas momentuzņēmuma atgriešana šos failus nelabo, jo `/home` netiek atgriezts.

Kad vari pieteikties, izlabo saglabāto kopiju, pirms pārvieto to atpakaļ. `sh -n` uztver sintakses kļūdas, nepalaižot failu, bet nevar uztvert katru kļūdu, kas rodas, kad fails tiek ielādēts. Testējot izmaiņas, turi atvērtu darbojošos termināli.

### Kāpēc neparādās mani 1Password autorizācijas pieprasījumi 1Password SSH Agent / CLI vajadzībām?

Tam var būt 2 iemesli:

Lai parādītos pilnvērtīgais apstiprinājuma pieprasījums, Settings > Advanced > Use Hardware Acceleration ir jābūt ieslēgtam. _Piezīme: Lai tas sāktu darboties, nepieciešama pārstartēšana._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Vai, ja neesi palaidis 1Password kopš datora ieslēgšanas, pieprasījums neparādīsies.
