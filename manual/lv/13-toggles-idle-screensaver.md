# Pārslēgi, dīkstāve un ekrānsaudzētājs

Daudz no tā, ko maināt ikdienā, īsti nav iestatījums. Tas ir režīms, ko ieslēdzat uz stundu un pēc tam atkal izslēdzat: nakts gaisma, kamēr strādājat vēlu, netraucēt, kamēr prezentējat, palikt nomodā, kamēr kaut ko skatāties. Omarchy tos sauc par pārslēgiem, un tie visi darbojas vienādi — karstais taustiņš, izvēlnes ieraksts un komanda, kas visi trāpa vienam un tam pašam slēdzim.

### Pārslēgu izvēlne

`Super + Ctrl + O` atver _Aktivizēšana > Pārslēgi_ tieši, vai arī varat turp aiziet no Omarchy izvēlnes (`Super + Space`). Viss šajā sarakstā ir slēdzis, ko varat pārslēgt, nedomājot par to, kur glabājas stāvoklis. Slēdži tam, kā darbvirsma izskatās, atrodas tai blakus, sadaļā _Izskats_.

No termināļa tie paši slēdži ir `omarchy toggle <thing>`. Palaidiet `omarchy toggle` vienu pašu, lai redzētu visu grupu.

| Pārslēgs | Karstais taustiņš | Komanda |
| ------ | ------ | ------- |
| Nakts gaisma | — | `omarchy toggle nightlight` |
| Apklusināt paziņojumus | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Palikt nomodā (bez dīkstāves bloķēšanas) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Avāriju tveršana | — | `omarchy toggle crash-capture` |
| Ekrānsaudzētājs | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) motīva sinhronizācija | — | `omarchy toggle theme sync` |
| Izvēlnes josla | `Super + Shift + Space` | `omarchy toggle bar` |
| Skārienpaliktnis | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Skārienekrāns | — | `omarchy device touchscreen` |
| Apturēt | — | `omarchy toggle suspend` |
| Hibrīdais GPU | — | `omarchy toggle hybrid gpu` |

Skārienpaliktņa, skārienekrāna un hibrīdā GPU slēdži atrodas sadaļā _Aktivizēšana > Aparatūra_ (`Super + Ctrl + H`), nevis sadaļā Pārslēgi, jo tie parādās tikai tad, kad jums tiešām ir šāda aparatūra. Skārienpaliktņa un skārienekrāna slēdži saglabājas pēc Hyprland pārlādēšanas — atspējotās ierīces nosaukums tiek saglabāts nelielā stāvokļa failā, ko Hyprland nolasa startēšanas laikā, lai to atkal atspējotu.

Sadaļā _Izskats_ ir izvēlnes josla un animācijas, kā arī dažas lietas, kas nav `omarchy toggle` komandas, bet darbojas tāpat: akumulatora procenti joslā, noklusējuma darbvietas izkārtojums un sadaļā _Logi_ — logu atstarpes (`Super + Shift + Backspace`) un 1 loga kvadrātveida malu attiecība (`Super + Ctrl + Backspace`).

Kad Hyprland nav GPU, ar ko zīmēt, un tā vietā renderēšana notiek ar CPU (llvmpipe), kā Mac datoros, kuru GPU vēl netiek atbalstīts, lielākajā daļā virtuālo mašīnu vai kad grafikas draiveris neielādējas, Omarchy šai sesijai izslēdz animācijas, izpludināšanu un ēnas un vienreiz jums to pasaka ar paziņojumu. _Izskats > Animācijas ieslēgtas_ tās atgriež atpakaļ, un Omarchy to atceras arī vēlākām sesijām.

Lielākā daļa no tiem ir vienkārši karodziņa fails mapē `~/.local/state/omarchy/toggles/`. Ja vēlaties skriptā sazaroties atkarībā no kāda no tiem, `omarchy-toggle-enabled` jums iedod izejas kodu, nevis liek pašam meklēt:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Karodziņi ir nosaukti izslēgtā stāvokļa vārdā — `screensaver-off`, `suspend-off`, `bar-off` — tāpēc to klātbūtne nozīmē, ka funkcija ir atspējota.

### Indikatori joslā

Kad režīms ir ieslēgts, augšējās joslas vidū blakus pulkstenim parādās neliela glifa. Tas ir indikatoru logrīks, un tajā ir diktēšana, ekrāna ierakstīšana, gaidošie atgādinājumi, nakts gaisma, netraucēt un palikšana nomodā.

Neaktīvie indikatori ir paslēpti. Uzbīdiet kursoru jebkur uz joslas, un tie parādās blāvi, lai varat noklikšķināt uz kāda, lai to ieslēgtu, nezinot tā karsto taustiņu. Noklikšķinot uz aktīva, tas tiek atkal izslēgts. Ja vēlaties tos visus redzēt visu laiku, iestatiet `alwaysShow` uz `true` ierakstā `omarchy.indicators` failā `~/.config/omarchy/shell.json` — skatiet [augšējo joslu](05-the-top-bar.md), lai uzzinātu, kā joslas logrīki tiek konfigurēti.

### Nakts gaisma

Nakts gaisma sasilda ekrānu līdz 4000K, un, pārslēdzot to vēlreiz, tas tiek atgriezts uz 6500K. Pārslēdziet to no pārslēgu izvēlnes (`Super + Ctrl + O`) vai ar `omarchy toggle nightlight`. To darbina hyprsunset, ko pārslēgs jums palaiž, ja tas vēl nedarbojas.

