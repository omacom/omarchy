# Zīmols

Omarchy ļauj iestatīt sava uzņēmuma logotipu vai personīgo attēlu gan sāknēšanas atbloķēšanai, gan ekrānsaudzētājam, gan ekrānam Par.

### Sāknēšanas atbloķēšana

Varat izmantot `omarchy plymouth preview`, lai redzētu, kā izskatītos jūsu pielāgotais logotips un krāsas. Tam nepieciešama fona krāsa, teksta krāsa, logotipa png un ceļš priekšskatījuma attēlam:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Pēc tam lietojiet iestatījumu ar `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, kas arī SDDM pieteikšanās ekrānam piešķirs tās pašas krāsas un logotipu. Ja vēlaties to atcelt, varat izmantot `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekrānsaudzētājs

Ekrānsaudzētājam izmantoto logotipu varat mainīt sadaļā _Izskats > Zīmols > Ekrānsaudzētājs_. Tas ir ASCII logotips, tāpēc varat rediģēt tekstu tieši, taču varat tam iedot arī png vai svg attēlu, un mēs to pārveidosim par ASCII. Izskatās diezgan forši.

 ![branding-screensaver](images/branding-screensaver.webp)

Tajā izvēlnē ir trīs ieraksti:

- **Rediģēt tekstu** atver `~/.config/omarchy/branding/screensaver.txt` jūsu redaktorā. Ierakstiet vai ielīmējiet, ko vien vēlaties — ASCII mākslu, savu vārdu, rupju vārdu. Saglabājiet un aizveriet, un ekrānsaudzētājs nekavējoties ieslēgsies, lai jūs to varētu redzēt.
- **Iestatīt no attēla** atver failu izvēli png vai svg failam, pārveido to par ASCII un parāda rezultātu. Logotipi ar skaidru siluetu darbojas daudz labāk nekā fotogrāfijas.
- **Atjaunot noklusējumu** atgriež Omarchy logotipu.

### Ekrāns Par

Tās pašas trīs opcijas atrodas sadaļā _Izskats > Zīmols > Par_ ekrānam _Par_, ko iegūstat no Omarchy izvēlnes, un tās darbojas identiski — fails ir `~/.config/omarchy/branding/about.txt`, un logs Par parādās pēc katrām izmaiņām. Attēls ekrānam Par tiek pārvērsts mazākā izmērā nekā ekrānsaudzētājam, jo tam jāietilpst logā, nevis jāaizpilda viss jūsu displejs.

Kamēr logs ir atvērts, zaļš atspīdums ik pēc dažām sekundēm pārslīd pāri attēlam un pēc tam atkal atstāj to nekustīgu. Arī jūsu paša attēls to saņem, ja vien katra rakstzīme tajā ir vienas kolonnas platumā — viss, ko izveido _Iestatīt no attēla_, tāds ir. Attēls, kas veidots no emocijzīmēm vai dubulta platuma rakstzīmēm, tā vietā paliek nekustīgs, un tāpat paliek arī ekrāns, ja jums ir sava fastfetch konfigurācija: nekustīgs logotips šajos gadījumos nozīmē, ka animācija netraucē, nevis ka tā ir izgāzusies, jo atspīduma slīdēšana pāri tiem novietotu pārējo rindas daļu nepareizā vietā.

 ![branding-about](images/branding-about.webp)

### Attēlu konvertēšana pašrocīgi

Abas opcijas _Iestatīt no attēla_ vienkārši izsauc `omarchy transcode ascii`, ko varat palaist tieši, ja vēlaties kontrolēt pārveidošanu:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Tas pieņem `--width` un `--height` termināļa kolonnās un rindās, `--mode` ar vērtību `braille` (noklusējums un daudz smalkāks) vai `block`, `--threshold` procentuālo vērtību, lai noteiktu, kuri pikseļi tiek uzskatīti par logotipa daļu, un `--invert`, ja jūsu logotips ir gaišs uz tumša fona. Ja pārveidojums iznāk kā pleķis, slieksnis parasti ir tas parametrs, ko vajag pagrozīt.

### Vārdi logotipa vietā

`omarchy ascii` zīmē tekstu ar Delta Corps Priest 1 — FIGlet fontu, ar kuru zīmēts arī pats Omarchy vārda zīmols —, tāpēc ekrānsaudzētājs var kaut ko pateikt, nevis rādīt attēlu:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Tas pieņem tekstu kā argumentus vai nolasa to no konveijera, ja arguments nav dots. Fonts satur tikai burtus un atstarpes — tas tika zīmēts bez cipariem un pieturzīmēm —, tāpēc viss pārējais tiek atmests un nosaukts stderr, nevis klusi norīts.
