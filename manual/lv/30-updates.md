# Atjauninājumi

Omarchy un tavas pakotnes tiek uzturētas aktuālas, izmantojot _Update > Omarchy_ Omarchy izvēlnē (`Super + Space`).

Pats Omarchy tiek instalēts kā parastas pacman pakotnes no [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), tāpēc atjauninājums instalē [jaunāko Omarchy laidienu](https://github.com/omacom/omarchy/releases), palaiž visas gaidošās migrācijas, lai tava sistēma būtu sinhronizēta ar jaunāko versiju, un atjaunina visas sistēmas pakotnes no [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) un [AUR](https://aur.archlinux.org/) (ja esi instalējis kādas AUR pakotnes).

Kad būs pieejami jauni laidieni, pa labi no tava pulksteņa parādīsies apļa bultiņas ikona. Noklikšķini uz tās, un sāksies atjaunināšanas process.

![update-available](images/update-available.webp)

### Četri kanāli

Omarchy tiek atjaunināts četros kanālos: stable, RC, edge un dev. Jaunas instalācijas sākas stable kanālā, kas seko [oficiālajiem laidieniem](https://github.com/omacom/omarchy/releases/), kā arī [stabilajam Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror), kas atpaliek par vienu mēnesi no jaunākā, lai mēs varētu pamanīt visas jaunās nesaderības, kurām nepieciešamas konfigurācijas izmaiņas, pirms tās sagādā problēmas cilvēkiem.

Bet, ja vēlies palīdzēt pamanīt šīs iespējamās problēmas, vari darboties edge kanālā. Tas ļaus tavām Omarchy pakotnēm sekot jaunākajām izstrādes versijām un ļaus tev atjaunināt uz jaunākajām Arch pakotnēm, tiklīdz tās kļūst pieejamas. Tev to vajadzētu darīt tikai tad, ja tev ir pieredze ar Linux un tu zini, kā atjaunot sistēmu, kurai radušās problēmas.

Pirms katra jauna lielā laidiena mēs veiksim galīgo pārbaudi, izmantojot RC kanālu. Ja tev ir interese palīdzēt ar pēdējiem uzlabojumiem, nāc pabūt #omarchy-release-candidates kanālā Discord.

Visbeidzot, ir dev kanāls, kas saista Omarchy tieši ar pirmkoda git checkout mapē `~/omarchy`, apvienojumā ar edge pakotnēm. Tev vajadzētu izmantot šo kanālu tikai tad, ja esi pieredzējis Linux lietotājs, strādā tieši pie Omarchy un esi gatavs samierināties ar bojājumiem.

Tu vari pārslēgties starp kanāliem, izmantojot _Update > Channel_ Omarchy izvēlnē (vai `omarchy-channel-set` terminālī).

### Kodolu pārslēgšana

Omarchy palaiž savu `linux-omarchy` kodolu, bet tu vari līdzās turēt instalētus arī citus, piemēram, standarta Arch `linux` kodolu vai eksperimentālu versiju, ko testē. Kad ir vairāk nekā viens, _Update > Kernel_ Omarchy izvēlnē tos parāda ar atzīmi blakus tam, kas pēc noklusējuma tiek palaists. Izvēlies citu, vienreiz ievadi savu paroli, un tas tiks palaists pēc nākamās restartēšanas. Pārējie kodoli paliek sāknēšanas izvēlnē, tāpēc tu joprojām vari izvēlēties kādu manuāli, ja jaunais noklusējuma kodols sagādā problēmas. Terminālī `omarchy-kernel` parāda pašreizējo noklusējumu, `omarchy-kernel list` parāda, kas ir instalēts, un `omarchy-kernel set <kernel>` pārslēdz.

### Aparātprogrammatūras atjauninājumi

Tavas pakotnes nav vienīgais, kas noveco. Daudzi klēpjdatori un perifērijas ierīces piegādā BIOS, SSD un dokstaciju aparātprogrammatūru, izmantojot Linux Vendor Firmware Service, un _Update > Firmware_ Omarchy izvēlnē ielādēs un instalēs visu, kas tavai aparatūrai gaida. Pirmo reizi to palaižot, tas instalē `fwupd`. Daudz aparātprogrammatūras var ierakstīt tikai restartēšanas laikā, tāpēc nebrīnies, ja tev lūgs restartēt.

Kad tev nepieciešams mainīt iestatījumu pašā BIOS, sistēmas izvēlnē (`Super + Escape`) turi nospiestu `Alt`, un _Reboot_ pārvērtīsies par _Reboot to BIOS_, kas restartē tieši uz aparātprogrammatūras iestatīšanu, bez nepieciešamības sāknēšanas laikā noķert pareizo taustiņu. Terminālī tas ir `omarchy system firmware`.

### Brīdinājums par tiešiem pacman/yay atjauninājumiem

Ja tu jau pazīsti Arch, tev varētu rasties kārdinājums vienkārši pašam palaist `pacman -Syu` vai `yay -Syu`, bet, ja tu to darīsi, tu palaidīsi garām momentuzņēmumu, migrācijas un konfigurācijas atjauninājumus, ko Omarchy palaiž kopā ar jaunajām pakotnēm. Tāpēc Omarchy patiesībā apturēs tiešu sistēmas jaunināšanu un tā vietā norādīs tev uz `omarchy update`. (Ja tu patiešām zini, ko dari, aizsargs tev pateiks, kā to apiet vienai transakcijai.)

### Neveiksmīgu atjauninājumu atgriešana

Ja tev kādreiz pēc atjaunināšanas rodas problēma, tu vari atgriezt savu sistēmu uz momentuzņēmumu, kas uzņemts pirms atjaunināšanas. Vienkārši restartē un sāknēšanas ielādes izvēlnē izvēlies momentuzņēmumu no laika pirms atjaunināšanas sākšanas.

![bootloader](images/bootloader.webp)

Ja kādu iemeslu dēļ tavi konfigurācijas faili ir bojāti, tu vari arī veikt Omarchy pārinstalēšanu, terminālī izmantojot `omarchy reinstall`. Tas pārinstalēs visas noklusējuma Omarchy pakotnes, pārslēgs tevi uz stable un pazeminās visas pakotnes, kas ir pārāk jaunas, kā arī atiestatīs visus konfigurācijas failus. Ņem vērā, ka, to darot, visas tavas lietotāja konfigurācijas izmaiņas Omarchy noklusējumos tiks pārrakstītas!
