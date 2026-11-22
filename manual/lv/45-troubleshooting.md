# Problēmu novēršana

### Es salauzu savu sistēmu ar atjauninājumu!

Vispirms mēģini [atgriezt sistēmu](47-system-snapshots.md) uz versiju pirms pēdējā atjauninājuma. Ja tas nelīdz, izmanto `omarchy-debug`, lai dalītos ar savu problēmu #omarchy-help kanālā Discord. Un ja nekas no tā nelīdz, tu vari atkārtoti instalēt noklusējuma konfigurācijas un pakotnes, izmantojot `omarchy-reinstall`.

### Kāpēc dažas lietotnes manā displejā ir tik lielas?

Omarchy pieņem, ka tev ir 2x augstas izšķirtspējas displejs, tāpēc tas iestata `GDK_SCALE` uz 2, līdz tu monitora panelī izvēlies mērogu. Ja tev ir 1x displejs un GTK vai X11 lietotnes iznāk pārāk lielas, monitora panelī izvēlies tam 1x vai pievieno `hl.env("GDK_SCALE", "1")` failam `~/.config/hypr/monitors.lua` (un pēc tam restartē visas lietotnes, kas ir pārāk lielas). Skaties [rokasgrāmatu par monitoriem](33-monitors.md).

Spotify gadījumā tu vari izmantot `Ctrl + Minus`, lai samazinātu saskarni (un `Ctrl + Plus`, lai to palielinātu).

### Kāpēc visas manas Super taustiņa kombinācijas pārstāja darboties?

Dažos ASUS ROG un TUF klēpjdatoros `Fn + Super` ir viegli nepamanāma taustiņu kombinācija, kas pārslēdz aparātprogrammatūras Windows taustiņa bloķēšanu (paredzēta spēlēm, lai tu nejauši neizietu no spēles). Nekas ekrānā par to neliecina. Kamēr bloķēšana ir ieslēgta, Super neizdod vispār neko — tāpēc katra Omarchy kombinācija, kas izmanto Super, vienkārši pārstāj darboties, un izskatās, ka Hyprland ir salūzis.

Nospied `Fn + Super` vienu reizi, pirms sāc rakties `~/.config/hypr/`, un ja tas neatgriež Super darbību, nospied to vēlreiz, lai neatstātu bloķēšanu ieslēgtu. Tā nav Fn-lock, kas maina tikai to, ko dara F taustiņu rinda.

### Mans Wi-Fi, Bluetooth, audio vai skārienpaliktnis vienkārši pārstāja darboties

Pirms pārstartē datoru, mēģini atsevišķi restartēt vainīgo apakšsistēmu. Omarchy izvēlnē _Update > Hardware_ ir Wi-Fi, Bluetooth, Audio un Trackpad, un vienas no tām pārlādēšana atrisina lielāko daļu situāciju "pirms piecām minūtēm vēl strādāja" — Bluetooth austiņas, kas negrib atkal savienoties, skārienpaliktnis, kas pēc miega režīma kļuva nedzīvs, skaņa, kas pazuda, kad atvienoji monitoru.

### Kāpēc mani ārējie skaļruņi nespēlē?

Iespējams, tāpēc, ka tie nav iestatīti kā galvenā izeja. Noklikšķini uz skaļruņa ikonas joslas labajā pusē, un tas atvērs skaļuma uznirstošo logu, kur vari izvēlēties izejas ierīci (un arī iestatīt katras lietotnes skaļumu atsevišķi).

### Mani klēpjdatora skaļruņi skan nepareizi

Dažos klēpjdatoros Omarchy automātiski piemēro skaļruņu regulējumu, kas koriģē iebūvēto skaļruņu frekvenču raksturlīkni. `omarchy audio tuning status` parāda, vai tavā datorā kāds ir aktīvs, un `omarchy audio tuning off` to izslēdz, ja labāk gribi dzirdēt skaļruņus neapstrādātus.

### Kāpēc es nevaru pieteikties vai izmantot sudo ar savu paroli?

Tu, iespējams, desmit reizes to ievadīji nepareizi un tiki bloķēts. Bloķēšana pati no sevis atceļas pēc divām minūtēm. Ja nevari gaidīt un tas notiek bloķēšanas ekrānā, tu vari nospiest `CTRL + ALT + F2`, lai sāktu jaunu TTY, kur vari pieteikties kā root, pēc tam palaist `faillock --reset --user [your-username]`. Tas atiestatīs bloķēšanu, un viss būs kārtībā.

### Mana parole tiek pieņemta, bet es atgriežos pieteikšanās ekrānā

Bojāts sesijas vides fails var neļaut darbvirsmai startēties pat tad, ja parole ir pareiza. To īpaši vērts pārbaudīt pēc `~/.config/uwsm/env.d/` rediģēšanas.

Nospied `Ctrl + Alt + F2`, piesakies ar savu parasto lietotājvārdu un paroli un pārbaudi pašreizējās sāknēšanas lietotāja žurnālu:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Meklē kļūdu, kas nosauc kādu no taviem vides failiem, piemēram, `bad substitution`, tieši pirms ziņojuma, ka env izejas atzīme netika atrasta. Pirms mēģini pieteikties vēlreiz, pārvieto šo failu ārā no `env.d`. Piemēram, ja kļūda nosauc `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM izlaiž failu ar sintakses kļūdu, bet fatāla kļūda, kas parādās tikai tad, kad fails darbojas, piemēram, `bad substitution`, joprojām var neļaut darbvirsmai startēties. Sistēmas momentuzņēmuma atgriešana šos failus nesalabo, jo `/home` netiek atgriezts.

Kad vari pieteikties, salabo saglabāto kopiju, pirms to pārvieto atpakaļ. `sh -n` uztver sintakses kļūdas, nepalaidot failu, bet nevar uztvert katru kļūdu, kas rodas, kad tas tiek ielādēts. Pārbaudot izmaiņas, turi atvērtu darbojošos termināli.

### Kāpēc neparādās manas 1Password autorizācijas uzvednes 1Password SSH Agent / CLI?

Tam var būt 2 iemesli:

Lai parādītos pilnvērtīgā apstiprinājuma uzvedne, Settings > Advanced > Use Hardware Acceleration jābūt ieslēgtam. _Piezīme: Lai tas sāktu darboties, nepieciešama pārstartēšana._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Vai arī, ja neesi palaidis 1Password kopš datora ieslēgšanas, uzvedne neparādīsies.
