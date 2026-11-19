# Grafinės programos

## Files

Files (Nautilus) yra grafinė failų tvarkyklė. `Super + Shift + F` ją atidaro, o `Super + Shift + Alt + F` atidaro ją kataloge, kuriame šiuo metu yra jūsų terminalas, todėl sutaupysite daug spustelėjimų. `Ctrl + L` leidžia įvesti kelią, o paspaudus `Space` ant bet kurio failo, bus parodyta greita peržiūra nieko neatidarant.

Prijunkite USB atmintinę arba SD kortelę ir ji bus prijungta automatiškai, todėl tiesiog atsiras šoninėje juostoje. Jei reikia ko nors sudėtingesnio — formatuoti diską, patikrinti SMART būklę, kurti skaidinius — paleiskite _Disks_ iš programų paleidyklės (`Super + Space`).

Dukart spustelėjus taikomos protingos numatytosios nuostatos: paveikslėliai, vaizdo įrašai ir muzika atidaromi programoje Omaview, PDF failai — programoje Document Viewer, Markdown — programoje Omawrite, o paprastas tekstas — redaktoriuje, pasirinktame skiltyje _Sąranka > Numatytasis > Redaktorius_.

## Disktree

Kai diskas prisipildo ir neturite supratimo, kas jį užima, paleiskite [Disktree](https://github.com/tobi/disktree) iš programų paleidyklės (`Super + Space`). Ji rodo grafinį jūsų namų katalogo medžio žemėlapį. Didesni blokai užima daugiau vietos; klaviatūra arba pele vaikščiokite po katalogus, pažymėkite, ką reikia pašalinti, ir prieš ką nors pašalindami peržiūrėkite savo pasirinkimus. Paleiskite `disktree --disk`, kad nuskaitytumėte visą diską.

## Obsidian

[Obsidian](https://obsidian.md/) yra nemokama ir labai išplečiama užrašų programa, sauganti duomenis paprastuose Markdown failuose.

Obsidian nemokama visiems tikslams, įskaitant asmeninį, komercinį ir ne pelno siekiantį naudojimą.

Obsidian taip pat siūlo [komercinį sinchronizavimo priedą](https://obsidian.md/sync), skirtą mobiliosioms programėlėms iOS ir Android sistemose. (https://obsidian.md/pricing).

Obsidian paleidžiate paspaudę `Super + Shift + O`. Norėdami naudoti temų sinchronizavimą, nustatymuose turite pasirinkti temą `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) yra pačios Omarchy sukurta itin paprasta Markdown rašymo programa. Jokių saugyklų, jokių papildinių, tik jūs ir žodžiai.

Omawrite paleidžiate paspaudę `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) yra paprastas vaizdų redagavimo įrankis, puikiai tinkantis apkarpyti, keisti dydį ir atlikti kitus paprastus veiksmus. Tik nesitikėkite Photoshop alternatyvos. Bet ji vis tiek turi Magic Wand ir sluoksnius!

Pinta paleidžiate per programų paleidyklę (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) yra temų kūrimo programa, galinti išgauti spalvas iš fono paveikslėlio ir paversti jas visaverte, darnia tema. Tai lengviausias būdas [susikurti savo temą](43-making-your-own-theme.md).

Aether paleidžiate per programų paleidyklę (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) leidžia siųsti failus į kitus įrenginius tame pačiame tinkle, kuriuose veikia ši programa, panašiai kaip Apple AirDrop. Tačiau ji veikia įvairiose platformose, todėl galite siųsti failus į Windows, macOS, Android, iOS ir, žinoma, Linux bei iš jų.

Bendrinimo meniu galite atidaryti paspaudę `Super + Ctrl + S` arba Omarchy meniu pasirinkę _Paleidiklis > Bendrinti_. Jame yra keturios parinktys:

- **Iškarpinė** siunčia viską, ką nukopijavote, kaip tekstinį failą. Puikiai tinka norint perkelti nuorodą ar kodo fragmentą į telefoną nesiunčiant sau el. laiško.
- **Failas** atidaro failų parinkiklį, kuriame galite pasirinkti kelis failus iš karto.
- **Aplankas** siunčia visą katalogą.
- **Gauti** atidaro pačią LocalSend, kad kitas įrenginys galėtų jums ką nors atsiųsti.

Tas pats veikia ir iš terminalo su `omarchy share clipboard`, `omarchy share file [path]` ir `omarchy share folder [path]`. Nenurodykite kelio ir gausite parinkiklį.

Siųsti galite ir tiesiai iš failų tvarkyklės: dešiniuoju pelės mygtuku spustelėkite bet kurį pasirinkimą programoje Nautilus ir pasirinkite _Siųsti per LocalSend_.

Omarchy ugniasienė pagal numatytuosius nustatymus yra uždaryta, išskyrus LocalSend prievadą, todėl šviežiai įdiegtoje sistemoje tai veikia iš karto. Žr. [saugumas](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) yra visavertis biuro programų paketas su teksto rengykle, skaičiuokle, pristatymais, piešimo programa ir dar daugiau. Jis suderinamas su Microsoft Office failais, todėl tai puikus būdas atidaryti tuos Word dokumentus.

LibreOffice paleidžiate per programų paleidyklę (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) yra pačios Omarchy sukurta itin paprasta pristatymų programa. Jūsų pristatymas yra vienas Markdown failas, o jo paveikslėliai ir vaizdo įrašai yra šalia jo: kiekvieną skaidrę rašykite po tiesiogine peržiūra, vilkite skaidres į norimą tvarką, tada pristatykite visame ekrane arba eksportuokite į PDF ir PowerPoint. Ji net perima jūsų Omarchy temą.

Hype paleidžiate per programų paleidyklę (`Super + Space`). Paspauskite `?` joje, kad pamatytumėte visus sparčiuosius klavišus.

## Signed

[Signed](https://github.com/omacom/signed) yra pačios Omarchy sukurtas itin paprastas būdas pasirašyti PDF failus ir juos užpildyti. Padėkite išsaugotą parašą, tekstą ir šiandienos datą bet kurioje puslapio vietoje, tada išsaugokite pasirašytą kopiją šalia originalo. Kaip tai padaryti, žr. [PDF failų pildymas](27-filling-out-pdfs.md).

Signed paleidžiate per programų paleidyklę (`Super + Space`) arba atidarote su ja PDF failą iš failų tvarkyklės.

## Game Vibes

Game Vibes, programų paleidyklėje (`Super + Space`), yra vieta, kurioje gyvena maži Omarchy žaidimai: Checkmate — 3D šachmatų žaidimas prieš draugą arba integruotą priešininką; Cards — Klondike pasiansas; ir Neon Swarm — arkadinė šaudyklė. Kiekvienas yra vienas tinklalapis, pritaikytas prie jūsų temos. Pasirinkite vieną rodyklėmis ir `Enter`, o į sąrašą grįžkite paspaudę `Esc` žaidimo pavadinimo ekrane arba `Q`, kai žaidimas pristabdytas. Jis atidaromas visame ekrane: `Super + F` paverčia jį langu, o `Super + W` jį uždaro.

Žaidimai, kuriuos sukuriate su agentu, taip pat rodomi čia: agentų skydelyje pasirinkite _Sukurti ką nors šaunaus → Žaidimas_ ir apibūdinkite vieną, arba nurodykite žaidimą, jau esantį Game Vibes, kad toliau dirbtumėte su juo. Agentas jį nukopijuoja į `~/Games/vibes`, kur galite jį keisti, ir atidaro, kai baigia. Tą kopiją galite pasidaryti patys su `omarchy games vibes copy <game>`. Žaidimas, kuriuo dalijasi kas nors kitas, įdiegiamas kaip tema: pasirinkite _Įdiegti > Žaidimai > Game Vibes_ ir įklijuokite jo git adresą arba paleiskite `omarchy games vibes install <git-repo-url>`. _Pašalinti > Žaidimai_ vėl jį pašalina, o _Atnaujinti > Game Vibes žaidimai_ paima naujas versijas. Žaidimai įkelia three.js iš interneto, todėl jiems paleisti reikia ryšio.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) yra pačios Omarchy sukurtas itin paprastas skaičiuotuvas, kuris atidaromas slankiajame lange.

Omacalc paleidžiate paspaudę `Super + Shift + Q` (arba skaičiuotuvo klavišu, jei jūsų klaviatūra tokį turi).

## Signal

[Signal](https://signal.org/) yra visiško šifravimo (E2E) susirašinėjimo pradininkas ir puikus bendravimo pasirinkimas visiems, kurie pageidauja nesinaudoti vienu iš didžiųjų technologijų konglomeratų.

Signal paleidžiate paspaudę `Super + Shift + G`. Ji nėra bazinio diegimo dalis, todėl pirmą kartą tai paspaudus, Omarchy pasiūlys ją jums įdiegti (ji taip pat yra Omarchy meniu skiltyje _Įdiegti > Paslauga_).

## Omaview

[Omaview](https://github.com/omacom/omaview) yra pačios Omarchy sukurta itin paprasta paveikslėlių peržiūros ir medijos leistuvo programa: vienas langas jūsų nuotraukoms, vaizdo įrašams ir muzikai. Atidarykite nuotrauką ir rodyklių klavišai pereis per likusius jos aplanko failus, `N` ir `P` tai daro su bet kuo, o `Ctrl + M` rodo visą aplanką kaip tinklelį. Ji taip pat rodo HEIC, AVIF ir JPEG XL nuotraukas ir tęsia nuo tos vietos, kurioje sustojote, žiūrėdami ar klausydami ką nors ilgo.

Paspauskite `F`, kad įjungtumėte visą ekraną, `E`, kad redaguotumėte paveikslėlį programoje Omasnap arba apkarpytumėte vaizdo įrašą programoje Omacut, `Ctrl + P`, kad atspausdintumėte paveikslėlį, ir `Delete`, kad perkeltumėte failą į šiukšlinę (`Ctrl + Z` jį grąžina). Paspauskite `?` joje, kad pamatytumėte visus sparčiuosius klavišus.

Omaview paleidžiate kaip _Medijos peržiūros programa_ per programų paleidyklę (`Super + Space`) arba tiesiog dukart spustelėkite paveikslėlį, vaizdo įrašą ar dainą failų tvarkyklėje.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) yra pačios Omarchy sukurtas itin paprastas vaizdo įrašų apkarpymo įrankis. Kai tereikia nukirpti klipo pradžią ir pabaigą, jis pranoksta viso vaizdo redaktoriaus paleidimą.

Omacut paleidžiate per programų paleidyklę (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) yra pačios Omarchy sukurtas itin paprastas internetinės kameros įrašymo įrankis. Vieną kartą pasirinkite kamerą ir mikrofoną, tada paspauskite `Space`, kad įrašytumėte, ir dar kartą, kad pristabdytumėte ir tęstumėte tą patį įrašą. Jis visada įrašo didžiausia jūsų kameros raiška, su tiesioginiu mikrofono lygio matuokliu, kad prieš pradėdami galėtumėte patikrinti lygius.

Sustabdykite įrašą ir jis iš karto atsidarys integruotame redaktoriuje. Dukart spustelėkite klipą, kad jį padalintumėte, vilkite rankenėles, kad apkarpytumėte kiekvieną dalį, ir pašalinkite dalis, kurių nenorite. Tada išsaugokite jį kaip MP4. Jūsų originalus įrašas saugomas tol, kol jo neatsisakysite, todėl visada galite grįžti ir apkarpyti jį kitaip.

Monologue paleidžiate per programų paleidyklę (`Super + Space`).
