# Grafični vmesniki

## Files

Files (Folio) je grafični upravitelj datotek. `Super + Shift + F` ga odpre, `Super + Shift + Alt + F` pa ga odpre v imeniku, v katerem je vaš terminal, kar prihrani veliko klikanja. S `Ctrl + L` lahko vnesete pot, s pritiskom na `Space` na kateri koli datoteki pa si jo ogledate v polni velikosti, ne da bi jo odprli.

Priključite ključek USB ali kartico SD in samodejno se priklopi, tako da se preprosto prikaže v stranski vrstici. Za kaj zahtevnejšega — formatiranje pogona, preverjanje stanja SMART, ustvarjanje particij — zaženite _Disks_ iz zaganjalnika aplikacij (`Super + Space`).

Šifriran pogon ob priključitvi zahteva svoje geslo. Da se odkleni sam, mu dodajte datoteko s ključem z `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` in to datoteko s ključem shranite v `~/.config/omarchy/drive-keys/<UUID>`, poimenovano po UUID, ki ga za šifrirano particijo izpiše `lsblk -dno UUID /dev/sdX1`, in berljivo samo za vas (`chmod 600`). Če ta datoteka s ključem manjka ali je zavrnjena, boste kot običajno pozvani k vnosu gesla.

Dvoklik sledi smiselnim privzetim nastavitvam: slike, videoposnetki in glasba se odprejo v Omaview, PDF-ji v Document Viewer, Markdown v Omawrite, navadno besedilo pa v vašem urejevalniku, Plain, razen če pod _Setup > Defaults > Editor_ izberete drugega.

## Disktree

