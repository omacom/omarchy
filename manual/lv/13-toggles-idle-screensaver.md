# Pārslēgi, dīkstāve un ekrānsaudzētājs

Daudz kas no tā, ko tu maini ikdienā, patiesībā nav iestatījums. Tas ir režīms, ko tu ieslēdz uz stundu un atkal izslēdz: nakts apgaismojums, kamēr tu strādā vēlu, netraucēt, kamēr tu prezentē, palikt nomodā, kamēr tu kaut ko skaties. Omarchy tos sauc par pārslēgiem, un tie visi darbojas vienādi — karstā taustiņa kombinācija, izvēlnes ieraksts un komanda, kas visi trāpa vienam un tam pašam slēdzim.

### Pārslēgu izvēlne

`Super + Ctrl + O` atver _Palaist > Pārslēgt_ tieši vai tu vari turp aiziet no Omarchy izvēlnes (`Super + Space`). Viss šajā sarakstā ir slēdzis, ko tu vari pārslēgt, nedomājot par to, kur dzīvo stāvoklis. Slēdži tam, kā darbvirsma izskatās, sēž tai blakus zem _Palaist > Izskats_.

No termināla tie paši slēdži ir `omarchy toggle <thing>`. Palaid `omarchy toggle` atsevišķi, lai redzētu visu grupu.

| Pārslēgs | Karstā taustiņa kombinācija | Komanda |
| ------ | ------ | ------- |
| Nakts apgaismojums | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Klusināt paziņojumus | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Palikt nomodā (bez dīkstāves bloķēšanas) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Avāriju fiksēšana | — | `omarchy toggle crash-capture` |
| Ekrānsaudzētājs | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) tēmu sinhronizācija | — | `omarchy toggle theme sync` |
| Izvēlņu josla | `Super + Shift + Space` | `omarchy toggle bar` |
| Skārienpaliktnis | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Skārienekrāns | — | `omarchy toggle touchscreen` |
| Iemidzināt | — | `omarchy toggle suspend` |
| Hibrīdais GPU | — | `omarchy toggle hybrid gpu` |

Skārienpaliktņa, skārienekrāna un hibrīdā GPU slēdži dzīvo zem _Palaist > Aparatūra_ (`Super + Ctrl + H`), nevis zem Pārslēgt, jo tie parādās tikai tad, kad tev patiešām ir tā aparatūra. Skārienpaliktņa un skārienekrāna slēdži pārdzīvo Hyprland pārlādēšanu — atspējotās ierīces nosaukums tiek saglabāts mazā stāvokļa failā, ko Hyprland lasa startēšanas laikā, lai to atkal atspējotu.

_Palaist > Izskats_ satur izvēlņu joslu un animācijas, kā arī dažas lietas, kas nav `omarchy toggle` komandas, bet uzvedas vienādi: baterijas procenti joslā, noklusējuma darbvietas izkārtojums, logu atstarpes (`Super + Shift + Backspace`) un 1 loga kvadrāta attiecība (`Super + Ctrl + Backspace`).

Lielākā daļa no tiem ir tikai karoga fails zem `~/.local/state/omarchy/toggles/`. Ja tu vēlies sazaroties uz viena skriptā, `omarchy-toggle-enabled` dod tev izejas kodu, nevis liek tev iet meklēt:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Karogi ir nosaukti izslēgtam stāvoklim — `screensaver-off`, `suspend-off`, `bar-off` —, tāpēc to klātbūtne nozīmē, ka funkcija ir atspējota.

### Rādītāji joslā

Kad režīms ir ieslēgts, tu iegūsti mazu zīmi augšējās joslas vidū blakus pulkstenim. Tas ir rādītāju logrīks, un tas satur diktēšanu, ekrāna ierakstīšanu, gaidošos atgādinājumus, nakts apgaismojumu, netraucēt un palikt nomodā.

Neaktīvie rādītāji ir paslēpti. Novieto kursoru apgabalā ap tiem, un tie izbalē blāvi, tāpēc tu vari noklikšķināt uz viena, lai to ieslēgtu, nezinot tā karsto taustiņa kombināciju. Noklikšķinot uz aktīva, tas tiek izslēgts. Ja tu labāk vēlētos tos visus redzēt vienmēr, iestati `alwaysShow` uz `true` ierakstā `omarchy.indicators` failā `~/.config/omarchy/shell.json` — skat. [augšējā josla](05-the-top-bar.md), kā joslas logrīki tiek konfigurēti.

### Nakts apgaismojums

`Super + Ctrl + N` sasilda ekrānu līdz 4000K, un, nospiežot to vēlreiz, tas tiek atjaunots uz 6500K. To darbina hyprsunset, ko pārslēgs tev startē, ja tas jau nedarbojas.

