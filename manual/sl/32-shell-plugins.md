# Vtičniki lupine

Namizje Omarchy teče kot en sam dolgotrajen proces Quickshell z imenom `omarchy-shell`, skoraj vse, kar vidite na zaslonu, pa je vtičnik znotraj njega. Vrstica je vtičnik. Prav tako paneli, ki padajo iz nje, celozaslonska prekrivanja, kot sta izbirnik emojijev in upravitelj odložišča, meni Omarchy sam, zaklepni zaslon, pogovorno okno polkit in brezglave storitve, ki spremljajo vašo baterijo in ponoči ogrevajo zaslon.

To ni le podrobnost izvajanja. Pomeni, da lahko dele namizja izklopite, jih zamenjate ali napisete svoje, ne da bi se dotaknili ene same vrstice izvorne kode Omarchy.

Prvostrankarski vtičniki se dobavljajo z Omarchy in živijo v `$OMARCHY_PATH/shell/plugins/`. Vse, kar dodate sami — lastni poskusi ali kaj, kar ste našli na GitHubu — živi v `~/.config/omarchy/plugins/`. Oba se odkrijeta na enak način ob zagonu, vendar vgrajeni prejmejo zaupanja vredne vmesnike lupine, vtičniki tretjih oseb pa omejen vmesnik, omejen na lastno storitev in življenjski cikel. Kloni vgrajenih vtičnikov obdržijo le izvorno specifične konfiguracije in klice UI, potrebne za izvirno vedenje.

## Ogled tega, kar imate

```
omarchy plugin list
```

To izpiše vsak odkriti vtičnik z njegovim id-jem, ali je omogočen, ali je prvostrankarski ali tretje osebe, njegove vrste in prikazno ime. Dodajte `--json`, če ga napajate v kaj drugega.

