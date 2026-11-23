# Grafični vmesniki

## Files

Files (Folio) je grafični upravitelj datotek. `Super + Shift + F` ga odpre, `Super + Shift + Alt + F` pa ga odpre v imeniku, v katerem je trenutno tvoj terminal, kar prihrani veliko klikanja. S `Ctrl + L` lahko vtipkaš pot, s pritiskom na `Space` na kateri koli datoteki pa si jo ogledaš v polni velikosti, ne da bi jo odprl.

Priključi ključ USB ali kartico SD in samodejno se priklopi, tako da se kar pojavi v stranski vrstici. Za kaj zahtevnejšega — formatiranje pogona, preverjanje zdravja SMART, ustvarjanje particij — zaženi _Disks_ iz zaganjalnika aplikacij (`Super + Space`).

Dvoklik sledi smiselnim privzetim nastavitvam: slike, videi in glasba se odprejo v Omaview, dokumenti PDF v Document Viewer, Markdown v Omawrite, navadno besedilo pa v tvojem urejevalniku, Plain, razen če pod _Setup > Defaults > Editor_ izbereš drugega.

## Disktree

Ko se pogon napolni in nimaš pojma, kaj ga žre, zaženi [Disktree](https://github.com/tobi/disktree) iz zaganjalnika aplikacij (`Super + Space`). Pokaže grafični drevesni zemljevid tvojega domačega imenika. Večji bloki zavzamejo več prostora; po imenikih se sprehodi s tipkovnico ali miško, označi, kaj mora iti, in preglej svoje izbire, preden kar koli odstraniš. Zaženi `disktree --disk`, da pregledaš celoten disk.

## Obsidian

[Obsidian](https://obsidian.md/) je brezplačna in zelo razširljiva aplikacija za zapiske, ki za shranjevanje uporablja preproste datoteke Markdown.

Obsidian je brezplačen za vse namene, vključno z osebno, komercialno in neprofitno uporabo.

Obsidian ponuja tudi [komercialni dodatek za sinhronizacijo](https://obsidian.md/sync) z mobilnimi aplikacijami v sistemih iOS in Android. (https://obsidian.md/pricing).

Obsidian zaženeš s `Super + Shift + O`. Za uporabo sinhronizacije tem moraš v nastavitvah izbrati temo `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je Omarchyjeva lastna izjemno preprosta aplikacija za pisanje v Markdownu. Brez trezorjev, brez vtičnikov, samo ti in besede.

Omawrite zaženeš s `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovno orodje za urejanje slik, ki je odlično za obrezovanje, spreminjanje velikosti in druge osnovne obdelave. Samo ne pričakuj alternative za Photoshop. Ampak ima vseeno Magic Wand in plasti!

Pinto zaženeš prek zaganjalnika aplikacij (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme, ki lahko iz slike ozadja izvleče barve in jih spremeni v popolno, skladno temo. To je najlažji način, da [izdelaš svojo temo](43-making-your-own-theme.md).

Aether zaženeš prek zaganjalnika aplikacij (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ti omogoča pošiljanje datotek drugim napravam v istem omrežju, v katerih teče aplikacija, kot Apple AirDrop. Je pa medplatformski, tako da lahko datoteke pošiljaš v Windows, macOS, Android, iOS in seveda Linux ter z njih.

Meni Share lahko odpreš s `Super + Ctrl + S` ali pod _Trigger > Share_ v meniju Omarchy. Ponudi ti štiri možnosti:

- **Clipboard** pošlje vse, kar si kopiral, kot besedilno datoteko. Odlično za to, da povezavo ali izsek spraviš na telefon, ne da bi si pošiljal e-pošto.
- **File** odpre izbirnik datotek, kjer lahko naenkrat izbereš več datotek.
- **Folder** pošlje celoten imenik.
- **Receive** odpre pravi LocalSend, da ti lahko druga naprava kaj pošlje.

Enako deluje iz terminala z `omarchy share clipboard`, `omarchy share file [path]` in `omarchy share folder [path]`. Če pot izpustiš, dobiš izbirnik.

Pošiljaš lahko tudi neposredno iz upravitelja datotek: v Files z desno tipko klikni katero koli izbiro in jo deli z LocalSend.

Požarni zid v Omarchy je privzeto zaprt, razen za vrata LocalSend, zato to deluje takoj po sveži namestitvi. Glej [varnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je popoln pisarniški paket z urejevalnikom besedil, preglednicami, predstavitvami, aplikacijo za risanje in še več. Združljiv je z datotekami iz Microsoft Office, zato je to odličen način, da lahko odpreš tiste dokumente Word.

LibreOffice zaženeš prek zaganjalnika aplikacij (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je Omarchyjeva lastna izjemno preprosta aplikacija za predstavitve. Tvoja predstavitev je ena sama datoteka Markdown, ob njej pa so njene slike in videi: vsak diapozitiv napiši pod predogledom v živo, diapozitive povleci v vrstni red, nato predstavljaj čez cel zaslon ali izvozi v PDF in PowerPoint. Prevzame celo tvojo temo Omarchy.

Hype zaženeš prek zaganjalnika aplikacij (`Super + Space`). V njem pritisni `?`, da vidiš vse bližnjice.

## Signed

[Signed](https://github.com/omacom/signed) je Omarchyjev lastni izjemno preprost način za podpisovanje dokumentov PDF in njihovo izpolnjevanje. Svoj shranjeni podpis, besedilo in današnji datum postavi kamor koli na stran, nato shrani podpisano kopijo ob izvirnik. Kako to gre, glej [Izpolnjevanje dokumentov PDF](27-filling-out-pdfs.md).

Signed zaženeš prek zaganjalnika aplikacij (`Super + Space`) ali z njim odpreš PDF iz upravitelja datotek.

## Game Vibes

Game Vibes je v zaganjalniku aplikacij (`Super + Space`) kraj, kjer živijo Omarchyjeve majhne igre: Checkmate, 3D igra šaha proti prijatelju ali vgrajenemu nasprotniku; Cards, pasjansa Klondike; Death Wish, na piksel natančna ploščadna igra z desetimi sobami, polnimi konic in žag; in Neon Swarm, arkadna streljačina. Vsaka je ena sama spletna stran, ki sledi tvoji temi. Eno izberi s puščicami in `Enter`, na seznam pa se vrni z `Esc` z naslovnega zaslona igre ali s `Q`, ko je začasno ustavljena. Odpre se čez cel zaslon: s `Super + F` postane okno, s `Super + W` pa jo zapreš.

Tudi igre, ki jih narediš z agentom, se pokažejo tukaj: v plošči z agenti izberi _Make something cool → Game_ in eno opiši ali pa poimenuj igro, ki je že v Game Vibes, da nadaljuješ delo na njej. Agent jo kopira v `~/Games/vibes`, kjer je tvoja, da jo spreminjaš, in jo odpre, ko je končana. To kopijo lahko narediš sam z `omarchy games vibes copy <game>`. Igra, ki jo deli nekdo drug, se namesti kot tema: izberi _Install > Gaming > Game Vibes_ in prilepi njen naslov git ali zaženi `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ eno spet odstrani, _Update > Game Vibes Games_ pa prenese nove različice. Igre naložijo three.js s spleta, zato za zagon potrebujejo povezavo.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je Omarchyjev lastni izjemno preprost kalkulator, ki se odpre v plavajočem oknu.

Omacalc zaženeš s `Super + Shift + Q` (ali s tipko za kalkulator, če jo tvoja tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir sporočanja s šifriranjem E2E in odlična možnost komunikacije za vsakogar, ki raje ne bi šel prek enega od velikih tehnoloških konglomeratov.

Signal zaženeš s `Super + Shift + G`. Ni del osnovne namestitve, zato ti bo Omarchy ob prvem pritisku te kombinacije ponudil, da ga namesti zate (najdeš ga tudi pod _Install > Service_ v meniju Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je Omarchyjev lastni izjemno preprost pregledovalnik slik in predvajalnik medijev: eno okno za tvoje fotografije, videe in glasbo. Odpri fotografijo in puščične tipke te pomikajo po preostalih datotekah v njeni mapi, `N` in `P` to naredita za kar koli, `Ctrl + M` pa pokaže celotno mapo kot mrežo. Pokaže tudi fotografije HEIC, AVIF in JPEG XL ter nadaljuje tam, kjer si končal pri čem dolgem.

Pritisni `F` za celozaslonski način, `E` za urejanje slike v Omasnap ali obrezovanje videa v Omacut, `Ctrl + P` za tiskanje slike in `Delete`, da datoteko premakneš v Trash (`Ctrl + Z` jo vrne nazaj). V njem pritisni `?`, da vidiš vse bližnjice.

Omaview zaženeš kot _Media Viewer_ prek zaganjalnika aplikacij (`Super + Space`) ali pa preprosto dvoklikneš sliko, video ali pesem v upravitelju datotek.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je Omarchyjev lastni izjemno preprost obrezovalnik videov. Kadar potrebuješ le odrezati začetek in konec posnetka, premaga zaganjanje polnega urejevalnika videov.

Omacut zaženeš prek zaganjalnika aplikacij (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je Omarchyjev lastni izjemno preprost snemalnik s spletno kamero. Enkrat izberi kamero in mikrofon, nato pritisni `Space` za snemanje in znova za premor ter nadaljevanje istega posnetka. Vedno snema v najvišji ločljivosti tvoje kamere, z merilnikom mikrofona v živo, da lahko pred začetkom preveriš svoje ravni.

Ustavi posnetek in takoj se odpre v vgrajenem urejevalniku. Dvoklikni posnetek, da ga razdeliš, povleci ročice, da obrežeš vsak kos, in odstrani dele, ki jih nočeš. Nato ga shrani kot MP4. Tvoj izvirni posnetek se hrani, dokler ga ne zavržeš, zato se lahko vedno vrneš in ga odrežeš drugače.

Monologue zaženeš prek zaganjalnika aplikacij (`Super + Space`).
