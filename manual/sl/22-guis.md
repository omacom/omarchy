# Grafični uporabniški vmesniki

## Datoteke

Files (Nautilus) je grafični upravitelj datotek. `Super + Shift + F` ga odpre, `Super + Shift + Alt + F` pa ga odpre v imeniku, v katerem je trenutno vaš terminal, kar prihrani veliko klikanja. `Ctrl + L` vam omogoča vnos poti, pritisk tipke `Space` na katerikoli datoteki pa vam prikaže hiter predogled, ne da bi karkoli odprli.

Priključite ključek USB ali kartico SD in samodejno se priklopi, zato se preprosto prikaže v stranski vrstici. Za karkoli zahtevnejšega — formatiranje pogona, preverjanje zdravja SMART, ustvarjanje particij — zaženite _Disks_ iz zaganjalnika aplikacij (`Super + Space`).

Dvoklik sledi smiselnim privzetim nastavitvam: slike se odprejo v imv, videoposnetki v mpv, PDF-ji v Document Viewer, navadno besedilo pa v Neovim.

## Disktree

Ko se pogon napolni in nimate pojma, kaj ga žre, zaženite [Disktree](https://github.com/tobi/disktree) iz zaganjalnika aplikacij (`Super + Space`). Prikaže grafični drevesni zemljevid vašega domačega imenika. Večji bloki zavzamejo več prostora; po imenikih se sprehajajte s tipkovnico ali miško, označite, kaj mora iti, in preglejte izbire, preden karkoli odstranite. Zaženite `disktree --disk`, da pregledate celoten disk.

## Obsidian

[Obsidian](https://obsidian.md/) je brezplačna in zelo razširljiva aplikacija za zapiske, ki za shranjevanje uporablja preproste datoteke Markdown.

Obsidian je brezplačen za vse namene, vključno z osebno, komercialno in neprofitno uporabo.

Obsidian ponuja tudi [komercialni dodatek za sinhronizacijo](https://obsidian.md/sync) z mobilnimi aplikacijami v sistemih iOS in Android. (https://obsidian.md/pricing).

Obsidian zaženete s `Super + Shift + O`. Za uporabo sinhronizacije tem morate v nastavitvah izbrati temo `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je mrtvo preprosta aplikacija za pisanje v Markdownu, lastna aplikacija sistema Omarchy. Brez trezorjev, brez vtičnikov, samo vi in besede.

Omawrite zaženete s `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovno orodje za urejanje slik, ki je odlično za obrezovanje, spreminjanje velikosti in druge osnovne posege. Samo ne pričakujte alternative Photoshopu. A ima vseeno čarobno palico in plasti!

Pinta zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme, ki lahko iz slikovnega ozadja izvleče barve in jih spremeni v popolno, skladno temo. To je najlažji način, da [ustvarite svojo temo](43-making-your-own-theme.md).

Aether zaženete prek zaganjalnika aplikacij (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vam omogoča pošiljanje datotek drugim napravam v istem omrežju, v katerih je zagnana aplikacija, podobno kot Applov AirDrop. Je pa medplatformska, zato lahko datoteke pošiljate v sisteme Windows, macOS, Android, iOS in seveda Linux ter iz njih.

Meni Share lahko odprete s `Super + Ctrl + S` ali prek _Trigger > Share_ v meniju Omarchy. Ponudi vam štiri možnosti:

- **Clipboard** pošlje vse, kar ste kopirali, kot besedilno datoteko. Odlično, če želite povezavo ali izrezek spraviti na telefon, ne da bi si pošiljali e-pošto.
- **File** odpre izbirnik datotek, v katerem lahko izberete več datotek hkrati.
- **Folder** pošlje celoten imenik.
- **Receive** odpre pravi LocalSend, da vam lahko druga naprava kaj pošlje.

Isto deluje iz terminala z `omarchy share clipboard`, `omarchy share file [path]` in `omarchy share folder [path]`. Če pot izpustite, dobite izbirnik.

Pošiljate lahko tudi neposredno iz upravitelja datotek: v Nautilusu z desno tipko kliknite katerikoli izbor in izberite _Send via LocalSend_.

Požarni zid sistema Omarchy je privzeto zaprt, razen za vrata aplikacije LocalSend, zato to deluje že takoj po sveži namestitvi. Glejte [varnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je popoln pisarniški paket z urejevalnikom besedil, preglednicami, predstavitvami, aplikacijo za risanje in še več. Združljiv je z datotekami iz Microsoft Office, zato je to odličen način, da lahko odprete tiste Wordove dokumente.

LibreOffice zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je mrtvo preprosta aplikacija za predstavitve, lastna aplikacija sistema Omarchy. Vaš komplet je ena sama datoteka Markdown s slikami in videoposnetki ob njej: vsak diapozitiv napišite pod sprotnim predogledom, diapozitive povlecite v vrstni red, nato predstavite celozaslonsko ali izvozite v PDF in PowerPoint. Pobere celo vašo temo Omarchy.

Hype zaženete prek zaganjalnika aplikacij (`Super + Space`). V njej pritisnite `?`, da vidite vse bližnjice.

## Signed

[Signed](https://github.com/omacom/signed) je mrtvo preprost način sistema Omarchy za podpisovanje in izpolnjevanje PDF-jev. Shranjeni podpis, besedilo in današnji datum postavite kamorkoli na stran, nato shranite podpisano kopijo ob izvirnik. Glejte [Izpolnjevanje PDF-jev](27-filling-out-pdfs.md) za navodila.

Signed zaženete prek zaganjalnika aplikacij (`Super + Space`) ali z njim odprete PDF iz upravitelja datotek.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je mrtvo preprosto računalo, lastna aplikacija sistema Omarchy, ki se odpre v lebdečem oknu.

Omacalc zaženete s `Super + Shift + Q` (ali s tipko za računalo, če jo vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir sporočanja s šifriranjem E2E in odlična komunikacijska možnost za vsakogar, ki raje ne bi šel prek enega od velikih tehnoloških konglomeratov.

Signal zaženete s `Super + Shift + G`. Ni del osnovne namestitve, zato vam bo Omarchy ob prvem pritisku ponudil, da ga namesti namesto vas (na voljo je tudi pod _Install > Service_ v meniju Omarchy).

## mpv

[mpv](https://mpv.io/) je preprost, hiter predvajalnik predstavnosti, ki bo predvajal skoraj vse iz kateregakoli vira. Odličen za gledanje videoposnetkov.

mpv zaženete prek zaganjalnika aplikacij (`Super + Space`) ali preprosto dvokliknete videoposnetek v upravitelju datotek.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je mrtvo preprost rezalnik videoposnetkov, lastna aplikacija sistema Omarchy. Ko morate le odrezati začetek in konec posnetka, premaga zagon polnega urejevalnika videoposnetkov.

Omacut zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je mrtvo preprost snemalnik s spletno kamero, lastna aplikacija sistema Omarchy. Enkrat izberite kamero in mikrofon, nato pritisnite `Space` za snemanje in še enkrat za premor in nadaljevanje istega posnetka. Vedno snema v najvišji ločljivosti vaše kamere, z živim merilnikom mikrofona, da lahko pred začetkom preverite ravni.

Ustavite posnetek in takoj se odpre v vgrajenem urejevalniku. Dvokliknite posnetek, da ga razdelite, povlecite ročice, da obrežete vsak del, in odstranite dele, ki jih ne želite. Nato ga shranite kot MP4. Vaš izvirni posnetek se hrani, dokler ga ne zavržete, zato se lahko vedno vrnete in ga odrežete drugače.

Monologue zaženete prek zaganjalnika aplikacij (`Super + Space`).
