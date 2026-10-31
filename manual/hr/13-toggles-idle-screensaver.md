# Prekidači, mirovanje i čuvar zaslona

Mnogo toga što mijenjaš iz dana u dan zapravo i nije postavka. To je način rada koji uključiš na sat vremena pa opet isključiš: noćno svjetlo dok radiš do kasno, ne ometaj dok izlažeš, ostani budan dok nešto gledaš. Omarchy ih naziva prekidačima i svi rade na isti način — prečac, stavka izbornika i naredba, svi pogađaju isti prekidač.

### Izbornik prekidača

`Super + Ctrl + O` izravno otvara _Trigger > Toggle_, a do tamo možeš doći i iz izbornika Omarchy (`Super + Space`). Sve na tom popisu je prekidač koji možeš prebaciti bez razmišljanja o tome gdje se stanje nalazi. Prekidači za izgled radne površine nalaze se odmah pokraj, pod _Appearance_.

Iz terminala su isti prekidači `omarchy toggle <thing>`. Pokreni sam `omarchy toggle` da vidiš cijelu skupinu.

| Prekidač | Prečac | Naredba |
| ------ | ------ | ------- |
| Noćno svjetlo | — | `omarchy toggle nightlight` |
| Utišaj obavijesti | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ostani budan (bez zaključavanja u mirovanju) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Snimanje rušenja | — | `omarchy toggle crash-capture` |
| Čuvar zaslona | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sinkronizacija teme | — | `omarchy toggle theme sync` |
| Traka izbornika | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Zaslon osjetljiv na dodir | — | `omarchy toggle touchscreen` |
| Obustava | — | `omarchy toggle suspend` |
| Hibridni GPU | — | `omarchy toggle hybrid gpu` |

Prekidači za touchpad, zaslon osjetljiv na dodir i hibridni GPU nalaze se pod _Trigger > Hardware_ (`Super + Ctrl + H`), a ne pod Toggle, jer se pojavljuju samo kad taj hardver stvarno imaš. Prekidači za touchpad i zaslon osjetljiv na dodir preživljavaju ponovno učitavanje Hyprlanda — naziv onemogućenog uređaja sprema se u malu datoteku stanja koju Hyprland čita pri pokretanju kako bi ga ponovno onemogućio.

Pod _Appearance_ nalaze se traka izbornika i animacije, plus nekoliko stvari koje nisu naredbe `omarchy toggle`, ali se ponašaju jednako: postotak baterije u traci, zadani raspored radnog prostora i, pod _Windows_, razmaci među prozorima (`Super + Shift + Backspace`) i kvadratni omjer za 1 prozor (`Super + Ctrl + Backspace`).

Većina njih samo je datoteka zastavice pod `~/.local/state/omarchy/toggles/`. Ako u skripti želiš granati prema nekoj od njih, `omarchy-toggle-enabled` daje ti izlazni kod umjesto da ih moraš tražiti:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Zastavice su nazvane po isključenom stanju — `screensaver-off`, `suspend-off`, `bar-off` — pa njihova prisutnost znači da je značajka onemogućena.

### Indikatori u traci

Kad je neki način rada uključen, u sredini gornje trake, pokraj sata, dobiješ mali glif. To je widget indikatora i nosi diktiranje, snimanje zaslona, podsjetnike na čekanju, noćno svjetlo, ne ometaj i ostani budan.

Neaktivni indikatori su skriveni. Prijeđi pokazivačem bilo gdje na traci i oni će se prigušeno pojaviti, pa možeš kliknuti jedan da ga uključiš bez poznavanja njegova prečaca. Klik na aktivni vraća ga u isključeno stanje. Ako ih radije želiš vidjeti sve cijelo vrijeme, postavi `alwaysShow` na `true` na unosu `omarchy.indicators` u `~/.config/omarchy/shell.json` — vidi [gornju traku](05-the-top-bar.md) za to kako se widgeti trake konfiguriraju.

### Noćno svjetlo

Noćno svjetlo zagrijava zaslon na 4000K, a ponovno prebacivanje vraća ga na 6500K. Prebaci ga iz izbornika prekidača (`Super + Ctrl + O`) ili naredbom `omarchy toggle nightlight`. Pokreće ga hyprsunset, koji prekidač za tebe pokreće ako već ne radi.