Id-ji vtičnikov so v imenskih prostorih. Vgrajeni se začnejo z `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — in ta imenski prostor je rezerviran, tako da ga vtičnik tretjih oseb nikoli ne more zahtevati.

## Vklapljanje in izklapljanje

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Ali uporabite meni: _Nastavitve > Vtičniki_ ima Enable, Disable, Add, Clone in Remove, vsak z izbirnikom, ki ponudi le vtičnike, primerne za to dejanje.

Stanje omogočenosti je shranjeno v `~/.config/omarchy/shell.json`, pravilo pa se nekoliko razlikuje za dve vrsti vtičnikov. Vtičnik tretjih oseb je omogočen natanko takrat, ko se njegov id kje pojavi v tej datoteki — kot vnos postavitve vrstice, kot vnos v `plugins[]` ali kot `bar.id`. Prvostrankarski vtičniki, ki niso pripomočki vrstice, so obratni: so privzeto vklopljeni in se izklopijo le, če so navedeni v `disabledPlugins[]`.

Polni vtičnik vrstice sploh nima izklopljenega stanja. Vedno obstaja natanko ena vrstica, zato jo zamenjate tako, da omogočite drugo. Postavitev pripomočkov vrstice je obravnavana v [menijski vrstici](05-the-top-bar.md).

## Dodajanje vtičnika iz gita

Vtičnik tretjih oseb je le repozitorij git z `manifest.json` v korenu.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Preden kaj stori, vam odkrito pove, da vtičniki tečejo kot poljubna, ne-varovana koda znotraj vašega dolgotrajnega procesa lupine, pokaže URL in prosi za potrditev. To vzemite resno. Vmesnik vtičnikov tretjih oseb ne izpostavlja neposredno avtentikacijskih storitev, nadomestna vrstica pa prejme le omejene zmožnosti za konfiguriran UI brez avtentikacije. Vizualni vtičniki še vedno delijo sceno QML lupine in lahko hodijo po običajnih nadrejenih objektih, vsa koda vtičnikov pa teče z vsem, kar lahko doseže vaš uporabniški račun. Stanje avtentikacije je ločeno zaščiteno, tako da so te storitve zunaj dosegljivega grafa gostiteljev. Dodajajte le repozitorije, ki ste jih pripravljeni zagnati, in jih preberite, preden jih omogočite.

Nadomestna vrstica lahko upodobi nameščene pripomočke, pripomočki tretjih oseb, podprti s storitvijo, pa imajo lahko tam zmanjšano funkcionalnost, ker vrstica ne sme zahtevati žive storitve drugega vtičnika. Preklopite nazaj na vgrajeno `omarchy.bar`, če tak pripomoček potrebuje svojo spremljevalno storitev.

Nato repozitorij klonira v pripravljalno mapo, preveri manifest, zavrne namestitev, če drug vtičnik že zahteva ta id, in ga premakne v `~/.config/omarchy/plugins/<id>/`. Brez `--enable` vpraša, ali ga želite zdaj vklopiti, in lahko rečete ne in greste najprej prebrati kodo. Nikoli ne zažene ničesar iz vtičnika, nikoli ne izvede namestitvenega kavlja in nikoli ne prosi za sudo — klonira datoteke, preveri manifest in prek IPC obrne bit.

Posodobitev je poteg hitrega pomika naprej iste kopije:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Brez id-ja posodobi vse vtičnike, upravljane z gitom, ki jih imate. Preden uporabi, pokaže diff, zavrne posodobitev, če imate lokalne spremembe, ki jih ne more hitro pomakniti naprej, in se vrne nazaj, če nova revizija ne opravi preverjanja.

```
omarchy plugin remove acme.weather
```

Odstranitev najprej onemogoči vtičnik, nato ga izbriše, če gre za kopijo git (repozitorij je še vedno navzgor) ali odklopi, če gre za simbolno povezavo. Ročno izdelana mapa vtičnika brez repozitorija git se namesto dokončnega izbrisa premakne v časovno žigosano varnostno kopijo znotraj mape vtičnikov.

## Kloniranje vgrajenega vtičnika za spreminjanje

To je moj najljubši del. Če želite spremeniti, kako se obnaša vgrajeni pripomoček, ne urejajte datotek pod `$OMARCHY_PATH` — pripadajo paketu in naslednja posodobitev jih bo prepisala. Namesto tega ga klonirajte:

```
omarchy plugin clone omarchy.clock
```

To kopira celoten vtičnik v `~/.config/omarchy/plugins/dhh.clock` (vaše uporabniško ime, ne moje), ga preimenuje v "My Clock", ga omogoči in lupino preklopi iz vgrajenega na vašo kopijo — pri čemer ohrani položaj in nastavitve obstoječega pripomočka vrstice. Dodajte `--edit`, da novo mapo takoj odprete v `$EDITOR`, kar meni _Nastavitve > Vtičniki > Clone Plugin_ stori za vas.

Predpona uporabniškega imena ohranja id vašega klona vaš, tako da deljenje ne trči z nikakršnim drugim. Klici na izvirni vgrajeni id se usmerjajo na vaš klon, tako da ničesar, kar se je sklicevalo na `omarchy.clock`, ni treba posodabljati. Če naredite zmedo, `omarchy plugin remove dhh.clock` vrne vgrajeni nazaj.

Shranjevanje datoteke kjer koli pod `~/.config/omarchy/plugins/` samodejno znova naloži kodo vtičnika, tako da lahko pustite urejevalnik odprt in opazujete, kako vaše spremembe pristajajo.

## Pisanje lastnega

Vtičnik je mapa z `manifest.json` in nekaj QML. Manifest deklarira `schemaVersion: 1`, `id`, `name`, `version`, eno ali več `kinds` in objekt `entryPoints`, ki kaže na datoteko QML za vsako vrsto:

| Kind | What it is |
|------|------------|
| `bar-widget` | Komponenta, ki jo aktivna vrstica lahko spusti v razdelek |
| `panel` | Vztrajno ali priklicano lebdeče okno |
| `overlay` | Celozaslonsko prekrivanje |
| `menu` | Priklicana menijska površina |
| `service` | Brezglavi singleton brez UI |
| `bar` | Polna vrstica, ki nadomesti vgrajeno |

Vtičnik lahko deklarira več vrst naenkrat — medijski vtičnik je hkrati `service` in `bar-widget`. Pripomočki vrstice dobijo dodatni blok `barWidget` s prikaznim imenom, kategorijo, neobveznim `defaultSection` in `allowMultiple`, kar pove, ali ima smisel imeti več kot enega na vrstici. Večina pripomočkov ga nastavi na `false`; distančniki in indikatorji ga nastavijo na `true`.

Preden kar koli objavite, preverite:

```
omarchy plugin validate ./my-plugin
```

To izvede ista preverjanja kot lupina ob obremenitvi: različica sheme, zahtevana polja, id, ki ni rezerviran, vstopne točke, ki so varne relativne poti in dejansko obstajajo, vstopna točka za vsako vrsto, ki ste jo zahtevali, in nobenih simbolnih povezav znotraj mape.

Za razvoj vtičnikov glejte [referenco lupine](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) in [katalog prvostrankarskih vtičnikov](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Deljenje svojega s svetom

Ko naredite nekaj, kar vam je všeč, to postavite v javni repozitorij git. To je celoten mehanizem distribucije — kdorkoli lahko nato zažene `omarchy plugin add` proti vašemu URL-ju in ga ima v nekaj sekundah zagnanega.

Da ga bodo ljudje dejansko našli, ga navedete na [plugins.omarchy.org](https://plugins.omarchy.org). To je tržnica za vtičnike lupine Omarchy in prvo mesto, kamor pogledati, ko se sprašujete, ali je nekdo že zgradil pripomoček, ki ga nameravate napisati. Pred začetkom ga prebrskajte!
