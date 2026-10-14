# Zīmolvedība

Omarchy ļauj iestatīt sava uzņēmuma logotipu vai personisko attēlu gan sāknēšanas atbloķēšanai, gan ekrānsaudzētājam, gan ekrānam Par.

### Sāknēšanas atbloķēšana

Ar `omarchy plymouth preview` varat redzēt, kā jūsu pielāgotais logotips un krāsas izskatītos. Tas pieņem fona krāsu, teksta krāsu, logotipa png un ceļu priekšskatījuma attēlam:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Pēc tam lietojiet iestatījumu ar `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, kas arī SDDM pieteikšanās ekrānam piešķirs tās pašas krāsas un logotipu. Ja vēlaties atgriezties, varat izmantot `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekrānsaudzētājs

Ekrānsaudzētājā izmantoto logotipu varat mainīt sadaļā _Stils > Ekrānsaudzētājs_. Tas ir ASCII logotips, tāpēc tekstu varat rediģēt tieši, bet varat tam iedot arī png vai svg attēlu, un mēs to pārveidosim par ASCII. Tas izskatās diezgan forši.

 ![branding-screensaver](images/branding-screensaver.webp)

Šajā izvēlnē ir trīs ieraksti:

- **Rediģēt tekstu** jūsu redaktorā atver failu `~/.config/omarchy/branding/screensaver.txt`. Ierakstiet vai ielīmējiet, ko gribat — ASCII mākslu, savu vārdu, rupju vārdu. Saglabājiet un aizveriet, un ekrānsaudzētājs uzreiz ieslēgsies, lai varat to redzēt.
- **Uzlikt no attēla** atver failu atlasītāju png vai svg failam, pārveido to par ASCII un parāda rezultātu. Logotipi ar skaidru siluetu darbojas daudz labāk nekā fotogrāfijas.
- **Atjaunot noklusējumu** atgriež Omarchy logotipu.

### Ekrāns Par

Tās pašas trīs opcijas ir sadaļā _Stils > Par_ ekrānam _Par_, ko iegūstat no Omarchy izvēlnes, un tās darbojas identiski — fails ir `~/.config/omarchy/branding/about.txt`, un logs Par parādās pēc katrām izmaiņām. Attēls ekrānā Par tiek pārveidots mazākā izmērā nekā ekrānsaudzētāja attēls, jo tam jāietilpst logā, nevis jāaizpilda displejs.

Kamēr logs ir atvērts, ik pēc dažām sekundēm pāri attēlam pārslīd zaļš atspīdums un pēc tam atkal atstāj to mierā. Arī jūsu pašu attēls to saņem, ja vien katra rakstzīme tajā ir vienas kolonnas plata — viss, ko rada _Uzlikt no attēla_, tāds ir. Attēls, kas būvēts no emocijzīmēm vai dubultplatuma rakstzīmēm, tā vietā paliek nekustīgs, un tāds paliek arī ekrāns, ja saglabājat savu fastfetch konfigurāciju: nekustīgs logotips šajos gadījumos nozīmē, ka animācija netraucē, nevis ka tā ir sabrukusi, jo atspīduma slīdēšana pāri tiem novietotu pārējo rindu nepareizā vietā.

 ![branding-about](images/branding-about.webp)

### Attēlu pārveidošana pašam

Abas _Uzlikt no attēla_ opcijas vienkārši izsauc `omarchy transcode ascii`, ko varat palaist tieši, ja vēlaties kontrolēt pārveidošanu:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Tas pieņem `--width` un `--height` termināļa kolonnās un rindās, `--mode` ar vērtību `braille` (noklusējuma un daudz smalkāks) vai `block`, `--threshold` procentu, kas izlemj, kuri pikseļi pieder pie logotipa, un `--invert` gadījumiem, kad jūsu logotips ir gaišs uz tumša fona. Ja pārveidojums iznāk kā pleķis, parasti grozāmā poga ir slieksnis.

### Vārdi logotipa vietā

`omarchy ascii` zīmē tekstu ar Delta Corps Priest 1, FIGlet fontu, ar ko zīmēta pati Omarchy vārda zīme, tāpēc ekrānsaudzētājs var kaut ko pateikt, nevis rādīt attēlu:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Tas tekstu pieņem kā argumentus vai nolasa no konveijera, ja argumentu nav. Fonts satur tikai burtus un atstarpes — tas tika zīmēts bez cipariem un pieturzīmēm —, tāpēc viss pārējais tiek atmests un nosaukts stderr, nevis klusi norīts.
