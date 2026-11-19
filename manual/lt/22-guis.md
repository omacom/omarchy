# Grafinės sąsajos

## Files

Files (Folio) yra grafinė failų tvarkyklė. `Super + Shift + F` ją atidaro, o `Super + Shift + Alt + F` atidaro ją kataloge, kuriame šiuo metu yra jūsų terminalas, o tai sutaupo daug spustelėjimų. `Ctrl + L` leidžia įvesti kelią, o paspaudus `Space` ant bet kurio failo, jis peržiūrimas visu dydžiu jo neatidarant.

Prijunkite USB atmintinę arba SD kortelę ir ji bus prijungta automatiškai, todėl tiesiog atsiras šoninėje juostoje. Jei reikia ko nors sudėtingesnio — formatuoti diską, patikrinti SMART būklę, kurti skaidinius — paleiskite _Disks_ iš programų paleidyklės (`Super + Space`).

Dukart spustelint laikomasi protingų numatytųjų parinkčių: paveikslėliai, vaizdo įrašai ir muzika atidaromi programoje Omaview, PDF — Document Viewer, Markdown — Omawrite, o paprastas tekstas — redaktoriuje, pasirinktame skiltyje _Setup > Default > Editor_.

## Disktree

Kai diskas prisipildo ir neturite supratimo, kas jį užima, paleiskite [Disktree](https://github.com/tobi/disktree) iš programų paleidyklės (`Super + Space`). Ji rodo grafinį jūsų namų katalogo medžio žemėlapį. Didesni blokai užima daugiau vietos; klaviatūra arba pele vaikščiokite po katalogus, pažymėkite, kas turi būti pašalinta, ir prieš ką nors šalindami peržiūrėkite savo pasirinkimus. Paleiskite `disktree --disk`, kad nuskaitytumėte visą diską.

## Obsidian

[Obsidian](https://obsidian.md/) yra nemokama ir labai išplečiama užrašų programa, saugojimui naudojanti paprastus Markdown failus.

Obsidian yra nemokama visiems tikslams, įskaitant asmeninį, komercinį ir ne pelno naudojimą.

Obsidian taip pat siūlo [komercinį sinchronizavimo priedą](https://obsidian.md/sync) su mobiliosiomis programėlėmis iOS ir Android sistemose. (https://obsidian.md/pricing).

Obsidian paleidžiate su `Super + Shift + O`. Norėdami naudoti temų sinchronizavimą, nustatymuose turite pasirinkti `Omarchy` temą.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) yra pačios Omarchy itin paprasta Markdown rašymo programa. Jokių saugyklų, jokių įskiepių, tik jūs ir žodžiai.

Omawrite paleidžiate su `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) yra paprastas vaizdų redagavimo įrankis, puikiai tinkantis apkarpyti, keisti dydį ir atlikti kitus paprastus veiksmus. Tik nesitikėkite Photoshop alternatyvos. Bet ji vis tiek turi Magic Wand ir sluoksnius!

Pinta paleidžiate per programų paleidyklę (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) yra temų kūrimo programa, galinti išgauti spalvas iš fono paveikslėlio ir paversti jas visaverte, darnia tema. Tai lengviausias būdas [susikurti savo temą](43-making-your-own-theme.md).

Aether paleidžiate per programų paleidyklę (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) leidžia siųsti failus į kitus to paties tinklo įrenginius, kuriuose veikia ši programa, panašiai kaip Apple AirDrop. Vis dėlto ji veikia įvairiose platformose, todėl galite siųsti failus į Windows, macOS, Android, iOS ir, žinoma, Linux bei iš jų.

Bendrinimo meniu galite atidaryti paspaudę `Super + Ctrl + S` arba Omarchy meniu skiltyje _Trigger > Share_. Jame yra keturios parinktys:

- **Clipboard** išsiunčia viską, ką nukopijavote, kaip tekstinį failą. Puikiai tinka nuorodai ar fragmentui perkelti į telefoną nesiunčiant sau el. laiško.
- **File** atidaro failų pasirinkimo langą, kuriame galite pasirinkti kelis iš karto.
- **Folder** išsiunčia visą katalogą.
- **Receive** atidaro pačią LocalSend, kad kitas įrenginys galėtų ką nors atsiųsti jums.

Tas pats veikia iš terminalo su `omarchy share clipboard`, `omarchy share file [path]` ir `omarchy share folder [path]`. Nenurodykite kelio ir gausite pasirinkimo langą.

Taip pat galite siųsti tiesiai iš failų tvarkyklės: dešiniuoju pelės mygtuku spustelėkite bet kurį pasirinkimą programoje Files ir bendrinkite jį su LocalSend.

Omarchy ugniasienė pagal numatytuosius nustatymus yra uždara, išskyrus LocalSend prievadą, todėl tai veikia iš karto naujame diegime. Žr. [saugą](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) yra visavertis biuro programų paketas su tekstų rengykle, skaičiuokle, pristatymais, braižymo programa ir dar daugiau. Jis suderinamas su Microsoft Office failais, todėl tai puikus būdas atidaryti tuos Word dokumentus.

LibreOffice paleidžiate per programų paleidyklę (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) yra pačios Omarchy itin paprasta pristatymų programa. Jūsų pristatymas yra vienas Markdown failas, o jo paveikslėliai ir vaizdo įrašai yra šalia: rašykite kiekvieną skaidrę po tiesiogine peržiūra, vilkdami išdėstykite skaidres norima tvarka, tada pristatykite visame ekrane arba eksportuokite į PDF ir PowerPoint. Ji netgi perima jūsų Omarchy temą.

Hype paleidžiate per programų paleidyklę (`Super + Space`). Paspauskite `?` joje, kad pamatytumėte visus sparčiuosius klavišus.

## Signed

[Signed](https://github.com/omacom/signed) yra pačios Omarchy itin paprastas būdas pasirašyti PDF failus ir juos užpildyti. Padėkite išsaugotą parašą, tekstą ir šiandienos datą bet kurioje puslapio vietoje, tada išsaugokite pasirašytą kopiją šalia originalo. Kaip tai padaryti, žr. [PDF failų pildymas](27-filling-out-pdfs.md).

Signed paleidžiate per programų paleidyklę (`Super + Space`) arba atidarote su ja PDF iš failų tvarkyklės.

## Game Vibes

Game Vibes, programų paleidyklėje (`Super + Space`), yra vieta, kurioje gyvena maži Omarchy žaidimai: Checkmate, 3D šachmatų žaidimas prieš draugą arba integruotą priešininką; Cards, Klondike pasjansas; ir Neon Swarm, arkadinė šaudyklė. Kiekvienas yra vienas tinklalapis, derantis prie jūsų temos. Pasirinkite vieną rodyklėmis ir `Enter`, o į sąrašą grįžkite paspaudę `Esc` žaidimo pavadinimo ekrane arba `Q`, kai jis pristabdytas. Jis atidaromas visame ekrane: `Super + F` paverčia jį langu, o `Super + W` jį uždaro.

Žaidimai, kuriuos sukuriate su agentu, taip pat atsiranda čia: agentų skydelyje pasirinkite _Make something cool → Game_ ir aprašykite žaidimą arba nurodykite žaidimą, jau esantį Game Vibes, kad toliau su juo dirbtumėte. Agentas nukopijuoja jį į `~/Games/vibes`, kur galite jį keisti kaip savą, ir atidaro jį, kai baigia. Tą kopiją galite pasidaryti patys su `omarchy games vibes copy <game>`. Žaidimas, kuriuo pasidalija kas nors kitas, įdiegiamas kaip tema: pasirinkite _Install > Gaming > Game Vibes_ ir įklijuokite jo git adresą arba paleiskite `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ vėl jį pašalina, o _Update > Game Vibes Games_ atsisiunčia naujas versijas. Žaidimai įkelia three.js iš interneto, todėl jiems pradėti reikia ryšio.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) yra pačios Omarchy itin paprastas skaičiuotuvas, atsidarantis slankiajame lange.

Omacalc paleidžiate su `Super + Shift + Q` (arba skaičiuotuvo klavišu, jei jūsų klaviatūra tokį turi).

## Signal

[Signal](https://signal.org/) yra E2E šifruoto susirašinėjimo pradininkė ir puikus bendravimo pasirinkimas visiems, kurie pageidauja nesinaudoti vienu iš didžiųjų technologijų konglomeratų.

Signal paleidžiate su `Super + Shift + G`. Ji nėra bazinio diegimo dalis, todėl pirmą kartą paspaudus šį derinį, Omarchy pasiūlys ją įdiegti už jus (ji taip pat yra Omarchy meniu skiltyje _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) yra pačios Omarchy itin paprasta paveikslėlių peržiūros programa ir medijos leistuvas: vienas langas jūsų nuotraukoms, vaizdo įrašams ir muzikai. Atidarykite nuotrauką ir rodyklių klavišai pereina likusį jos aplanką, `N` ir `P` tai daro su bet kuo, o `Ctrl + M` rodo visą aplanką kaip tinklelį. Ji taip pat rodo HEIC, AVIF ir JPEG XL nuotraukas ir tęsia nuo tos vietos, kurioje sustojote grodami ką nors ilgo.

Paspauskite `F`, kad įjungtumėte visą ekraną, `E`, kad redaguotumėte paveikslėlį programoje Omasnap arba apkarpytumėte vaizdo įrašą programoje Omacut, `Ctrl + P`, kad atspausdintumėte paveikslėlį, ir `Delete`, kad perkeltumėte failą į Trash (`Ctrl + Z` jį sugrąžina). Paspauskite `?` programoje, kad pamatytumėte visus sparčiuosius klavišus.

Omaview paleidžiate kaip _Media Viewer_ per programų paleidyklę (`Super + Space`) arba tiesiog dukart spustelėkite paveikslėlį, vaizdo įrašą ar dainą failų tvarkyklėje.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) yra pačios Omarchy itin paprastas vaizdo įrašų apkarpymo įrankis. Kai tereikia nukirpti klipo pradžią ir pabaigą, jis pranoksta visaverčio vaizdo redaktoriaus paleidimą.

Omacut paleidžiate per programų paleidyklę (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) yra pačios Omarchy itin paprastas internetinės kameros įrašymo įrankis. Vieną kartą pasirinkite kamerą ir mikrofoną, tada paspauskite `Space`, kad įrašytumėte, ir dar kartą, kad pristabdytumėte ir tęstumėte tą patį įrašą. Jis visada įrašo didžiausia jūsų kameros raiška, su tiesioginiu mikrofono lygio matuokliu, kad prieš pradėdami galėtumėte patikrinti lygius.

Sustabdykite įrašą ir jis iš karto atsidarys integruotame redaktoriuje. Dukart spustelėkite klipą, kad jį padalintumėte, vilkite rankenėles, kad apkarpytumėte kiekvieną dalį, ir pašalinkite dalis, kurių nenorite. Tada išsaugokite jį kaip MP4. Originalus įrašas išsaugomas tol, kol jį atmesite, todėl visada galite grįžti ir sukirpti jį kitaip.

Monologue paleidžiate per programų paleidyklę (`Super + Space`).
