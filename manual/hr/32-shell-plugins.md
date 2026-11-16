# Dodaci ljuske

Radna površina Omarchy radi kao jedan dugovječni Quickshell proces koji se zove `omarchy-shell`, a gotovo sve što vidiš na zaslonu dodatak je unutar njega. Traka je dodatak. Isto vrijedi i za panele koji se spuštaju s nje, preklapanja preko cijelog zaslona poput birača emojija i upravitelja međuspremnika, sam izbornik Omarchy, zaslon za zaključavanje, dijaloški okvir polkit i headless usluge koje prate tvoju bateriju i zagrijavaju ti zaslon noću.

To nije samo detalj implementacije. To znači da dijelove radne površine možeš isključiti, zamijeniti ili napisati vlastite bez diranja retka Omarchyjeva izvornog koda.

Dodaci prve strane isporučuju se s Omarchyjem i nalaze se u `$OMARCHY_PATH/shell/plugins/`. Sve što sam dodaš — vlastite eksperimente ili nešto što si pronašao na GitHubu — nalazi se u `~/.config/omarchy/plugins/`. Oba se otkrivaju na isti način pri pokretanju, ali ugrađeni dobivaju pouzdana sučelja ljuske, dok dodaci treće strane dobivaju ograničeno sučelje ograničeno na vlastitu uslugu i životni ciklus. Klonovi ugrađenih zadržavaju samo konfiguraciju specifičnu za izvor i pozive korisničkog sučelja potrebne za izvorno ponašanje.

## Vidjeti što imaš

```
omarchy plugin list
```

To ispisuje svaki otkriveni dodatak s njegovim id-em, je li omogućen, je li prve ili treće strane, njegovim vrstama i prikaznim imenom. Dodaj `--json` ako ga šalješ u nešto drugo.

