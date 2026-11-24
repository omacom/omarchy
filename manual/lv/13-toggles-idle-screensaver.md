# Pārslēgi, dīkstāve un ekrānsaudzētājs

Daudz kas no tā, ko maināt ikdienā, īsti nav iestatījums. Tas ir režīms, ko ieslēdzat uz stundu un pēc tam atkal izslēdzat: nakts gaisma, kad strādājat vēlu, netraucēt, kad prezentējat, palikt nomodā, kad kaut ko skatāties. Omarchy tos sauc par pārslēgiem, un tie visi darbojas vienādi — karstais taustiņš, izvēlnes ieraksts un komanda, visi trāpa vienam un tam pašam slēdzim.

### Pārslēgu izvēlne

`Super + Ctrl + O` atver _Trigger > Toggle_ tieši, vai arī varat tur nonākt no Omarchy izvēlnes (`Super + Space`). Viss šajā sarakstā ir slēdzis, ko varat pārslēgt, nedomājot par to, kur glabājas stāvoklis. Slēdži tam, kā darbvirsma izskatās, atrodas tam blakus, zem _Appearance_.

No termināļa tie paši slēdži ir `omarchy toggle <thing>`. Palaidiet `omarchy toggle` vienu pašu, lai redzētu visu grupu.

| Pārslēgs | Karstais taustiņš | Komanda |
| ------ | ------ | ------- |
| Nakts gaisma | — | `omarchy toggle nightlight` |
| Klusināt paziņojumus | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Palikt nomodā (bez dīkstāves bloķēšanas) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Avāriju uztveršana | — | `omarchy toggle crash-capture` |
| Ekrānsaudzētājs | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) motīva sinhronizācija | — | `omarchy toggle theme sync` |
| Izvēļņu josla | `Super + Shift + Space` | `omarchy toggle bar` |
| Pilnekrāna darbvirsma (bez joslas, bez atstarpēm) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animācijas, izplūdums un ēnas | — | `omarchy toggle animations` |
| Skārienpaliktnis | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Skārienekrāns | — | `omarchy device touchscreen` |
| Apturēšana | — | `omarchy toggle suspend` |
| Hibrīdais GPU | — | `omarchy device gpu hybrid` |

Skārienpaliktņa, skārienekrāna un hibrīdā GPU slēdži atrodas zem _Trigger > Hardware_ (`Super + Ctrl + H`), nevis zem Toggle, jo tie parādās tikai tad, kad jums faktiski ir šāda aparatūra. Skārienpaliktņa un skārienekrāna slēdži saglabājas pēc Hyprland pārlādēšanas — atspējotās ierīces nosaukums tiek saglabāts mazā stāvokļa failā, ko Hyprland nolasa startējot, lai to atkal atspējotu.

_Appearance_ glabā izvēļņu joslu un animācijas, kā arī dažas lietas, kas nav `omarchy toggle` komandas, bet darbojas tāpat: akumulatora procentus joslā, noklusējuma darbvietas izkārtojumu un zem _Windows_ — logu atstarpes (`Super + Shift + Backspace`) un 1 loga kvadrātveida malu attiecību (`Super + Ctrl + Backspace`).

Kad Hyprland nav GPU, ar ko zīmēt, un tas tā vietā renderē ar CPU (llvmpipe), piemēram, Mac datoros, kuru GPU vēl netiek atbalstīts, lielākajā daļā virtuālo mašīnu vai kad grafikas draiveris neielādējas, Omarchy šai sesijai izslēdz animācijas, izplūdumu un ēnas un reizi par to paziņo ar paziņojumu. _Appearance > Animations On_ tos ieslēdz atpakaļ, un Omarchy to atceras arī vēlākām sesijām.

Lielākā daļa no tiem ir tikai karodziņa fails zem `~/.local/state/omarchy/toggles/`. Ja vēlaties skriptā zaroties atkarībā no kāda no tiem, `omarchy-toggle-enabled` jums iedod izejas kodu, nevis liek jums to meklēt:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Karodziņi ir nosaukti izslēgtā stāvokļa vārdā — `screensaver-off`, `suspend-off`, `bar-off` — tāpēc to klātbūtne nozīmē, ka funkcija ir atspējota.

### Indikatori joslā

Kad režīms ir ieslēgts, augšējās joslas vidū blakus pulkstenim parādās maza zīme. Tas ir indikatoru logrīks, un tajā ir ekrāna ierakstīšana, gaidāmie atgādinājumi, nakts gaisma, netraucēt un palikt nomodā, kā arī brīdinājumi, kamēr ir ieslēgts sudo bez paroles vai kāds ir pieslēdzies attālai sesijai.

Neaktīvi indikatori ir paslēpti. Novietojiet kursoru jebkur uz joslas, un tie parādīsies blāvi, lai varētu noklikšķināt uz kāda, to ieslēdzot, nezinot tā karsto taustiņu. Noklikšķinot uz aktīva, tas izslēdzas atpakaļ. Ja vēlaties tos visus redzēt visu laiku, iestatiet `alwaysShow` uz `true` ierakstā `omarchy.indicators` failā `~/.config/omarchy/shell.json` — skatiet [augšējo joslu](05-the-top-bar.md), lai uzzinātu, kā tiek konfigurēti joslas logrīki.

### Nakts gaisma

