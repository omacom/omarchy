# Shell-viðbætur

Omarchy-skjáborðið keyrir sem eitt langlíft Quickshell-ferli sem kallast `omarchy-shell`, og næstum allt sem þú sérð á skjánum er viðbót inni í því. Stikan er viðbót. Það eru líka spjöldin sem falla niður úr henni, heilskjáa-yfirborðin eins og emoji-valið og klippiborðsstjórinn, Omarchy-valmyndin sjálf, læsingarskjárinn, polkit-glugginn og höfuðlausu þjónusturnar sem fylgjast með rafhlöðunni þinni og hlýja skjáinn þinn á nóttunni.

Það er ekki bara útfærsluupplýsing. Það þýðir að þú getur slökkt á hlutum af skjáborðinu, skipt þeim út eða skrifað þína eigin án þess að snerta línu af frumkóða Omarchy.

Fyrstu-flokks viðbæturnar koma með Omarchy og búa í `$OMARCHY_PATH/shell/plugins/`. Allt sem þú bætir við sjálfur — þínar eigin tilraunir, eða eitthvað sem þú fannst á GitHub — býr í `~/.config/omarchy/plugins/`. Bæði eru uppgötvuð á sama hátt við ræsingu, en innbyggðar fá traust shell-viðmót á meðan viðbætur frá þriðja aðila fá takmarkað viðmót sem afmarkast við þeirra eigin þjónustu og lífsferil. Klónar af innbyggðum halda aðeins stillingum og UI-köllum sem eru sértæk fyrir upprunann og þarf fyrir upprunalega hegðun.

## Að sjá hvað þú hefur

```
omarchy plugin list
```

Það prentar hverja uppgötvaða viðbót með kenni hennar, hvort hún sé virkjuð, hvort hún sé fyrsta-flokks eða frá þriðja aðila, tegundum hennar og birtingarnafni. Bættu við `--json` ef þú ert að fæða það í eitthvað annað.