Id-evi dodataka su u imenskom prostoru. Svi ugrađeni počinju s `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — a taj imenski prostor je rezerviran, pa ga dodatak treće strane nikad ne može prisvojiti.

## Uključivanje i isključivanje

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Ili koristi izbornik: _Postavke > Plugins_ ima Enable, Disable, Add, Clone i Remove, svaki s biračem koji nudi samo dodatke koji imaju smisla za tu radnju.

Omogućeno stanje pohranjuje se u `~/.config/omarchy/shell.json`, a pravilo se malo razlikuje za dvije vrste dodataka. Dodatak treće strane omogućen je točno kad se njegov id pojavi negdje u toj datoteci — kao unos rasporeda trake, kao unos u `plugins[]` ili kao `bar.id`. Dodaci prve strane koji nisu widgeti trake obrnuti su: uključeni su prema zadanim postavkama i isključuju se samo ako su navedeni u `disabledPlugins[]`.

Potpuni dodatak trake uopće nema isključeno stanje. Uvijek postoji točno jedna traka, pa je zamjenjuješ omogućavanjem druge. Postavljanje widgeta trake obrađeno je u [traci izbornika](05-the-top-bar.md).

## Dodavanje dodatka iz gita

Dodatak treće strane samo je git repozitorij s `manifest.json` u korijenu.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Prije nego što učini bilo što, jasno ti kaže da se dodaci pokreću kao proizvoljan, nesandboxiran kod unutar tvog dugovječnog procesa ljuske, pokazuje ti URL i traži potvrdu. Shvati to ozbiljno. Sučelje dodataka treće strane ne izlaže izravno usluge autentifikacije, a zamjenska traka dobiva samo ograničene mogućnosti za konfigurirano korisničko sučelje bez autentifikacije. Vizualni dodaci i dalje dijele QML scenu ljuske i mogu hodati po običnim roditeljskim objektima, dok sav kod dodatka radi sa svime što tvoj korisnički račun može dosegnuti. Stanje autentifikacije zaštićeno je zasebno držanjem tih usluga izvan dosegljivog grafa objekata hosta. Dodaj samo repozitorije koje si spreman pokrenuti i pročitaj ih prije nego što ih omogućiš.

Zamjenska traka može prikazivati instalirane widgete, ali widgeti treće strane podržani uslugom mogu tamo imati smanjenu funkcionalnost jer traci nije dopušteno zatražiti živi objekt usluge drugog dodatka. Vrati se na ugrađeni `omarchy.bar` ako takav widget treba svoju prateću uslugu.

Zatim klonira repozitorij u direktorij za pripremu, provjerava manifest, odbija instalaciju ako drugi dodatak već prisvaja taj id i premješta ga u `~/.config/omarchy/plugins/<id>/`. Bez `--enable` pita želiš li ga sada uključiti, a možeš reći ne i prvo otići pročitati kod. Nikad ne pokreće ništa iz dodatka, nikad ne izvršava hook za instalaciju i nikad ne traži sudo — klonira datoteke, provjerava manifest i okreće bit preko IPC-a.

Ažuriranje je fast-forward pull istog checkouta:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Bez id-a ažurira svaki dodatak kojim upravlja git koji imaš. Pokazuje ti diff prije primjene, odbija ažuriranje ako imaš lokalne promjene preko kojih ne može fast-forwardati i vraća nazad ako nova revizija ne prođe validaciju.

```
omarchy plugin remove acme.weather
```

Uklanjanje prvo onemogućuje dodatak, a zatim ga briše ako je git checkout (repozitorij je i dalje upstream) ili ga odvaja ako je simbolička poveznica. Ručno izrađena mapa dodatka bez git repozitorija premješta se u sigurnosnu kopiju s vremenskom oznakom unutar direktorija dodataka umjesto da se izravno izbriše.

## Kloniranje ugrađenog za izmjenu

Ovo mi je najdraži dio. Ako želiš promijeniti kako se ugrađeni widget ponaša, ne uređuj datoteke pod `$OMARCHY_PATH` — one pripadaju paketu i sljedeće ažuriranje će ih prebrisati. Umjesto toga ga kloniraj:

```
omarchy plugin clone omarchy.clock
```

To kopira cijeli dodatak u `~/.config/omarchy/plugins/dhh.clock` (tvoje korisničko ime, ne moje), preimenuje ga u "My Clock", omogućuje ga i prebacuje ljusku s ugrađenog na tvoju kopiju — zadržavajući položaj i postavke postojećeg widgeta trake. Dodaj `--edit` za odmah otvaranje novog direktorija u tvom `$EDITOR`, što je ono što izbornikov _Postavke > Plugins > Clone Plugin_ radi za tebe.

Prefiks korisničkog imena drži id tvog klona tvojim, pa dijeljenje ne sudara se s ničijim drugim. Pozivi upućeni izvornom ugrađenom id-u usmjeravaju se na tvoj klon, pa ništa što se odnosilo na `omarchy.clock` ne treba ažurirati. A ako napraviš zbrku, `omarchy plugin remove dhh.clock` vraća ugrađeni.

Spremanje datoteke bilo gdje pod `~/.config/omarchy/plugins/` automatski ponovno učitava kod dodatka, pa uređivač možeš ostaviti otvoren i gledati kako tvoje promjene slijeću.

## Pisanje vlastitog

Dodatak je direktorij s `manifest.json` i malo QML-a. Manifest deklarira `schemaVersion: 1`, `id`, `name`, `version`, jednu ili više `kinds` i objekt `entryPoints` koji pokazuje na QML datoteku za svaku vrstu:

| Vrsta | Što je to |
|------|------------|
| `bar-widget` | Komponenta koju aktivna traka može ispustiti u odjeljak |
| `panel` | Trajni ili pozvani plutajući prozor |
| `overlay` | Preklapanje preko cijelog zaslona |
| `menu` | Pozvana površina izbornika |
| `service` | Headless singleton bez korisničkog sučelja |
| `bar` | Potpuna traka koja zamjenjuje ugrađenu |

Dodatak može deklarirati nekoliko vrsta odjednom — dodatak za medije i `service` je i `bar-widget`. Widgeti trake dobivaju dodatni blok `barWidget` s prikaznim imenom, kategorijom, opcionalnim `defaultSection` i `allowMultiple`, koji govori ima li smisla imati više od jednog na traci. Većina widgeta postavlja ga na `false`; distanceri i pokazatelji postavljaju ga na `true`.

Prije nego što bilo što objaviš, provjeri ga:

```
omarchy plugin validate ./my-plugin
```

To pokreće iste provjere koje ljuska radi pri učitavanju: verziju sheme, obavezna polja, id koji nije rezerviran, ulazne točke koje su sigurne relativne putanje i zapravo postoje, ulaznu točku za svaku vrstu koju si prisvojio i nikakve simboličke poveznice nigdje unutar mape.

Za razvoj dodataka pogledaj [referencu ljuske](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) i [katalog dodataka prve strane](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Dijeljenje svog sa svijetom

Nakon što napraviš nešto što ti se sviđa, stavi to u javni git repozitorij. To je cijeli mehanizam distribucije — svatko tada može pokrenuti `omarchy plugin add` protiv tvog URL-a i imati ga pokrenutog u sekundama.

Da pomogneš ljudima da ga zapravo pronađu, navedi ga na [plugins.omarchy.org](https://plugins.omarchy.org). To je tržište za Omarchy dodatke ljuske i prvo je mjesto za pogledati kad se pitaš je li netko već izgradio widget koji se spremaš napisati. Pregledaj ga prije početka!
