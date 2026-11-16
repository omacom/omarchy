# Grafinės programos

## Failai

Failai (Nautilus) yra grafinė failų tvarkyklė. `Super + Shift + F` ją atidaro, o `Super + Shift + Alt + F` atidaro ją kataloge, kuriame šiuo metu yra jūsų terminalas, ir tai sutaupo daug spustelėjimų. `Ctrl + L` leidžia įvesti kelią, o paspaudus `Space` ant bet kurio failo gaunate greitą peržiūrą nieko neatidarę.

Įkiškite USB atmintinę arba SD kortelę ir ji bus prijungta automatiškai, todėl tiesiog atsiras šoninėje juostoje. Jei reikia ko nors sudėtingesnio — formatuoti diską, patikrinti SMART būklę, kurti skaidinius — paleiskite _Disks_ iš programų paleidyklės (`Super + Space`).

Dvigubas spustelėjimas vadovaujasi protingais numatytaisiais nustatymais: paveikslėliai, vaizdo įrašai ir muzika atidaromi Omaview, PDF — Document Viewer, Markdown — Omawrite, o paprastas tekstas — redaktoriuje, pasirinktame _Setup > Default > Editor_.

## Disktree

Kai diskas prisipildo ir neturite supratimo, kas jį kemša, paleiskite [Disktree](https://github.com/tobi/disktree) iš programų paleidyklės (`Super + Space`). Ji rodo grafinį jūsų namų katalogo medžio žemėlapį. Didesni blokai užima daugiau vietos; į katalogus įeikite klaviatūra arba pele, pažymėkite, ką reikia pašalinti, ir prieš ką nors pašalindami peržiūrėkite savo pasirinkimus. Paleiskite `disktree --disk`, kad nuskaitytumėte visą diską.

## Obsidian

[Obsidian](https://obsidian.md/) yra nemokama ir labai išplečiama užrašų programa, saugojimui naudojanti paprastus Markdown failus.

Obsidian yra nemokama visiems tikslams, įskaitant asmeninį, komercinį ir ne pelno siekiantį naudojimą.

Obsidian taip pat siūlo [komercinį sinchronizavimo priedą](https://obsidian.md/sync) su mobiliomis programėlėmis iOS ir Android. (https://obsidian.md/pricing).

Obsidian paleidžiate su `Super + Shift + O`. Kad galėtumėte naudoti temų sinchronizavimą, nustatymuose turite pasirinkti `Omarchy` temą.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) yra pačios Omarchy sukurta be galo paprasta Markdown rašymo programa. Jokių saugyklų, jokių papildinių — tik jūs ir žodžiai.

Omawrite paleidžiate su `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) yra paprastas vaizdų redagavimo įrankis, puikiai tinkantis apkirpti, keisti dydį ir atlikti kitus paprastus veiksmus. Tik nesitikėkite Photoshop alternatyvos. Bet ji vis tiek turi Magic Wand ir sluoksnius!

Pinta paleidžiate per programų paleidyklę (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) yra temų kūrimo programa, galinti išgauti spalvas iš fono paveikslėlio ir paversti jas visaverte, darna tema. Tai lengviausias būdas [susikurti savo temą](43-making-your-own-theme.md).

Aether paleidžiate per programų paleidyklę (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) leidžia siųsti failus į kitus to paties tinklo įrenginius, kuriuose veikia ši programa, panašiai kaip Apple AirDrop. Tačiau ji veikia įvairiose platformose, todėl galite siųsti failus į Windows, macOS, Android, iOS ir, žinoma, Linux bei iš jų.

Bendrinimo meniu galite atidaryti su `Super + Ctrl + S` arba Omarchy meniu dalyje _Trigger > Share_. Jame yra keturios parinktys:

- **Clipboard** siunčia viską, ką nukopijavote, kaip tekstinį failą. Puikiai tinka, kai norite nuorodą ar teksto fragmentą nusiųsti į telefoną nesiųsdami sau el. laiško.
- **File** atidaro failų pasirinkimo langą, kuriame galite pasirinkti kelis iš karto.
- **Folder** siunčia visą katalogą.
- **Receive** atidaro pačią LocalSend, kad kitas įrenginys galėtų ką nors nusiųsti jums.

Tas pats veikia ir iš terminalo su `omarchy share clipboard`, `omarchy share file [path]` ir `omarchy share folder [path]`. Praleiskite kelią ir gausite pasirinkimo langą.

Taip pat galite siųsti tiesiai iš failų tvarkyklės: dešiniuoju pelės mygtuku spustelėkite bet kurį pasirinkimą Nautilus ir pasirinkite _Send via LocalSend_.

Omarchy užkarda pagal numatytuosius nustatymus yra uždaryta, išskyrus LocalSend prievadą, todėl tai veikia iš karto naujame įdiegime. Žr. [saugumą](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) yra visavertis biuro programų paketas su teksto rengykle, skaičiuokle, pristatymais, piešimo programa ir dar daugiau. Jis suderinamas su Microsoft Office failais, todėl tai puikus būdas atidaryti tuos Word dokumentus.

LibreOffice paleidžiate per programų paleidyklę (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) yra pačios Omarchy sukurta be galo paprasta pristatymų programa. Jūsų pristatymas yra vienas Markdown failas, o jo paveikslėliai ir vaizdo įrašai guli šalia: rašykite kiekvieną skaidrę po tiesiogine peržiūra, vilkite skaidres į norimą tvarką, tada pristatykite visame ekrane arba eksportuokite į PDF ir PowerPoint. Ji net perima jūsų Omarchy temą.

Hype paleidžiate per programų paleidyklę (`Super + Space`). Paspauskite `?` joje, kad pamatytumėte visus sparčiuosius klavišus.

## Signed

[Signed](https://github.com/omacom/signed) yra pačios Omarchy sukurtas be galo paprastas būdas pasirašyti PDF ir juos užpildyti. Padėkite išsaugotą parašą, tekstą ir šiandienos datą bet kurioje puslapio vietoje, tada išsaugokite pasirašytą kopiją šalia originalo. Kaip tai padaryti, žr. [PDF pildymas](27-filling-out-pdfs.md).

Signed paleidžiate per programų paleidyklę (`Super + Space`) arba atidarote su ja PDF iš failų tvarkyklės.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) yra pačios Omarchy sukurtas be galo paprastas skaičiuotuvas, atsidarantis slankiajame lange.

Omacalc paleidžiate su `Super + Shift + Q` (arba skaičiuotuvo klavišu, jei jūsų klaviatūra tokį turi).

## Signal

[Signal](https://signal.org/) yra E2E šifruoto susirašinėjimo pradininkė ir puikus bendravimo pasirinkimas visiems, kurie pageidauja nesinaudoti vienu iš didžiųjų technologijų konglomeratų.

Signal paleidžiate su `Super + Shift + G`. Ji nėra bazinio įdiegimo dalis, todėl pirmą kartą tai paspaudus Omarchy pasiūlys ją įdiegti už jus (ją taip pat rasite Omarchy meniu dalyje _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) yra pačios Omarchy sukurta be galo paprasta paveikslėlių peržiūros programa ir medijos leistuvas: vienas langas jūsų nuotraukoms, vaizdo įrašams ir muzikai. Atidarykite nuotrauką ir rodyklių klavišai pereis per likusius jos aplanko failus, `N` ir `P` tai daro su bet kuo, o `Ctrl + M` rodo visą aplanką kaip tinklelį. Ji rodo ir HEIC, AVIF bei JPEG XL nuotraukas, o ilgus įrašus tęsia nuo tos vietos, kurioje sustojote.

Paspauskite `F`, kad įjungtumėte visą ekraną, `E`, kad redaguotumėte paveikslėlį Omasnap arba apkirptumėte vaizdo įrašą Omacut, `Ctrl + P`, kad atspausdintumėte paveikslėlį, ir `Delete`, kad perkeltumėte failą į Šiukšlinę (`Ctrl + Z` jį sugrąžina). Paspauskite `?` joje, kad pamatytumėte visus sparčiuosius klavišus.

Omaview paleidžiate kaip _Media Viewer_ per programų paleidyklę (`Super + Space`) arba tiesiog dukart spustelėkite paveikslėlį, vaizdo įrašą ar dainą failų tvarkyklėje.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) yra pačios Omarchy sukurtas be galo paprastas vaizdo įrašų apkirpiklis. Kai tereikia nukirpti klipo pradžią ir pabaigą, jis pranoksta visaverčio vaizdo redaktoriaus paleidimą.

Omacut paleidžiate per programų paleidyklę (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) yra pačios Omarchy sukurtas be galo paprastas internetinės kameros įrašytuvas. Pasirinkite kamerą ir mikrofoną vieną kartą, tada paspauskite `Space`, kad pradėtumėte įrašyti, ir dar kartą — kad pristabdytumėte ir tęstumėte tą patį įrašą. Jis visada įrašo aukščiausia jūsų kameros raiška, su tiesioginiu mikrofono lygio matuokliu, kad prieš pradėdami galėtumėte pasitikrinti lygius.

Sustabdę įrašą, jis iš karto atsidaro integruotame redaktoriuje. Dukart spustelėkite klipą, kad jį padalintumėte, vilkite rankenėles, kad apkirptumėte kiekvieną dalį, ir pašalinkite dalis, kurių nenorite. Tada išsaugokite jį kaip MP4. Jūsų originalus įrašas išsaugomas, kol jo neišmetate, todėl visada galite sugrįžti ir sukarpyti jį kitaip.

Monologue paleidžiate per programų paleidyklę (`Super + Space`).
