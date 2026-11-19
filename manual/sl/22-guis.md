# Grafični vmesniki

## Datoteke

Datoteke (Nautilus) so grafični upravitelj datotek. `Super + Shift + F` ga odpre, `Super + Shift + Alt + F` pa ga odpre v imeniku, v katerem je trenutno vaš terminal, kar prihrani veliko klikanja. `Ctrl + L` vam omogoči vnos poti, pritisk tipke `Space` na kateri koli datoteki pa prikaže hitri predogled, ne da bi karkoli odprli.

Priključite ključek USB ali kartico SD in samodejno se priklopi, tako da se preprosto prikaže v stranski vrstici. Za kaj zahtevnejšega — formatiranje pogona, preverjanje zdravja SMART, ustvarjanje particij — zaženite _Disks_ iz zaganjalnika aplikacij (`Super + Space`).

Dvoklik sledi smiselnim privzetim nastavitvam: slike, videi in glasba se odprejo v Omaview, PDF-ji v Document Viewer, Markdown v Omawrite, navadno besedilo pa v urejevalniku, izbranem pod _Setup > Default > Editor_.

## Disktree

Ko se pogon zapolni in nimate pojma, kaj ga žre, zaženite [Disktree](https://github.com/tobi/disktree) iz zaganjalnika aplikacij (`Super + Space`). Prikazuje grafični drevesni zemljevid vašega domačega imenika. Večji bloki zavzamejo več prostora; s tipkovnico ali miško se premikajte po imenikih, označite, kaj mora iti, in preglejte svoje izbire, preden karkoli odstranite. Zaženite `disktree --disk` za pregled celotnega diska.

## Obsidian

[Obsidian](https://obsidian.md/) je brezplačna in zelo razširljiva aplikacija za zapiske, ki za shranjevanje uporablja preproste datoteke Markdown.

Obsidian je brezplačen za vse namene, vključno z osebno, komercialno in neprofitno uporabo.

Obsidian ponuja tudi [komercialni dodatek za sinhronizacijo](https://obsidian.md/sync) z mobilnimi aplikacijami v sistemih iOS in Android. (https://obsidian.md/pricing).

Obsidian zaženete z `Super + Shift + O`. Za uporabo sinhronizacije tem morate v nastavitvah izbrati temo `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je Omarchyjeva lastna izjemno preprosta aplikacija za pisanje v Markdownu. Brez trezorjev, brez vtičnikov, samo vi in besede.

Omawrite zaženete z `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovno orodje za urejanje slik, odlično za obrezovanje, spreminjanje velikosti in druge osnovne obdelave. Samo ne pričakujte alternative za Photoshop. Pa še vedno ima Magic Wand in plasti!

Pinta zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme, ki lahko iz slike ozadja izvleče barve in jih pretvori v celovito, skladno temo. To je najlažji način, da [ustvarite lastno temo](43-making-your-own-theme.md).

Aether zaženete prek zaganjalnika aplikacij (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vam omogoča pošiljanje datotek drugim napravam v istem omrežju, v katerih teče aplikacija, podobno kot Apple AirDrop. Vendar deluje na več platformah, tako da lahko datoteke pošiljate v Windows, macOS, Android, iOS in seveda Linux ter iz njih.

Meni Share odprete z `Super + Ctrl + S` ali pod _Trigger > Share_ v meniju Omarchy. Ponuja vam štiri možnosti:

- **Clipboard** pošlje vse, kar ste kopirali, kot besedilno datoteko. Odlično za prenos povezave ali izseka na telefon, ne da bi si pošiljali e-pošto.
- **File** odpre izbirnik datotek, v katerem lahko izberete več datotek hkrati.
- **Folder** pošlje celoten imenik.
- **Receive** odpre pravi LocalSend, tako da vam lahko druga naprava nekaj pošlje.

Enako deluje iz terminala z `omarchy share clipboard`, `omarchy share file [path]` in `omarchy share folder [path]`. Če izpustite pot, dobite izbirnik.

Pošiljate lahko tudi neposredno iz upravitelja datotek: z desno tipko kliknite poljubno izbiro v Nautilusu in izberite _Send via LocalSend_.

Požarni zid v Omarchy je privzeto zaprt, razen za vrata LocalSend, tako da to deluje takoj po sveži namestitvi. Glejte [varnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je celovit pisarniški paket z urejevalnikom besedil, preglednico, predstavitvami, aplikacijo za risanje in še čim. Združljiv je z datotekami iz Microsoft Office, tako da je to odličen način za odpiranje tistih Wordovih dokumentov.

LibreOffice zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je Omarchyjeva lastna izjemno preprosta aplikacija za predstavitve. Vaša predstavitev je ena sama datoteka Markdown s slikami in videi ob njej: vsak diapozitiv napišite pod predogledom v živo, diapozitive povlecite v ustrezen vrstni red, nato predstavite čez cel zaslon ali izvozite v PDF in PowerPoint. Prevzame celo vašo temo Omarchy.

Hype zaženete prek zaganjalnika aplikacij (`Super + Space`). Pritisnite `?` v aplikaciji, da vidite vse bližnjice.

## Signed

[Signed](https://github.com/omacom/signed) je Omarchyjev lastni izjemno preprost način za podpisovanje PDF-jev in njihovo izpolnjevanje. Shranjeni podpis, besedilo in današnji datum postavite kamorkoli na strani, nato shranite podpisano kopijo ob izvirniku. Kako to storite, glejte v [Izpolnjevanje PDF-jev](27-filling-out-pdfs.md).

Signed zaženete prek zaganjalnika aplikacij (`Super + Space`) ali pa z njim odprete PDF iz upravitelja datotek.

## Game Vibes

Game Vibes v zaganjalniku aplikacij (`Super + Space`) je prostor, kjer živijo majhne igre Omarchy: Checkmate, 3D igra šaha proti prijatelju ali vgrajenemu nasprotniku; Cards, pasjansa Klondike; in Neon Swarm, arkadna streljačina. Vsaka je ena sama spletna stran, ki sledi vaši temi. Eno izberete s puščicami in `Enter`, na seznam pa se vrnete z `Esc` z naslovnega zaslona igre ali s `Q`, ko je igra v premoru. Odpre se čez cel zaslon: `Super + F` jo spremeni v okno, `Super + W` pa jo zapre.

Tudi igre, ki jih ustvarite z agentom, se prikažejo tukaj: v plošči agentov izberite _Make something cool → Game_ in eno opišite, ali pa poimenujte igro, ki je že v Game Vibes, da nadaljujete delo na njej. Agent jo kopira v `~/Games/vibes`, kjer jo lahko spreminjate po svoje, in jo odpre, ko konča. To kopijo lahko ustvarite sami z `omarchy games vibes copy <game>`. Igra, ki jo deli nekdo drug, se namesti kot tema: izberite _Install > Gaming > Game Vibes_ in prilepite njen naslov git ali zaženite `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ igro spet odstrani, _Update > Game Vibes Games_ pa prenese nove različice. Igre naložijo three.js s spleta, zato za zagon potrebujejo povezavo.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je Omarchyjev lastni izjemno preprost kalkulator, ki se odpre v plavajočem oknu.

Omacalc zaženete z `Super + Shift + Q` (ali s tipko za kalkulator, če jo vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir sporočanja s šifriranjem E2E in odlična komunikacijska možnost za vse, ki raje ne bi šli prek enega od velikih tehnoloških konglomeratov.

Signal zaženete z `Super + Shift + G`. Ni del osnovne namestitve, zato vam bo Omarchy ob prvem pritisku te kombinacije ponudil, da ga namesti namesto vas (na voljo je tudi pod _Install > Service_ v meniju Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je Omarchyjev lastni izjemno preprost pregledovalnik slik in predvajalnik medijev: eno okno za vaše fotografije, videe in glasbo. Odprite fotografijo in puščične tipke vas premikajo po preostanku njene mape, `N` in `P` to storita za karkoli, `Ctrl + M` pa prikaže celotno mapo kot mrežo. Prikazuje tudi fotografije HEIC, AVIF in JPEG XL ter nadaljuje tam, kjer ste končali, pri čemerkoli dolgem.

Pritisnite `F` za celozaslonski način, `E` za urejanje slike v Omasnap ali obrezovanje videa v Omacut, `Ctrl + P` za tiskanje slike in `Delete` za premik datoteke v Trash (`Ctrl + Z` jo vrne). Pritisnite `?` v aplikaciji, da vidite vse bližnjice.

Omaview zaženete kot _Media Viewer_ prek zaganjalnika aplikacij (`Super + Space`) ali pa v upravitelju datotek preprosto dvokliknete sliko, video ali pesem.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je Omarchyjev lastni izjemno preprost obrezovalnik videov. Ko morate odrezati le začetek in konec posnetka, je to boljše, kot da zaženete celoten urejevalnik videov.

Omacut zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je Omarchyjev lastni izjemno preprost snemalnik s spletno kamero. Enkrat izberite kamero in mikrofon, nato pritisnite `Space` za snemanje in še enkrat za premor in nadaljevanje istega posnetka. Vedno snema pri najvišji ločljivosti vaše kamere, z merilnikom mikrofona v živo, tako da lahko pred začetkom preverite ravni.

Ustavite posnetek in takoj se odpre v vgrajenem urejevalniku. Dvokliknite posnetek, da ga razdelite, povlecite ročice za obrezovanje vsakega dela in odstranite dele, ki jih ne želite. Nato ga shranite kot MP4. Izvirni posnetek se hrani, dokler ga ne zavržete, tako da se lahko vedno vrnete in ga odrežete drugače.

Monologue zaženete prek zaganjalnika aplikacij (`Super + Space`).