Ko se pogon napolni in nimate pojma, kaj ga žre, zaženite [Disktree](https://github.com/tobi/disktree) iz zaganjalnika aplikacij (`Super + Space`). Prikazuje grafični drevesni zemljevid vašega domačega imenika. Večji bloki zavzemajo več prostora; po imenikih se premikajte s tipkovnico ali miško, označite, kaj mora stran, in pred odstranitvijo česar koli preglejte svojo izbiro. Zaženite `disktree --disk`, da pregledate celoten disk.

## Obsidian

[Obsidian](https://obsidian.md/) je brezplačna in zelo razširljiva aplikacija za zapiske, ki za shranjevanje uporablja preproste datoteke Markdown.

Obsidian je brezplačen za vse namene, vključno z osebno, komercialno in neprofitno uporabo.

Obsidian ponuja tudi [komercialni dodatek za sinhronizacijo](https://obsidian.md/sync) z mobilnimi aplikacijami v sistemih iOS in Android. (https://obsidian.md/pricing).

Obsidian zaženete s `Super + Shift + O`. Če želite uporabljati sinhronizacijo teme, morate v nastavitvah izbrati temo `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je Omarchyjeva lastna prekleto preprosta aplikacija za pisanje v Markdownu. Brez trezorjev, brez vtičnikov, samo vi in besede.

Omawrite zaženete s `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovno orodje za urejanje slik, odlično za obrezovanje, spreminjanje velikosti in druge osnovne obdelave. Samo ne pričakujte alternative za Photoshop. Ima pa vseeno Magic Wand in plasti!

Pinta zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme, ki lahko iz slike ozadja izvleče barve in jih spremeni v celotno, skladno temo. To je najlažji način, da [ustvarite svojo temo](43-making-your-own-theme.md).

Aether zaženete prek zaganjalnika aplikacij (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vam omogoča pošiljanje datotek drugim napravam v istem omrežju, ki poganjajo aplikacijo, podobno kot Apple AirDrop. Je pa medplatformski, tako da lahko datoteke pošiljate v Windows, macOS, Android, iOS in seveda Linux ter iz njih.

Meni Share lahko odprete s `Super + Ctrl + S` ali pod _Trigger > Share_ v meniju Omarchy. Ponuja vam štiri možnosti:

- **Clipboard** pošlje vse, kar ste kopirali, kot besedilno datoteko. Odlično, da dobite povezavo ali delček na telefon, ne da bi si pošiljali e-pošto.
- **File** odpre izbirnik datotek, kjer lahko izberete več hkrati.
- **Folder** pošlje celoten imenik.
- **Receive** odpre pravi LocalSend, da vam lahko druga naprava kaj pošlje.

Enako deluje iz terminala z `omarchy share clipboard`, `omarchy share file [path]` in `omarchy share folder [path]`. Če pot izpustite, dobite izbirnik.

Pošiljate lahko tudi neposredno iz upravitelja datotek: v Files z desno tipko kliknite katero koli izbiro in jo delite z LocalSend.

Požarni zid v Omarchy je privzeto zaprt, razen za vrata LocalSend, tako da to deluje takoj po sveži namestitvi. Glejte [varnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je celoten pisarniški paket z urejevalnikom besedil, preglednicami, predstavitvami, aplikacijo za risanje in še več. Združljiv je z datotekami iz Microsoft Office, tako da je to odličen način, da lahko odprete tiste Wordove dokumente.

LibreOffice zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je Omarchyjeva lastna prekleto preprosta aplikacija za predstavitve. Vaša predstavitev je ena sama datoteka Markdown s slikami in videoposnetki ob njej: vsak diapozitiv napišite pod predogledom v živo, diapozitive povlecite v vrstni red, nato predstavite čez cel zaslon ali izvozite v PDF in PowerPoint. Prevzame celo vašo temo Omarchy.

Hype zaženete prek zaganjalnika aplikacij (`Super + Space`). V njej pritisnite `?`, da vidite vse bližnjice.

## Signed

[Signed](https://github.com/omacom/signed) je Omarchyjev lastni prekleto preprost način za podpisovanje PDF-jev in njihovo izpolnjevanje. Shranjen podpis, besedilo in današnji datum postavite kamor koli na stran, nato pa shranite podpisano kopijo ob izvirnik. Kako to storite, glejte v [Izpolnjevanje PDF-jev](27-filling-out-pdfs.md).

Signed zaženete prek zaganjalnika aplikacij (`Super + Space`) ali z njim odprete PDF iz upravitelja datotek.

## Game Vibes

Game Vibes v zaganjalniku aplikacij (`Super + Space`) je kraj, kjer živijo majhne igre Omarchy: Checkmate, 3D šahovska igra proti prijatelju ali vgrajenemu nasprotniku; Cards, pasjansa Klondike; Death Wish, na piksel natančna ploščadna igra z desetimi sobami, polnimi konic in žag; in Neon Swarm, arkadna streljačina. Vsaka je ena sama spletna stran, ki sledi vaši temi. Eno izberite s puščicami in `Enter`, na seznam pa se vrnite z `Esc` z naslovnega zaslona igre ali s `Q`, medtem ko je začasno ustavljena. Odpre se čez cel zaslon: s `Super + F` postane okno, s `Super + W` pa ga zaprete.

Tukaj se prikažejo tudi igre, ki jih naredite z agentom: v panelu agentov izberite _Make something cool → Game_ in opišite eno ali poimenujte igro, ki je že v Game Vibes, da nadaljujete delo na njej. Agent jo kopira v `~/Games/vibes`, kjer je vaša in jo lahko spreminjate, ter jo odpre, ko je končana. To kopijo lahko naredite sami z `omarchy games vibes copy <game>`. Igra, ki jo deli nekdo drug, se namesti kot tema: izberite _Install > Gaming > Game Vibes_ in prilepite njen naslov git ali zaženite `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ eno spet odstrani, _Update > Game Vibes Games_ pa prenese nove različice. Igre naložijo three.js s spleta, tako da za zagon potrebujejo povezavo.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je Omarchyjev lastni prekleto preprost kalkulator, ki se odpre v plavajočem oknu.

Omacalc zaženete s `Super + Shift + Q` (ali s tipko za kalkulator, če jo vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir sporočanja s šifriranjem E2E in odlična komunikacijska možnost za vsakogar, ki raje ne bi šel prek enega od velikih tehnoloških konglomeratov.

Signal zaženete s `Super + Shift + G`. Ni del osnovne namestitve, tako da vam bo Omarchy, ko boste prvič pritisnili to kombinacijo, ponudil, da ga namesti za vas (je tudi pod _Install > Service_ v meniju Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je Omarchyjev lastni prekleto preprost pregledovalnik slik in predvajalnik medijev: eno okno za vaše fotografije, videoposnetke in glasbo. Odprite fotografijo in puščične tipke vas pomikajo skozi preostanek njene mape, `N` in `P` to storita za karkoli, `Ctrl + M` pa prikaže celotno mapo kot mrežo. Prikazuje tudi fotografije HEIC, AVIF in JPEG XL in nadaljuje tam, kjer ste končali pri čemer koli dolgem.

Pritisnite `F` za cel zaslon, `E` za urejanje slike v Omasnap ali obrezovanje videoposnetka v Omacut, `Ctrl + P` za tiskanje slike in `Delete`, da datoteko premaknete v Smetnjak (`Ctrl + Z` jo vrne nazaj). V njem pritisnite `?`, da vidite vse bližnjice.

Omaview zaženete kot _Media Viewer_ prek zaganjalnika aplikacij (`Super + Space`) ali preprosto dvokliknete sliko, videoposnetek ali pesem v upravitelju datotek.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je Omarchyjev lastni prekleto preprost obrezovalnik videoposnetkov. Ko morate posnetku le odrezati začetek in konec, je to bolje, kot da zaženete celoten urejevalnik videoposnetkov.

Omacut zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je Omarchyjev lastni prekleto preprost snemalnik s spletno kamero. Kamero in mikrofon izberite enkrat, nato pritisnite `Space` za snemanje in še enkrat, da isti posnetek začasno ustavite in nadaljujete. Vedno snema pri najvišji ločljivosti vaše kamere, z merilnikom mikrofona v živo, tako da lahko pred začetkom preverite svoje ravni.

Ustavite posnetek in takoj se odpre v vgrajenem urejevalniku. Dvokliknite posnetek, da ga razdelite, povlecite ročice, da obrežete vsak del, in odstranite dele, ki jih ne želite. Nato ga shranite kot MP4. Vaš izvirni posnetek se hrani, dokler ga ne zavržete, tako da se lahko vedno vrnete in ga obrežete drugače.

Monologue zaženete prek zaganjalnika aplikacij (`Super + Space`).
