# Kesta pistikprogrammid

Omarchy töölaud töötab ühe pikaealise Quickshelli protsessina nimega `omarchy-shell` ja peaaegu kõik, mida ekraanil näed, on selle sees olev pistikprogramm. Riba on pistikprogramm. Nagu ka paneelid, mis sellelt alla langevad, täisekraani ülekatteid nagu emoji valija ja lõikelaua haldur, Omarchy menüü ise, lukkuekraan, polkit dialoog ja peata teenused, mis jälgivad sinu akut ja soojendavad öösel ekraani.

See pole lihtsalt rakendusdetail. See tähendab, et saad töölaua osi välja lülitada, välja vahetada või kirjutada oma, puudutamata rida ka Omarchy lähtekoodi.

Esmase osapoole pistikprogrammid tulevad Omarchyga ja elavad kaustas `$OMARCHY_PATH/shell/plugins/`. Kõik, mida ise lisad — oma katsetused või midagi, mille GitHubist leidsid — elab kaustas `~/.config/omarchy/plugins/`. Mõlemad avastatakse käivitamisel samal viisil, kuid sisseehitatud saavad usaldusväärsed kesta liidesed, samas kui kolmanda osapoole pistikprogrammid saavad piiratud liidese, mis on piiratud nende oma teenuse ja elutsükliga. Sisseehitatute kloonid säilitavad ainult allikaspetsiifilise konfiguratsiooni ja UI kõned, mida on vaja algse käitumise jaoks.

## Selle nägemine, mis sul on

```
omarchy plugin list
```

See prindib iga avastatud pistikprogrammi koos selle ID-ga, kas see on lubatud, kas see on esmase või kolmanda osapoole, selle liigid ja kuvanimi. Lisa `--json`, kui söödad seda millelegi muule.

Pistikprogrammide ID-del on nimeruumi. Sisseehitatud algavad kõik `omarchy.`-ga — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — ja see nimeruum on reserveeritud, nii et kolmanda osapoole pistikprogramm ei saa seda kunagi nõuda.

## Nende sisse- ja väljalülitamine

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Või kasuta menüüd: jaotis _Seaded > Plugins_ on Enable, Disable, Add, Clone ja Remove, igaühel valija, mis pakub ainult pistikprogramme, mis selle toimingu puhul mõttekas on.

Lubatud olek salvestatakse faili `~/.config/omarchy/shell.json` ja reegel on kahe pistikprogrammi liigi puhul veidi erinev. Kolmanda osapoole pistikprogramm on lubatud täpselt siis, kui selle ID ilmub kuskil selles failis — riba paigutuse kirjena, kirjeks `plugins[]`-s või `bar.id`-na. Esmase osapoole pistikprogrammid, mis pole riba vidinad, on vastupidi: need on vaikimisi sisse lülitatud ja lülituvad välja ainult siis, kui need on loetletud `disabledPlugins[]`-is.

Täielikul ribapistikprogrammil pole üldse väljalülitatud olekut. Riba on alati täpselt üks, nii et asendad selle teise lubamisega. Riba vidinate paigutust käsitletakse jaotises [menüüriba](05-the-top-bar.md).

## Pistikprogrammi lisamine gitist

Kolmanda osapoole pistikprogramm on lihtsalt giti repo, mille juures on `manifest.json`.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Enne, kui see midagi teeb, ütleb see sulle selgelt, et pistikprogrammid töötavad suvalise, liivakastita koodina sinu pikaealise kestaprotsessi sees, näitab URL-i ja palub sul kinnitada. Võta seda tõsiselt. Kolmanda osapoole pistikprogrammi liides ei paljasta otse autentimisteenuseid ja asendusriba saab ainult piiratud võimalused konfigureeritud mitteautentiva UI jaoks. Visuaalsed pistikprogrammid jagavad endiselt kesta QML stseeni ja saavad liikuda tavaliste vanemobjektide kohal, samas kui kogu pistikprogrammi kood töötab kõigega, millele sinu kasutajakonto ligi pääseb. Autentimisolekut kaitstakse eraldi, hoides need teenused kättesaadavast hosti objektgraafist väljas. Lisa ainult reposid, mida oled valmis käitama, ja loe neid enne lubamist.

Asendusriba saab renderdada paigaldatud vidinaid, kuid teenusega toetatud kolmanda osapoole vidinatel võib seal olla vähenenud funktsionaalsus, kuna ribal pole lubatud küsida teise pistikprogrammi elava teenuse objekti. Lülitu tagasi sisseehitatud ribale `omarchy.bar`, kui selline vidin vajab oma kaasteenust.

Seejärel kloonib see repo lavastuskausta, valideerib manifesti, keeldub paigaldusest, kui teine pistikprogramm juba seda ID-d nõuab, ja teisaldab selle kausta `~/.config/omarchy/plugins/<id>/`. Ilma `--enable`-ta küsib see, kas soovid selle nüüd sisse lülitada, ja saad ei öelda ja kõigepealt koodi lugeda. See ei käivita kunagi midagi pistikprogrammist, ei käivita kunagi paigalduskonksu ega küsi kunagi sudo — see kloonib faile, kontrollib manifesti ja lülitab biti IPC kaudu.

