# Preklopnici, mirovanje i čuvar zaslona

Mnogo toga što mijenjate iz dana u dan zapravo i nije postavka. To je način rada koji uključite na sat vremena i zatim opet isključite: noćno svjetlo dok radite do kasno, ne ometaj dok ste na prezentaciji, ostani budan dok nešto gledate. Omarchy ih naziva preklopnicima i svi rade na isti način — tipkovni prečac, stavka u izborniku i naredba, a svi pogađaju isti prekidač.

### Izbornik preklopnika

`Super + Ctrl + O` izravno otvara _Trigger > Toggle_, a možete doći i kroz Omarchy izbornik (`Super + Space`). Sve na tom popisu prekidač je koji možete prebaciti bez razmišljanja o tome gdje se stanje nalazi. Prekidači za izgled radne površine smješteni su odmah pokraj, pod _Appearance_.

Iz terminala su isti prekidači `omarchy toggle <thing>`. Pokrenite sam `omarchy toggle` da vidite cijelu grupu.

| Preklopnik | Tipkovni prečac | Naredba |
| ------ | ------ | ------- |
| Noćno svjetlo | — | `omarchy toggle nightlight` |
| Utišavanje obavijesti | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ostani budan (bez zaključavanja u mirovanju) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Bilježenje rušenja | — | `omarchy toggle crash-capture` |
| Čuvar zaslona | — | `omarchy toggle screensaver` |
| Sinkronizacija [Herdr](https://herdr.dev) teme | — | `omarchy toggle theme sync` |
| Traka izbornika | `Super + Shift + Space` | `omarchy toggle bar` |
| Dodirna pločica | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Zaslon osjetljiv na dodir | — | `omarchy toggle touchscreen` |
| Suspenzija | — | `omarchy toggle suspend` |
| Hibridni GPU | — | `omarchy toggle hybrid gpu` |

Prekidači za dodirnu pločicu, zaslon osjetljiv na dodir i hibridni GPU nalaze se pod _Trigger > Hardware_ (`Super + Ctrl + H`), a ne pod Toggle, jer se pojavljuju samo kad doista imate taj hardver. Prekidači za dodirnu pločicu i zaslon osjetljiv na dodir preživljavaju ponovno učitavanje Hyprlanda — naziv onemogućenog uređaja sprema se u malu datoteku stanja koju Hyprland čita pri pokretanju da bi ga ponovno onemogućio.

_Appearance_ sadrži traku izbornika i animacije, plus nekoliko stvari koje nisu naredbe `omarchy toggle`, ali se ponašaju jednako: postotak baterije u traci, zadani raspored radnih prostora te, pod _Windows_, razmake oko prozora (`Super + Shift + Backspace`) i kvadratni format za 1 prozor (`Super + Ctrl + Backspace`).

Većina njih samo je datoteka zastavice pod `~/.local/state/omarchy/toggles/`. Ako u skripti želite granati na temelju jedne od njih, `omarchy-toggle-enabled` daje vam izlazni kod umjesto da je morate tražiti:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Zastavice su nazvane po isključenom stanju — `screensaver-off`, `suspend-off`, `bar-off` — pa njihova prisutnost znači da je značajka onemogućena.

### Pokazatelji u traci

Kada je način rada uključen, dobijete mali glif na sredini gornje trake pokraj sata. To je widget za pokazatelje i nosi diktiranje, snimanje zaslona, podsjetnike na čekanju, noćno svjetlo, ne ometaj i ostani budan.

Neaktivni pokazatelji skriveni su. Prijeđite mišem bilo gdje preko trake i oni će se pojaviti prigušeni, pa možete kliknuti jedan da biste ga uključili bez poznavanja tipkovnog prečaca. Klik na aktivni pokazatelj ponovno ga isključuje. Ako ih radije vidite sve cijelo vrijeme, postavite `alwaysShow` na `true` na unosu `omarchy.indicators` u `~/.config/omarchy/shell.json` — pogledajte [gornja traka](05-the-top-bar.md) za način konfiguriranja widgeta trake.

### Noćno svjetlo

Noćno svjetlo zagrijava zaslon na 4000K, a ponovno prebacivanje vraća ga na 6500K. Prebacite ga iz izbornika preklopnika (`Super + Ctrl + O`) ili pomoću `omarchy toggle nightlight`. Pokreće ga hyprsunset, koji preklopnik pokreće umjesto vas ako već nije pokrenut.

Prema zadanim postavkama hyprsunset uopće ne radi ništa vašem zaslonu. `~/.config/hypr/hyprsunset.conf` isporučuje se s profilom identiteta upravo zato da zaslon ostane netaknut dok ne zatražite toplinu. Ako biste radije da se prebacuje prema satu, zamijenite to vremenskim profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Zatim pokrenite hyprsunset pri prijavi dodavanjem `o.launch_on_start("hyprsunset")` u `~/.config/hypr/autostart.lua`. Par od 4000K/6500K koji koristi preklopnik fiksan je, pa je konfiguracijska datoteka mjesto na koje idete ako želite drugu temperaturu.

### Ne ometaj

`Super + Ctrl + Alt + ,` utišava obavijesti. Dok je uključen, ne pojavljuju se skočni prikazi, a pokazatelj prekriženog zvona sjedi u traci da vas podsjeti zašto je radna površina utihnula.

Ipak, ništa se ne gubi. Utišane obavijesti zadržavaju se: vratite posljednjih nekoliko na zaslon pomoću `Super + Shift + Alt + ,`. Pogledajte [obavijesti](10-notices.md) za ostatak.

Dvije vrste poruka ipak prolaze: Omarchyjevi vlastiti skočni prikazi potvrde za nešto što ste upravo učinili ("Theme changed", "Screenshot saved") i kritična upozorenja poslana iz naredbenog retka. Aplikacije za razgovor koje sve označavaju kao kritično kako bi vam se silom nametnule ne ubrajaju se u to.

### Mirovanje

Omarchy ljuska upravlja ponašanjem u mirovanju, a vremena su blok `idle` na najvišoj razini u `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Oba broja sekunde su koje se broje od trenutka kada ste prešli u mirovanje — ne jedan od drugoga. Dakle, sa zadanim postavkama, čuvar zaslona pojavljuje se nakon dvije i pol minute, a zaslon za zaključavanje preuzima nakon pet minuta, bez obzira na to je li čuvar zaslona radio ili nije. Spremite datoteku i ljuska odmah preuzima nova vremena.

Ako odbacite čuvar zaslona prije roka za zaključavanje, to se računa kao aktivnost i zaključavanje na čekanju poništava se. Nećete se naći zaključani samo zato što ste bacili pogled na svoje računalo.

Da biste u potpunosti zaustavili zaključavanje u mirovanju, `Super + Ctrl + I` — ili `omarchy toggle idle` — uključuje ostanak budnim, a u traci se pojavljuje pokazatelj šalice kave. To je ono što trebate pritisnuti prije duge prezentacije ili gradnje koju želite pratiti. Pritisnite ga ponovno da biste se vratili u normalu. `omarchy toggle idle status` ispisuje trenutačno stanje kao JSON ako vam treba iz skripte.

Ovo se odnosi na zaključavanje i čuvar zaslona, a ne na napajanje. Suspenzija i hibernacija imaju vlastitu postavku u [spavanje sustava](36-system-sleep.md).

### Čuvar zaslona

Omarchyjev čuvar zaslona ASCII je umjetnost koja prolazi kroz nasumične tekstualne efekte, po jedan primjerak po monitoru. Bilo koji pritisak tipke ili pomak miša izlazi iz njega.

Možete ga pokrenuti na zahtjev iz _System > Screensaver_ (`Super + Esc`), što ga prisilno pokreće čak i ako ste isključili čuvar zaslona u mirovanju. Prema zadanim postavkama nije vezan ni uz jedan tipkovni prečac.

`omarchy toggle screensaver` ono je što isključuje onaj u mirovanju, ako biste radije izravno prešli iz rada u zaključano stanje. Treba mu terminal koji zna konfigurirati — Alacritty, Foot, Ghostty ili Kitty — i to će vam reći ako je vaš zadani terminal nešto drugo.

Logotip koji crta možete promijeniti, pod _Appearance > Branding > Screensaver_. Prenesite png ili svg i Omarchy će ga pretvoriti u ASCII. Pogledajte [brendiranje](41-branding.md).

### Zaslon za zaključavanje

`Super + Ctrl + L` zaključava računalo. To pokreće zaslon za zaključavanje iz Omarchy ljuske, zatamnjuje zaslon, vraća raspored tipkovnice na prvi kako ne biste pisali lozinku u pogrešnoj abecedi te — ako vam je pokrenut — zaključava 1Password na izlasku.

Zaslon za zaključavanje prima lozinku, a primit će i otisak prsta nakon što ga postavite. To i ostali načini autentifikacije obrađeni su u [hardverska autentifikacija](37-hardware-authentication.md).
