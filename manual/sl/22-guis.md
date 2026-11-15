# GUIs

## Files

Files (Nautilus) je grafični upravitelj datotek. `Super + Shift + F` ga odpre, `Super + Shift + Alt + F` pa ga odpre v imeniku, v katerem je trenutno vaš terminal, kar prihrani veliko klikanja. S `Ctrl + L` lahko vnesete pot, s pritiskom na `Space` na katerikoli datoteki pa dobite hiter predogled, ne da bi karkoli odprli.

Priključite USB-ključek ali kartico SD in samodejno se bo priklopila, tako da se kar prikaže v stranski vrstici. Za kaj zahtevnejšega — formatiranje pogona, preverjanje zdravja SMART, ustvarjanje particij — zaženite _Disks_ iz zaganjalnika aplikacij (`Super + Space`).

Dvoklik sledi smiselnim privzetim nastavitvam: slike, videoposnetki in glasba se odprejo v Omaview, PDF-ji v Document Viewer, navadno besedilo pa v Neovim.

## Disktree

Ko se disk napolni in nimate pojma, kaj ga žre, zaženite [Disktree](https://github.com/tobi/disktree) iz zaganjalnika aplikacij (`Super + Space`). Prikaže grafični drevesni zemljevid vašega domačega imenika. Večji bloki zavzamejo več prostora; po imenikih se sprehajajte s tipkovnico ali miško, označite, kaj mora iti, in pred odstranitvijo preglejte svoj izbor. Zaženite `disktree --disk`, da pregledate celoten disk.

## Obsidian

[Obsidian](https://obsidian.md/) je brezplačna in zelo razširljiva aplikacija za zapisovanje, ki za shranjevanje uporablja preproste datoteke Markdown.

Obsidian je brezplačen za vse namene, vključno z osebno, komercialno in neprofitno uporabo.

Obsidian ponuja tudi [komercialni dodatek za sinhronizacijo](https://obsidian.md/sync) z mobilnimi aplikacijami v sistemih iOS in Android. (https://obsidian.md/pricing).

Obsidian zaženete s `Super + Shift + O`. Za uporabo sinhronizacije tem morate v nastavitvah izbrati temo `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je Omarchyjeva lastna izjemno preprosta aplikacija za pisanje v Markdownu. Brez trezorjev, brez vtičnikov, samo vi in besede.

Omawrite zaženete s `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovno orodje za urejanje slik, ki je odlično za obrezovanje, spreminjanje velikosti in druge osnovne obdelave. Samo ne pričakujte alternative za Photoshop. A ima vseeno Magic Wand in plasti!

Pinto zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme, ki lahko iz slike ozadja izvleče barve in jih spremeni v celotno, skladno temo. To je najlažji način, da [ustvarite svojo temo](43-making-your-own-theme.md).

Aether zaženete prek zaganjalnika aplikacij (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vam omogoča pošiljanje datotek drugim napravam v istem omrežju, v katerih je nameščena ta aplikacija, podobno kot Appleov AirDrop. Je pa medplatformska, tako da lahko datoteke pošiljate v sisteme Windows, macOS, Android, iOS in seveda Linux ter iz njih.

Meni Share lahko odprete s `Super + Ctrl + S` ali pod _Trigger > Share_ v meniju Omarchy. Ponudi vam štiri možnosti:

- **Clipboard** pošlje vse, kar ste kopirali, kot besedilno datoteko. Odlično, če želite povezavo ali delček spraviti v telefon, ne da bi si ga poslali po e-pošti.
- **File** odpre izbirnik datotek, v katerem jih lahko izberete več hkrati.
- **Folder** pošlje celoten imenik.
- **Receive** odpre pravi LocalSend, da vam lahko druga naprava kaj pošlje.

Isto deluje tudi iz terminala z ukazi `omarchy share clipboard`, `omarchy share file [path]` in `omarchy share folder [path]`. Če pot izpustite, dobite izbirnik.

Pošiljate lahko tudi neposredno iz upravitelja datotek: v Nautilusu z desno tipko kliknite katerikoli izbor in izberite _Send via LocalSend_.

Požarni zid v Omarchyju je privzeto zaprt, razen za vrata za LocalSend, zato to deluje takoj po sveži namestitvi. Glejte [varnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je celoten pisarniški paket s programom za urejanje besedil, preglednicami, predstavitvami, aplikacijo za risanje in še čim. Združljiv je z datotekami iz Microsoft Office, zato je to odličen način, da lahko odpirate tiste Wordove dokumente.

LibreOffice zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je Omarchyjeva lastna izjemno preprosta aplikacija za predstavitve. Vaša predstavitev je ena sama datoteka Markdown s slikami in videoposnetki ob njej: vsak diapozitiv napišete pod živim predogledom, diapozitive povlečete v pravi vrstni red, nato pa predstavljate čez celoten zaslon ali izvozite v PDF in PowerPoint. Prevzame celo vašo temo Omarchy.

Hype zaženete prek zaganjalnika aplikacij (`Super + Space`). Pritisnite `?` znotraj njega, da vidite vse bližnjice.

## Signed

[Signed](https://github.com/omacom/signed) je Omarchyjev lastni izjemno preprost način za podpisovanje PDF-jev in njihovo izpolnjevanje. Shranjeni podpis, besedilo in današnji datum postavite kamorkoli na stran, nato pa shranite podpisano kopijo poleg izvirnika. Za navodila glejte [Izpolnjevanje PDF-jev](27-filling-out-pdfs.md).

Signed zaženete prek zaganjalnika aplikacij (`Super + Space`) ali pa z njim odprete PDF iz upravitelja datotek.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je Omarchyjev lastni izjemno preprost kalkulator, ki se odpre v lebdečem oknu.

Omacalc zaženete s `Super + Shift + Q` (ali s tipko za kalkulator, če jo vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir sporočanja s šifriranjem E2E in odlična možnost za komunikacijo za vse, ki raje ne bi šli prek enega od velikih tehnoloških konglomeratov.

Signal zaženete s `Super + Shift + G`. Ni del osnovne namestitve, zato vam bo Omarchy ob prvem pritisku te kombinacije ponudil, da ga namesti namesto vas (najdete ga tudi pod _Install > Service_ v meniju Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je Omarchyjev lastni izjemno preprost pregledovalnik slik in predvajalnik predstavnosti: eno okno za vaše fotografije, videoposnetke in glasbo. Odprete fotografijo in puščične tipke vas vodijo skozi preostale datoteke v njeni mapi, `N` in `P` to počneta za karkoli, `Ctrl + M` pa prikaže celotno mapo kot mrežo. Prikazuje tudi fotografije HEIC, AVIF in JPEG XL ter nadaljuje tam, kjer ste končali pri čemerkoli daljšem.

Pritisnite `F` za celozaslonski način, `E` za urejanje slike v Omasnap ali obrezovanje videoposnetka v Omacut, `Ctrl + P` za tiskanje slike in `Delete`, da datoteko premaknete v koš (`Ctrl + Z` jo vrne nazaj). Pritisnite `?` znotraj njega, da vidite vse bližnjice.

Omaview zaženete kot _Media Viewer_ prek zaganjalnika aplikacij (`Super + Space`) ali pa preprosto dvokliknete sliko, videoposnetek ali pesem v upravitelju datotek.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je Omarchyjev lastni izjemno preprost obrezovalnik videoposnetkov. Ko morate posnetku le odrezati začetek in konec, je boljši kot zagnati celoten urejevalnik videoposnetkov.

Omacut zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je Omarchyjev lastni izjemno preprost snemalnik s spletno kamero. Enkrat izberete kamero in mikrofon, nato pritisnete `Space` za snemanje in znova za premor ter nadaljevanje istega posnetka. Vedno snema pri najvišji ločljivosti vaše kamere, z merilnikom mikrofona v živo, da lahko pred začetkom preverite ravni.

Ustavite posnetek in takoj se odpre v vgrajenem urejevalniku. Dvokliknite posnetek, da ga razdelite, povlecite ročice, da obrežete vsak del, in odstranite dele, ki jih ne želite. Nato ga shranite kot MP4. Vaš izvirni posnetek se ohrani, dokler ga ne zavržete, zato se lahko vedno vrnete in ga odrežete drugače.

Monologue zaženete prek zaganjalnika aplikacij (`Super + Space`).
