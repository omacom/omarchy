# Pārslēgi, dīkstāve un ekrānsaudzētājs

Liela daļa no tā, ko maināt ikdienā, īsti nav iestatījums. Tas ir režīms, ko ieslēdzat uz stundu un pēc tam atkal izslēdzat: nakts apgaismojums, kamēr strādājat vēlu, netraucēt, kamēr prezentējat, palikt nomodā, kamēr kaut ko skatāties. Omarchy tos sauc par pārslēgiem, un tie visi darbojas vienādi — karstais taustiņš, izvēlnes ieraksts un komanda, kas visi trāpa vienam un tam pašam slēdzim.

### Pārslēgu izvēlne

`Super + Ctrl + O` atver _Trigger > Toggle_ tieši, vai arī varat tur nokļūt no Omarchy izvēlnes (`Super + Space`). Viss šajā sarakstā ir slēdzis, ko varat pārslēgt, nedomājot par to, kur atrodas stāvoklis. Slēdži tam, kā izskatās darbvirsma, atrodas tai blakus, sadaļā _Appearance_.

No termināļa tie paši slēdži ir `omarchy toggle <thing>`. Palaidiet `omarchy toggle` pašu par sevi, lai redzētu visu grupu.

| Pārslēgs | Karstais taustiņš | Komanda |
| ------ | ------ | ------- |
| Nakts apgaismojums | — | `omarchy toggle nightlight` |
| Klusināt paziņojumus | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Palikt nomodā (bez dīkstāves bloķēšanas) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Avārijas datu uztveršana | — | `omarchy toggle crash-capture` |
| Ekrānsaudzētājs | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) motīva sinhronizācija | — | `omarchy toggle theme sync` |
| Izvēlnes josla | `Super + Shift + Space` | `omarchy toggle bar` |
| Skārienpaliktnis | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Skārienekrāns | — | `omarchy toggle touchscreen` |
| Apturēt | — | `omarchy toggle suspend` |
| Hibrīdais GPU | — | `omarchy toggle hybrid gpu` |

Skārienpaliktņa, skārienekrāna un hibrīdā GPU slēdži atrodas sadaļā _Trigger > Hardware_ (`Super + Ctrl + H`), nevis sadaļā Toggle, jo tie parādās tikai tad, kad jums faktiski ir šāda aparatūra. Skārienpaliktņa un skārienekrāna slēdži saglabājas pēc Hyprland pārlādēšanas — atspējotās ierīces nosaukums tiek saglabāts nelielā stāvokļa failā, ko Hyprland nolasa startēšanas laikā, lai to atkal atspējotu.

_Appearance_ satur izvēlnes joslu un animācijas, kā arī dažas lietas, kas nav `omarchy toggle` komandas, bet darbojas tāpat: akumulatora procentuālo daudzumu joslā, noklusējuma darbvietas izkārtojumu un sadaļā _Windows_ — logu atstarpes (`Super + Shift + Backspace`) un 1 loga kvadrātisko malu attiecību (`Super + Ctrl + Backspace`).

Lielākā daļa no tiem ir vienkārši karoga fails mapē `~/.local/state/omarchy/toggles/`. Ja vēlaties skriptā zaroties atkarībā no kāda no tiem, `omarchy-toggle-enabled` sniedz jums izejas kodu, nevis liek jums to meklēt pašam:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Karogi ir nosaukti izslēgtajam stāvoklim — `screensaver-off`, `suspend-off`, `bar-off` — tāpēc to klātbūtne nozīmē, ka funkcija ir atspējota.

### Indikatori joslā

Kad režīms ir ieslēgts, augšējās joslas vidū blakus pulkstenim redzēsit nelielu glifu. Tas ir indikatoru logrīks, un tajā ir diktēšana, ekrāna ierakstīšana, gaidošie atgādinājumi, nakts apgaismojums, netraucēt un palikt nomodā.

Neaktīvie indikatori ir paslēpti. Novietojiet kursoru jebkur uz joslas, un tie izbalējot parādīsies aptumšoti, lai jūs varētu noklikšķināt uz kāda, lai to ieslēgtu, nezinot tā karsto taustiņu. Noklikšķinot uz aktīva indikatora, tas atkal izslēdzas. Ja vēlaties tos visus redzēt visu laiku, iestatiet `alwaysShow` uz `true` ierakstam `omarchy.indicators` failā `~/.config/omarchy/shell.json` — skatiet [augšējo joslu](05-the-top-bar.md), lai uzzinātu, kā tiek konfigurēti joslas logrīki.

### Nakts apgaismojums

Nakts apgaismojums sasilda ekrānu līdz 4000K, un, pārslēdzot to vēlreiz, tas atgriežas pie 6500K. Pārslēdziet to no pārslēgu izvēlnes (`Super + Ctrl + O`) vai ar `omarchy toggle nightlight`. To darbina hyprsunset, ko pārslēgs startē jūsu vietā, ja tas jau nedarbojas.

