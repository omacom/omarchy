# Grafični programi

## Datoteke

Datoteke (Nautilus) so grafični upravitelj datotek. Odprete ga s `Super + Shift + F`, s `Super + Shift + Alt + F` pa ga odprete v imeniku, v katerem je trenutno vaš terminal, kar prihrani veliko klikanja. `Ctrl + L` vam omogoči vnos poti, pritisk tipke `Space` na katerikoli datoteki pa prikaže hitri predogled, ne da bi karkoli odprli.

Priključite ključek USB ali kartico SD in samodejno se priklopi, tako da se kar prikaže v stranski vrstici. Za kaj bolj zapletenega — formatiranje pogona, preverjanje zdravja SMART, ustvarjanje particij — zaženite _Disks_ iz zaganjalnika aplikacij (`Super + Space`).

Dvoklik sledi smiselnim privzetim nastavitvam: slike, videoposnetki in glasba se odprejo v Omaview, PDF-ji v Document Viewer, Markdown v Omawrite, navadno besedilo pa v urejevalniku, izbranem pod _Nastavitve > Privzeto > Urejevalnik_.

## Disktree

Ko se pogon napolni in nimate pojma, kaj ga žre, zaženite [Disktree](https://github.com/tobi/disktree) iz zaganjalnika aplikacij (`Super + Space`). Prikaže grafični drevesni zemljevid vašega domačega imenika. Večji bloki zavzamejo več prostora; po imenikih se sprehajajte s tipkovnico ali miško, označite, kaj mora iti, in preglejte svoje izbire, preden karkoli odstranite. Zaženite `disktree --disk`, da pregledate celoten disk.

## Obsidian

[Obsidian](https://obsidian.md/) je brezplačna in zelo razširljiva aplikacija za zapiske, ki za shranjevanje uporablja preproste datoteke Markdown.

Obsidian je brezplačen za vse namene, vključno z osebno, komercialno in neprofitno uporabo.

Obsidian ponuja tudi [komercialni dodatek za sinhronizacijo](https://obsidian.md/sync) z mobilnimi aplikacijami v sistemih iOS in Android. (https://obsidian.md/pricing).

Obsidian zaženete s `Super + Shift + O`. Za uporabo sinhronizacije teme morate v nastavitvah izbrati temo `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je Omarchyjeva lastna izjemno preprosta aplikacija za pisanje v Markdownu. Brez trezorjev, brez vtičnikov, samo vi in besede.

Omawrite zaženete s `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovno orodje za urejanje slik, ki je odlično za obrezovanje, spreminjanje velikosti in druge osnovne posege. Le ne pričakujte alternative za Photoshop. Pa še vedno ima čarobno palico in plasti!

Pinta zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme, ki lahko iz ozadne slike izvleče barve in jih spremeni v popolno, skladno temo. To je najlažji način, da [ustvarite svojo temo](43-making-your-own-theme.md).

Aether zaženete prek zaganjalnika aplikacij (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vam omogoča pošiljanje datotek drugim napravam v istem omrežju, v katerih teče aplikacija, podobno kot Applov AirDrop. Vendar je večplatformski, tako da lahko datoteke pošiljate v sisteme Windows, macOS, Android, iOS in seveda Linux ter iz njih.

Meni Deli odprete s `Super + Ctrl + S` ali pod _Prožilec > Deli_ v meniju Omarchy. Ponudi vam štiri možnosti:

- **Odložišče** pošlje vse, kar ste kopirali, kot besedilno datoteko. Odlično za prenos povezave ali izrezka na telefon, ne da bi si pošiljali e-pošto.
- **Datoteka** odpre izbirnik datotek, v katerem lahko izberete več hkrati.
- **Mapa** pošlje celoten imenik.
- **Prejmi** odpre pravi LocalSend, da vam lahko druga naprava kaj pošlje.

Enako deluje iz terminala z `omarchy share clipboard`, `omarchy share file [path]` in `omarchy share folder [path]`. Če pot izpustite, dobite izbirnik.

Pošiljate lahko tudi neposredno iz upravitelja datotek: v Nautilusu z desno tipko kliknite katerokoli izbiro in izberite _Pošlji prek LocalSend_.

Požarni zid v Omarchyju je privzeto zaprt, razen vrat za LocalSend, zato to deluje takoj po sveži namestitvi. Glejte [varnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je popoln pisarniški paket z urejevalnikom besedil, preglednicami, predstavitvami, aplikacijo za risanje in še čim. Združljiv je z datotekami iz Microsoft Office, tako da je to odličen način za odpiranje tistih Wordovih dokumentov.

LibreOffice zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je Omarchyjeva lastna izjemno preprosta aplikacija za predstavitve. Vaša predstavitev je ena sama datoteka Markdown s slikami in videoposnetki ob njej: vsak diapozitiv napišite pod živim predogledom, diapozitive povlecite v vrstni red, nato predstavite čez cel zaslon ali izvozite v PDF in PowerPoint. Pobere celo vašo temo Omarchy.

Hype zaženete prek zaganjalnika aplikacij (`Super + Space`). V njem pritisnite `?`, da si ogledate vse bližnjice.

## Signed

[Signed](https://github.com/omacom/signed) je Omarchyjev lastni izjemno preprost način za podpisovanje PDF-jev in njihovo izpolnjevanje. Shranjeni podpis, besedilo in današnji datum postavite kamorkoli na stran, nato shranite podpisano kopijo poleg izvirnika. Kako, si oglejte v [Izpolnjevanje PDF-jev](27-filling-out-pdfs.md).

Signed zaženete prek zaganjalnika aplikacij (`Super + Space`) ali pa z njim odprete PDF iz upravitelja datotek.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) je Omarchyjeva lastna 3D-šahovska igra. Igrajte s prijateljem na istem računalniku ali proti vgrajenemu nasprotniku na treh ravneh, na štirih izklesanih kompletih, od katerih se vsak premika na svoj način: orbitalna plovila, izrezljano drevo in slonovina, gozdna bitja in sladkarije. Igre so brez ure in se shranijo po vsaki potezi.

Checkmate zaženete prek zaganjalnika aplikacij (`Super + Space`), kjer je naveden kot Chess. V njem pritisnite `?`, da si ogledate vse bližnjice.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je Omarchyjev lastni izjemno preprost kalkulator, ki se odpre v plavajočem oknu.

Omacalc zaženete s `Super + Shift + Q` (ali s tipko za kalkulator, če jo vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir sporočanja s končnim šifriranjem E2E in odlična komunikacijska možnost za vse, ki raje ne bi šli prek enega od velikih tehnoloških konglomeratov.

Signal zaženete s `Super + Shift + G`. Ni del osnovne namestitve, zato vam bo Omarchy ob prvem pritisku na to ponudil, da ga namesti namesto vas (je tudi pod _Namesti > Storitev_ v meniju Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je Omarchyjev lastni izjemno preprost pregledovalnik slik in predvajalnik predstavnosti: eno okno za vaše fotografije, videoposnetke in glasbo. Odprite fotografijo in puščične tipke se pomikajo po preostalih v njeni mapi, `N` in `P` to naredita za karkoli, `Ctrl + M` pa prikaže celotno mapo kot mrežo. Prikaže tudi fotografije HEIC, AVIF in JPEG XL ter pri vsem dolgem nadaljuje tam, kjer ste obstali.

Pritisnite `F` za celozaslonski način, `E` za urejanje slike v Omasnap ali obrezovanje videoposnetka v Omacut, `Ctrl + P` za tiskanje slike in `Delete` za premik datoteke v smetnjak (`Ctrl + Z` jo vrne nazaj). V njem pritisnite `?`, da si ogledate vse bližnjice.

Omaview zaženete kot _Media Viewer_ prek zaganjalnika aplikacij (`Super + Space`) ali pa v upravitelju datotek preprosto dvokliknete sliko, videoposnetek ali pesem.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je Omarchyjev lastni izjemno preprost obrezovalnik videoposnetkov. Ko morate posnetku le odrezati začetek in konec, premaga zagon polnega urejevalnika videoposnetkov.

Omacut zaženete prek zaganjalnika aplikacij (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je Omarchyjev lastni izjemno preprost snemalnik s spletno kamero. Enkrat izberite kamero in mikrofon, nato pritisnite `Space` za snemanje ter znova za premor in nadaljevanje istega posnetka. Vedno snema pri najvišji ločljivosti vaše kamere, z merilnikom mikrofona v živo, da lahko pred začetkom preverite svoje ravni.

Ustavite posnetek in takoj se odpre v vgrajenem urejevalniku. Dvokliknite posnetek, da ga razdelite, povlecite ročice, da obrežete vsak kos, in odstranite dele, ki jih ne želite. Nato ga shranite kot MP4. Vaš izvirni posnetek se ohrani, dokler ga ne zavržete, tako da se lahko vedno vrnete in ga obrežete drugače.

Monologue zaženete prek zaganjalnika aplikacij (`Super + Space`).
