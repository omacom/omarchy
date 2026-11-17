# Preklopnici, mirovanje i čuvar zaslona

Mnogo toga što mijenjaš iz dana u dan zapravo nije postavka. To je način rada koji uključiš na sat vremena pa ga opet isključiš: noćno svjetlo dok radiš do kasno, ne ometaj dok prezentiraš, ostani budan dok nešto gledaš. Omarchy ih zove preklopnicima i svi rade na isti način — prečac, stavka u izborniku i naredba, svi pogađaju isti prekidač.

### Izbornik preklopnika

`Super + Ctrl + O` otvara izravno _Trigger > Toggle_, ili tamo možeš doći iz Omarchy izbornika (`Super + Space`). Sve na tom popisu je prekidač koji možeš prebaciti bez razmišljanja o tome gdje stanje živi. Prekidači za izgled radne površine sjede pokraj njega, pod _Appearance_.

Iz terminala, isti prekidači su `omarchy toggle <thing>`. Pokreni samo `omarchy toggle` da vidiš cijelu skupinu.

| Preklopnik | Prečac | Naredba |
| ------ | ------ | ------- |
| Noćno svjetlo | — | `omarchy toggle nightlight` |
| Utišaj obavijesti | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ostani budan (bez zaključavanja u mirovanju) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Prikupljanje podataka o rušenju | — | `omarchy toggle crash-capture` |
| Čuvar zaslona | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sinkronizacija teme | — | `omarchy toggle theme sync` |
| Traka izbornika | `Super + Shift + Space` | `omarchy toggle bar` |
| Dodirna pločica | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Dodirni zaslon | — | `omarchy toggle touchscreen` |
| Obustava | — | `omarchy toggle suspend` |
| Hibridni GPU | — | `omarchy toggle hybrid gpu` |

Preklopnici za dodirnu pločicu, dodirni zaslon i hibridni GPU nalaze se pod _Trigger > Hardware_ (`Super + Ctrl + H`) umjesto pod Toggle, jer se pojavljuju samo kad doista imaš taj hardver. Preklopnici za dodirnu pločicu i dodirni zaslon preživljavaju ponovno učitavanje Hyprlanda — naziv onemogućenog uređaja sprema se u malu datoteku stanja koju Hyprland čita pri pokretanju kako bi ga ponovno onemogućio.

_Appearance_ sadrži traku izbornika i animacije, plus nekoliko stvari koje nisu naredbe `omarchy toggle`, ali se ponašaju isto: postotak baterije u traci, zadani raspored radnog prostora i, pod _Windows_, razmake među prozorima (`Super + Shift + Backspace`) i kvadratni omjer za 1 prozor (`Super + Ctrl + Backspace`).

Kad Hyprland nema GPU za crtanje i umjesto toga renderira na CPU-u (llvmpipe), kao na Macovima čiji GPU još nije podržan, u većini virtualnih strojeva ili kad se grafički upravljački program ne uspije učitati, Omarchy za tu sesiju isključuje animacije, zamućenje i sjene i kaže ti to jednom obaviješću. _Appearance > Animations On_ ih vraća, a Omarchy to pamti i za kasnije sesije.

Većina ih je samo datoteka zastavice pod `~/.local/state/omarchy/toggles/`. Ako u skripti želiš granati prema jednoj od njih, `omarchy-toggle-enabled` daje ti izlazni kod umjesto da moraš ići tražiti:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Zastavice su nazvane po isključenom stanju — `screensaver-off`, `suspend-off`, `bar-off` — pa njihova prisutnost znači da je značajka onemogućena.

### Pokazatelji u traci

Kad je način rada uključen, dobiješ mali glif u sredini gornje trake pokraj sata. To je widget za pokazatelje i nosi diktiranje, snimanje zaslona, podsjetnike na čekanju, noćno svjetlo, ne ometaj i ostani budan.

Neaktivni pokazatelji su skriveni. Zadrži pokazivač bilo gdje na traci i oni će se pojaviti prigušeni, pa možeš kliknuti jedan da ga uključiš bez poznavanja njegovog prečaca. Klik na aktivni isključuje ga. Ako ih radije vidiš sve stalno, postavi `alwaysShow` na `true` na unosu `omarchy.indicators` u `~/.config/omarchy/shell.json` — vidi [gornju traku](05-the-top-bar.md) za to kako se widgeti trake konfiguriraju.

### Noćno svjetlo

Noćno svjetlo zagrijava zaslon na 4000K, a ponovno prebacivanje vraća ga na 6500K. Prebaci ga iz izbornika preklopnika (`Super + Ctrl + O`) ili s `omarchy toggle nightlight`. Pokreće ga hyprsunset, koji preklopnik pokreće za tebe ako već ne radi.

