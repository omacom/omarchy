# Zīmols

Omarchy ļauj iestatīt sava uzņēmuma logotipu vai personisku attēlu gan ekrānsaudzētājam, gan ekrānam Par.

### Ekrānsaudzētājs

Ekrānsaudzētājam izmantoto logotipu var mainīt sadaļā _Izskats > Zīmols > Ekrānsaudzētājs_. Tas ir ASCII logotips, tāpēc tekstu var rediģēt tieši, bet var arī iedot png vai svg attēlu, un mēs to pārveidosim par ASCII. Izskatās diezgan forši.

 ![branding-screensaver](images/branding-screensaver.webp)

Tajā izvēlnē ir trīs ieraksti:

- **Rediģēt tekstu** atver `~/.config/omarchy/branding/screensaver.txt` jūsu redaktorā. Rakstiet vai ielīmējiet, ko vien vēlaties — ASCII mākslu, savu vārdu, rupju vārdu. Saglabājiet un aizveriet, un ekrānsaudzētājs uzreiz ieslēgsies, lai jūs to varētu redzēt.
- **Iestatīt no attēla** atver failu atlasītāju png vai svg failam, pārveido to par ASCII un parāda rezultātu. Logotipi ar skaidru siluetu darbojas daudz labāk nekā fotogrāfijas.
- **Atjaunot noklusējumu** atgriež Omarchy logotipu.

### Ekrāns Par

Tās pašas trīs opcijas atrodas sadaļā _Izskats > Zīmols > Par_ ekrānam _Par_, ko iegūstat no Omarchy izvēlnes, un tās darbojas identiski — fails ir `~/.config/omarchy/branding/about.txt`, un pēc katrām izmaiņām uznirst logs Par. Ekrāna Par māksla tiek pārveidota mazākā izmērā nekā ekrānsaudzētāja, jo tai jāietilpst logā, nevis jāaizpilda viss displejs.

Kamēr logs ir atvērts, spilgti baltas gaismas josla ik pēc dažām sekundēm nosveras pāri mākslai un pēc tam atkal atstāj to nekustīgu. Arī jūsu pašu māksla to iegūst, ja vien katra rakstzīme tajā ir vienas kolonnas platumā — viss, ko rada _Iestatīt no attēla_, tāds ir. No emocijzīmēm vai dubulta platuma rakstzīmēm veidota māksla tā vietā paliek nekustīga, un tāpat arī ekrāns, ja jums ir pašam sava fastfetch konfigurācija: nekustīgs logotips šajos gadījumos nozīmē, ka animācija apzināti netraucē, nevis ka tā ir izgāzusies, jo, pārslīdot atspīdumam pāri tiem, pārējā rindas daļa nonāktu nepareizā vietā.

 ![branding-about](images/branding-about.webp)

### Attēlu pārveidošana pašam

Abas _Iestatīt no attēla_ opcijas vienkārši izsauc `omarchy transcode ascii`, ko varat palaist arī tieši, ja vēlaties kontrolēt pārveidošanu:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Tas pieņem `--width` un `--height` termināļa kolonnās un rindās, `--mode` ar vērtību `braille` (noklusējums, un daudz smalkāks) vai `block`, `--threshold` procentos, lai izlemtu, kuri pikseļi tiek uzskatīti par logotipa daļu, un `--invert` gadījumiem, kad jūsu logotips ir gaišs uz tumša fona. Ja pārveidojums iznāk kā viens liels pleķis, slieksnis parasti ir tas regulētājs, ko pagriezt.

### Vārdi logotipa vietā

`omarchy ascii` zīmē tekstu fontā Delta Corps Priest 1, FIGlet fontā, kurā uzzīmēts arī pats Omarchy vārdu zīmes logotips, tāpēc ekrānsaudzētājs var kaut ko pateikt, nevis rādīt attēlu:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Tas pieņem tekstu kā argumentus vai nolasa to no konveijera, ja argumentu nav. Fonts satur tikai burtus un atstarpes — tas tika uzzīmēts bez cipariem un pieturzīmēm —, tāpēc viss pārējais tiek atmests un nosaukts stderr, nevis klusām norīts.
