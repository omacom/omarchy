# Grafinės sąsajos

## Files

Files (Folio) yra grafinė failų tvarkyklė. `Super + Shift + F` ją atidaro, o `Super + Shift + Alt + F` atidaro ją kataloge, kuriame šiuo metu yra jūsų terminalas, ir tai sutaupo daug spustelėjimų. `Ctrl + L` leidžia įvesti kelią, o paspaudus `Space` ant bet kurio failo, jis peržiūrimas visu dydžiu jo neatidarant.

Prijunkite USB atmintinę ar SD kortelę ir ji automatiškai prijungiama, todėl tiesiog atsiranda šoninėje juostoje. Jei reikia ko nors sudėtingesnio — formatuoti diską, patikrinti SMART būklę, kurti skaidinius — paleiskite _Disks_ iš programų paleidyklės (`Super + Space`).

Šifruotas diskas jį prijungus paprašo slaptažodžio. Kad diskas atsirakintų pats, pridėkite prie jo raktinį failą komanda `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` ir įdėkite tą raktinį failą į `~/.config/omarchy/drive-keys/<UUID>`, pavadintą pagal UUID, kurį šifruotam skaidiniui išspausdina `lsblk -dno UUID /dev/sdX1`, ir prieinamą tik jums (`chmod 600`). Jei to raktinio failo trūksta arba jis atmetamas, jūsų kaip įprasta paprašoma slaptažodžio.

Dukart spustelėjus taikomos protingos numatytosios parinktys: paveikslėliai, vaizdo įrašai ir muzika atidaromi programoje Omaview, PDF — programoje Document Viewer, Markdown — programoje Omawrite, o paprastas tekstas — jūsų redaktoriuje, Plain, nebent skiltyje _Setup > Defaults > Editor_ pasirinksite kitą.

## Disktree

