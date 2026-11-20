# Prekidači, mirovanje i čuvar zaslona

Puno toga što mijenjaš iz dana u dan zapravo nije postavka. To je način rada koji uključiš na sat vremena pa ga opet isključiš: noćno svjetlo dok radiš do kasno, ne ometaj dok prezentiraš, ostani budan dok nešto gledaš. Omarchy ih naziva prekidačima i svi rade na isti način — prečac, stavka izbornika i naredba, svi pogađaju isti prekidač.

### Izbornik prekidača

`Super + Ctrl + O` izravno otvara _Trigger > Toggle_, a tamo možeš i prošetati iz izbornika Omarchy (`Super + Space`). Sve na tom popisu je prekidač koji možeš prebaciti bez razmišljanja o tome gdje se stanje nalazi. Prekidači za izgled radne površine nalaze se odmah pored toga, pod _Appearance_.

Iz terminala su isti prekidači `omarchy toggle <thing>`. Pokreni samo `omarchy toggle` da vidiš cijelu skupinu.

| Prekidač | Prečac | Naredba |
| ------ | ------ | ------- |
| Noćno svjetlo | — | `omarchy toggle nightlight` |
| Utišavanje obavijesti | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ostani budan (bez zaključavanja u mirovanju) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Snimanje padova sustava | — | `omarchy toggle crash-capture` |
| Čuvar zaslona | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sinkronizacija teme | — | `omarchy toggle theme sync` |
| Traka izbornika | `Super + Shift + Space` | `omarchy toggle bar` |
| Dodirna ploha | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Zaslon osjetljiv na dodir | — | `omarchy device touchscreen` |
| Obustava | — | `omarchy toggle suspend` |
| Hibridni GPU | — | `omarchy toggle hybrid gpu` |

Prekidači za dodirnu plohu, zaslon osjetljiv na dodir i hibridni GPU nalaze se pod _Trigger > Hardware_ (`Super + Ctrl + H`), a ne pod Toggle, jer se pojavljuju samo kad doista imaš taj hardver. Prekidači za dodirnu plohu i zaslon osjetljiv na dodir preživljavaju ponovno učitavanje Hyprlanda — naziv onemogućenog uređaja sprema se u malu datoteku stanja koju Hyprland pročita pri pokretanju da bi ga ponovno onemogućio.

_Appearance_ sadrži traku izbornika i animacije, plus nekoliko stvari koje nisu naredbe `omarchy toggle`, ali se ponašaju jednako: postotak baterije u traci, zadani raspored radnog prostora te, pod _Windows_, razmake prozora (`Super + Shift + Backspace`) i kvadratni omjer za 1 prozor (`Super + Ctrl + Backspace`).

Kad Hyprland nema GPU za crtanje i umjesto toga renderira na CPU-u (llvmpipe), kao na Macovima čiji GPU još nije podržan, u većini virtualnih strojeva ili kad se grafički upravljački program ne uspije učitati, Omarchy za tu sesiju isključuje animacije, zamućenje i sjene i jednom te o tome obavijesti obaviješću. _Appearance > Animations On_ ih vraća, a Omarchy to pamti i za kasnije sesije.

Većina su to tek datoteka zastavice pod `~/.local/state/omarchy/toggles/`. Ako u skripti želiš granati na temelju neke od njih, `omarchy-toggle-enabled` ti daje izlazni kod umjesto da moraš ići tražiti:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Zastavice su nazvane po isključenom stanju — `screensaver-off`, `suspend-off`, `bar-off` — pa njihova prisutnost znači da je značajka onemogućena.

### Pokazatelji u traci

Kad je neki način rada uključen, dobiješ mali glif u sredini gornje trake pored sata. To je widget pokazatelja i nosi diktiranje, snimanje zaslona, podsjetnike na čekanju, noćno svjetlo, ne ometaj i ostani budan.

Neaktivni pokazatelji su skriveni. Zadrži pokazivač bilo gdje na traci i oni će se pojaviti prigušeni, pa možeš kliknuti jedan da ga uključiš bez da znaš njegov prečac. Klik na aktivni isključuje ga natrag. Ako bi ih radije vidio sve cijelo vrijeme, postavi `alwaysShow` na `true` na unosu `omarchy.indicators` u `~/.config/omarchy/shell.json` — pogledaj [gornju traku](05-the-top-bar.md) za način konfiguriranja widgeta trake.

### Noćno svjetlo

Noćno svjetlo zagrijava zaslon na 4000K, a ponovno prebacivanje vraća ga na 6500K. Prebaci ga iz izbornika prekidača (`Super + Ctrl + O`) ili s `omarchy toggle nightlight`. Pokreće ga hyprsunset, koji prekidač pokreće za tebe ako već ne radi.

