# GUI

## Datoteke

Files (Nautilus) je grafični upravitelj datotek. `Super + Shift + F` ga odpre, `Super + Shift + Alt + F` pa ga odpre v mapi, v kateri je vaš terminal, kar prihrani veliko klikanja. `Ctrl + L` omogoča vnos poti, pritisk `Space` na kateri koli datoteki pa poda hiter predogled brez odpiranja česar koli.

Vstavite pomnilniški ključek USB ali kartico SD in samodejno se priklopi, tako da se preprosto prikaže v stranski vrstici. Za kaj bolj zapletenega — formatiranje pogona, preverjanje zdravja SMART, ustvarjanje particij — zaženite _Disks_ iz zaganjalnika aplikacij (`Super + Space`).

Dvojni klik sledi smiselnim privzetim vrednostim: slike se odprejo v imv, video v mpv, PDF-ji v Document Viewer in navadno besedilo v Neovimu.

## Disktree

Ko se pogon napolni in nimate pojma, kaj ga žre, zaženite [Disktree](https://github.com/tobi/disktree) iz zaganjalnika aplikacij (`Super + Space`). Prikazuje grafično drevesno karto vaše domače mape. Večji bloki zasedajo več prostora; hodite po mapah s tipkovnico ali miško, označite, kaj mora iti, in preglejte svoje izbire, preden karkoli odstranite. Zaženite `disktree --disk`, da pregledate celoten disk.

## Obsidian

[Obsidian](https://obsidian.md/) je brezplačna in zelo razširljiva aplikacija za zapisovanje, ki za shranjevanje uporablja preproste datoteke Markdown.

Obsidian je brezplačen za vse namene, vključno z osebno, komercialno in neprofitno uporabo.

Obsidian ponuja tudi [komercialni dodatek za sinhronizacijo](https://obsidian.md/sync) z mobilnimi aplikacijami v sistemih iOS in Android. (https://obsidian.md/pricing).

Obsidian zaženete s `Super + Shift + O`. Za uporabo sinhronizacije teme morate v nastavitvah izbrati temo `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je preprosta aplikacija Omarchy za pisanje v Markdownu. Brez trezorjev, brez vtičnikov, samo vi in besede.

Omawrite zaženete s `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovno orodje za urejanje slik, ki je odlično za obrezovanje, spreminjanje velikosti in druge osnovne manipulacije. Le ne pričakujte alternative Photoshopu. Ampak vseeno ima čarobno paličko in plasti!

Pinto zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za oblikovanje tem, ki lahko izvleče barve iz slike ozadja in jih spremeni v popolno, kohezivno temo. To je najlažji način, da [izdelate svojo temo](43-making-your-own-theme.md).

Aether zaženete prek zaganjalnika aplikacij (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) omogoča pošiljanje datotek drugim napravam v istem omrežju, ki izvajajo aplikacijo, kot Apple AirDrop. Je pa večplatformen, tako da lahko pošiljate datoteke do in iz Windows, macOS, Androida, iOS in seveda Linuxa.

Meni Deli lahko odprete s `Super + Ctrl + S` ali pod _Sproži > Deli_ v meniju Omarchy. Ponudi štiri možnosti:

- **Odložišče** pošlje, kar ste kopirali, kot besedilno datoteko. Odlično, da povezavo ali delček prenesete v telefon, ne da bi si pošiljali e-pošto.
- **Datoteka** odpre izbirnik datotek, kjer lahko izberete več naenkrat.
- **Mapa** pošlje celotno mapo.
- **Prejmi** odpre pravi LocalSend, da vam druga naprava lahko kaj pošlje.

Enako deluje iz terminala z `omarchy share clipboard`, `omarchy share file [path]` in `omarchy share folder [path]`. Če pot izpustite, dobite izbirnik.

Pošiljate lahko tudi neposredno iz upravitelja datotek: z desno tipko miške kliknite katero koli izbiro v Nautilusu in izberite _Send via LocalSend_.

Požarni zid Omarchy je privzeto zaprt, razen za vrata LocalSenda, zato to deluje kar iz škatle pri sveži namestitvi. Glejte [varnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je popoln pisarniški paket z urejevalnikom besedil, preglednico, predstavitvami, aplikacijo za risanje in še več. Združljiv je z datotekami iz Microsoft Office, zato je to odličen način, da lahko odprete tiste dokumente Word.

LibreOffice zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je preprosta predstavitvena aplikacija Omarchy. Vaša predstavitev je ena sama datoteka Markdown s slikami in videi ob njej: vsak diapozitiv napišete pod živim predogledom, diapozitive povlečete v vrstni red, nato predstavite čez cel zaslon ali izvozite v PDF in PowerPoint. Prevzame celo vašo temo Omarchy.

Hype zaženete prek zaganjalnika aplikacij (`Super + Space`). Pritisnite `?` znotraj njega, da vidite vsako bližnjico.

## Signed

[Signed](https://github.com/omacom/signed) je preprost način Omarchy za podpisovanje PDF-jev in njihovo izpolnjevanje. Shranjeni podpis, besedilo in današnji datum postavite kamor koli na stran, nato shranite podpisano kopijo poleg izvirnika. Za navodila glejte [Izpolnjevanje PDF-jev](27-filling-out-pdfs.md).

Signed zaženete prek zaganjalnika aplikacij (`Super + Space`) ali z njim odprete PDF iz upravitelja datotek.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je preprost kalkulator Omarchy, ki se odpre v lebdečem oknu.

Omacalc zaženete s `Super + Ctrl + Q` (ali tipko kalkulatorja, če jo vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir šifriranja sporočil E2E in odlična možnost za komunikacijo za vse, ki raje ne bi šli prek enega od velikih tehnoloških konglomeratov.

Signal zaženete s `Super + Shift + G`. Ni del osnovne namestitve, zato bo Omarchy ob prvem pritisku ponudil namestitev (je tudi pod _Namesti > Storitev_ v meniju Omarchy).

## mpv

[mpv](https://mpv.io/) je preprost in hiter predvajalnik medijev, ki predvaja skoraj kar koli s kateregakoli vira. Odličen za gledanje videoposnetkov.

mpv zaženete prek zaganjalnika aplikacij (`Super + Space`) ali preprosto dvokliknete videoposnetek v upravitelju datotek.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je preprost rezalnik videa Omarchy. Ko morate samo odrezati začetek in konec posnetka, premaga zagon celotnega urejevalnika videa.

Omacut zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je preprost snemalnik spletne kamere Omarchy. Enkrat izberite kamero in mikrofon, nato pritisnite `Space` za snemanje in znova za premor in nadaljevanje istega posnetka. Vedno snema v najvišji ločljivosti vaše kamere, z živim merilnikom mikrofona, da lahko pred začetkom preverite ravni.

Ustavite posnetek in takoj se odpre v vgrajenem urejevalniku. Dvojni klik na posnetek ga razdeli, povlecite ročice, da obrežete vsak kos, in odstranite dele, ki jih ne želite. Nato ga shranite kot MP4. Izvirni posnetek se obdrži, dokler ga ne zavržete, tako da se lahko vedno vrnete in ga urežete drugače.

Monologue zaženete prek zaganjalnika aplikacij (`Super + Space`).