Nakts gaisma sasilda ekrānu līdz 4000K, un, to pārslēdzot vēlreiz, tas atgriežas pie 6500K. Pārslēdziet to no pārslēgu izvēlnes (`Super + Ctrl + O`) vai ar `omarchy toggle nightlight`. To darbina hyprsunset, ko pārslēgs jums palaiž, ja tas vēl nedarbojas.

Pēc noklusējuma hyprsunset ar jūsu ekrānu nedara neko. `~/.config/hypr/hyprsunset.conf` tiek piegādāts ar identitātes profilu tieši tāpēc, lai displejs paliktu neskarts, līdz jūs prasāt siltumu. Ja vēlaties, lai tas pārslēdzas pēc pulksteņa, aizstājiet to ar laika profilu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pēc tam palaidiet hyprsunset pieslēgšanās brīdī, pievienojot `o.launch_on_start("hyprsunset")` failam `~/.config/hypr/autostart.lua`. Pārslēga izmantotais 4000K/6500K pāris ir fiksēts, tāpēc konfigurācijas fails ir vieta, kurp doties, ja vēlaties citu temperatūru.

### Netraucēt

`Super + Ctrl + Alt + ,` apklusina paziņojumus. Kamēr tas ir ieslēgts, neparādās nekādi uznirstošie paziņojumi, un pārsvītrota zvana indikators atrodas joslā, lai atgādinātu, kāpēc darbvirsma ir kļuvusi klusa.

Nekas netiek zaudēts. Apklusinātie paziņojumi tiek aizturēti: izlieciet pēdējos dažus atpakaļ ekrānā ar `Super + Shift + Alt + ,`. Pārējo skatiet [paziņojumos](10-notices.md).

Trīs veidu ziņojumi joprojām tiek cauri: Omarchy paša apstiprinājuma uznirstošie paziņojumi par kaut ko, ko tikko izdarījāt ("Theme changed", "Screenshot saved"), kritiski brīdinājumi, kas nosūtīti no komandrindas, un verifikācijas kodi. Tērzēšanas lietotnes, kas visu atzīmē kā kritisku, lai piespiestu sevi jums priekšā, nekvalificējas.

### Dīkstāve

Omarchy apvalks pārvalda dīkstāves uzvedību, un laiki ir augstākā līmeņa `idle` bloks failā `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Abi skaitļi ir sekundes, kas skaitītas no brīža, kad iestājās dīkstāve, — nevis viens no otra. Tātad ar noklusējumiem ekrānsaudzētājs parādās pēc divarpus minūtēm un bloķēšanas ekrāns pārņem pēc piecām minūtēm neatkarīgi no tā, vai ekrānsaudzētājs darbojās. Saglabājiet failu, un apvalks uzreiz pārņem jaunos laikus.

Ja noraidāt ekrānsaudzētāju pirms bloķēšanas termiņa, tas tiek uzskatīts par aktivitāti un gaidāmā bloķēšana tiek atcelta. Jūs netiekat bloķēts tikai tāpēc, ka uzmetāt skatienu savam datoram.

Lai pilnībā pārtrauktu bloķēšanu dīkstāvē, `Super + Ctrl + I` — vai `omarchy toggle idle` — ieslēdz palikšanu nomodā, un joslā parādās kafijas tasītes indikators. Tas ir tas, ko nospiest pirms garas prezentācijas vai būvējuma, ko vēlaties vērot. Nospiediet to vēlreiz, lai atgrieztos pie normālā režīma. `omarchy toggle idle status` izdrukā pašreizējo stāvokli kā JSON, ja jums tas vajadzīgs no skripta.

Šeit ir runa par bloķēšanu un ekrānsaudzētāju, nevis par barošanu. Apturēšanai un hibernācijai ir sava iestatīšana [sistēmas miegā](36-system-sleep.md).

### Ekrānsaudzētājs

Omarchy ekrānsaudzētājs ir ASCII māksla, kas iet caur nejaušiem teksta efektiem, viens eksemplārs katram monitoram. Jebkurš taustiņš vai peles kustība to izslēdz.

Varat to palaist pēc pieprasījuma no _System > Screensaver_ (`Super + Esc`), kas to piespiedu kārtā parāda pat tad, ja esat izslēdzis dīkstāves ekrānsaudzētāju. Pēc noklusējuma tam nav piesaistīts neviens karstais taustiņš.

`omarchy toggle screensaver` ir tas, kas izslēdz dīkstāves ekrānsaudzētāju, ja vēlaties doties tieši no darba uz bloķētu stāvokli. Jebkurš taustiņš, klikšķis, ritināšana vai peles kustība to aizver.

Logotips, ko tas zīmē, ir jūsu maināmais, zem _Appearance > Branding > Screensaver_. Augšupielādējiet png vai svg, un Omarchy to pārvērš ASCII. Skatiet [zīmola veidošanu](41-branding.md).

### Bloķēšanas ekrāns

`Super + Ctrl + L` bloķē datoru. Tas palaiž bloķēšanas ekrānu no Omarchy apvalka, aptumšo displeju, atiestata tastatūras izkārtojumu uz pirmo, lai jūs nerakstītu paroli nepareizā alfabētā, un — ja tas darbojas — izejot bloķē 1Password.

Bloķēšanas ekrāns pieņem paroli, un tas pieņems arī pirksta nospiedumu, kad būsiet tādu iestatījis. Tas un citi autentifikācijas veidi ir aprakstīti [aparatūras autentifikācijā](37-hardware-authentication.md).
