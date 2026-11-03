# Pārslēgi, dīkstāve un ekrānsaudzētājs

Liela daļa no tā, ko tu ikdienā maini, īstenībā nav iestatījums. Tas ir režīms, ko uz stundu ieslēdz un pēc tam atkal izslēdz: nakts gaisma, kamēr vēlu strādā, netraucēt režīms, kamēr prezentē, palikšana nomodā, kamēr kaut ko skaties. Omarchy tos sauc par pārslēgiem, un tie visi darbojas vienādi — karstais taustiņš, izvēlnes ieraksts un komanda, tie visi trāpa vienam un tam pašam slēdzim.

### Pārslēgu izvēlne

`Super + Ctrl + O` tieši atver _Aktivizētājs > Pārslēgs_, vai arī tu vari tur nokļūt no Omarchy izvēlnes (`Super + Space`). Viss šajā sarakstā ir slēdzis, ko vari pārslēgt, nedomājot par to, kur glabājas tā stāvoklis. Slēdži tam, kā izskatās darbvirsma, atrodas tam blakus, sadaļā _Izskats_.

No termināļa tie paši slēdži ir `omarchy toggle <thing>`. Palaid `omarchy toggle` pašu par sevi, lai redzētu visu grupu.

| Pārslēgs | Karstais taustiņš | Komanda |
| ------ | ------ | ------- |
| Nakts gaisma | — | `omarchy toggle nightlight` |
| Apklusināt paziņojumus | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Palikt nomodā (bez dīkstāves bloķēšanas) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Avāriju tveršana | — | `omarchy toggle crash-capture` |
| Ekrānsaudzētājs | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) motīva sinhronizācija | — | `omarchy toggle theme sync` |
| Izvēļņu josla | `Super + Shift + Space` | `omarchy toggle bar` |
| Skārienpaliktnis | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Skārienekrāns | — | `omarchy toggle touchscreen` |
| Iemidzināšana | — | `omarchy toggle suspend` |
| Hibrīdais GPU | — | `omarchy toggle hybrid gpu` |

Skārienpaliktņa, skārienekrāna un hibrīdā GPU slēdži atrodas sadaļā _Aktivizētājs > Aparatūra_ (`Super + Ctrl + H`), nevis sadaļā Pārslēgs, jo tie parādās tikai tad, kad tev tiešām ir šāda aparatūra. Skārienpaliktņa un skārienekrāna slēdži izdzīvo pēc Hyprland pārlādēšanas — atspējotās ierīces nosaukums tiek saglabāts mazā stāvokļa failā, ko Hyprland nolasa startēšanas laikā, lai to atkal atspējotu.

_Izskats_ satur izvēļņu joslu un animācijas, kā arī dažas lietas, kas nav `omarchy toggle` komandas, bet darbojas tāpat: akumulatora procentuālo daudzumu joslā, noklusējuma darbvietas izkārtojumu un sadaļā _Logi_ — logu atstarpes (`Super + Shift + Backspace`) un 1 loga kvadrātisko malu attiecību (`Super + Ctrl + Backspace`).

Lielākā daļa no tiem ir vienkārši karodziņa fails zem `~/.local/state/omarchy/toggles/`. Ja vēlies skriptā no kāda no tiem sazaroties, `omarchy-toggle-enabled` iedod tev izejas kodu, nevis liek tev to pašam meklēt:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Karodziņi ir nosaukti izslēgtā stāvokļa vārdā — `screensaver-off`, `suspend-off`, `bar-off` — tāpēc to klātbūtne nozīmē, ka funkcija ir atspējota.

### Indikatori joslā

Kad režīms ir ieslēgts, augšējās joslas vidū blakus pulkstenim tu saņem mazu zīmi. Tas ir indikatoru logrīks, un tajā ir diktēšana, ekrāna ierakstīšana, gaidošie atgādinājumi, nakts gaisma, netraucēt režīms un palikšana nomodā.

Neaktīvie indikatori ir paslēpti. Novieto kursoru jebkur uz joslas, un tie parādās aptumšoti, lai tu varētu noklikšķināt uz kāda un to ieslēgt, nezinot tā karsto taustiņu. Noklikšķinot uz aktīva indikatora, tas atkal izslēdzas. Ja labprātāk tos visus redzētu visu laiku, iestati `alwaysShow` uz `true` ierakstam `omarchy.indicators` failā `~/.config/omarchy/shell.json` — skati [augšējo joslu](05-the-top-bar.md), lai uzzinātu, kā tiek konfigurēti joslas logrīki.

### Nakts gaisma

Nakts gaisma sasilda ekrānu līdz 4000K, un atkārtota tās pārslēgšana atgriež to uz 6500K. Pārslēdz to no pārslēgu izvēlnes (`Super + Ctrl + O`) vai ar `omarchy toggle nightlight`. To darbina hyprsunset, ko pārslēgs tev startē, ja tas jau nedarbojas.