Kai diskas prisipildo ir neturite supratimo, kas jį ryja, paleiskite [Disktree](https://github.com/tobi/disktree) iš programų paleidyklės (`Super + Space`). Ji rodo grafinį jūsų namų katalogo medžio žemėlapį. Didesni blokai užima daugiau vietos; klaviatūra ar pele eikite į katalogus, pažymėkite, ką reikia pašalinti, ir prieš ką nors šalindami peržiūrėkite savo pasirinkimus. Paleiskite `disktree --disk`, kad nuskaitytumėte visą diską.

## Obsidian

[Obsidian](https://obsidian.md/) yra nemokama ir labai išplečiama užrašų programa, saugojimui naudojanti paprastus Markdown failus.

Obsidian yra nemokama visiems tikslams, įskaitant asmeninį, komercinį ir ne pelno naudojimą.

Obsidian taip pat siūlo [komercinį sinchronizavimo priedą](https://obsidian.md/sync) su mobiliosiomis programėlėmis, skirtomis iOS ir Android. (https://obsidian.md/pricing).

Obsidian paleidžiate su `Super + Shift + O`. Kad galėtumėte naudoti temų sinchronizavimą, nustatymuose turite pasirinkti `Omarchy` temą.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) yra pačios Omarchy itin paprasta Markdown rašymo programa. Jokių saugyklų, jokių papildinių, tik jūs ir žodžiai.

Omawrite paleidžiate su `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) yra paprastas paveikslėlių redagavimo įrankis, puikiai tinkantis apkarpyti, keisti dydį ir atlikti kitus pagrindinius veiksmus. Tik nesitikėkite Photoshop alternatyvos. Bet ji vis tiek turi Magic Wand ir sluoksnius!

Pinta paleidžiate per programų paleidyklę (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) yra temų kūrimo programa, galinti išgauti spalvas iš fono paveikslėlio ir paversti jas visaverte, darnia tema. Tai lengviausias būdas [susikurti savo temą](43-making-your-own-theme.md).

Aether paleidžiate per programų paleidyklę (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) leidžia siųsti failus į kitus įrenginius tame pačiame tinkle, kuriuose veikia ši programa, panašiai kaip Apple AirDrop. Vis dėlto ji veikia įvairiose platformose, todėl galite siųsti failus į Windows, macOS, Android, iOS ir, žinoma, Linux bei iš jų.

Bendrinimo meniu galite atidaryti su `Super + Ctrl + S` arba skiltyje _Trigger > Share_ Omarchy meniu. Jame yra keturios parinktys:

- **Clipboard** siunčia viską, ką nukopijavote, kaip tekstinį failą. Puiku, kai reikia nuorodą ar fragmentą nusiųsti į telefoną nesiunčiant sau el. laiško.
- **File** atidaro failų parinkiklį, kuriame galite pasirinkti kelis iš karto.
- **Folder** siunčia visą katalogą.
- **Receive** atidaro pačią LocalSend, kad kitas įrenginys galėtų ką nors nusiųsti jums.

Tą patį galima padaryti terminale komandomis `omarchy share clipboard`, `omarchy share file [path]` ir `omarchy share folder [path]`. Nenurodykite kelio ir gausite parinkiklį.

Siųsti galite ir tiesiai iš failų tvarkyklės: dešiniuoju pelės mygtuku spustelėkite bet kurį pasirinkimą programoje Files ir bendrinkite jį su LocalSend.

Omarchy užkarda pagal numatytuosius nustatymus yra uždara, išskyrus LocalSend prievadą, todėl tai veikia iš karto šviežiai įdiegtoje sistemoje. Žr. [saugumas](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) yra visavertis biuro programų rinkinys su tekstų rengykle, skaičiuokle, pristatymų programa, braižymo programa ir dar daugiau. Jis suderinamas su Microsoft Office failais, todėl tai puikus būdas atidaryti tuos Word dokumentus.

LibreOffice paleidžiate per programų paleidyklę (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) yra pačios Omarchy itin paprasta pristatymų programa. Jūsų prezentacija yra vienas Markdown failas, o šalia jo — paveikslėliai ir vaizdo įrašai: kiekvieną skaidrę rašykite po tiesiogine peržiūra, vilkite skaidres į norimą tvarką, tada pristatykite visame ekrane arba eksportuokite į PDF ir PowerPoint. Ji net perima jūsų Omarchy temą.

Hype paleidžiate per programų paleidyklę (`Super + Space`). Paspauskite `?` joje, kad pamatytumėte visus sparčiuosius klavišus.

## Signed

[Signed](https://github.com/omacom/signed) yra pačios Omarchy itin paprastas būdas pasirašyti PDF ir juos užpildyti. Įdėkite išsaugotą parašą, tekstą ir šiandienos datą bet kurioje puslapio vietoje, tada išsaugokite pasirašytą kopiją šalia originalo. Kaip tai padaryti, žr. [PDF pildymas](27-filling-out-pdfs.md).

Signed paleidžiate per programų paleidyklę (`Super + Space`) arba atidarote su ja PDF iš failų tvarkyklės.

## Game Vibes

Game Vibes, programų paleidyklėje (`Super + Space`), yra vieta, kur gyvena mažieji Omarchy žaidimai: Checkmate — 3D šachmatų žaidimas prieš draugą arba įtaisytąjį varžovą; Cards — Klondike pasjansas; Death Wish — pikselio tikslumo platforminis žaidimas su dešimčia kambarių, pilnų spyglių ir pjūklų; ir Neon Swarm — arkadinė šaudyklė. Kiekvienas yra vienas tinklalapis, kuris seka jūsų temą. Pasirinkite vieną rodyklėmis ir `Enter`, o į sąrašą grįžkite su `Esc` iš žaidimo pavadinimo ekrano arba `Q`, kai jis pristabdytas. Jis atidaromas visame ekrane: `Super + F` paverčia jį langu, o `Super + W` jį uždaro.

Žaidimai, kuriuos sukuriate su agentu, taip pat atsiranda čia: agentų skydelyje pasirinkite _Make something cool → Game_ ir aprašykite žaidimą arba įvardykite žaidimą, kuris jau yra Game Vibes, kad galėtumėte toliau su juo dirbti. Agentas nukopijuoja jį į `~/Games/vibes`, kur jis yra jūsų ir galite jį keisti, ir baigęs jį atidaro. Tą kopiją galite pasidaryti patys komanda `omarchy games vibes copy <game>`. Žaidimas, kuriuo pasidalija kas nors kitas, įdiegiamas kaip tema: pasirinkite _Install > Gaming > Game Vibes_ ir įklijuokite jo git adresą arba paleiskite `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ vėl jį pašalina, o _Update > Game Vibes Games_ atsisiunčia naujas versijas. Žaidimai įkelia three.js iš interneto, todėl jiems paleisti reikia ryšio.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) yra pačios Omarchy itin paprastas skaičiuotuvas, atidaromas slankiajame lange.

Omacalc paleidžiate su `Super + Shift + Q` (arba skaičiuotuvo klavišu, jei jūsų klaviatūra tokį turi).

## Signal

[Signal](https://signal.org/) yra E2E šifruoto susirašinėjimo pradininkas ir puikus bendravimo pasirinkimas visiems, kurie verčiau nesinaudotų vienu iš didžiųjų technologijų konglomeratų.

Signal paleidžiate su `Super + Shift + G`. Jis nėra bazinio diegimo dalis, todėl pirmą kartą paspaudus šį derinį Omarchy pasiūlys jį įdiegti už jus (jis taip pat yra skiltyje _Install > Service_ Omarchy meniu).

## Omaview

[Omaview](https://github.com/omacom/omaview) yra pačios Omarchy itin paprasta paveikslėlių peržiūros programa ir medijos leistuvas: vienas langas jūsų nuotraukoms, vaizdo įrašams ir muzikai. Atidarykite nuotrauką ir rodyklių klavišai pereis per likusius jos aplanko failus, `N` ir `P` tai daro su bet kuo, o `Ctrl + M` rodo visą aplanką kaip tinklelį. Ji taip pat rodo HEIC, AVIF ir JPEG XL nuotraukas ir tęsia nuo tos vietos, kurioje baigėte ką nors ilgo.

Paspauskite `F`, kad įjungtumėte viso ekrano režimą, `E`, kad redaguotumėte paveikslėlį programoje Omasnap arba apkarpytumėte vaizdo įrašą programoje Omacut, `Ctrl + P`, kad atsispausdintumėte paveikslėlį, ir `Delete`, kad perkeltumėte failą į šiukšlinę (`Ctrl + Z` jį sugrąžina). Paspauskite `?` joje, kad pamatytumėte visus sparčiuosius klavišus.

Omaview paleidžiate kaip _Media Viewer_ per programų paleidyklę (`Super + Space`) arba tiesiog dukart spustelėkite paveikslėlį, vaizdo įrašą ar dainą failų tvarkyklėje.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) yra pačios Omarchy itin paprastas vaizdo įrašų apkarpymo įrankis. Kai tereikia nupjauti klipo pradžią ir pabaigą, jis geriau nei paleidinėti visą vaizdo įrašų redaktorių.

Omacut paleidžiate per programų paleidyklę (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) yra pačios Omarchy itin paprastas internetinės kameros įrašymo įrankis. Kartą pasirinkite kamerą ir mikrofoną, tada paspauskite `Space`, kad įrašytumėte, ir dar kartą, kad pristabdytumėte ir tęstumėte tą patį įrašą. Jis visada įrašo didžiausia jūsų kameros raiška, su tiesioginiu mikrofono lygio matuokliu, kad prieš pradėdami galėtumėte patikrinti lygius.

Sustabdykite įrašą ir jis iškart atsidarys įtaisytajame redaktoriuje. Dukart spustelėkite klipą, kad jį padalytumėte, vilkite rankenėles, kad apkarpytumėte kiekvieną dalį, ir pašalinkite dalis, kurių nenorite. Tada išsaugokite jį kaip MP4. Jūsų originalus įrašas išsaugomas, kol jo neatsisakysite, todėl visada galite sugrįžti ir permontuoti jį kitaip.

Monologue paleidžiate per programų paleidyklę (`Super + Space`).
