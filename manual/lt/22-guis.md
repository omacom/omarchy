# Grafinės programos

## Failai

Files (Nautilus) yra grafinė failų tvarkyklė. `Super + Shift + F` ją atidaro, o `Super + Shift + Alt + F` atidaro ją kataloge, kuriame šiuo metu yra jūsų terminalas, todėl sutaupoma daug spustelėjimų. `Ctrl + L` leidžia įvesti kelią, o paspaudus `Space` ant bet kurio failo gaunama greita peržiūra nieko neatidarant.

Prijunkite USB atmintinę arba SD kortelę ir ji bus prijungta automatiškai, todėl tiesiog atsiras šoninėje juostoje. Jei reikia ko nors sudėtingesnio — formatuoti diską, patikrinti SMART būklę, kurti skaidinius — paleiskite _Disks_ iš programų paleidyklės (`Super + Space`).

Dukart spustelėjus taikomos protingos numatytosios parinktys: paveikslėliai, vaizdo įrašai ir muzika atidaromi programoje Omaview, PDF failai — Document Viewer, o paprastas tekstas — Neovim.

## Disktree

Kai diskas prisipildo ir neturite supratimo, kas jį užima, paleiskite [Disktree](https://github.com/tobi/disktree) iš programų paleidyklės (`Super + Space`). Ji rodo grafinį jūsų namų katalogo medžio žemėlapį. Didesni blokai užima daugiau vietos; klaviatūra arba pele vaikščiokite po katalogus, pažymėkite, ką reikia pašalinti, ir prieš ką nors šalindami peržiūrėkite savo pasirinkimus. Paleiskite `disktree --disk`, kad nuskaitytumėte visą diską.

## Obsidian

[Obsidian](https://obsidian.md/) yra nemokama ir labai išplečiama užrašų programa, saugojimui naudojanti paprastus Markdown failus.

Obsidian yra nemokama visiems tikslams, įskaitant asmeninį, komercinį ir ne pelno siekiantį naudojimą.

Obsidian taip pat siūlo [komercinį sinchronizavimo priedą](https://obsidian.md/sync) su mobiliosiomis programėlėmis iOS ir Android. (https://obsidian.md/pricing).

Obsidian paleidžiate paspaudę `Super + Shift + O`. Norėdami naudoti temų sinchronizavimą, nustatymuose turite pasirinkti `Omarchy` temą.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) yra itin paprasta pačios Omarchy Markdown rašymo programa. Jokių saugyklų, jokių papildinių, tik jūs ir žodžiai.

Omawrite paleidžiate paspaudę `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) yra paprastas vaizdų redagavimo įrankis, puikiai tinkantis apkarpyti, keisti dydį ir atlikti kitus paprastus veiksmus. Tik nesitikėkite Photoshop alternatyvos. Bet ji vis tiek turi Magic Wand ir sluoksnius!

Pinta paleidžiate per programų paleidyklę (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) yra temų kūrimo programa, galinti išgauti spalvas iš fono paveikslėlio ir paversti jas visaverte, darna tema. Tai lengviausias būdas [susikurti savo temą](43-making-your-own-theme.md).

Aether paleidžiate per programų paleidyklę (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) leidžia siųsti failus į kitus to paties tinklo įrenginius, kuriuose veikia ši programa, panašiai kaip Apple AirDrop. Tačiau ji veikia įvairiose platformose, todėl galite siųsti failus į Windows, macOS, Android, iOS ir, žinoma, Linux bei iš jų.

Bendrinimo meniu galite atidaryti paspaudę `Super + Ctrl + S` arba Omarchy meniu pasirinkę _Trigger > Share_. Jame yra keturios parinktys:

- **Clipboard** siunčia viską, ką nukopijavote, kaip tekstinį failą. Puikiai tinka norint perkelti nuorodą ar fragmentą į telefoną nesiunčiant sau el. laiško.
- **File** atidaro failų pasirinkimo langą, kuriame galite pasirinkti kelis iš karto.
- **Folder** siunčia visą katalogą.
- **Receive** atidaro pačią LocalSend, kad kitas įrenginys galėtų ką nors atsiųsti jums.

Tą patį galite padaryti iš terminalo naudodami `omarchy share clipboard`, `omarchy share file [path]` ir `omarchy share folder [path]`. Nenurodykite kelio ir gausite pasirinkimo langą.

Taip pat galite siųsti tiesiai iš failų tvarkyklės: Nautilus dešiniuoju pelės mygtuku spustelėkite bet kurį pasirinkimą ir pasirinkite _Send via LocalSend_.

Omarchy ugniasienė pagal numatytuosius nustatymus yra uždaryta, išskyrus LocalSend prievadą, todėl tai veikia iš karto naujai įdiegtoje sistemoje. Žr. [saugumą](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) yra visavertis biuro programų paketas su teksto rengykle, skaičiuokle, pristatymais, piešimo programa ir dar daugiau. Jis suderinamas su Microsoft Office failais, todėl tai puikus būdas atidaryti tuos Word dokumentus.

LibreOffice paleidžiate per programų paleidyklę (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) yra itin paprasta pačios Omarchy pristatymų programa. Jūsų pristatymas yra vienas Markdown failas su greta esančiais paveikslėliais ir vaizdo įrašais: rašykite kiekvieną skaidrę po tiesiogine peržiūra, vilkite skaidres į norimą tvarką, tada pristatykite visame ekrane arba eksportuokite į PDF ir PowerPoint. Ji netgi perima jūsų Omarchy temą.

Hype paleidžiate per programų paleidyklę (`Super + Space`). Paspauskite `?` programoje, kad pamatytumėte visus sparčiuosius klavišus.

## Signed

[Signed](https://github.com/omacom/signed) yra itin paprastas pačios Omarchy būdas pasirašyti PDF failus ir juos užpildyti. Įdėkite savo išsaugotą parašą, tekstą ir šiandienos datą bet kurioje puslapio vietoje, tada išsaugokite pasirašytą kopiją šalia originalo. Kaip tai padaryti, žr. [PDF failų pildymas](27-filling-out-pdfs.md).

Signed paleidžiate per programų paleidyklę (`Super + Space`) arba atidarote PDF failą su ja iš failų tvarkyklės.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) yra itin paprastas pačios Omarchy skaičiuotuvas, atsidarantis slankiajame lange.

Omacalc paleidžiate paspaudę `Super + Shift + Q` (arba skaičiuotuvo klavišą, jei jūsų klaviatūra tokį turi).

## Signal

[Signal](https://signal.org/) yra E2E šifruoto susirašinėjimo pradininkė ir puikus bendravimo pasirinkimas visiems, kurie nenori naudotis vienu iš didžiųjų technologijų konglomeratų.

Signal paleidžiate paspaudę `Super + Shift + G`. Ji nėra bazinio diegimo dalis, todėl pirmą kartą tai paspaudus Omarchy pasiūlys ją įdiegti už jus (ji taip pat yra Omarchy meniu dalyje _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) yra itin paprasta pačios Omarchy paveikslėlių peržiūros programa ir medijos leistuvas: vienas langas jūsų nuotraukoms, vaizdo įrašams ir muzikai. Atidarykite nuotrauką ir rodyklių klavišai peržiūrės likusias jos aplanko nuotraukas, `N` ir `P` tai daro su bet kuo, o `Ctrl + M` rodo visą aplanką kaip tinklelį. Ji taip pat rodo HEIC, AVIF ir JPEG XL nuotraukas ir tęsia nuo tos vietos, kurioje sustojote, bet kokiame ilgame įraše.

Paspauskite `F`, kad įjungtumėte visą ekraną, `E`, kad redaguotumėte paveikslėlį programoje Omasnap arba apkarpytumėte vaizdo įrašą programoje Omacut, `Ctrl + P`, kad atspausdintumėte paveikslėlį, ir `Delete`, kad perkeltumėte failą į Trash (`Ctrl + Z` jį sugrąžina). Paspauskite `?` programoje, kad pamatytumėte visus sparčiuosius klavišus.

Omaview paleidžiate kaip _Media Viewer_ per programų paleidyklę (`Super + Space`) arba tiesiog dukart spustelėkite paveikslėlį, vaizdo įrašą ar dainą failų tvarkyklėje.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) yra itin paprastas pačios Omarchy vaizdo įrašų karpytuvas. Kai jums tereikia nukirpti klipo pradžią ir pabaigą, tai geriau nei paleidinėti visavertį vaizdo redaktorių.

Omacut paleidžiate per programų paleidyklę (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) yra itin paprastas pačios Omarchy internetinės kameros įrašytuvas. Vieną kartą pasirinkite kamerą ir mikrofoną, tada paspauskite `Space`, kad įrašytumėte, ir dar kartą, kad pristabdytumėte ir tęstumėte tą patį įrašą. Jis visada įrašo didžiausia jūsų kameros skiriamąja geba, su tiesioginiu mikrofono lygio matuokliu, kad prieš pradėdami galėtumėte patikrinti lygius.

Sustabdykite įrašą ir jis iš karto atsidarys integruotame redaktoriuje. Dukart spustelėkite klipą, kad jį padalytumėte, vilkite rankenėles, kad apkarpytumėte kiekvieną dalį, ir pašalinkite nenorimas dalis. Tada išsaugokite jį kaip MP4. Jūsų originalus įrašas saugomas tol, kol jo neišmetate, todėl visada galite sugrįžti ir sukirpti jį kitaip.

Monologue paleidžiate per programų paleidyklę (`Super + Space`).
