# Slēdži, dīkstāve un ekrānsaudzētājs

Liela daļa no tā, ko ikdienā maini, patiesībā nav nekāds iestatījums. Tas ir režīms, ko ieslēdz uz stundu un pēc tam atkal izslēdz: nakts gaisma, kamēr vakarā strādā, netraucēt, kamēr prezentē, palikt nomodā, kamēr kaut ko skaties. Omarchy tos sauc par slēdžiem, un tie visi darbojas vienādi — karstais taustiņš, izvēlnes ieraksts un komanda, visi trāpa vienam un tam pašam slēdzim.

### Slēdžu izvēlne

`Super + Ctrl + O` atver _Trigger > Toggle_ tieši, vai arī vari tur nonākt no Omarchy izvēlnes (`Super + Space`). Viss šajā sarakstā ir slēdzis, ko vari pārslēgt, nedomājot par to, kur glabājas stāvoklis. Slēdži tam, kā izskatās darbvirsma, atrodas tai blakus, zem _Appearance_.

No termināļa tie paši slēdži ir `omarchy toggle <thing>`. Palaid `omarchy toggle` vienu pašu, lai redzētu visu grupu.

| Slēdzis | Karstais taustiņš | Komanda |
| ------ | ------ | ------- |
| Nakts gaisma | — | `omarchy toggle nightlight` |
| Klusināt paziņojumus | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Palikt nomodā (bez dīkstāves bloķēšanas) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Avāriju fiksēšana | — | `omarchy toggle crash-capture` |
| Ekrānsaudzētājs | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) motīva sinhronizācija | — | `omarchy toggle theme sync` |
| Izvēlnes josla | `Super + Shift + Space` | `omarchy toggle bar` |
| Skārienpaliktnis | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Skārienekrāns | — | `omarchy toggle touchscreen` |
| Apturēšana | — | `omarchy toggle suspend` |
| Hibrīdais GPU | — | `omarchy toggle hybrid gpu` |

Skārienpaliktņa, skārienekrāna un hibrīdā GPU slēdži atrodas zem _Trigger > Hardware_ (`Super + Ctrl + H`), nevis zem Toggle, jo tie parādās tikai tad, kad tev tiešām ir tāda aparatūra. Skārienpaliktņa un skārienekrāna slēdži pārdzīvo Hyprland pārlādi — atspējotās ierīces nosaukums tiek saglabāts mazā stāvokļa failā, ko Hyprland startējot nolasa, lai to atspējotu atkal.

_Appearance_ satur izvēlnes joslu un animācijas, kā arī dažas lietas, kas nav `omarchy toggle` komandas, bet uzvedas tāpat: akumulatora procentus joslā, noklusējuma darbvietas izkārtojumu un zem _Windows_ — logu atstarpes (`Super + Shift + Backspace`) un 1 loga kvadrātisko malu attiecību (`Super + Ctrl + Backspace`).

Kad Hyprland nav GPU, ar ko zīmēt, un tā vietā tas renderē ar CPU (llvmpipe), kā tas ir Mac datoros, kuru GPU vēl netiek atbalstīts, lielākajā daļā virtuālo mašīnu vai kad grafikas draiveris neielādējas, Omarchy šai sesijai izslēdz animācijas, izpludināšanu un ēnas un vienreiz par to paziņo ar paziņojumu. _Appearance > Animations On_ tās atgriež atpakaļ, un Omarchy to atceras arī vēlākām sesijām.

Lielākā daļa no tiem ir vienkārši karoga fails zem `~/.local/state/omarchy/toggles/`. Ja skriptā gribi no kāda zaroties, `omarchy-toggle-enabled` tev iedod izejas kodu, nevis liek pašam meklēt:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Karogi ir nosaukti izslēgtajam stāvoklim — `screensaver-off`, `suspend-off`, `bar-off` —, tāpēc to klātbūtne nozīmē, ka funkcija ir atspējota.

### Indikatori joslā

Kad režīms ir ieslēgts, augšējās joslas vidū blakus pulkstenim parādās maza zīme. Tas ir indikatoru logrīks, un tajā ir diktēšana, ekrāna ierakstīšana, gaidošie atgādinājumi, nakts gaisma, netraucēt un palikt nomodā.

Neaktīvie indikatori ir paslēpti. Novieto kursoru jebkur uz joslas, un tie izbalējuši parādās, lai varētu uzklikšķināt kādam un to ieslēgt, nezinot tā karsto taustiņu. Noklikšķinot uz aktīva, tas izslēdzas atpakaļ. Ja gribi tos visus redzēt visu laiku, iestati `alwaysShow` uz `true` ierakstā `omarchy.indicators` failā `~/.config/omarchy/shell.json` — skati [augšējo joslu](05-the-top-bar.md), lai uzzinātu, kā tiek konfigurēti joslas logrīki.

### Nakts gaisma

Nakts gaisma sasilda ekrānu līdz 4000K, un, pārslēdzot to atkal, atgriež atpakaļ uz 6500K. Pārslēdz to no slēdžu izvēlnes (`Super + Ctrl + O`) vai ar `omarchy toggle nightlight`. To darbina hyprsunset, ko slēdzis tev startē, ja tas vēl nedarbojas.