Prema zadanim postavkama hyprsunset uopće ništa ne radi tvom zaslonu. `~/.config/hypr/hyprsunset.conf` dolazi s identitetskim profilom upravo zato da zaslon ostane netaknut dok ne zatražiš toplinu. Ako radije želiš da se mijenja prema satu, zamijeni to vremenskim profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Zatim pokreni hyprsunset pri prijavi dodavanjem `o.launch_on_start("hyprsunset")` u `~/.config/hypr/autostart.lua`. Par 4000K/6500K koji koristi prekidač je fiksan, pa je konfiguracijska datoteka mjesto na koje ideš ako želiš drugu temperaturu.

### Ne ometaj

`Super + Ctrl + Alt + ,` utišava obavijesti. Dok je uključeno, ne pojavljuju se nikakve skočne obavijesti, a precrtano zvonce u traci podsjeća te zašto je radna površina utihnula.

Ipak, ništa se ne gubi. Utišane obavijesti zadržavaju se: posljednjih nekoliko vrati na zaslon s `Super + Shift + Alt + ,`. Ostatak vidi u [obavijestima](10-notices.md).

Dvije vrste poruka i dalje prolaze: vlastite potvrdne skočne poruke Omarchyja za nešto što si upravo napravio ("Theme changed", "Screenshot saved") i kritična upozorenja poslana iz naredbenog retka. Aplikacije za razgovor koje sve označavaju kao kritično kako bi se silom progurale ispred tebe ne računaju se.

### Mirovanje

Omarchyjeva ljuska upravlja ponašanjem u mirovanju, a vremenske postavke su blok `idle` na najvišoj razini u `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Oba broja su sekunde koje se broje od trenutka kad si prešao u mirovanje — ne jedan od drugoga. Dakle, sa zadanim postavkama čuvar zaslona pojavljuje se nakon dvije i pol minute, a zaslon za zaključavanje preuzima nakon pet minuta, bez obzira na to je li se čuvar zaslona pokrenuo. Spremi datoteku i ljuska će odmah preuzeti nova vremena.

Ako odbaciš čuvara zaslona prije roka za zaključavanje, to se računa kao aktivnost i zaključavanje na čekanju se otkazuje. Nećeš biti zaključan zato što si bacio pogled na svoje računalo.

Da uopće prestaneš sa zaključavanjem u mirovanju, `Super + Ctrl + I` — ili `omarchy toggle idle` — uključuje ostani budan i u traci se pojavljuje indikator šalice kave. Taj pritisni prije duge prezentacije ili izgradnje koju želiš pratiti. Pritisni ga ponovno za povratak na normalno. `omarchy toggle idle status` ispisuje trenutno stanje kao JSON ako ti treba iz skripte.

Ovdje se radi o zaključavanju i čuvaru zaslona, ne o napajanju. Obustava i hibernacija imaju vlastitu postavku u [spavanju sustava](36-system-sleep.md).

### Čuvar zaslona

Omarchyjev čuvar zaslona je ASCII umjetnost koja prolazi kroz nasumične tekstualne efekte, po jedna instanca za svaki monitor. Svaka tipka ili pomak miša izlazi iz njega.

Možeš ga pokrenuti na zahtjev iz _System > Screensaver_ (`Super + Esc`), što ga prisilno pokreće čak i ako si isključio čuvara zaslona u mirovanju. Prema zadanim postavkama za njega nije vezan nijedan prečac.

`omarchy toggle screensaver` isključuje onoga u mirovanju, ako radije ideš ravno s posla na zaključavanje. Svaka tipka, klik, pomicanje kotačićem ili pomak miša zatvara ga.

Logotip koji crta možeš promijeniti pod _Appearance > Branding > Screensaver_. Prenesi png ili svg i Omarchy će ga pretvoriti u ASCII. Vidi [brendiranje](41-branding.md).

### Zaslon za zaključavanje

`Super + Ctrl + L` zaključava računalo. To pokreće zaslon za zaključavanje iz Omarchyjeve ljuske, isprazni zaslon, vraća raspored tipkovnice na prvi kako ne bi upisivao lozinku pogrešnom abecedom i — ako ti radi — usput zaključava 1Password.

Zaslon za zaključavanje prihvaća lozinku, a prihvatit će i otisak prsta kad ga postaviš. To, i ostali načini provjere autentičnosti, obrađeni su u [hardverskoj provjeri autentičnosti](37-hardware-authentication.md).
