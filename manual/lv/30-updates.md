# Atjauninājumi

Omarchy un jūsu pakotnes tiek uzturētas aktuālas no Omarchy izvēlnes (`Super + Space`) sadaļas _Atjaunināt > Omarchy_.

Pats Omarchy tiek instalēts kā ierastas pacman pakotnes no [Omarchy pakotņu repozitorija](https://github.com/omacom-io/omarchy-pkgs), tāpēc atjauninājums instalē [jaunāko Omarchy laidiņu](https://github.com/omacom/omarchy/releases), palaiž visas neizpildītās migrācijas, lai jūsu sistēma būtu sinhronā ar jaunāko versiju, un atjaunina visas sistēmas pakotnes no [Omarchy Arch spoguļa](https://github.com/omacom-io/omarchy-mirror) un [AUR](https://aur.archlinux.org/) (ja jums ir instalētas kādas AUR pakotnes).

Kad tiek izlaisti jauni laidieni, pa labi no jūsu pulksteņa parādīsies apļveida bultiņas ikona. Noklikšķiniet uz tās, un sāksies atjaunināšanas process.

![update-available](images/update-available.webp)

### Četri kanāli

Omarchy tiek atjaunināts četros kanālos: stable, RC, edge un dev. Jaunas instalācijas sāk darbu stabilajā kanālā, kurš seko [oficiālajiem laidieniem](https://github.com/omacom/omarchy/releases/), kā arī [stabilajam Omarchy Arch spogulim](https://github.com/omacom-io/omarchy-mirror), kas par mēnesi atpaliek no jaunākā, lai mēs varētu pamanīt jebkādas jaunas nesaderības, kurām vajadzīgas konfigurācijas izmaiņas, pirms tās cilvēkiem sagādā problēmas.

Taču, ja vēlaties palīdzēt pamanīt šīs iespējamās problēmas, varat darboties edge kanālā. Tajā jūsu Omarchy pakotnes sekos jaunākajām izstrādes būvēm un ļauj atjaunināt uz jaunākajām Arch pakotnēm, tiklīdz tās ir pieejamas. To vajadzētu darīt tikai tad, ja esat pieredzējis Linux lietošanā un zināt, kā atjaunot sistēmu, kurai ir problēmas.

Pirms jebkura jauna lielā laidiena mēs veiksim galīgo pārbaudi, izmantojot RC kanālu. Ja jūs interesē palīdzēt galīgajā pieslīpēšanā, iegriezieties Discord kanālā #omarchy-release-candidates.

Visbeidzot, ir dev kanāls, kas Omarchy savieno tieši ar pirmkoda git izrakstīšanu mapē `~/omarchy`, apvienojumā ar edge pakotnēm. Šo kanālu vajadzētu izmantot tikai tad, ja esat pieredzējis Linux lietotājs, strādājat tieši pie Omarchy un esat gatavs paciest sabrukšanu.

Starp kanāliem var pārslēgties no Omarchy izvēlnes sadaļas _Atjaunināt > Channel_ (vai terminālī ar `omarchy-channel-set`).

### Programmaparatūras atjauninājumi

Jūsu pakotnes nav vienīgais, kas noveco. Daudzi klēpjdatori un perifērijas ierīces caur Linux pārdevēju programmaparatūras pakalpojumu (Linux Vendor Firmware Service) piegādā BIOS, SSD un dokstacijas programmaparatūru, un Omarchy izvēlnes sadaļa _Atjaunināt > Firmware_ ienesīs un instalēs visu, kas jūsu aparatūru gaida. Pirmajā palaišanas reizē tā instalē `fwupd`. Daudz programmaparatūras var ierakstīt tikai pārstartēšanās laikā, tāpēc nebrīnieties, ja jums tādu paprasīs.

### Brīdinājums par tiešiem pacman/yay atjauninājumiem

Ja Arch jums jau ir pazīstams, jums var būt kārdinājums vienkārši pašam palaist `pacman -Syu` vai `yay -Syu`, taču, ja to darīsiet, palaidīsiet garām momentuzņēmumu, migrācijas un konfigurācijas atjauninājumus, ko Omarchy palaiž kopā ar jaunām pakotnēm. Tāpēc Omarchy tiešu sistēmas jaunināšanu patiesībā apturēs un tā vietā parādīs ceļu uz `omarchy update`. (Ja patiesi zināt, ko darāt, aizsargs jums pateiks, kā to vienai transakcijai apiet.)

### Sliktu atjauninājumu atcelšana

Ja pēc atjaunināšanas jums kādreiz rodas problēma, sistēmu varat atcelt līdz momentuzņēmumam, kas uzņemts pirms atjaunināšanas. Vienkārši pārstartējiet un sāknēšanas ielādes izvēlnē izvēlieties momentuzņēmumu pirms atjaunināšanas sākšanas.

![bootloader](images/bootloader.webp)

Ja jūsu konfigurācijas faili kaut kā ir sabojāti, varat arī veikt Omarchy pārinstalēšanu, terminālī izmantojot `omarchy reinstall`. Tas pārinstalēs visas noklusējuma Omarchy pakotnes, iestatīs jums stabilo kanālu un pazeminās visas pārāk jaunās pakotnes, kā arī atiestatīs visus konfigurācijas failus. Ievērojiet, ka, šādi rīkojoties, visas jūsu lietotāja izmaiņas Omarchy noklusējumu konfigurācijās tiks pārrakstītas!
