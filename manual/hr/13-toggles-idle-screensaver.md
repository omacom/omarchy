# Prekidači, neaktivnost i čuvar zaslona

Mnogo toga što mijenjaš iz dana u dan zapravo nije postavka. To je način rada koji uključiš na sat vremena pa ga opet isključiš: noćno svjetlo dok radiš do kasno, ne ometaj dok držiš prezentaciju, ostani budan dok nešto gledaš. Omarchy ih naziva prekidačima i svi rade na isti način — prečac, stavka izbornika i naredba, svi pogađaju isti prekidač.

### Izbornik prekidača

`Super + Ctrl + O` izravno otvara _Trigger > Toggle_, ili do tamo možeš doći iz izbornika Omarchy (`Super + Space`). Sve na tom popisu je prekidač koji možeš prebaciti bez razmišljanja o tome gdje se stanje čuva. Prekidači za izgled radne površine nalaze se odmah pored, pod _Appearance_.

Iz terminala su isti prekidači `omarchy toggle <thing>`. Pokreni samo `omarchy toggle` da vidiš cijelu skupinu.

| Prekidač | Prečac | Naredba |
| ------ | ------ | ------- |
| Noćno svjetlo | — | `omarchy toggle nightlight` |
| Utišaj obavijesti | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ostani budan (bez zaključavanja u neaktivnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Snimanje rušenja | — | `omarchy toggle crash-capture` |
| Čuvar zaslona | — | `omarchy toggle screensaver` |
| Sinkronizacija teme za [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Traka izbornika | `Super + Shift + Space` | `omarchy toggle bar` |
| Radna površina preko cijelog zaslona (bez trake, bez razmaka) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animacije, zamućenje i sjene | — | `omarchy toggle animations` |
| Dodirna podloga | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Zaslon osjetljiv na dodir | — | `omarchy device touchscreen` |
| Suspenzija | — | `omarchy toggle suspend` |
| Hibridni GPU | — | `omarchy device gpu hybrid` |

Prekidači za dodirnu podlogu, zaslon osjetljiv na dodir i hibridni GPU nalaze se pod _Trigger > Hardware_ (`Super + Ctrl + H`), a ne pod Toggle, jer se pojavljuju samo kad doista imaš taj hardver. Prekidači za dodirnu podlogu i zaslon osjetljiv na dodir preživljavaju ponovno učitavanje Hyprlanda — naziv onemogućenog uređaja sprema se u malu datoteku stanja koju Hyprland čita pri pokretanju da bi ga ponovno onemogućio.

U _Appearance_ nalaze se traka izbornika i animacije, plus nekoliko stvari koje nisu naredbe `omarchy toggle`, ali se ponašaju isto: postotak baterije u traci, zadani raspored radnih prostora i, pod _Windows_, razmaci među prozorima (`Super + Shift + Backspace`) i kvadratni omjer za 1 prozor (`Super + Ctrl + Backspace`).

Kad Hyprland nema GPU za crtanje i umjesto toga renderira na CPU-u (llvmpipe), kao na Macovima čiji GPU još nije podržan, u većini virtualnih strojeva ili kad se grafički upravljački program ne učita, Omarchy za tu sesiju isključuje animacije, zamućenje i sjene i jednom te o tome obavijesti obaviješću. _Appearance > Animations On_ ih vraća, a Omarchy to pamti i za kasnije sesije.

Većina njih samo je datoteka zastavice pod `~/.local/state/omarchy/toggles/`. Ako u skripti želiš granati na temelju jedne, `omarchy-toggle-enabled` ti daje izlazni kod umjesto da moraš tražiti:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Zastavice su nazvane po isključenom stanju — `screensaver-off`, `suspend-off`, `bar-off` — pa njihova prisutnost znači da je značajka onemogućena.

### Indikatori u traci

Kad je neki način rada uključen, dobiješ mali glif u sredini gornje trake pored sata. To je widget za indikatore i nosi snimanje zaslona, podsjetnike na čekanju, noćno svjetlo, ne ometaj i ostani budan, plus upozorenja dok je sudo bez lozinke uključen ili je netko povezan na udaljenu sesiju.

Neaktivni indikatori su skriveni. Pređi mišem bilo gdje preko trake i oni će se pojaviti prigušeni, pa možeš kliknuti jedan da ga uključiš bez poznavanja njegova prečaca. Klik na aktivni vraća ga u isključeno stanje. Ako ih radije želiš vidjeti sve stalno, postavi `alwaysShow` na `true` na stavci `omarchy.indicators` u `~/.config/omarchy/shell.json` — pogledaj [gornju traku](05-the-top-bar.md) za to kako se widgeti trake konfiguriraju.

### Noćno svjetlo

Noćno svjetlo zagrijava zaslon na 4000K, a ponovno prebacivanje vraća ga na 6500K. Prebaci ga iz izbornika prekidača (`Super + Ctrl + O`) ili s `omarchy toggle nightlight`. Pokreće ga hyprsunset, koji prekidač pokreće za tebe ako već ne radi.

Prema zadanim postavkama hyprsunset uopće ne radi ništa tvom zaslonu. `~/.config/hypr/hyprsunset.conf` dolazi s profilom identity upravo zato da zaslon ostane netaknut dok ne zatražiš toplinu. Ako radije želiš da se prebacuje prema satu, zamijeni to vremenskim profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Zatim pokreni hyprsunset pri prijavi dodavanjem `o.launch_on_start("hyprsunset")` u `~/.config/hypr/autostart.lua`. Par 4000K/6500K koji koristi prekidač je fiksan, pa je konfiguracijska datoteka mjesto kamo ideš ako želiš drugačiju temperaturu.

### Ne ometaj

`Super + Ctrl + Alt + ,` utišava obavijesti. Dok je uključeno, ne iskaču nikakve skočne obavijesti, a indikator prekriženog zvona sjedi u traci da te podsjeti zašto je radna površina utihnula.

Ipak se ništa ne gubi. Utišane obavijesti zadržavaju se: vrati posljednjih nekoliko na zaslon s `Super + Shift + Alt + ,`. Pogledaj [obavijesti](10-notices.md) za ostatak.

Tri vrste poruka i dalje prolaze: vlastite potvrdne skočne obavijesti Omarchyja za nešto što si upravo napravio ("Theme changed", "Screenshot saved"), kritična upozorenja poslana iz naredbenog retka i verifikacijski kodovi. Aplikacije za chat koje sve označavaju kritičnim da bi se silom probile ispred tebe ne zadovoljavaju uvjete.

### Neaktivnost

Ljuska Omarchyja upravlja ponašanjem u neaktivnosti, a vremena su blok `idle` na najvišoj razini u `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Oba broja su sekunde koje se broje od trenutka kad si postao neaktivan — ne jedan od drugoga. Dakle uz zadane vrijednosti čuvar zaslona pojavljuje se nakon dvije i pol minute, a zaslon za zaključavanje preuzima nakon pet minuta, bez obzira je li čuvar zaslona radio ili ne. Spremi datoteku i ljuska odmah preuzima nova vremena.

Ako odbaciš čuvara zaslona prije roka za zaključavanje, to se računa kao aktivnost i zaključavanje na čekanju se otkazuje. Neće te zaključati samo zato što si bacio pogled na računalo.

Da uopće zaustaviš zaključavanje u neaktivnosti, `Super + Ctrl + I` — ili `omarchy toggle idle` — uključuje ostani budan, a u traci se pojavljuje indikator šalice kave. To je onaj koji treba pritisnuti prije duge prezentacije ili builda koji želiš gledati. Pritisni ga ponovno da se vratiš u normalu. `omarchy toggle idle status` ispisuje trenutno stanje kao JSON ako ti treba iz skripte.

Ovdje je riječ o zaključavanju i čuvaru zaslona, a ne o napajanju. Suspenzija i hibernacija imaju vlastite postavke u [spavanju sustava](36-system-sleep.md).

### Čuvar zaslona

Čuvar zaslona Omarchyja je ASCII umjetnost koja prolazi kroz nasumične tekstualne efekte, po jedan primjerak po monitoru. Bilo koja tipka ili pokret miša izlazi iz njega.

Možeš ga pokrenuti na zahtjev iz _System > Screensaver_ (`Super + Esc`), što ga prisilno pokreće čak i ako si isključio čuvara zaslona u neaktivnosti. Prema zadanim postavkama za njega nije vezan nijedan prečac.

`omarchy toggle screensaver` isključuje onoga u neaktivnosti, ako radije ideš izravno s posla na zaključano. Bilo koja tipka, klik, pomicanje kotačićem ili pokret miša ga zatvara.

Logotip koji crta možeš promijeniti, pod _Appearance > Branding > Screensaver_. Prenesi png ili svg i Omarchy će ga pretvoriti u ASCII. Pogledaj [brendiranje](41-branding.md).

### Zaslon za zaključavanje

`Super + Ctrl + L` zaključava računalo. To pokreće zaslon za zaključavanje iz ljuske Omarchyja, zatamnjuje zaslon, vraća raspored tipkovnice na prvi da ne upisuješ lozinku u pogrešnoj abecedi i — ako ti radi — zaključava 1Password na izlasku.

Zaslon za zaključavanje prima lozinku, a primit će i otisak prsta kad ga postaviš. To i drugi načini autentifikacije obrađeni su u [hardverskoj autentifikaciji](37-hardware-authentication.md).