Viðbótarkenni eru nafnrýmiskennd. Innbyggðu byrja allar á `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — og það nafnrými er frátekið, þannig að viðbót frá þriðja aðila getur aldrei gert tilkall til þess.

## Að kveikja og slökkva á þeim

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Eða notaðu valmyndina: _Uppsetning > Viðbætur_ hefur Virkja viðbót, Slökkva á viðbót, Bæta viðbót við, Klóna viðbót og Fjarlægja viðbót, hver með vali sem býður aðeins upp á viðbæturnar sem eiga við þá aðgerð.

Virkt ástand er geymt í `~/.config/omarchy/shell.json`, og reglan er nokkuð mismunandi fyrir tegundirnar tvær af viðbótum. Viðbót frá þriðja aðila er virkjuð nákvæmlega þegar kenni hennar birtist einhvers staðar í þeirri skrá — sem færsla í stikuuppsetningu, sem færsla í `plugins[]`, eða sem `bar.id`. Fyrstu-flokks viðbætur sem eru ekki stikugræjur eru öfugt: þær eru kveiktar sjálfgefið og slökkva aðeins á sér með því að vera listaðar í `disabledPlugins[]`.

Full stikuviðbót hefur alls ekkert slökkt ástand. Það er alltaf nákvæmlega ein stika, þannig að þú skiptir henni út með því að virkja aðra. Staðsetning stikugræja er fjallað um í [efstu stikunni](05-the-top-bar.md).

## Að bæta við viðbót frá git

Viðbót frá þriðja aðila er bara git-repo með `manifest.json` í rót sinni.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Áður en það gerir nokkuð segir það þér hreint út að viðbætur keyri sem handahófskenndur, ósandkassaður kóði inni í langlífa shell-ferlinu þínu, sýnir þér vefslóðina og biður þig um að staðfesta. Taktu það alvarlega. Viðmót viðbóta frá þriðja aðila afhjúpar ekki beint auðkenningarþjónustur, og staðgengilsstika fær aðeins takmarkaða getu fyrir stillt UI sem ekki er auðkenning. Sjónrænar viðbætur deila enn QML-senunni í shellinu og geta gengið í gegnum venjuleg foreldrahluti, á meðan allur viðbótarkóði keyrir með öllu sem notandareikningurinn þinn getur náð í. Auðkenningarástand er varið sérstaklega með því að halda þeim þjónustum utan náanlegs hlutagrafa hýsilsins. Bættu aðeins við repos sem þú ert tilbúinn að keyra, og lestu þau áður en þú virkjar þau.

Staðgengilsstika getur teiknað uppsettar græjur, en þjónustustuddar græjur frá þriðja aðila gætu haft skerta virkni þar vegna þess að stikunni er ekki leyft að biðja um lifandi þjónustuhlut annarrar viðbótar. Skiptu aftur yfir í innbyggða `omarchy.bar` ef slík græja þarf fylgiþjónustu sína.

Síðan klónar það repoið í sviðsetningarmöppu, sannreynir manifestið, neitar uppsetningunni ef önnur viðbót gerir þegar tilkall til þess kennis, og færir það í `~/.config/omarchy/plugins/<id>/`. Án `--enable` spyr það hvort þú viljir hafa það kveikt núna, og þú getur sagt nei og farið að lesa kóðann fyrst. Það keyrir aldrei neitt úr viðbótinni, keyrir aldrei uppsetningarkrók og biður aldrei um sudo — það klónar skrár, athugar manifestið og flettir bita yfir IPC.

Uppfærsla er hraðframspóluð upptaka af sama afriti:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Án kennis uppfærir það hverja git-stýrða viðbót sem þú hefur. Það sýnir þér diffið áður en það beitir því, neitar að uppfæra ef þú átt staðbundnar breytingar sem það getur ekki hraðframspólað framhjá, og bakkar ef nýja útgáfan stenst ekki sannprófun.

```
omarchy plugin remove acme.weather
```

Fjarlæging slekkur fyrst á viðbótinni, eyðir henni síðan ef hún er git-afrit (repoið er enn andstreymis) eða aftengir hana ef hún er tákntengill. Handgerð viðbótarmappa án git-repo er færð í tímastimpað afrit inni í viðbótamöppunni í stað þess að vera eytt alveg.

## Að klóna innbyggða viðbót til að breyta henni

Þetta er uppáhaldshlutinn minn. Ef þú vilt breyta því hvernig innbyggð græja hegðar sér skaltu ekki breyta skránum undir `$OMARCHY_PATH` — þær tilheyra pakkanum og næsta uppfærsla mun yfirskrifa þær. Klónaðu hana í staðinn:

```
omarchy plugin clone omarchy.clock
```

Það afritar alla viðbótina í `~/.config/omarchy/plugins/dhh.clock` (notandanafnið þitt, ekki mitt), endurnefnir hana í „My Clock“, virkjar hana og skiptir shellinu yfir úr innbyggðu í eintakið þitt — þar sem núverandi staða og stillingar stikugræju haldast. Bættu við `--edit` til að opna nýju möppuna í `$EDITOR` þínum strax, sem er það sem _Uppsetning > Viðbætur > Klóna viðbót_ í valmyndinni gerir fyrir þig.

Notandanafnsforskeytið heldur kenni klónsins þíns þínu, þannig að það að deila honum rekst ekki á neinn annan. Köll sem gerð eru á upprunalega innbyggða kennið eru beind að klóninum þínum, þannig að ekkert sem vísaði í `omarchy.clock` þarf uppfærslu. Og ef þú gerir drasl úr því setur `omarchy plugin remove dhh.clock` innbyggðu aftur.

Að vista skrá hvar sem er undir `~/.config/omarchy/plugins/` endurhleður viðbótarkóðann sjálfkrafa, þannig að þú getur látið ritilinn vera opinn og horft á breytingarnar þínar lenda.

## Að skrifa þína eigin

Viðbót er mappa með `manifest.json` og nokkru QML. Manifestið lýsir yfir `schemaVersion: 1`, `id`, `name`, `version`, einni eða fleiri `kinds`, og `entryPoints`-hlut sem vísar á QML-skrána fyrir hverja tegund:

| Kind | What it is |
|------|------------|
| `bar-widget` | Hluti sem virka stikan getur sett í hluta |
| `panel` | Viðvarandi eða kallaður fljótandi gluggi |
| `overlay` | Heilskjáa-yfirborð |
| `menu` | Kallað valmyndaryfirborð |
| `service` | Höfuðlaus einþáttungur án UI |
| `bar` | Full stika sem kemur í stað innbyggðu |

Viðbót getur lýst yfir nokkrum tegundum í einu — fjölmiðlaviðbótin er bæði `service` og `bar-widget`. Stikugræjur fá auka `barWidget`-blokk með birtingarnafni, flokki, valfrjálsum `defaultSection` og `allowMultiple`, sem segir hvort það eigi við að hafa fleiri en eina á stikunni. Flestar græjur stilla það á `false`; bil og vísar stilla það á `true`.

Áður en þú birtir nokkuð skaltu athuga það:

```
omarchy plugin validate ./my-plugin
```

Það keyrir sömu athuganir og shellið gerir við hleðslutíma: skemaútgáfuna, nauðsynlegu reitina, kenni sem er ekki frátekið, inngangspunkta sem eru öruggar afstæðar slóðir og eru raunverulega til, inngangspunkt fyrir hverja tegund sem þú gerðir tilkall til, og enga tákntengla neins staðar inni í möppunni.

Fyrir viðbótarþróun, sjá [shell-tilvísunina](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) og [fyrstu-flokks viðbótakatalóginn](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Að deila þinni með heiminum

Þegar þú hefur gert eitthvað sem þér líkar skaltu setja það í opinbert git-repo. Það er allt dreififyrirkomulagið — hver sem er getur þá keyrt `omarchy plugin add` gegn vefslóðinni þinni og fengið það keyrandi á nokkrum sekúndum.

Til að hjálpa fólki raunverulega að finna það skaltu skrá það á [plugins.omarchy.org](https://plugins.omarchy.org). Það er markaðstorgið fyrir Omarchy shell-viðbætur, og það er fyrsti staðurinn til að leita þegar þú veltir fyrir þér hvort einhver hafi þegar byggt græjuna sem þú ert að fara að skrifa. Skoðaðu það áður en þú byrjar!
