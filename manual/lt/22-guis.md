# Grafinės programos

## Files

Files (Nautilus) yra grafinė failų tvarkyklė. `Super + Shift + F` ją atidaro, o `Super + Shift + Alt + F` atidaro ją kataloge, kuriame šiuo metu yra jūsų terminalas, todėl sutaupote daug spustelėjimų. `Ctrl + L` leidžia įvesti kelią, o paspaudus `Space` ant bet kurio failo gaunate greitą peržiūrą nieko neatidarę.

Prijunkite USB atmintinę arba SD kortelę ir ji bus prijungta automatiškai, tad tiesiog atsiras šoninėje juostoje. Jei reikia ko nors sudėtingesnio — formatuoti diską, patikrinti SMART būklę, kurti skaidinius — paleiskite _Disks_ iš programų paleidyklės (`Super + Space`).

Dukart spustelėjus laikomasi protingų numatytųjų nustatymų: vaizdai atidaromi su imv, vaizdo įrašai su mpv, PDF su Document Viewer, o paprastas tekstas su Neovim.

## Disktree

Kai diskas prisipildo ir neturite supratimo, kas jį ryja, paleiskite [Disktree](https://github.com/tobi/disktree) iš programų paleidyklės (`Super + Space`). Ji rodo grafinį jūsų namų katalogo medžio žemėlapį. Didesni blokai užima daugiau vietos; klaviatūra arba pele vaikščiokite po katalogus, pažymėkite, kas turi būti pašalinta, ir peržiūrėkite savo pasirinkimus prieš ką nors pašalindami. Paleiskite `disktree --disk`, kad nuskaitytumėte visą diską.

## Obsidian

[Obsidian](https://obsidian.md/) yra nemokama ir itin išplečiama užrašų programa, kuri saugojimui naudoja paprastus Markdown failus.

Obsidian yra nemokama visiems tikslams, įskaitant asmeninį, komercinį ir ne pelno siekiantį naudojimą.

Obsidian taip pat siūlo [komercinį sinchronizavimo priedą](https://obsidian.md/sync) su mobiliomis programomis iOS ir Android. (https://obsidian.md/pricing).

Obsidian paleidžiate su `Super + Shift + O`. Norėdami naudotis temų sinchronizavimu, nustatymuose turite pasirinkti `Omarchy` temą.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) yra pačios Omarchy itin paprasta Markdown rašymo programa. Jokių saugyklų, jokių papildinių, tik jūs ir žodžiai.

Omawrite paleidžiate su `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) yra paprastas vaizdų redagavimo įrankis, puikiai tinkantis apkarpyti, keisti dydį ir atlikti kitas pagrindines manipuliacijas. Tik nesitikėkite Photoshop alternatyvos. Bet ji vis tiek turi Magic Wand ir sluoksnius!

Pinta paleidžiate per programų paleidyklę (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) yra temų kūrimo programa, galinti išgauti spalvas iš fono paveikslėlio ir paversti jas visaverte, darnia tema. Tai lengviausias būdas [susikurti savo temą](43-making-your-own-theme.md).

Aether paleidžiate per programų paleidyklę (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) leidžia siųsti failus į kitus to paties tinklo įrenginius, kuriuose veikia ši programa, panašiai kaip Apple AirDrop. Tačiau ji veikia įvairiose platformose, tad galite siųsti failus į Windows, macOS, Android, iOS ir, žinoma, Linux bei iš jų.

Bendrinimo meniu galite atidaryti su `Super + Ctrl + S` arba per _Trigger > Share_ Omarchy meniu. Jis siūlo keturias parinktis:

- **Clipboard** siunčia viską, ką nukopijavote, kaip tekstinį failą. Puiku, kai reikia nuorodą ar fragmentą nusiųsti į telefoną nesiunčiant sau el. laiško.
- **File** atidaro failų parinkiklį, kuriame galite pasirinkti kelis iš karto.
- **Folder** siunčia visą katalogą.
- **Receive** atidaro tikrąją LocalSend, kad kitas įrenginys galėtų ką nors nusiųsti jums.

Tas pats veikia iš terminalo su `omarchy share clipboard`, `omarchy share file [path]` ir `omarchy share folder [path]`. Nenurodykite kelio ir gausite parinkiklį.

Taip pat galite siųsti tiesiai iš failų tvarkyklės: dešiniuoju pelės mygtuku spustelėkite bet kurį pasirinkimą Nautilus ir pasirinkite _Send via LocalSend_.

Omarchy užkarda pagal numatytuosius nustatymus yra uždaryta, išskyrus LocalSend prievadą, tad tai veikia iš karto naujai įdiegtoje sistemoje. Žr. [saugumą](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) yra visavertis biuro programų paketas su teksto redaktoriumi, skaičiuokle, pristatymais, braižymo programa ir dar daugiau. Jis suderinamas su Microsoft Office failais, tad tai puikus būdas atidaryti tuos Word dokumentus.

LibreOffice paleidžiate per programų paleidyklę (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) yra pačios Omarchy itin paprasta pristatymų programa. Jūsų pristatymas yra vienas Markdown failas, o jo paveikslėliai ir vaizdo įrašai yra šalia jo: rašykite kiekvieną skaidrę po tiesiogine peržiūra, vilkite skaidres į norimą tvarką, tada pristatykite visame ekrane arba eksportuokite į PDF ir PowerPoint. Ji net pritaiko jūsų Omarchy temą.

Hype paleidžiate per programų paleidyklę (`Super + Space`). Paspauskite `?` joje, kad pamatytumėte visus sparčiuosius klavišus.

## Signed

[Signed](https://github.com/omacom/signed) yra pačios Omarchy itin paprastas būdas pasirašyti PDF ir juos užpildyti. Įdėkite savo išsaugotą parašą, tekstą ir šiandienos datą bet kurioje puslapio vietoje, tada išsaugokite pasirašytą kopiją šalia originalo. Žr. [PDF pildymą](27-filling-out-pdfs.md), kaip tai daroma.

Signed paleidžiate per programų paleidyklę (`Super + Space`) arba atidarote su ja PDF iš failų tvarkyklės.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) yra pačios Omarchy itin paprastas skaičiuotuvas, atsidarantis slankiajame lange.

Omacalc paleidžiate su `Super + Shift + Q` (arba skaičiuotuvo klavišu, jei jūsų klaviatūra tokį turi).

## Signal

[Signal](https://signal.org/) yra E2E šifruoto susirašinėjimo pradininkė ir puikus bendravimo variantas visiems, kurie mieliau nesinaudotų vienu iš didžiųjų technologijų konglomeratų.

Signal paleidžiate su `Super + Shift + G`. Ji nėra bazinio įdiegimo dalis, tad pirmą kartą tai paspaudus Omarchy pasiūlys ją jums įdiegti (ji taip pat yra _Install > Service_ Omarchy meniu).

## mpv

[mpv](https://mpv.io/) yra paprastas, greitas medijos leistuvas, kuris paleis beveik viską iš bet kurio šaltinio. Puikiai tinka vaizdo įrašams žiūrėti.

mpv paleidžiate per programų paleidyklę (`Super + Space`) arba tiesiog dukart spustelėkite vaizdo įrašą failų tvarkyklėje.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) yra pačios Omarchy itin paprastas vaizdo įrašų apkarpytuvas. Kai tereikia nukirpti klipo pradžią ir pabaigą, jis pranoksta visaverčio vaizdo redaktoriaus paleidimą.

Omacut paleidžiate per programų paleidyklę (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) yra pačios Omarchy itin paprastas internetinės kameros įrašytuvas. Kartą pasirinkite savo kamerą ir mikrofoną, tada paspauskite `Space`, kad įrašytumėte, ir dar kartą, kad pristabdytumėte ir tęstumėte tą patį įrašą. Ji visada įrašo didžiausia jūsų kameros raiška, su tiesioginiu mikrofono lygio matuokliu, kad prieš pradėdami galėtumėte patikrinti savo lygius.

Sustabdykite įrašą ir jis iš karto atsidarys integruotame redaktoriuje. Dukart spustelėkite klipą, kad jį padalytumėte, vilkite rankenėles, kad apkarpytumėte kiekvieną dalį, ir pašalinkite dalis, kurių nenorite. Tada išsaugokite jį kaip MP4. Jūsų originalus įrašas išsaugomas, kol jo neatsisakote, tad visada galite sugrįžti ir sukirpti jį kitaip.

Monologue paleidžiate per programų paleidyklę (`Super + Space`).
