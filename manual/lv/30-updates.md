# Atjauninājumi

Omarchy un jūsu pakotnes tiek uzturētas aktuālas, izmantojot _Atjaunināšana > Omarchy_ Omarchy izvēlnē (`Super + Space`).

Omarchy pats ir instalēts kā parastas pacman pakotnes no [Omarchy pakotņu repozitorija](https://github.com/omacom-io/omarchy-pkgs), tāpēc atjauninājums instalē [jaunāko Omarchy laidienu](https://github.com/omacom/omarchy/releases), palaiž visas neizpildītās migrācijas, lai jūsu sistēmu saskaņotu ar jaunāko versiju, un atjaunina visas sistēmas pakotnes no [Omarchy Arch spoguļa](https://github.com/omacom-io/omarchy-mirror) un [AUR](https://aur.archlinux.org/) (ja esat instalējis kādas AUR pakotnes).

Kad tiek izlaisti jauni laidieni, pulksteņa labajā pusē parādīsies apļa bultiņas ikona. Noklikšķiniet uz tās, un sāksies atjaunināšanas process.

![update-available](images/update-available.webp)

### Četri kanāli

Omarchy tiek atjaunināts četros kanālos: stable, RC, edge un dev. Jaunas instalācijas sākas stable kanālā, kas seko [oficiālajiem laidieniem](https://github.com/omacom/omarchy/releases/), kā arī [stabilajam Omarchy Arch spogulim](https://github.com/omacom-io/omarchy-mirror), kas atpaliek par vienu mēnesi no jaunākā, lai mēs varētu pamanīt visas jaunās nesaderības, kurām nepieciešamas konfigurācijas izmaiņas, pirms tās sagādā problēmas cilvēkiem.

Bet, ja vēlaties palīdzēt pamanīt šīs iespējamās problēmas, varat darboties edge kanālā. Tas nodrošinās, ka jūsu Omarchy pakotnes seko jaunākajām izstrādes versijām, un ļaus jums atjaunināt uz jaunākajām Arch pakotnēm, tiklīdz tās kļūst pieejamas. Jums to vajadzētu darīt tikai tad, ja jums ir pieredze ar Linux un jūs zināt, kā atjaunot sistēmu, kurai radušās problēmas.

Pirms katra jauna lielā laidiena mēs veiksim galīgo pārbaudi, izmantojot RC kanālu. Ja jūs interesē palīdzēt ar pēdējo pulēšanu, nāciet pievienoties #omarchy-release-candidates kanālam Discord.

Visbeidzot, ir dev kanāls, kas saista Omarchy tieši ar avota koda git izrakstu `~/omarchy`, apvienojumā ar edge pakotnēm. Šo kanālu vajadzētu izmantot tikai tad, ja esat pieredzējis Linux lietotājs, strādājat tieši pie Omarchy un esat gatavs samierināties ar sabojāšanos.

Jūs varat pārslēgties starp kanāliem, izmantojot _Atjaunināšana > Kanāls_ Omarchy izvēlnē (vai `omarchy channel set <stable|rc|edge|dev>` terminālī, ar `omarchy channel current`, lai redzētu, kur atrodaties).

### Kodolu pārslēgšana

Omarchy palaiž savu `linux-omarchy` kodolu, bet jūs varat turēt citus instalētus līdzās tam, piemēram, standarta Arch `linux` kodolu vai eksperimentālu būvējumu, kuru testējat. Kad ir vairāk nekā viens, _Atjaunināšana > Kodols_ Omarchy izvēlnē uzskaita tos ar atzīmi blakus tam, kurš tiek palaists pēc noklusējuma. Izvēlieties citu, vienreiz ievadiet savu paroli, un tas tiks palaists pēc nākamās restartēšanas. Pārējie kodoli paliek palaišanas izvēlnē, tāpēc jūs joprojām varat izvēlēties kādu manuāli, ja jaunais noklusējums sagādā jums problēmas. Terminālī `omarchy kernel` parāda pašreizējo noklusējumu, `omarchy kernel list` parāda to, kas ir instalēts, un `omarchy kernel set <kernel>` pārslēdz.

### Aparātprogrammatūras atjauninājumi

Jūsu pakotnes nav vienīgais, kas noveco. Daudzi klēpjdatori un perifērijas ierīces nodrošina BIOS, SSD un dokstaciju aparātprogrammatūru, izmantojot Linux Vendor Firmware Service, un _Atjaunināšana > Aparātprogrammatūra_ Omarchy izvēlnē iegūs un instalēs visu, ko jūsu aparatūra gaida. Pirmajā palaišanas reizē tas instalē `fwupd`. Lielu daļu aparātprogrammatūras var ierakstīt tikai restartēšanas laikā, tāpēc nebrīnieties, ja jums tiks lūgts restartēt.

Kad jums nepieciešams mainīt iestatījumu pašā BIOS, turiet nospiestu `Alt` sistēmas izvēlnē (`Super + Escape`), un _Restartēt_ pārvēršas par _Restartēt uz BIOS_, kas restartē tieši uz aparātprogrammatūras iestatīšanu, bez nepieciešamības noķert pareizo taustiņu palaišanas laikā. Terminālī tas ir `omarchy system firmware`.

### Brīdinājums par tiešiem pacman/yay atjauninājumiem

Ja jūs jau pārzināt Arch, jums varētu rasties kārdinājums vienkārši pašam palaist `pacman -Syu` vai `yay -Syu`, bet, ja jūs to darīsiet, jūs palaidīsiet garām momentuzņēmumu, migrācijas un konfigurācijas atjauninājumus, ko Omarchy palaiž kopā ar jaunajām pakotnēm. Tāpēc Omarchy faktiski apturēs tiešu sistēmas jaunināšanu un norādīs jums uz `omarchy update`. (Ja jūs patiešām zināt, ko darāt, aizsargs jums pateiks, kā to apiet vienai transakcijai.)

### Sliktu atjauninājumu atcelšana

Ja pēc atjaunināšanas jums kādreiz rodas problēma, jūs varat atcelt sistēmu uz momentuzņēmumu, kas uzņemts pirms atjaunināšanas. Vienkārši restartējiet un palaišanas ielādes izvēlnē izvēlieties momentuzņēmumu no laika pirms atjaunināšanas sākšanas.

![bootloader](images/bootloader.webp)

Ja jūsu konfigurācijas faili kaut kā ir sabojāti, jūs varat arī veikt Omarchy pārinstalēšanu, izmantojot `omarchy reinstall` terminālī. Tas pārinstalēs visas noklusējuma Omarchy pakotnes, novietos jūs stable kanālā (edge Apple Silicon) un pazeminās visas pakotnes, kas ir pārāk jaunas, kā arī atiestatīs visus konfigurācijas failus. Ņemiet vērā, ka, to darot, visas jūsu lietotāja konfigurācijas izmaiņas Omarchy noklusējumos tiks pārrakstītas!