Prema zadanim postavkama hyprsunset uopće ne radi ništa tvom zaslonu. `~/.config/hypr/hyprsunset.conf` isporučuje se s profilom identiteta upravo zato da zaslon ostane netaknut dok ne zatražiš toplinu. Ako bi radije da se prebacuje prema satu, zamijeni to vremenskim profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Zatim pokreni hyprsunset pri prijavi dodavanjem `o.launch_on_start("hyprsunset")` u `~/.config/hypr/autostart.lua`. Par 4000K/6500K koji prekidač koristi je fiksan, pa je konfiguracijska datoteka mjesto na koje ideš ako želiš drugu temperaturu.

### Ne ometaj

`Super + Ctrl + Alt + ,` utišava obavijesti. Dok je uključeno ne iskaču nikakve obavijesti, a pokazatelj precrtanog zvona sjedi u traci da te podsjeti zašto je radna površina utihnula.

Ništa se ipak ne gubi. Utišane obavijesti zadržavaju se: vrati posljednjih nekoliko na zaslon s `Super + Shift + Alt + ,`. Pogledaj [obavijesti](10-notices.md) za ostatak.

Dvije vrste poruka i dalje prolaze: vlastite obavijesti potvrde Omarchyja za nešto što si upravo napravio ("Theme changed", "Screenshot saved") i kritična upozorenja poslana iz naredbenog retka. Aplikacije za razgovor koje sve označavaju kao kritično da bi se silom probile ispred tebe ne zadovoljavaju uvjete.

### Mirovanje

Ljuska Omarchy upravlja ponašanjem u mirovanju, a vremena su blok `idle` na najvišoj razini u `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Oba broja su sekunde koje se broje od trenutka kad si otišao u mirovanje — a ne jedan od drugoga. Dakle, sa zadanim postavkama čuvar zaslona pojavljuje se nakon dvije i pol minute, a zaslon za zaključavanje preuzima nakon pet minuta, bez obzira na to je li čuvar zaslona radio. Spremi datoteku i ljuska će odmah preuzeti nova vremena.

Ako odbaciš čuvara zaslona prije roka zaključavanja, to se računa kao aktivnost i zaključavanje na čekanju se poništava. Nećeš biti zaključan zato što si bacio pogled na svoje računalo.

Da u potpunosti zaustaviš zaključavanje u mirovanju, `Super + Ctrl + I` — ili `omarchy toggle idle` — uključuje ostani budan, a pokazatelj šalice kave pojavljuje se u traci. To je onaj koji treba pritisnuti prije duge prezentacije ili builda koji želiš gledati. Pritisni ga ponovno da se vratiš na normalno. `omarchy toggle idle status` ispisuje trenutno stanje kao JSON ako ti treba iz skripte.

Ovo se odnosi na zaključavanje i čuvara zaslona, a ne na napajanje. Obustava i hibernacija imaju vlastite postavke u [spavanju sustava](36-system-sleep.md).

### Čuvar zaslona

Čuvar zaslona Omarchyja je ASCII umjetnost koja prolazi kroz nasumične tekstualne efekte, po jedna instanca po monitoru. Bilo koja tipka ili pomak miša izlazi iz njega.

Možeš ga pokrenuti na zahtjev iz _System > Screensaver_ (`Super + Esc`), što ga forsira čak i ako si isključio čuvara zaslona u mirovanju. Prema zadanim postavkama na njega nije vezan nijedan prečac.

`omarchy toggle screensaver` je ono što isključuje onoga u mirovanju, ako bi radije išao izravno s posla na zaključano. Bilo koja tipka, klik, pomak kotačića ili pomak miša zatvara ga.

Logotip koji crta možeš promijeniti, pod _Appearance > Branding > Screensaver_. Prenesi png ili svg i Omarchy će ga pretvoriti u ASCII. Pogledaj [brendiranje](41-branding.md).

### Zaslon za zaključavanje

`Super + Ctrl + L` zaključava računalo. To pokreće zaslon za zaključavanje iz ljuske Omarchy, zatamnjuje zaslon, vraća raspored tipkovnice na prvi da ne upisuješ lozinku u pogrešnoj abecedi i — ako ti radi — usput zaključava 1Password.

Zaslon za zaključavanje prima lozinku, a primit će i otisak prsta kad ga postaviš. To i drugi načini autentifikacije obrađeni su u [hardverskoj autentifikaciji](37-hardware-authentication.md).