Pēc noklusējuma hyprsunset ar jūsu ekrānu nedara neko. `~/.config/hypr/hyprsunset.conf` tiek piegādāts ar identitātes profilu tieši tāpēc, lai displejs paliktu neskarts, līdz jūs paprasāt siltumu. Ja vēlaties, lai tas pārslēgtos pēc pulksteņa, aizstājiet to ar laika profilu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pēc tam palaidiet hyprsunset pieteikšanās laikā, pievienojot `o.launch_on_start("hyprsunset")` failam `~/.config/hypr/autostart.lua`. Pārslēga izmantotais 4000K/6500K pāris ir fiksēts, tāpēc konfigurācijas fails ir vieta, kur vērsties, ja vēlaties citu temperatūru.

### Netraucēt

`Super + Ctrl + Alt + ,` apklusina paziņojumus. Kamēr tas ir ieslēgts, neparādās nekādi uznirstošie paziņojumi, un joslā sēž pārsvītrota zvana indikators, lai atgādinātu, kāpēc darbvirsma ir kļuvusi tik klusa.

Tomēr nekas netiek zaudēts. Apklusinātie paziņojumi tiek aizturēti: pēdējos dažus atkal parādiet ekrānā ar `Super + Shift + Alt + ,`. Pārējo skatiet sadaļā [paziņojumi](10-notices.md).

Divu veidu ziņojumi joprojām tiek cauri: paša Omarchy apstiprinājuma uznirstošie paziņojumi par kaut ko, ko tikko izdarījāt ("Motīvs mainīts", "Ekrānuzņēmums saglabāts"), un kritiski brīdinājumi, kas nosūtīti no komandrindas. Tērzēšanas lietotnes, kas visu atzīmē kā kritisku, lai piespiestu sevi izvirzīties jums priekšā, tam nekvalificējas.

### Dīkstāve

Omarchy čaula pārvalda dīkstāves uzvedību, un laiki ir augšējā līmeņa `idle` bloks failā `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Abi skaitļi ir sekundes, kas skaitītas no brīža, kad pārgājāt dīkstāvē — nevis viens no otra. Tātad ar noklusējumiem ekrānsaudzētājs parādās pēc divarpus minūtēm un bloķēšanas ekrāns pārņem pēc piecām minūtēm neatkarīgi no tā, vai ekrānsaudzētājs darbojās. Saglabājiet failu, un čaula jaunos laikus paņem uzreiz.

Ja noraidāt ekrānsaudzētāju pirms bloķēšanas termiņa, tas tiek uzskatīts par aktivitāti un gaidošā bloķēšana tiek atcelta. Nebūsiet bloķēts tikai tāpēc, ka paskatījāties uz savu datoru.

Lai pilnībā apturētu bloķēšanu dīkstāvē, `Super + Ctrl + I` — vai `omarchy toggle idle` — ieslēdz palikšanu nomodā, un joslā parādās kafijas krūzes indikators. Tas ir tas, ko nospiest pirms garas prezentācijas vai būvējuma, ko vēlaties vērot. Nospiediet to vēlreiz, lai atgrieztos pie normālā režīma. `omarchy toggle idle status` izdrukā pašreizējo stāvokli kā JSON, ja jums tas vajadzīgs no skripta.

Šeit runa ir par bloķēšanu un ekrānsaudzētāju, nevis par barošanu. Apturēšanai un hibernācijai ir sava iestatīšana sadaļā [sistēmas miegs](36-system-sleep.md).

### Ekrānsaudzētājs

Omarchy ekrānsaudzētājs ir ASCII māksla, kas darbojas ar nejaušiem teksta efektiem, viens eksemplārs katram monitoram. Jebkurš taustiņš vai peles kustība no tā iziet.

Varat to palaist pēc pieprasījuma no _Sistēma > Ekrānsaudzētājs_ (`Super + Esc`), kas to piespiedu kārtā parāda pat tad, ja esat izslēdzis dīkstāves ekrānsaudzētāju. Pēc noklusējuma tam nav piesaistīts neviens karstais taustiņš.

`omarchy toggle screensaver` ir tas, kas izslēdz dīkstāves ekrānsaudzētāju, ja vēlaties pāriet tieši no darba uz bloķētu stāvokli. Jebkurš taustiņš, klikšķis, ritināšana vai peles kustība to aizver.

Logo, ko tas zīmē, varat mainīt sadaļā _Izskats > Zīmols > Ekrānsaudzētājs_. Augšupielādējiet png vai svg, un Omarchy to pārvērš ASCII formātā. Skatiet [zīmolu](41-branding.md).

### Bloķēšanas ekrāns

`Super + Ctrl + L` bloķē datoru. Tas palaiž bloķēšanas ekrānu no Omarchy čaulas, aptumšo displeju, atiestata tastatūras izkārtojumu uz pirmo, lai jūs nerakstītu paroli nepareizā alfabētā, un — ja jums tas darbojas — pa ceļam uz āru bloķē 1Password.

Bloķēšanas ekrāns pieņem paroli, un tas pieņems arī pirksta nospiedumu, kad būsiet tādu iestatījis. Tas un citi autentifikācijas veidi ir aprakstīti sadaļā [aparatūras autentifikācija](37-hardware-authentication.md).
