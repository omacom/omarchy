# Grafični vmesniki

## Datoteke

Datoteke (Folio) so grafični upravitelj datotek. `Super + Shift + F` ga odpre, `Super + Shift + Alt + F` pa ga odpre v imeniku, v katerem je trenutno vaš terminal, kar prihrani veliko klikanja. S `Ctrl + L` lahko vnesete pot, z `Space` na kateri koli datoteki pa jo predogledate v polni velikosti, ne da bi jo odprli.

Vstavite ključ USB ali kartico SD in samodejno se priklopi, tako da se preprosto pokaže v stranski vrstici. Za kaj zahtevnejšega — formatiranje pogona, preverjanje zdravja SMART, ustvarjanje particij — zaženite _Disks_ iz zaganjalnika aplikacij (`Super + Space`).

Dvoklik sledi smiselnim privzetim nastavitvam: slike, videi in glasba se odprejo v Omaview, PDF-ji v Document Viewer, Markdown v Omawrite, navadno besedilo pa v urejevalniku, izbranem pod _Setup > Default > Editor_.

## Disktree

Ko se pogon napolni in nimate pojma, kaj ga žre, zaženite [Disktree](https://github.com/tobi/disktree) iz zaganjalnika aplikacij (`Super + Space`). Prikazuje grafični drevesni zemljevid vašega domačega imenika. Večji bloki zavzamejo več prostora; po imenikih se sprehajajte s tipkovnico ali miško, označite, kaj mora iti, in preglejte svoje izbire, preden karkoli odstranite. Zaženite `disktree --disk`, da pregledate celoten disk.

## Obsidian

[Obsidian](https://obsidian.md/) je brezplačna in zelo razširljiva aplikacija za zapiske, ki za shranjevanje uporablja preproste datoteke Markdown.

Obsidian je brezplačen za vse namene, vključno z osebno, komercialno in neprofitno uporabo.

Obsidian ponuja tudi [komercialni dodatek za sinhronizacijo](https://obsidian.md/sync) z mobilnimi aplikacijami za iOS in Android. (https://obsidian.md/pricing).

Obsidian zaženete s `Super + Shift + O`. Če želite uporabljati sinhronizacijo tem, morate v nastavitvah izbrati temo `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je Omarchyjeva lastna izjemno preprosta aplikacija za pisanje v Markdownu. Brez trezorjev, brez vtičnikov, samo vi in besede.

Omawrite zaženete s `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovno orodje za urejanje slik, odlično za obrezovanje, spreminjanje velikosti in druge osnovne posege. Le ne pričakujte alternative za Photoshop. Pa še vedno ima čarobno palico in plasti!

Pinto zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme, ki lahko iz ozadne slike izvleče barve in jih spremeni v celovito, skladno temo. To je najlažji način, da [izdelate svojo temo](43-making-your-own-theme.md).

Aether zaženete prek zaganjalnika aplikacij (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vam omogoča pošiljanje datotek drugim napravam v istem omrežju, v katerih teče aplikacija, podobno kot Applov AirDrop. Je pa medplatformska, tako da lahko datoteke pošiljate v Windows, macOS, Android, iOS in seveda Linux ter iz njih.

Meni Deli odprete s `Super + Ctrl + S` ali pod _Trigger > Share_ v meniju Omarchy. Ponuja vam štiri možnosti:

- **Clipboard** pošlje vse, kar ste kopirali, kot besedilno datoteko. Odlično, če želite povezavo ali izrezek prenesti na telefon, ne da bi si pošiljali e-pošto.
- **File** odpre izbirnik datotek, kjer lahko izberete več hkrati.
- **Folder** pošlje celoten imenik.
- **Receive** odpre pravi LocalSend, da vam lahko druga naprava nekaj pošlje.

Isto deluje iz terminala z `omarchy share clipboard`, `omarchy share file [path]` in `omarchy share folder [path]`. Če izpustite pot, dobite izbirnik.

Pošiljate lahko tudi neposredno iz upravitelja datotek: z desno tipko kliknite poljubno izbiro v Datotekah in jo delite z LocalSend.

Požarni zid v Omarchyju je privzeto zaprt, razen za vrata LocalSend, tako da to na sveži namestitvi deluje takoj. Glejte [varnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je celoten pisarniški paket z urejevalnikom besedil, preglednicami, predstavitvami, aplikacijo za risanje in še čem. Združljiv je z datotekami iz Microsoft Office, tako da je to odličen način za odpiranje tistih Wordovih dokumentov.

LibreOffice zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je Omarchyjeva lastna izjemno preprosta aplikacija za predstavitve. Vaša predstavitev je ena sama datoteka Markdown s slikami in videi ob njej: vsak diapozitiv napišite pod živim predogledom, diapozitive povlecite v vrstni red, nato predstavite čez cel zaslon ali izvozite v PDF in PowerPoint. Prevzame celo vašo temo Omarchy.

Hype zaženete prek zaganjalnika aplikacij (`Super + Space`). V njem pritisnite `?`, da vidite vse bližnjice.

## Signed

[Signed](https://github.com/omacom/signed) je Omarchyjev lastni izjemno preprost način za podpisovanje PDF-jev in njihovo izpolnjevanje. Shranjeni podpis, besedilo in današnji datum postavite kamor koli na stran, nato pa podpisano kopijo shranite ob izvirniku. Kako to storite, glejte [Izpolnjevanje PDF-jev](27-filling-out-pdfs.md).

Signed zaženete prek zaganjalnika aplikacij (`Super + Space`) ali pa z njim odprete PDF iz upravitelja datotek.

## Game Vibes

Game Vibes v zaganjalniku aplikacij (`Super + Space`) je kraj, kjer živijo Omarchyjeve majhne igre: Checkmate, 3D igra šaha proti prijatelju ali vgrajenemu nasprotniku; Cards, pasjansa Klondike; in Neon Swarm, arkadna streljačina. Vsaka je ena sama spletna stran, ki sledi vaši temi. Eno izberite s puščicami in `Enter`, nazaj na seznam pa se vrnete s `Esc` z naslovnega zaslona igre ali s `Q`, ko je ustavljena. Odpre se čez cel zaslon: s `Super + F` postane okno, s `Super + W` pa jo zaprete.

Tu se pokažejo tudi igre, ki jih naredite z agentom: v plošči agentov izberite _Make something cool → Game_ in eno opišite ali poimenujte igro, ki je že v Game Vibes, da nadaljujete delo na njej. Agent jo kopira v `~/Games/vibes`, kjer je vaša in jo lahko spreminjate, ter jo odpre, ko konča. To kopijo lahko naredite sami z `omarchy games vibes copy <game>`. Igro, ki jo deli nekdo drug, namestite kot temo: izberite _Install > Gaming > Game Vibes_ in prilepite njen naslov git ali zaženite `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ eno spet odstrani, _Update > Game Vibes Games_ pa prenese nove različice. Igre naložijo three.js s spleta, zato za zagon potrebujejo povezavo.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je Omarchyjev lastni izjemno preprost kalkulator, ki se odpre v lebdečem oknu.

Omacalc zaženete s `Super + Shift + Q` (ali s tipko za kalkulator, če jo vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir šifriranega sporočanja E2E in odlična komunikacijska možnost za vsakogar, ki raje ne bi šel prek enega od velikih tehnoloških konglomeratov.

Signal zaženete s `Super + Shift + G`. Ni del osnovne namestitve, zato vam bo Omarchy ob prvem pritisku te kombinacije ponudil, da ga namesti za vas (je tudi pod _Install > Service_ v meniju Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je Omarchyjev lastni izjemno preprost pregledovalnik slik in predvajalnik medijev: eno okno za vaše fotografije, videe in glasbo. Odprite fotografijo in puščične tipke korakajo skozi preostanek njene mape, `N` in `P` to storita za kar koli, `Ctrl + M` pa pokaže celotno mapo kot mrežo. Prikazuje tudi fotografije HEIC, AVIF in JPEG XL ter nadaljuje tam, kjer ste končali pri vsem dolgem.

Pritisnite `F` za celozaslonski način, `E` za urejanje slike v Omasnap ali obrezovanje videa v Omacut, `Ctrl + P` za tiskanje slike in `Delete`, da datoteko premaknete v koš (`Ctrl + Z` jo pripelje nazaj). V njem pritisnite `?`, da vidite vse bližnjice.

Omaview zaženete kot _Media Viewer_ prek zaganjalnika aplikacij (`Super + Space`) ali preprosto dvokliknete sliko, video ali pesem v upravitelju datotek.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je Omarchyjev lastni izjemno preprost obrezovalnik videov. Ko morate posnetku le odrezati začetek in konec, premaga zagon polnega urejevalnika videov.

Omacut zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je Omarchyjev lastni izjemno preprost snemalnik spletne kamere. Kamero in mikrofon izberite enkrat, nato pritisnite `Space` za snemanje in spet za premor in nadaljevanje istega posnetka. Vedno snema v najvišji ločljivosti vaše kamere, z živim merilnikom mikrofona, da lahko pred začetkom preverite svoje ravni.

Ko posnetek ustavite, se takoj odpre v vgrajenem urejevalniku. Dvokliknite posnetek, da ga razdelite, povlecite ročice, da obrežete vsak del, in odstranite dele, ki jih ne želite. Nato ga shranite kot MP4. Vaš izvirni posnetek se hrani, dokler ga ne zavržete, tako da se lahko vedno vrnete in ga obrežete drugače.

Monologue zaženete prek zaganjalnika aplikacij (`Super + Space`).
