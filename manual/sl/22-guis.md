# Grafični vmesniki

## Datoteke

Datoteke (Nautilus) so grafični upravljalnik datotek. `Super + Shift + F` ga odpre, `Super + Shift + Alt + F` pa ga odpre v imeniku, v katerem je trenutno vaš terminal, kar prihrani veliko klikanja. `Ctrl + L` vam omogoči vnos poti, pritisk tipke `Space` na kateri koli datoteki pa prikaže hiter predogled, ne da bi karkoli odprli.

Priključite ključek USB ali kartico SD in samodejno se priklopi, zato se preprosto prikaže v stranski vrstici. Za kaj zahtevnejšega — formatiranje pogona, preverjanje zdravja SMART, ustvarjanje particij — zaženite _Disks_ iz zaganjalnika aplikacij (`Super + Space`).

Dvoklik sledi smiselnim privzetim nastavitvam: slike, videoposnetki in glasba se odprejo v Omaview, PDF-ji v Document Viewer, Markdown v Omawrite, navadno besedilo pa v urejevalniku, izbranem pod _Setup > Default > Editor_.

## Disktree

Ko se pogon napolni in nimate pojma, kaj ga žre, zaženite [Disktree](https://github.com/tobi/disktree) iz zaganjalnika aplikacij (`Super + Space`). Prikaže grafični drevesni zemljevid vašega domačega imenika. Večji bloki zavzamejo več prostora; po imenikih se sprehajajte s tipkovnico ali miško, označite, kaj mora iti, in preglejte izbire, preden karkoli odstranite. Zaženite `disktree --disk`, da pregledate celoten disk.

## Obsidian

[Obsidian](https://obsidian.md/) je brezplačna in zelo razširljiva aplikacija za zapiske, ki za shranjevanje uporablja preproste datoteke Markdown.

Obsidian je brezplačen za vse namene, vključno z osebno, komercialno in nepridobitno uporabo.

Obsidian ponuja tudi [komercialni dodatek za sinhronizacijo](https://obsidian.md/sync) z mobilnimi aplikacijami v sistemih iOS in Android. (https://obsidian.md/pricing).

Obsidian zaženete s `Super + Shift + O`. Če želite uporabljati sinhronizacijo teme, morate v nastavitvah izbrati temo `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je Omarchyjeva lastna mrtvo preprosta aplikacija za pisanje v Markdownu. Brez trezorjev, brez vtičnikov, samo vi in besede.

Omawrite zaženete s `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovno orodje za urejanje slik, odlično za obrezovanje, spreminjanje velikosti in druge osnovne posege. Le ne pričakujte alternative Photoshopu. Ima pa vseeno Magic Wand in plasti!

Pinto zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme, ki lahko iz slike ozadja izvleče barve in jih spremeni v popolno, skladno temo. To je najlažji način, da [ustvarite lastno temo](43-making-your-own-theme.md).

Aether zaženete prek zaganjalnika aplikacij (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vam omogoča pošiljanje datotek drugim napravam v istem omrežju, v katerih teče aplikacija, podobno kot Apple AirDrop. Je pa medplatformska, zato lahko datoteke pošiljate v sisteme Windows, macOS, Android, iOS in seveda Linux ter iz njih.

Meni Share odprete s `Super + Ctrl + S` ali pod _Trigger > Share_ v meniju Omarchy. Ponudi vam štiri možnosti:

- **Clipboard** pošlje vse, kar ste kopirali, kot besedilno datoteko. Odlično, da povezavo ali izrezek spravite na telefon, ne da bi si pošiljali e-pošto.
- **File** odpre izbirnik datotek, v katerem lahko izberete več hkrati.
- **Folder** pošlje celoten imenik.
- **Receive** odpre pravi LocalSend, da vam lahko druga naprava kaj pošlje.

Isto deluje iz terminala z `omarchy share clipboard`, `omarchy share file [path]` in `omarchy share folder [path]`. Če pot izpustite, dobite izbirnik.

Pošiljate lahko tudi neposredno iz upravljalnika datotek: z desno tipko kliknite katero koli izbiro v Nautilusu in izberite _Send via LocalSend_.

Požarni zid v Omarchyju je privzeto zaprt, razen za vrata LocalSenda, zato to deluje takoj po sveži namestitvi. Glejte [varnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je popoln pisarniški paket z urejevalnikom besedil, preglednicami, predstavitvami, aplikacijo za risanje in še čem. Združljiv je z datotekami iz Microsoft Officea, zato je to odličen način, da lahko odpirate tiste Wordove dokumente.

LibreOffice zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je Omarchyjeva lastna mrtvo preprosta aplikacija za predstavitve. Vaša predstavitev je ena sama datoteka Markdown s slikami in videoposnetki ob njej: vsak diapozitiv napišete pod predogledom v živo, diapozitive povlečete v vrstni red, nato predstavite čez cel zaslon ali izvozite v PDF in PowerPoint. Uporabi celo vašo temo Omarchy.

Hype zaženete prek zaganjalnika aplikacij (`Super + Space`). Pritisnite `?` v njem, da vidite vse bližnjice.

## Signed

[Signed](https://github.com/omacom/signed) je Omarchyjev lastni mrtvo preprost način za podpisovanje PDF-jev in njihovo izpolnjevanje. Shranjeni podpis, besedilo in današnji datum postavite kamor koli na stran, nato pa podpisano kopijo shranite ob izvirniku. Kako to gre, si oglejte v [Izpolnjevanje PDF-jev](27-filling-out-pdfs.md).

Signed zaženete prek zaganjalnika aplikacij (`Super + Space`) ali z njim odprete PDF iz upravljalnika datotek.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je Omarchyjev lastni mrtvo preprost kalkulator, ki se odpre v plavajočem oknu.

Omacalc zaženete s `Super + Shift + Q` (ali s tipko za kalkulator, če jo vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir sporočanja s šifriranjem E2E in odlična možnost za komunikacijo za vse, ki raje ne bi šli prek enega od velikih tehnoloških konglomeratov.

Signal zaženete s `Super + Shift + G`. Ni del osnovne namestitve, zato vam bo Omarchy ob prvem pritisku ponudil, da ga namesti namesto vas (je tudi pod _Install > Service_ v meniju Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je Omarchyjev lastni mrtvo preprost pregledovalnik slik in predvajalnik predstavnosti: eno okno za vaše fotografije, videoposnetke in glasbo. Odprite fotografijo in puščične tipke stopajo skozi preostanek njene mape, `N` in `P` to naredita za kar koli, `Ctrl + M` pa prikaže celotno mapo kot mrežo. Prikaže tudi fotografije HEIC, AVIF in JPEG XL ter nadaljuje tam, kjer ste končali pri čem koli dolgem.

Pritisnite `F` za celozaslonski način, `E` za urejanje slike v Omasnap ali obrezovanje videoposnetka v Omacut, `Ctrl + P` za tiskanje slike in `Delete`, da datoteko premaknete v smetnjak (`Ctrl + Z` jo pripelje nazaj). Pritisnite `?` v njem, da vidite vse bližnjice.

Omaview zaženete kot _Media Viewer_ prek zaganjalnika aplikacij (`Super + Space`) ali preprosto dvokliknete fotografijo, videoposnetek ali pesem v upravljalniku datotek.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je Omarchyjev lastni mrtvo preprost obrezovalnik videoposnetkov. Kadar morate posnetku odrezati le začetek in konec, premaga zaganjanje polnega urejevalnika videoposnetkov.

Omacut zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je Omarchyjev lastni mrtvo preprost snemalnik s spletno kamero. Enkrat izberite kamero in mikrofon, nato pritisnite `Space` za snemanje in še enkrat za premor in nadaljevanje istega posnetka. Vedno snema v najvišji ločljivosti vaše kamere, z merilnikom mikrofona v živo, da lahko pred začetkom preverite ravni.

Ustavite posnetek in takoj se odpre v vgrajenem urejevalniku. Dvokliknite posnetek, da ga razdelite, povlecite ročice za obrezovanje vsakega dela in odstranite dele, ki jih ne želite. Nato ga shranite kot MP4. Izvirni posnetek se hrani, dokler ga ne zavržete, zato se lahko vedno vrnete in ga odrežete drugače.

Monologue zaženete prek zaganjalnika aplikacij (`Super + Space`).
