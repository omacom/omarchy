# Grafični vmesniki

## Files

Files (Nautilus) je grafični upravitelj datotek. Odprete ga s `Super + Shift + F`, s `Super + Shift + Alt + F` pa se odpre v imeniku, v katerem je trenutno vaš terminal, kar prihrani veliko klikanja. S `Ctrl + L` lahko vnesete pot, s pritiskom na `Space` na kateri koli datoteki pa dobite hiter predogled, ne da bi karkoli odprli.

Priključite ključek USB ali kartico SD in samodejno se priklopi, tako da se kar prikaže v stranski vrstici. Za kaj zahtevnejšega — formatiranje pogona, preverjanje stanja SMART, ustvarjanje particij — zaženite _Disks_ iz zaganjalnika aplikacij (`Super + Space`).

Dvoklik sledi smiselnim privzetim nastavitvam: slike, videi in glasba se odprejo v Omaview, PDF-ji v Document Viewer, Markdown v Omawrite, navadno besedilo pa v urejevalniku, izbranem pod _Setup > Default > Editor_.

## Disktree

Ko se pogon napolni in nimate pojma, kaj ga žre, zaženite [Disktree](https://github.com/tobi/disktree) iz zaganjalnika aplikacij (`Super + Space`). Pokaže grafični drevesni zemljevid vašega domačega imenika. Večji bloki zavzemajo več prostora; po imenikih se premikajte s tipkovnico ali miško, označite, kaj mora iti, in pred odstranitvijo preglejte svojo izbiro. Zaženite `disktree --disk`, da pregledate celoten disk.

## Obsidian

[Obsidian](https://obsidian.md/) je brezplačna in zelo razširljiva aplikacija za zapiske, ki za shranjevanje uporablja preproste datoteke Markdown.

Obsidian je brezplačen za vse namene, vključno z osebno, komercialno in neprofitno uporabo.

Obsidian ponuja tudi [komercialni dodatek za sinhronizacijo](https://obsidian.md/sync) z mobilnimi aplikacijami v sistemih iOS in Android. (https://obsidian.md/pricing).

Obsidian zaženete s `Super + Shift + O`. Če želite uporabljati sinhronizacijo teme, morate v nastavitvah izbrati temo `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je Omarchyjeva lastna izjemno preprosta aplikacija za pisanje v Markdownu. Brez trezorjev, brez vtičnikov, samo vi in besede.

Omawrite zaženete s `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovno orodje za urejanje slik, odlično za obrezovanje, spreminjanje velikosti in druge osnovne posege. Le ne pričakujte alternative za Photoshop. Ampak še vedno ima Magic Wand in plasti!

Pinta zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme, ki lahko iz slike ozadja izvleče barve in jih spremeni v celotno, usklajeno temo. To je najlažji način, da [ustvarite svojo temo](43-making-your-own-theme.md).

Aether zaženete prek zaganjalnika aplikacij (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vam omogoča pošiljanje datotek drugim napravam v istem omrežju, v katerih teče aplikacija, podobno kot Apple AirDrop. Je pa večplatformska, tako da lahko datoteke pošiljate v Windows, macOS, Android, iOS in seveda Linux ter iz njih.

Meni Share lahko odprete s `Super + Ctrl + S` ali pod _Trigger > Share_ v meniju Omarchy. Ponudi vam štiri možnosti:

- **Clipboard** pošlje vse, kar ste kopirali, kot besedilno datoteko. Odlično, da povezavo ali delček prenesete v telefon, ne da bi si pošiljali e-pošto.
- **File** odpre izbirnik datotek, v katerem jih lahko izberete več hkrati.
- **Folder** pošlje celoten imenik.
- **Receive** odpre pravi LocalSend, da vam lahko druga naprava kaj pošlje.

Isto deluje iz terminala z `omarchy share clipboard`, `omarchy share file [path]` in `omarchy share folder [path]`. Če pot izpustite, dobite izbirnik.

Pošiljate lahko tudi neposredno iz upravitelja datotek: v Nautilusu z desno tipko kliknite katero koli izbiro in izberite _Send via LocalSend_.

Požarni zid v Omarchyju je privzeto zaprt, razen za vrata LocalSenda, tako da to deluje takoj po sveži namestitvi. Glejte [varnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je popoln pisarniški paket z urejevalnikom besedil, preglednico, predstavitvami, aplikacijo za risanje in še več. Združljiv je z datotekami iz Microsoft Office, tako da je to odličen način, da lahko odpirate tiste Wordove dokumente.

LibreOffice zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je Omarchyjeva lastna izjemno preprosta aplikacija za predstavitve. Vaša predstavitev je ena sama datoteka Markdown s slikami in videi ob njej: vsak diapozitiv napišite pod predogledom v živo, diapozitive povlecite v pravi vrstni red, nato predstavite v celozaslonskem načinu ali izvozite v PDF in PowerPoint. Celo prevzame vašo temo Omarchy.

Hype zaženete prek zaganjalnika aplikacij (`Super + Space`). V njej pritisnite `?`, da vidite vse bližnjice.

## Signed

[Signed](https://github.com/omacom/signed) je Omarchyjev lastni izjemno preprost način za podpisovanje PDF-jev in njihovo izpolnjevanje. Shranjeni podpis, besedilo in današnji datum postavite kamor koli na stran, nato pa podpisano kopijo shranite ob izvirnik. Kako to gre, glejte v [Izpolnjevanje PDF-jev](27-filling-out-pdfs.md).

Signed zaženete prek zaganjalnika aplikacij (`Super + Space`) ali pa z njim odprete PDF iz upravitelja datotek.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) je Omarchyjeva lastna 3D šahovska igra. Igrajte s prijateljem na istem računalniku ali proti vgrajenemu nasprotniku na treh ravneh, na štirih izklesanih garniturah, od katerih se vsaka premika na svoj način: orbitalna plovila, izrezljan les in slonovina, gozdna bitja in bonboni. Igre nimajo ure in se shranijo po vsaki potezi.

Checkmate zaženete prek zaganjalnika aplikacij (`Super + Space`). V njej pritisnite `?`, da vidite vse bližnjice.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je Omarchyjev lastni izjemno preprost kalkulator, ki se odpre v plavajočem oknu.

Omacalc zaženete s `Super + Shift + Q` (ali s tipko za kalkulator, če jo vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir sporočanja s šifriranjem E2E in odlična možnost komunikacije za vsakogar, ki raje ne bi šel prek enega od velikih tehnoloških konglomeratov.

Signal zaženete s `Super + Shift + G`. Ni del osnovne namestitve, zato vam bo Omarchy ob prvem pritisku te kombinacije ponudil, da ga namesti namesto vas (najdete ga tudi pod _Install > Service_ v meniju Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je Omarchyjev lastni izjemno preprost pregledovalnik slik in predvajalnik medijev: eno okno za vaše fotografije, videe in glasbo. Odprite fotografijo in puščične tipke vas vodijo skozi preostanek njene mape, `N` in `P` to počneta za karkoli, `Ctrl + M` pa prikaže celotno mapo kot mrežo. Prikazuje tudi fotografije HEIC, AVIF in JPEG XL ter nadaljuje tam, kjer ste končali pri čemerkoli dolgem.

Pritisnite `F` za celozaslonski način, `E` za urejanje slike v Omasnap ali obrezovanje videa v Omacut, `Ctrl + P` za tiskanje slike in `Delete`, da datoteko premaknete v koš (`Ctrl + Z` jo vrne nazaj). V njem pritisnite `?`, da vidite vse bližnjice.

Omaview zaženete kot _Media Viewer_ prek zaganjalnika aplikacij (`Super + Space`) ali pa kar dvokliknite sliko, video ali skladbo v upravitelju datotek.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je Omarchyjev lastni izjemno preprost obrezovalnik videov. Kadar morate posnetku odrezati le začetek in konec, premaga zaganjanje polnega urejevalnika videa.

Omacut zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je Omarchyjev lastni izjemno preprost snemalnik s spletno kamero. Kamero in mikrofon izberite enkrat, nato pritisnite `Space` za snemanje in še enkrat za premor in nadaljevanje istega posnetka. Vedno snema v najvišji ločljivosti vaše kamere, z merilnikom mikrofona v živo, da lahko pred začetkom preverite ravni.

Ustavite posnetek in takoj se odpre v vgrajenem urejevalniku. Dvokliknite posnetek, da ga razdelite, povlecite ročaje, da obrežete vsak del, in odstranite dele, ki jih ne želite. Nato ga shranite kot MP4. Vaš izvirni posnetek se hrani, dokler ga ne zavržete, tako da se lahko vedno vrnete in ga odrežete drugače.

Monologue zaženete prek zaganjalnika aplikacij (`Super + Space`).