Pēc noklusējuma hyprsunset tavam ekrānam vispār neko nedara. `~/.config/hypr/hyprsunset.conf` tiek piegādāts ar identitātes profilu tieši tāpēc, lai displejs paliktu neskarts, līdz tu palūdz siltumu. Ja labprātāk to pārslēgtu pēc pulksteņa, aizstāj to ar laika profilu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Tad startē hyprsunset piesakoties, pievienojot `o.launch_on_start("hyprsunset")` failam `~/.config/hypr/autostart.lua`. Pārslēga izmantotais 4000K/6500K pāris ir fiksēts, tāpēc konfigurācijas fails ir vieta, kurp doties, ja vēlies citu temperatūru.

### Netraucēt

`Super + Ctrl + Alt + ,` apklusina paziņojumus. Kamēr tas ir ieslēgts, neparādās nekādi uznirstošie paziņojumi, un joslā atrodas pārsvītrota zvana indikators, lai atgādinātu tev, kāpēc darbvirsma ir kļuvusi tik klusa.

Tomēr nekas netiek zaudēts. Apklusinātie paziņojumi tiek aizturēti: pēdējos dažus atgriez ekrānā ar `Super + Shift + Alt + ,`. Skati [paziņojumus](10-notices.md), lai uzzinātu pārējo.

Divu veidu ziņojumi joprojām tiek cauri: paša Omarchy apstiprinājuma uznirstošie paziņojumi par kaut ko, ko tu tikko izdarīji ("Motīvs nomainīts", "Ekrānuzņēmums saglabāts"), un kritiski brīdinājumi, kas nosūtīti no komandrindas. Tērzēšanas lietotnes, kas visu atzīmē kā kritisku, lai piespiestu sev ceļu pie tevis, nekvalificējas.

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

Abi skaitļi ir sekundes, kas skaitītas no brīža, kad tu kļuvi neaktīvs — nevis viens no otra. Tāpēc ar noklusējumiem ekrānsaudzētājs parādās pēc divarpus minūtēm un bloķēšanas ekrāns pārņem pēc piecām minūtēm neatkarīgi no tā, vai ekrānsaudzētājs darbojās vai ne. Saglabā failu, un čaula jaunos laikus uztver uzreiz.

Ja tu atmet ekrānsaudzētāju pirms bloķēšanas termiņa, tas tiek uzskatīts par aktivitāti un gaidošā bloķēšana tiek atcelta. Tevi nebloķēs tikai tāpēc, ka esi uzmetis aci savai ierīcei.

Lai pilnībā apturētu bloķēšanu dīkstāvē, `Super + Ctrl + I` — vai `omarchy toggle idle` — ieslēdz palikšanu nomodā, un joslā parādās kafijas tases indikators. Tas ir tas, kuru nospiest pirms garas prezentācijas vai būvējuma, kam vēlies sekot līdzi. Nospied to vēlreiz, lai atgrieztos pie normālā režīma. `omarchy toggle idle status` izdrukā pašreizējo stāvokli kā JSON, ja tev tas nepieciešams no skripta.

Šeit runa ir par bloķēšanu un ekrānsaudzētāju, nevis par barošanu. Iemidzināšanai un hibernācijai ir sava iestatīšana sadaļā [sistēmas miegs](36-system-sleep.md).

### Ekrānsaudzētājs

Omarchy ekrānsaudzētājs ir ASCII māksla, kas iet caur nejaušiem teksta efektiem, viena instance katram monitoram. Jebkurš taustiņš vai peles kustība to pārtrauc.

Tu vari to startēt pēc pieprasījuma no _Sistēma > Ekrānsaudzētājs_ (`Super + Esc`), kas to piespiedu kārtā parāda pat tad, ja esi izslēdzis dīkstāves ekrānsaudzētāju. Pēc noklusējuma tam nav piesaistīts neviens karstais taustiņš.

`omarchy toggle screensaver` ir tas, kas izslēdz dīkstāves ekrānsaudzētāju, ja labprātāk no darba uzreiz pārietu uz bloķētu stāvokli. Jebkurš taustiņš, klikšķis, ritināšana vai peles kustība to aizver.

Logotips, ko tas zīmē, ir tavā ziņā maināms sadaļā _Izskats > Zīmols > Ekrānsaudzētājs_. Augšupielādē png vai svg, un Omarchy to pārvērtīs par ASCII. Skati [zīmolvedību](41-branding.md).

### Bloķēšanas ekrāns

`Super + Ctrl + L` bloķē ierīci. Tas palaiž bloķēšanas ekrānu no Omarchy čaulas, aptumšo displeju, atiestata tastatūras izkārtojumu uz pirmo, lai tu nerakstītu paroli nepareizā alfabētā, un — ja tev tas darbojas — izejot bloķē 1Password.

Bloķēšanas ekrāns pieņem paroli, un tas pieņems arī pirksta nospiedumu, tiklīdz tu tādu būsi iestatījis. Tas un citi autentifikācijas veidi ir aprakstīti sadaļā [aparatūras autentifikācija](37-hardware-authentication.md).
