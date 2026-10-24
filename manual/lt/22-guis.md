# GUI

## Files

Files (Nautilus) yra grafinė failų tvarkytuvė. `Super + Shift + F` ją atverčia, o `Super + Shift + Alt + F` atverčia ją kataloge, kuriame šiuo metu yra tavo terminalas, o tai sutaupo daug spustelėjimų. `Ctrl + L` leidžia įvesti kelią, o paspaudus `Space` ant bet kurio failo gauni greitą peržiūrą nieko neatverdamas.

Įjunk USB raktą ar SD kortelę ir jis automatiškai primontuojamas, tad tiesiog pasirodo šoninėje juostoje. Jei reikia ko nors sudėtingesnio — formatuoti diską, patikrinti SMART sveikatą, sukurti skaidinius — paleisk _Disks_ iš programų paleidimo priemonės (`Super + Space`).

Dukart spustelėjus laikomasi protingų numatytųjų: vaizdai atidaromi imv, vaizdo įrašai mpv, PDF Document Viewer, o paprastas tekstas Neovim.

## Disktree

Kai diskas užsipildo ir neturi supratimo, kas jį valgo, paleisk [Disktree](https://github.com/tobi/disktree) iš programų paleidimo priemonės (`Super + Space`). Jis rodo grafinį tavo namų katalogo treemap. Didesni blokai užima daugiau vietos; vaikščiok katalogais klaviatūra ar pele, pažymėk, kas turi išeiti, ir peržiūrėk savo pasirinkimus prieš ką nors pašalindamas. Paleisk `disktree --disk`, kad nuskaitytum visą diską.

## Obsidian

[Obsidian](https://obsidian.md/) yra nemokama ir labai plečiama užrašų programa, saugojimui naudojanti paprastus Markdown failus.

Obsidian yra nemokama visiems tikslams, įskaitant asmeninį, komercinį ir nepelno naudojimą.

Obsidian taip pat siūlo [komercinį priedą sinchronizavimui](https://obsidian.md/sync) su mobiliosiomis programėlėmis iOS ir Android. (https://obsidian.md/pricing).

Obsidian paleidi su `Super + Shift + O`. Kad naudotum temų sinchronizavimą, nuostatose turi pasirinkti temą `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) yra pačios Omarchy nepaprastai paprasta Markdown rašymo programa. Be vaultų, be įskiepių, tiesiog tu ir žodžiai.

Omawrite paleidi su `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) yra paprastas vaizdų redagavimo įrankis, puikiai tinkantis apkarpymui, dydžio keitimui ir kitiems paprastiems veiksmams. Tik nesitikėk Photoshop alternatyvos. Bet jis vis dar turi Magic Wand ir sluoksnius!

Pinta paleidi per programų paleidimo priemonę (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) yra temų programa, galinti išgauti spalvas iš fono paveikslėlio ir paversti jas pilna, darniu tema. Tai lengviausias būdas [sukurti savo temą](43-making-your-own-theme.md).

Aether paleidi per programų paleidimo priemonę (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) leidžia siųsti failus į kitus įrenginius tame pačiame tinkle, kuriuose veikia programa, kaip Apple AirDrop. Tačiau jis yra daugiaplatformis, tad gali siųsti failus į ir iš Windows, macOS, Android, iOS ir, žinoma, Linux.

Share meniu gali atverti su `Super + Ctrl + S` arba Omarchy meniu skiltyje _Veiksmai > Dalytis_. Jis siūlo keturias parinktis:

- **Iškarpinė** siunčia viską, ką nukopijavai, kaip tekstinį failą. Puikiai tinka norint nusiųsti nuorodą ar fragmentą į savo telefoną nesiunčiant sau el. laiško.
- **Failas** atverčia failų rinkiklį, kuriame gali pasirinkti kelis vienu metu.
- **Aplankas** siunčia visą katalogą.
- **Gauti** atverčia patį LocalSend, kad kitas įrenginys galėtų ką nors atsiųsti tau.

Tas pats veikia iš terminalo su `omarchy share clipboard`, `omarchy share file [path]` ir `omarchy share folder [path]`. Praleisk kelią ir gausi rinkiklį.

Taip pat gali siųsti tiesiai iš failų tvarkytuvės: dešiniuoju pelės klavišu spustelėk bet kurį pasirinkimą Nautilus ir pasirink _Send via LocalSend_.

Omarchy ugniesiena pagal nutylėjimą uždarta, išskyrus LocalSend portą, tad tai veikia iš karto šviežiai įdiegus. Žr. [sauga](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) yra pilnas biuro paketas su teksto procesoriumi, skaičiuokle, pristatymais, piešimo programa ir daugiau. Jis suderinamas su Microsoft Office failais, tad tai puikus būdas atverti tuos Word dokumentus.

LibreOffice paleidi per programų paleidimo priemonę (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) yra pačios Omarchy nepaprastai paprasta pristatymų programa. Tavo rinkinys yra vienas Markdown failas su paveikslėliais ir vaizdo įrašais šalia jo: rašyk kiekvieną skaidrę po gyva peržiūra, vilk skaidres į eilę, tada pristatyk per visą ekraną arba eksportuok į PDF ir PowerPoint. Ji netgi perima tavo Omarchy temą.

Hype paleidi per programų paleidimo priemonę (`Super + Space`). Paspausk `?` jo viduje, kad pamatytum visus sparčiuosius klavišus.

## Signed

[Signed](https://github.com/omacom/signed) yra pačios Omarchy nepaprastai paprastas būdas pasirašyti PDF ir juos užpildyti. Padėk savo išsaugotą parašą, tekstą ir šiandienos datą bet kurioje puslapio vietoje, tada išsaugok pasirašytą kopiją šalia originalo. Žr. [PDF pildymas](27-filling-out-pdfs.md), kaip tai padaryti.

Signed paleidi per programų paleidimo priemonę (`Super + Space`) arba atverk su ja PDF iš failų tvarkytuvės.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) yra pačios Omarchy nepaprastai paprastas skaičiuotuvas, atsidarantis plūduriuojančiame lange.

Omacalc paleidi su `Super + Ctrl + Q` (arba skaičiuotuvo klavišu, jei tavo klaviatūra jį turi).

## Signal

[Signal](https://signal.org/) yra E2E užšifruotų susirašinėjimų pradininkas ir puikus bendravimo pasirinkimas visiems, kurie mieliau neina per vieną iš didžiųjų technologijų konglomeratų.

Signal paleidi su `Super + Shift + G`. Jis nėra bazinio diegimo dalis, tad pirmą kartą tai paspaudus Omarchy pasiūlys jį įdiegti tau (jis taip pat yra Omarchy meniu skiltyje _Įdiegti > Service_).

## mpv

[mpv](https://mpv.io/) yra paprastas, greitas medijos grotuvas, kuris gros beveik bet ką iš bet kurio šaltinio. Puikiai tinka vaizdo įrašams žiūrėti.

mpv paleidi per programų paleidimo priemonę (`Super + Space`) arba tiesiog dukart spustelėk vaizdo įrašą failų tvarkytuvėje.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) yra pačios Omarchy nepaprastai paprastas vaizdo įrašų apkarpytojas. Kai tereikia nupjauti klipo pradžią ir pabaigą, jis pranoksta pilno vaizdo redaktoriaus paleidimą.

Omacut paleidi per programų paleidimo priemonę (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) yra pačios Omarchy nepaprastai paprastas vaizdo kameros įrašytuvas. Kartą pasirink kamerą ir mikrofoną, tada paspausk `Space`, kad įrašytum, ir dar kartą, kad pristabdytum ir tęstum tą patį kadrą. Jis visada įrašo tavo kameros didžiausia raiška, su gyvu mikrofono matuokliu, kad prieš pradedant galėtum patikrinti lygius.

Sustabdyk kadrą ir jis iškart atsidarys įtaisytame redaktoriuje. Dukart spustelėk klipą, kad jį padaly-tum, vilk rankenėles, kad apkarpytum kiekvieną dalį, ir pašalink dalis, kurių nenori. Tada išsaugok jį kaip MP4. Tavo originalus įrašas saugomas, kol jį išmesi, tad visada gali sugrįžti ir sukarpyti jį kitaip.

Monologue paleidi per programų paleidimo priemonę (`Super + Space`).