Pēc noklusējuma hyprsunset jūsu ekrānam nedara vispār neko. `~/.config/hypr/hyprsunset.conf` tiek piegādāts ar identitātes profilu tieši tāpēc, lai displejs paliktu neskarts, līdz jūs palūdzat siltumu. Ja vēlaties, lai tas pārslēgtos pēc pulksteņa, aizstājiet to ar laika profilu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pēc tam startējiet hyprsunset pieslēgšanās laikā, pievienojot `o.launch_on_start("hyprsunset")` failam `~/.config/hypr/autostart.lua`. Pārslēga izmantotais 4000K/6500K pāris ir fiksēts, tāpēc konfigurācijas fails ir vieta, kur doties, ja vēlaties citu temperatūru.

### Netraucēt

`Super + Ctrl + Alt + ,` apklusina paziņojumus. Kamēr tas ir ieslēgts, neparādās nekādi uznirstošie paziņojumi, un joslā atrodas pārsvītrota zvana indikators, lai atgādinātu jums, kāpēc darbvirsma ir palikusi klusa.

Tomēr nekas netiek zaudēts. Apklusinātie paziņojumi tiek aizturēti: atgrieziet pēdējos dažus atpakaļ uz ekrāna ar `Super + Shift + Alt + ,`. Pārējo skatiet sadaļā [paziņojumi](10-notices.md).

Divu veidu ziņojumi joprojām tiek cauri: Omarchy paša apstiprinājuma uznirstošie paziņojumi par kaut ko, ko tikko izdarījāt ("Motīvs mainīts", "Ekrānuzņēmums saglabāts"), un kritiski brīdinājumi, kas nosūtīti no komandrindas. Tērzēšanas lietotnes, kas visu atzīmē kā kritisku, lai piespiestu sevi jums priekšā, nekvalificējas.

### Dīkstāve

Omarchy čaula pārvalda dīkstāves uzvedību, un laiki ir augstākā līmeņa `idle` bloks failā `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Abi skaitļi ir sekundes, kas skaitītas no brīža, kad pārgājāt dīkstāvē — nevis viens no otra. Tātad ar noklusējuma vērtībām ekrānsaudzētājs parādās pēc divarpus minūtēm un bloķēšanas ekrāns pārņem pēc piecām minūtēm, neatkarīgi no tā, vai ekrānsaudzētājs darbojās vai ne. Saglabājiet failu, un čaula jaunos laikus uztver uzreiz.

Ja noraidāt ekrānsaudzētāju pirms bloķēšanas termiņa, tas tiek uzskatīts par aktivitāti un gaidošā bloķēšana tiek atcelta. Jūs netiekat bloķēts tikai tāpēc, ka uzmetāt aci savam datoram.

Lai pilnībā pārtrauktu bloķēšanu dīkstāvē, `Super + Ctrl + I` — vai `omarchy toggle idle` — ieslēdz palikšanu nomodā, un joslā parādās kafijas tases indikators. Tas ir jāieslēdz pirms garas prezentācijas vai būvējuma, ko vēlaties vērot. Ieslēdziet to vēlreiz, lai atgrieztos pie normālā režīma. `omarchy toggle idle status` izdrukā pašreizējo stāvokli kā JSON, ja jums tas nepieciešams no skripta.

Šis ir par bloķēšanu un ekrānsaudzētāju, nevis par barošanu. Apturēšanai un hibernācijai ir sava iestatīšana sadaļā [sistēmas miegs](36-system-sleep.md).

### Ekrānsaudzētājs

Omarchy ekrānsaudzētājs ir ASCII māksla, kas darbojas caur nejaušiem teksta efektiem, viens eksemplārs katram monitoram. Jebkurš taustiņš vai peles kustība to izbeidz.

Varat to palaist pēc pieprasījuma no _System > Screensaver_ (`Super + Esc`), kas to piespiež parādīties pat tad, ja esat izslēdzis dīkstāves ekrānsaudzētāju. Pēc noklusējuma tam nav piesaistīts neviens karstais taustiņš.

`omarchy toggle screensaver` ir tas, kas izslēdz dīkstāves ekrānsaudzētāju, ja vēlaties doties tieši no darba pie bloķēta ekrāna. Tam nepieciešams terminālis, ko tas zina, kā konfigurēt — Alacritty, Foot, Ghostty, vai Kitty — un tas jums tā pateiks, ja jūsu noklusējuma terminālis ir kaut kas cits.

Logotips, ko tas zīmē, ir jūsu maināmais, sadaļā _Appearance > Branding > Screensaver_. Augšupielādējiet png vai svg, un Omarchy to pārveidos par ASCII. Skatiet [zīmolvedību](41-branding.md).

### Bloķēšanas ekrāns

`Super + Ctrl + L` bloķē datoru. Tas palaiž bloķēšanas ekrānu no Omarchy čaulas, aptumšo displeju, atiestata tastatūras izkārtojumu uz pirmo, lai jūs nerakstītu paroli nepareizā alfabētā, un — ja jums tas darbojas — pa ceļam uz āru bloķē 1Password.

Bloķēšanas ekrāns pieņem paroli, un tas pieņems arī pirksta nospiedumu, kad būsit tādu iestatījis. Tas un pārējie autentifikācijas veidi ir aprakstīti sadaļā [aparatūras autentifikācija](37-hardware-authentication.md).