Pēc noklusējuma hyprsunset ar tavu ekrānu nedara pilnīgi neko. `~/.config/hypr/hyprsunset.conf` tiek piegādāts ar identitātes profilu tieši tāpēc, lai displejs paliktu neskarts, līdz palūdz siltumu. Ja labāk gribi, lai tas pārslēdzas pēc pulksteņa, aizstāj to ar laika profilu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pēc tam startē hyprsunset pie pieteikšanās, pievienojot `o.launch_on_start("hyprsunset")` failam `~/.config/hypr/autostart.lua`. Slēdža izmantotais 4000K/6500K pāris ir fiksēts, tāpēc konfigurācijas fails ir vieta, kurp doties, ja gribi citu temperatūru.

### Netraucēt

`Super + Ctrl + Alt + ,` klusina paziņojumus. Kamēr tas ir ieslēgts, neviens uznirstošais paziņojums neparādās, un pārsvītrota zvana indikators sēž joslā, lai atgādinātu, kāpēc darbvirsma ir kļuvusi tik klusa.

Tomēr nekas nepazūd. Apklusinātie paziņojumi tiek aizturēti: pēdējos dažus atgriez ekrānā ar `Super + Shift + Alt + ,`. Pārējo skati sadaļā [paziņojumi](10-notices.md).

Divu veidu ziņojumi joprojām tiek cauri: paša Omarchy apstiprinājuma uznirstošie paziņojumi par kaut ko, ko tikko izdarīji ("Motīvs nomainīts", "Ekrānuzņēmums saglabāts"), un kritiskie brīdinājumi, kas nosūtīti no komandrindas. Tērzēšanas lietotnes, kas visu atzīmē kā kritisku, lai ar varu izlauztos tev priekšā, tam nekvalificējas.

### Dīkstāve

Dīkstāves uzvedība pieder Omarchy čaulai, un laiki ir augšējā līmeņa `idle` bloks failā `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Abi skaitļi ir sekundes, kas skaitītas no brīža, kad pārgāji dīkstāvē, — nevis viens no otra. Tātad ar noklusējumiem ekrānsaudzētājs parādās pēc divarpus minūtēm un bloķēšanas ekrāns pārņem piecu minūšu laikā, neatkarīgi no tā, vai ekrānsaudzētājs darbojās. Saglabā failu, un čaula jaunos laikus paņem uzreiz.

Ja noraidi ekrānsaudzētāju pirms bloķēšanas termiņa, tas skaitās kā aktivitāte un gaidošā bloķēšana tiek atcelta. Tevi neizbloķē ārā par to, ka uzmeti aci savai mašīnai.

Lai pavisam pārtrauktu bloķēšanu dīkstāvē, `Super + Ctrl + I` — vai `omarchy toggle idle` — ieslēdz palikšanu nomodā, un joslā parādās kafijas krūzes indikators. Tieši to vajag nospiest pirms garas prezentācijas vai būvējuma, kam gribi sekot līdzi. Nospied to vēlreiz, lai atgrieztos pie normālā režīma. `omarchy toggle idle status` izdrukā pašreizējo stāvokli kā JSON, ja tev tas vajadzīgs no skripta.

Šis ir par bloķēšanu un ekrānsaudzētāju, nevis par barošanu. Apturēšanai un hibernācijai ir sava iestatīšana sadaļā [sistēmas miega režīms](36-system-sleep.md).

### Ekrānsaudzētājs

Omarchy ekrānsaudzētājs ir ASCII māksla, kas skrien cauri nejaušiem teksta efektiem, pa vienam eksemplāram uz katru monitoru. Jebkurš taustiņš vai peles kustība no tā iziet.

Vari to startēt pēc pieprasījuma no _System > Screensaver_ (`Super + Esc`), kas to uzspiež pat tad, ja dīkstāves ekrānsaudzētāju esi izslēdzis. Pēc noklusējuma tam nav piesaistīts neviens karstais taustiņš.

`omarchy toggle screensaver` ir tas, kas izslēdz dīkstāves ekrānsaudzētāju, ja labāk gribi iet tieši no darba uz bloķētu stāvokli. Jebkurš taustiņš, klikšķis, ritināšana vai peles kustība to aizver.

Logo, ko tas zīmē, vari mainīt pats, zem _Appearance > Branding > Screensaver_. Augšupielādē png vai svg, un Omarchy to pārveidos par ASCII. Skati [zīmola noformējumu](41-branding.md).

### Bloķēšanas ekrāns

`Super + Ctrl + L` bloķē mašīnu. Tas palaiž bloķēšanas ekrānu no Omarchy čaulas, aptumšo displeju, atiestata tastatūras izkārtojumu uz pirmo, lai nerakstītu paroli nepareizā alfabētā, un — ja tev tas darbojas — izejot bloķē 1Password.

Bloķēšanas ekrāns pieņem paroli, un tas pieņems arī pirksta nospiedumu, kad būsi tādu iestatījis. Tas un pārējie autentificēšanās veidi ir aprakstīti sadaļā [aparatūras autentifikācija](37-hardware-authentication.md).