Prema zadanim postavkama hyprsunset uopće ništa ne radi tvom zaslonu. `~/.config/hypr/hyprsunset.conf` dolazi s identitetskim profilom upravo zato da zaslon ostane netaknut dok ne zatražiš toplinu. Ako radije želiš da se mijenja prema satu, zamijeni to vremenskim profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Zatim pokreni hyprsunset pri prijavi dodavanjem `o.launch_on_start("hyprsunset")` u `~/.config/hypr/autostart.lua`. Par 4000K/6500K koji koristi preklopnik je fiksan, pa je konfiguracijska datoteka mjesto kamo ideš ako želiš drugačiju temperaturu.

### Ne ometaj

`Super + Ctrl + Alt + ,` utišava obavijesti. Dok je uključeno, ne iskaču nikakve tost-obavijesti, a pokazatelj prekriženog zvona sjedi u traci da te podsjeti zašto je radna površina utihnula.

Ništa se ipak ne gubi. Utišane obavijesti se zadržavaju: vrati posljednjih nekoliko natrag na zaslon s `Super + Shift + Alt + ,`. Vidi [obavijesti](10-notices.md) za ostalo.

Dvije vrste poruka i dalje prolaze: Omarchyjeve vlastite potvrdne tost-obavijesti za nešto što si upravo napravio („Tema je promijenjena“, „Snimka zaslona je spremljena“) i kritična upozorenja poslana iz naredbenog retka. Aplikacije za chat koje sve označavaju kao kritično da bi se silom probile ispred tebe ne kvalificiraju se.

### Mirovanje

Omarchy ljuska vlasnik je ponašanja u mirovanju, a vremena su blok `idle` na najvišoj razini u `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Oba broja su sekunde brojane od trenutka kad si otišao u mirovanje — ne jedan od drugoga. Dakle, sa zadanim postavkama, čuvar zaslona pojavljuje se nakon dvije i pol minute, a zaključani zaslon preuzima nakon pet minuta, bez obzira je li čuvar zaslona radio ili ne. Spremi datoteku i ljuska odmah pokupi nova vremena.

Ako odbaciš čuvar zaslona prije roka za zaključavanje, to se računa kao aktivnost i zaključavanje na čekanju se otkazuje. Nećeš ostati zaključan vani zato što si bacio pogled na svoje računalo.

Da u mirovanju uopće prestane zaključavati, `Super + Ctrl + I` — ili `omarchy toggle idle` — uključuje ostani budan, a pokazatelj šalice kave pojavljuje se u traci. Taj trebaš pritisnuti prije duge prezentacije ili builda koji želiš gledati. Pritisni ga ponovno da se vratiš na normalno. `omarchy toggle idle status` ispisuje trenutno stanje kao JSON ako ti treba iz skripte.

Ovdje se radi o zaključavanju i čuvaru zaslona, ne o napajanju. Obustava i hibernacija imaju vlastitu postavku u [spavanju sustava](36-system-sleep.md).

### Čuvar zaslona

Omarchyjev čuvar zaslona je ASCII umjetnost koja prolazi kroz nasumične tekstualne efekte, po jedna instanca po monitoru. Bilo koja tipka ili pokret miša izlazi iz njega.

Možeš ga pokrenuti na zahtjev iz _System > Screensaver_ (`Super + Esc`), što ga prisilno pokreće čak i ako si isključio čuvar zaslona u mirovanju. Prema zadanim postavkama za njega nije vezan nikakav prečac.

`omarchy toggle screensaver` je ono što isključuje onaj u mirovanju, ako radije ideš ravno s posla na zaključano. Bilo koja tipka, klik, pomicanje kotačića ili pokret miša zatvara ga.

Logotip koji crta tvoj je da ga promijeniš, pod _Appearance > Branding > Screensaver_. Prenesi png ili svg i Omarchy će ga pretvoriti u ASCII. Vidi [brendiranje](41-branding.md).

### Zaključani zaslon

`Super + Ctrl + L` zaključava računalo. To pokreće zaključani zaslon iz Omarchy ljuske, zatamnjuje zaslon, vraća raspored tipkovnice na prvi kako ne bi tipkao lozinku u pogrešnoj abecedi i — ako ti radi — zaključava 1Password na izlazu.

Zaključani zaslon prima lozinku, a primit će i otisak prsta kad ga postaviš. To, i drugi načini autentifikacije, obrađeni su u [hardverskoj autentifikaciji](37-hardware-authentication.md).