Uuendamine on sama checkouti kiire edasitõmme:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Ilma ID-ta uuendab see kõiki sinu giti hallatavaid pistikprogramme. See näitab sulle diffi enne selle rakendamist, keeldub uuendamast, kui sul on kohalikke muudatusi, millest see ei saa kiiresti edasi minna, ja võtab tagasi, kui uus revisjon valideerimisel ebaõnnestub.

```
omarchy plugin remove acme.weather
```

Eemaldamine keelab pistikprogrammi kõigepealt, seejärel kustutab selle, kui see on giti checkout (repo on endiselt ülesvoolus), või unlingib selle, kui see on sümbolviit. Käsitsi tehtud pistikprogrammi kaust ilma giti repota teisaldatakse selle otse kustutamise asemel ajatempliga varukoopiasse pistikprogrammide kausta sees.

## Sisseehitatud kloonimine selle muutmiseks

See on minu lemmikosa. Kui soovid muuta sisseehitatud vidina käitumist, ära redigeeri faile kausta `$OMARCHY_PATH` all — need kuuluvad paketile ja järgmine uuendus kirjutab need üle. Klooni see hoopis:

```
omarchy plugin clone omarchy.clock
```

See kopeerib kogu pistikprogrammi kausta `~/.config/omarchy/plugins/dhh.clock` (sinu kasutajanimi, mitte minu oma), nimetab selle ümber "My Clock", lubab selle ja lülitab kesta sisseehitatult sinu koopiale — säilitades olemasoleva riba vidina asendi ja seaded. Lisa `--edit`, et avada uus kaust kohe oma `$EDITOR`-is, mida menüü jaotis _Seaded > Plugins > Clone Plugin_ sinu eest teeb.

Kasutajanime eesliide hoiab sinu klooni ID-d sinu oma, nii et selle jagamine ei põrka kellegi teisega. Algsele sisseehitatud ID-le tehtud kõned suunatakse sinu kloonile, nii et miski, mis viitas `omarchy.clock`-le, ei vaja uuendamist. Ja kui teed sellest segaduse, paneb `omarchy plugin remove dhh.clock` sisseehitatud tagasi.

Faili salvestamine kuskil kausta `~/.config/omarchy/plugins/` all laadib pistikprogrammi koodi automaatselt uuesti, nii et saad redaktori avatuks jätta ja vaadata, kuidas sinu muudatused jõuavad.

## Oma kirjutamine

Pistikprogramm on kaust koos `manifest.json`-i ja mõne QML-iga. Manifest deklareerib `schemaVersion: 1`, `id`, `name`, `version`, ühe või mitu `kinds` ja `entryPoints` objekti, mis osutab iga liigi QML-failile:

| Kind | What it is |
|------|------------|
| `bar-widget` | Komponent, mille aktiivne riba saab sektsiooni paigutada |
| `panel` | Püsiv või esilekutsutud ujuv aken |
| `overlay` | Täisekraani ülekate |
| `menu` | Esilekutsutud menüü pind |
| `service` | Peata singleton ilma UI-ta |
| `bar` | Täielik riba, mis asendab sisseehitatud |

Pistikprogramm saab deklareerida mitu liiki korraga — meediapistikprogramm on nii `service` kui ka `bar-widget`. Riba vidinad saavad täiendava `barWidget` ploki kuvanime, kategooria, valikulise `defaultSection`-i ja `allowMultiple`-ga, mis ütleb, kas on mõttekas, et ribal on rohkem kui üks. Enamik vidinaid määrab selle `false`; vahed ja näidikud määravad selle `true`.

Enne millegi avaldamist kontrolli seda:

```
omarchy plugin validate ./my-plugin
```

See käivitab samad kontrollid, mida kest teeb laadimisajal: skeemi versioon, nõutavad väljad, ID, mis pole reserveeritud, sisestuspunktid, mis on turvalised suhtelised teed ja tegelikult olemas, sisestuspunkt iga nõutud liigi jaoks ja sümbolviidade puudumine kuskil kaustas.

Pistikprogrammide arendamiseks vaata [kesta viidet](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) ja [esmase osapoole pistikprogrammide kataloogi](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Oma jagamine maailmaga

Kui oled teinud midagi, mis sulle meeldib, pane see avalikku giti reposse. See on kogu levitamismehhanism — igaüks saab seejärel käivitada `omarchy plugin add` sinu URL-i vastu ja see töötab sekunditega.

Et aidata inimestel seda tegelikult leida, loetle see aadressil [plugins.omarchy.org](https://plugins.omarchy.org). See on Omarchy kesta pistikprogrammide turg ja see on esimene koht, kust vaadata, kui mõtled, kas keegi on juba ehitanud vidina, mida sa hakkad kirjutama. Sirvi seda enne alustamist!
