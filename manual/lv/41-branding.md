# Zīmols

Omarchy ļauj iestatīt jūsu uzņēmuma logotipu vai personīgo attēlu gan sāknēšanas atbloķēšanas ekrānam, gan ekrānsaudzētājam, gan Par ekrānam.

### Sāknēšanas atbloķēšana

Varat izmantot `omarchy plymouth preview`, lai redzētu, kā izskatītos jūsu pielāgotais logotips un krāsas. Tam nepieciešama fona krāsa, teksta krāsa, logotipa png un ceļš priekšskatījuma attēlam:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Pēc tam lietojiet iestatījumu ar `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, kas arī SDDM pieteikšanās ekrānam piešķirs tās pašas krāsas un logotipu. Ja vēlaties atsaukt izmaiņas, varat izmantot `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekrānsaudzētājs

Ekrānsaudzētājam izmantoto logotipu varat mainīt sadaļā _Izskats > Zīmols > Ekrānsaudzētājs_. Tas ir ASCII logotips, tāpēc varat rediģēt tekstu tieši, bet varat arī iedot tam png vai svg attēlu, un mēs to pārveidosim par ASCII. Izskatās diezgan forši.

 ![branding-screensaver](images/branding-screensaver.webp)

Tajā izvēlnē ir trīs ieraksti:

- **Rediģēt tekstu** atver `~/.config/omarchy/branding/screensaver.txt` jūsu redaktorā. Ierakstiet vai ielīmējiet, ko vien vēlaties — ASCII mākslu, savu vārdu, nepieklājīgu vārdu. Saglabājiet un aizveriet, un ekrānsaudzētājs nekavējoties ieslēgsies, lai jūs to varētu redzēt.
- **Iestatīt no attēla** atver failu atlasītāju png vai svg failam, pārveido to par ASCII un parāda jums rezultātu. Logotipi ar skaidru siluetu darbojas daudz labāk nekā fotoattēli.
- **Atjaunot noklusējumu** atgriež Omarchy logotipu.

### Par ekrāns

Tās pašas trīs iespējas sadaļā _Izskats > Zīmols > Par_ ir paredzētas _Par_ ekrānam, ko atverat no Omarchy izvēlnes, un tās darbojas identiski — fails ir `~/.config/omarchy/branding/about.txt`, un logs Par parādās pēc katrām izmaiņām. Māksla Par ekrānam tiek pārveidota mazākā izmērā nekā ekrānsaudzētāja māksla, jo tai jāietilpst logā, nevis jāaizpilda viss displejs.

Kamēr logs ir atvērts, ik pēc dažām sekundēm pāri mākslai pārslīd spilgti baltas gaismas josla un pēc tam atkal atstāj to nekustīgu. Arī jūsu pašu māksla to iegūst, ja vien katra rakstzīme tajā ir vienas kolonnas platumā — viss, ko rada _Iestatīt no attēla_, tāds ir. Māksla, kas veidota no emoji vai dubulta platuma rakstzīmēm, tā vietā paliek nekustīga, un tāpat paliek ekrāns, ja paturat savu fastfetch konfigurāciju: nekustīgs logotips šajos gadījumos nozīmē, ka animācija apzināti netraucē, nevis ka tā ir izgāzusies, jo atspīduma pārslīdēšana pāri tiem novietotu pārējo rindas daļu nepareizā vietā.

 ![branding-about](images/branding-about.webp)

### Attēlu konvertēšana pašam

Abas iespējas _Iestatīt no attēla_ vienkārši izsauc `omarchy transcode ascii`, ko varat palaist tieši, ja vēlaties kontrolēt konvertēšanu:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Tam nepieciešami `--width` un `--height` termināļa kolonnās un rindās, `--mode` — vai nu `braille` (noklusējums, un daudz smalkāks), vai `block`, `--threshold` procentos, lai izlemtu, kuri pikseļi tiek uzskatīti par logotipa daļu, un `--invert`, ja jūsu logotips ir gaišs uz tumša fona. Ja konvertēšana iznāk kā pleķis, slieksnis parasti ir tas parametrs, ko vajag pagrozīt.

### Vārdi logotipa vietā

`omarchy ascii` zīmē tekstu ar Delta Corps Priest 1 — FIGlet fontu, ar kuru uzzīmēts arī pats Omarchy vārdu zīmols —, tāpēc ekrānsaudzētājs var kaut ko pateikt, nevis rādīt attēlu:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Tas pieņem tekstu kā argumentus vai nolasa to no konveijera, ja neviens arguments nav dots. Fonts satur tikai burtus un atstarpes — tas tika uzzīmēts bez cipariem un pieturzīmēm —, tāpēc viss pārējais tiek atmests un nosaukts stderr, nevis klusi norīts.