Pēc noklusējuma hyprsunset ar tavu ekrānu nedara neko. `~/.config/hypr/hyprsunset.conf` nāk ar identitātes profilu tieši tāpēc, lai displejs paliktu neskarts, līdz tu palūdz siltumu. Ja tu labāk vēlētos, lai tas pārslēdzas pēc pulksteņa, aizstāj to ar laika profilu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pēc tam startē hyprsunset pieteikšanās laikā, pievienojot `o.launch_on_start("hyprsunset")` failam `~/.config/hypr/autostart.lua`. 4000K/6500K pāris, ko izmanto pārslēgs, ir fiksēts, tāpēc konfigurācijas fails ir vieta, kur doties, ja vēlies citu temperatūru.

### Netraucēt

`Super + Ctrl + ,` klusina paziņojumus. Kamēr tas ir ieslēgts, neparādās nekādi paziņojumi, un pārsvītrota zvana rādītājs sēž joslā, lai atgādinātu tev, kāpēc darbvirsma ir kļuvusi klusa.

Tomēr nekas netiek pazaudēts. Klusināts paziņojums tiek ierakstīts tieši tavā paziņojumu vēsturē, kas ir tieši tas ieraksts, ko tu vēlies, kad atgriezies un brīnies, ko tu esi palaidis garām. Atver to ar `Super + Shift + Alt + ,`. Skat. [paziņojumi](10-notices.md) pārējam paziņojumu stāstam.

Divu veidu ziņojumi joprojām izlaužas cauri: paša Omarchy apstiprinājuma paziņojumi par kaut ko, ko tu tikko izdarīji ("Theme changed", "Screenshot saved"), un kritiski brīdinājumi, kas nosūtīti no komandrindas. Tērzēšanas lietotnes, kas visu atzīmē kā kritisku, lai piespiestu ceļu tavā priekšā, nekvalificējas.

### Dīkstāve

Omarchy čaulai pieder dīkstāves uzvedība, un laiki ir augstākā līmeņa `idle` bloks failā `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Abi skaitļi ir sekundes, ko skaita no brīža, kad tu kļuvi dīkstāvē — nevis viens no otra. Tāpēc ar noklusējumiem ekrānsaudzētājs parādās pēc divarpus minūtēm un bloķēšanas ekrāns pārņem pēc piecām minūtēm neatkarīgi no tā, vai ekrānsaudzētājs darbojās. Saglabā failu, un čaula uzreiz uztver jaunos laikus.

Ja tu aizvāc ekrānsaudzētāju pirms bloķēšanas termiņa, tas tiek uzskatīts par aktivitāti, un gaidošā bloķēšana tiek atcelta. Tevi nebloķē par to, ka uzmeti skatienu savai iekārtai.

Lai pilnībā pārtrauktu bloķēšanu dīkstāvē, `Super + Ctrl + I` — vai `omarchy toggle idle` — ieslēdz palikšanu nomodā, un kafijas krūzes rādītājs parādās joslā. Tas ir tas, ko nospiest pirms garas prezentācijas vai būvējuma, ko tu vēlies skatīties. Nospied to vēlreiz, lai atgrieztos normālā režīmā. `omarchy toggle idle status` izdrukā pašreizējo stāvokli kā JSON, ja tev tas vajadzīgs no skripta.

Tas attiecas uz bloķēšanu un ekrānsaudzētāju, nevis barošanu. Iemidzināšanai un ziemas miegam ir sava iestatīšana [sistēmas miegs](36-system-sleep.md).

### Ekrānsaudzētājs

Omarchy ekrānsaudzētājs ir ASCII māksla, kas darbojas ar nejaušiem teksta efektiem, viena instance katram monitoram. Jebkurš taustiņš vai peles kustība iziet no tā.

Tu vari to startēt pēc pieprasījuma no _Sistēma > Ekrānsaudzētājs_ (`Super + Esc`), kas to piespiež parādīties pat tad, ja esi izslēdzis dīkstāves ekrānsaudzētāju. Pēc noklusējuma tam nav piesaistīta karstā taustiņa kombinācija.

`omarchy toggle screensaver` izslēdz dīkstāves ekrānsaudzētāju, ja tu labāk dotos tieši no darba uz bloķētu. Tam ir nepieciešams terminālis, ko tas zina, kā konfigurēt — Alacritty, Foot, Ghostty vai Kitty —, un tas tev tā pateiks, ja tavs noklusējuma terminālis ir kaut kas cits.

Logo, ko tas zīmē, ir tavs, ko mainīt, zem _Stils > Ekrānsaudzētājs_. Augšupielādē png vai svg, un Omarchy to pārvērš ASCII. Skat. [zīmolvedība](41-branding.md).

### Bloķēšanas ekrāns

`Super + Ctrl + L` bloķē iekārtu. Tas palaiž bloķēšanas ekrānu no Omarchy čaulas, aptumšo displeju, atiestata tavu tastatūras izkārtojumu uz pirmo, lai tu nerakstītu paroli nepareizajā alfabētā, un — ja tev tas darbojas — izejot bloķē 1Password.

Bloķēšanas ekrāns pieņem paroli, un tas pieņems arī pirkstu nospiedumu, kad tu būsi vienu iestatījis. Tas un citi autentificēšanās veidi ir apskatīti [aparatūras autentifikācija](37-hardware-authentication.md).
