# Grafični vmesniki

## Datoteke

Datoteke (Nautilus) je grafični upravitelj datotek. `Super + Shift + F` ga odpre, `Super + Shift + Alt + F` pa ga odpre v imeniku, v katerem je trenutno vaš terminal, kar prihrani veliko klikanja. `Ctrl + L` vam omogoča vnos poti, pritisk tipke `Space` na katero koli datoteko pa vam pokaže hiter predogled, ne da bi karkoli odprli.

Priključite ključek USB ali kartico SD in samodejno se priklopi, tako da se preprosto pokaže v stranski vrstici. Za kaj bolj zapletenega — formatiranje pogona, preverjanje zdravja SMART, ustvarjanje particij — zaženite _Disks_ iz zaganjalnika aplikacij (`Super + Space`).

Dvoklik sledi smiselnim privzetim nastavitvam: slike, videi in glasba se odprejo v Omaview, PDF-ji v Document Viewer, Markdown v Omawrite, navadno besedilo pa v urejevalniku, izbranem pod _Setup > Default > Editor_.

## Disktree

Ko se pogon napolni in nimate pojma, kaj ga žre, zaženite [Disktree](https://github.com/tobi/disktree) iz zaganjalnika aplikacij (`Super + Space`). Pokaže grafični drevesni zemljevid vašega domačega imenika. Večji bloki zavzamejo več prostora; po imenikih se sprehajajte s tipkovnico ali miško, označite, kaj mora iti, in preglejte svoje izbire, preden karkoli odstranite. Zaženite `disktree --disk`, da pregledate celoten disk.

## Obsidian

[Obsidian](https://obsidian.md/) je brezplačna in zelo razširljiva aplikacija za zapiske, ki za shranjevanje uporablja preproste datoteke Markdown.

Obsidian je brezplačen za vse namene, vključno z osebno, komercialno in nepridobitno uporabo.

Obsidian ponuja tudi [komercialni dodatek za sinhronizacijo](https://obsidian.md/sync) z mobilnimi aplikacijami v sistemih iOS in Android. (https://obsidian.md/pricing).

Obsidian zaženete s `Super + Shift + O`. Če želite uporabljati sinhronizacijo teme, morate v nastavitvah izbrati temo `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je lastna mrtvo preprosta aplikacija sistema Omarchy za pisanje v Markdownu. Brez trezorjev, brez vtičnikov, samo vi in besede.

Omawrite zaženete s `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovno orodje za urejanje slik, ki je odlično za obrezovanje, spreminjanje velikosti in druge osnovne obdelave. Samo ne pričakujte alternative za Photoshop. Pa še vedno ima Magic Wand in plasti!

Pinta zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme, ki lahko iz ozadne slike izlušči barve in jih pretvori v celotno, povezano temo. To je najlažji način, da [izdelate svojo temo](43-making-your-own-theme.md).

Aether zaženete prek zaganjalnika aplikacij (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vam omogoča pošiljanje datotek drugim napravam v istem omrežju, v katerih je zagnana ta aplikacija, podobno kot AirDrop podjetja Apple. Je pa medplatformska, tako da lahko datoteke pošiljate v sisteme Windows, macOS, Android, iOS in seveda Linux ter iz njih.

Meni Share lahko odprete s `Super + Ctrl + S` ali pod _Trigger > Share_ v meniju Omarchy. Ponuja vam štiri možnosti:

- **Clipboard** pošlje vse, kar ste kopirali, kot besedilno datoteko. Odlično, da povezavo ali delček dobite na telefon, ne da bi si pošiljali e-pošto.
- **File** odpre izbirnik datotek, v katerem lahko izberete več hkrati.
- **Folder** pošlje celoten imenik.
- **Receive** odpre pravi LocalSend, tako da vam lahko druga naprava kaj pošlje.

Enako deluje iz terminala s `omarchy share clipboard`, `omarchy share file [path]` in `omarchy share folder [path]`. Če pot izpustite, dobite izbirnik.

Pošljete lahko tudi naravnost iz upravitelja datotek: v Nautilusu z desno tipko kliknite poljubno izbiro in izberite _Send via LocalSend_.

Požarni zid sistema Omarchy je privzeto zaprt, razen za vrata aplikacije LocalSend, tako da to deluje takoj po sveži namestitvi. Glejte [varnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je celoten pisarniški paket z urejevalnikom besedil, preglednicami, predstavitvami, aplikacijo za risanje in še več. Združljiv je z datotekami iz Microsoft Office, tako da je to odličen način, da lahko odpirate tiste dokumente Word.

LibreOffice zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je lastna mrtvo preprosta aplikacija sistema Omarchy za predstavitve. Vaša predstavitev je ena sama datoteka Markdown, ob njej pa so njene slike in videi: vsako prosojnico napišite pod predogledom v živo, prosojnice povlecite v vrstni red, nato predstavite v celozaslonskem načinu ali izvozite v PDF in PowerPoint. Pobere celo vašo temo Omarchy.

Hype zaženete prek zaganjalnika aplikacij (`Super + Space`). V njej pritisnite `?`, da vidite vse bližnjice.

## Signed

[Signed](https://github.com/omacom/signed) je lastni mrtvo preprosti način sistema Omarchy za podpisovanje PDF-jev in njihovo izpolnjevanje. Svoj shranjeni podpis, besedilo in današnji datum postavite kamor koli na stran, nato pa podpisano kopijo shranite ob izvirniku. Kako to storite, glejte v [Izpolnjevanje PDF-jev](27-filling-out-pdfs.md).

Signed zaženete prek zaganjalnika aplikacij (`Super + Space`) ali pa z njim odprete PDF iz upravitelja datotek.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) je lastna 3D šahovska igra sistema Omarchy. Igrajte s prijateljem na istem računalniku ali proti vgrajenemu nasprotniku na treh ravneh, s štirimi oblikovanimi kompleti figur, od katerih se vsak premika na svoj način: orbitalna plovila, izrezljan les in slonovina, gozdna bitja in bonboni. Igre nimajo ure in se shranijo po vsaki potezi.

Checkmate zaženete prek zaganjalnika aplikacij (`Super + Space`), kjer je navedena kot Chess. V njej pritisnite `?`, da vidite vse bližnjice.

## Cards

[Cards](https://github.com/omacom/cards) je lastna igra pasjanse Klondike sistema Omarchy. Vlečete po tri, brez omejitve prehodov, v štirih serijah kart: ena je narisana v barvah vaše teme, tri pa imajo svoj videz. Kliknite karto in nato, kam gre, jo povlecite ali dvokliknite, da jo pošljete na najboljše mesto. Igre se shranijo po vsaki potezi.

Cards zaženete prek zaganjalnika aplikacij (`Super + Space`). Kliknite njeno ime ali pritisnite `?`, da vidite vse bližnjice.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je lastni mrtvo preprosti kalkulator sistema Omarchy, ki se odpre v plavajočem oknu.

Omacalc zaženete s `Super + Shift + Q` (ali s tipko za kalkulator, če jo vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir šifriranega sporočanja E2E in odlična možnost za komunikacijo za vsakogar, ki raje ne bi šel prek enega od velikih tehnoloških konglomeratov.

Signal zaženete s `Super + Shift + G`. Ni del osnovne namestitve, zato vam bo Omarchy, ko boste to kombinacijo pritisnili prvič, ponudil, da ga namesti namesto vas (je tudi pod _Install > Service_ v meniju Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je lastni mrtvo preprosti pregledovalnik slik in predvajalnik predstavnosti sistema Omarchy: eno okno za vaše fotografije, videe in glasbo. Odprite fotografijo in puščične tipke se pomikajo po preostanku njene mape, `N` in `P` to storita za kar koli, `Ctrl + M` pa pokaže celotno mapo kot mrežo. Prikazuje tudi fotografije HEIC, AVIF in JPEG XL ter pri daljših vsebinah nadaljuje tam, kjer ste ostali.

Pritisnite `F` za celozaslonski način, `E` za urejanje slike v Omasnap ali obrezovanje videa v Omacut, `Ctrl + P` za tiskanje slike in `Delete` za premik datoteke v Koš (`Ctrl + Z` jo pripelje nazaj). V njem pritisnite `?`, da vidite vse bližnjice.

Omaview zaženete kot _Media Viewer_ prek zaganjalnika aplikacij (`Super + Space`) ali pa preprosto dvokliknete fotografijo, video ali pesem v upravitelju datotek.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je lastni mrtvo preprosti obrezovalnik videov sistema Omarchy. Ko morate le odrezati začetek in konec posnetka, je boljši kot zagnati celoten urejevalnik videa.

Omacut zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je lastni mrtvo preprosti snemalnik s spletno kamero sistema Omarchy. Enkrat izberite kamero in mikrofon, nato pritisnite `Space` za snemanje in še enkrat za premor in nadaljevanje istega posnetka. Vedno snema v najvišji ločljivosti vaše kamere, z merilnikom mikrofona v živo, tako da lahko pred začetkom preverite svoje ravni.

Ustavite posnetek in takoj se odpre v vgrajenem urejevalniku. Dvokliknite posnetek, da ga razdelite, povlecite ročice, da obrežete vsak del, in odstranite dele, ki jih ne želite. Nato ga shranite kot MP4. Vaš izvirni posnetek se obdrži, dokler ga ne zavržete, tako da se lahko vedno vrnete in ga obrežete drugače.

Monologue zaženete prek zaganjalnika aplikacij (`Super + Space`).
