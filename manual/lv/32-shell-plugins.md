# Čaulas spraudņi

Omarchy darbvirsma darbojas kā viens ilgi dzīvojošs Quickshell process ar nosaukumu `omarchy-shell`, un gandrīz viss, ko redzat ekrānā, tās iekšienē ir spraudnis. Josla ir spraudnis. Tāpat arī paneļi, kas no tās nolaižas, pilnekrāna pārklājumi, piemēram, emocijzīmju atlasītājs un starpliktuves pārvaldnieks, pati Omarchy izvēlne, bloķēšanas ekrāns, polkit dialogs un bezgalvu pakalpojumi, kas vēro jūsu akumulatoru un naktī sasilda ekrānu.

Tas nav tikai īstenošanas sīkums. Tas nozīmē, ka jūs varat darbvirsmas daļas izslēgt, tās izmainīt vietām vai rakstīt savējās, nepieskaroties nevienai Omarchy avota rindai.

Pirmās puses spraudņi tiek piegādāti kopā ar Omarchy un dzīvo mapē `$OMARCHY_PATH/shell/plugins/`. Viss, ko pievienojat pats — savi eksperimenti vai kaut kas GitHub vietnē atrasts —, dzīvo mapē `~/.config/omarchy/plugins/`. Abi startēšanās laikā tiek atklāti vienādi, taču iebūvētie saņem uzticamas čaulas saskarnes, kamēr trešo pušu spraudņi saņem ierobežotu saskarni, kas norobežota līdz viņu pašu pakalpojumam un dzīves ciklam. Iebūvēto kloniem saglabājas tikai avotam raksturīgās konfigurācijas un lietotāja saskarnes izsaukumi, kas nepieciešami sākotnējai uzvedībai.

## Skatoties, kas jums ir

```
omarchy plugin list
```

Tas izdrukā katru atklāto spraudni ar tā identifikatoru, norādi, vai tas ir iespējots, norādi, vai tas ir pirmās puses vai trešās puses, tā veidiem un attēlojamu nosaukumu. Pievienojiet `--json`, ja padodat to kam citam.

Spraudņu identifikatori ir vārdtelpā. Iebūvētie visi sākas ar `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` —, un šī vārdtelpa ir rezervēta, tāpēc trešās puses spraudnis to nekad nevar pieprasīt.

## To ieslēgšana un izslēgšana

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Vai arī izmantojiet izvēlni: sadaļā _Iestatīšana > Plugins_ ir darbības Enable, Disable, Add, Clone un Remove, katra ar atlasītāju, kurš piedāvā tikai tos spraudņus, kuriem šai darbībai ir jēga.

Iespējots stāvoklis tiek glabāts failā `~/.config/omarchy/shell.json`, un abiem spraudņu veidiem noteikums nedaudz atšķiras. Trešās puses spraudnis ir iespējots tieši tad, kad tā identifikators kaut kur šajā failā parādās — kā joslas izkārtojuma ieraksts, kā ieraksts sarakstā `plugins[]` vai kā `bar.id`. Pirmās puses spraudņi, kas nav joslas logrīki, ir otrādi: tie pēc noklusējuma ir ieslēgti un izslēdzas tikai tad, kad tiek uzskaitīti sarakstā `disabledPlugins[]`.

Pilnam joslas spraudnim izslēgta stāvokļa vispār nav. Vienmēr ir tieši viena josla, tāpēc jūs to aizstājat, iespējojot citu. Joslas logrīku novietojums ir aprakstīts sadaļā [augšējā josla](05-the-top-bar.md).

## Spraudņa pievienošana no git

Trešās puses spraudnis ir vienkārši git repozitorijs ar `manifest.json` tā saknē.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Pirms tas kaut ko dara, tas jums skaidri pasaka, ka spraudņi jūsu ilgi dzīvojošajā čaulas procesā darbojas kā patvaļīgs kods bez smilškastes (sandbox), parāda vietrādi un prasa jums apstiprināt. Uztveriet to nopietni. Trešās puses spraudņu saskarne autentifikācijas pakalpojumus tiešā veidā neatklāj, bet aizvietojoša josla saņem tikai ierobežotas spējas konfigurētam neautentificējošam lietotāja saskarnes saturam. Vizuālie spraudņi joprojām koplieto čaulas QML ainu un var staigāt pa ierastajiem vecākobjektiem, kamēr katrs spraudņa kods darbojas ar visu, kam jūsu lietotāja konts var piekļūt. Autentifikācijas stāvoklis tiek aizsargāts atsevišķi, šos pakalpojumus turot ārpus sasniedzamā resursdatora objektu grafika. Pievienojiet tikai tās repozitorijas, ko esat gatavs darbināt, un izlasiet tās, pirms tās iespējojat.

Aizvietojoša josla var atveidot instalētos logrīkus, taču pakalpojumu atbalstītiem trešo pušu logrīkiem tur var būt samazināta funkcionalitāte, jo joslai nav atļauts pieprasīt cita spraudņa dzīvu pakalpojuma objektu. Pārslēdzieties atpakaļ uz iebūvēto `omarchy.bar`, ja šādam logrīkam vajadzīgs tā pavadošais pakalpojums.

Pēc tam tas repozitoriju klonē pagaidu direktorijā, pārbauda manifestu, atsaka instalēšanu, ja cits spraudnis šo identifikatoru jau pieprasa, un pārvieto to uz `~/.config/omarchy/plugins/<id>/`. Bez `--enable` tas vaicā, vai vēlaties to ieslēgt tūlīt, un jūs varat teikt nē un vispirms doties izlasīt kodu. Tas nekad no spraudņa neko nepalaiž, nekad neizpilda instalēšanas āķi un nekad neprasa sudo — tas klonē failus, pārbauda manifestu un caur IPC pagriež vienu bitu.

Atjaunināšana ir ātra tās pašas izrakstīšanas pārvilkšana (fast-forward pull):

```
omarchy plugin update acme.weather
omarchy plugin update
```

Bez identifikatora tas atjaunina katru jūsu git pārvaldīto spraudni. Tas jums pirms piemērošanas parāda starpību, atsaka atjaunināšanu, ja jums ir lokālas izmaiņas, kuras nevar ātri pārvilkt pāri, un atsauc izmaiņas, ja jaunā revīzija neiztur pārbaudi.

```
omarchy plugin remove acme.weather
```

Noņemšana spraudni vispirms atspējo un pēc tam izdzēš, ja tā ir git izrakstīšana (repozitorijs joprojām darbojas augšpusē), vai atsaista, ja tā ir simboliskā saite. Ar roku veidota spraudņa mape, kurai nav git repozitorija, tā vietā, lai to izdzēstu pavisam, tiek pārvietota uz ar laika zīmogu marķētu dublējumu spraudņu direktorijā.

## Iebūvēta spraudņa klonēšana, lai to mainītu

Šī ir mana mīļākā daļa. Ja vēlaties mainīt, kā iebūvēts logrīks uzvedas, nerediģējiet failus zem `$OMARCHY_PATH` — tie pieder pakotnei, un nākamais atjauninājums tos pārrakstīs. Tā vietā to klonējiet:

```
omarchy plugin clone omarchy.clock
```

Tas veselu spraudni pārkopē uz `~/.config/omarchy/plugins/dhh.clock` (jūsu lietotājvārds, ne mans), pārsauc to par “My Clock”, iespējo to un čaulu pārslēdz no iebūvētā uz jūsu kopiju — saglabājot esoša joslas logrīka novietojumu un iestatījumus. Pievienojiet `--edit`, lai jauno direktoriju uzreiz atvērtu savā redaktorā `$EDITOR`, ko jūsu vietā dara izvēlnes sadaļa _Iestatīšana > Plugins > Clone Plugin_.

Lietotājvārda prefikss jūsu klona identifikatoru saglabā jums, tāpēc tā koplietošana nesaduras ne ar vienu citu. Izsaukumi, kas veikti uz sākotnējo iebūvēto identifikatoru, tiek novirzīti uz jūsu klonu, tāpēc nekam, kas atsaucās uz `omarchy.clock`, nekas nav jāatjaunina. Un, ja jūs tajā izveidojat jucekli, komanda `omarchy plugin remove dhh.clock` iebūvēto ieliek atpakaļ.

Faila saglabāšana jebkurā vietā zem `~/.config/omarchy/plugins/` spraudņa kodu pārlādē automātiski, tāpēc varat redaktoru atstāt atvērtu un vērot, kā jūsu izmaiņas nolaižas.

## Sava rakstīšana

Spraudnis ir direktorija ar `manifest.json` un kādu QML. Manifests nosaka `schemaVersion: 1`, `id`, `name`, `version`, vienu vai vairākus `kinds` un objektu `entryPoints`, kas norāda uz QML failu katram veidam:

| Veids | Kas tas ir |
|------|------------|
| `bar-widget` | Komponente, kuru aktīvā josla var iemest sadaļā |
| `panel` | Noturīgs vai izsaukts peldošs logs |
| `overlay` | Pilnekrāna pārklājums |
| `menu` | Izsaukta izvēlnes virsma |
| `service` | Bezgalvu vienvietīgais elements (singleton) bez lietotāja saskarnes |
| `bar` | Pilna josla, kas aizstāj iebūvēto |

Spraudnis var deklarēt vairākus veidus vienlaikus — multivides spraudnis ir gan `service`, gan `bar-widget`. Joslas logrīki saņem papildu bloku `barWidget` ar attēlojamu nosaukumu, kategoriju, neobligātu `defaultSection` un `allowMultiple`, kas pasaka, vai vairāk nekā vienam uz joslas ir jēga. Vairums logrīku to iestata uz `false`; atstarpes veidotāji un rādītāji to iestata uz `true`.

Pirms ko publicējat, pārbaudiet to:

```
omarchy plugin validate ./my-plugin
```

Tas palaiž tās pašas pārbaudes, ko čaula veic ielādes laikā: shēmas versiju, nepieciešamos laukus, nerezervētu identifikatoru, drošus relatīvus ceļus, kas patiesībā pastāv, — ieejas punktu katram jūsu pieprasītajam veidam, un nevienu simbolisko saiti nekādā vietā mapes iekšienē.

Par spraudņu izstrādi skatiet [čaulas atsauci](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) un [pirmās puses spraudņu katalogu](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Sava koplietošana ar pasauli

Kad esat izveidojis kaut ko, kas jums patīk, ielieciet publiskā git repozitorijā. Tas ir viss izplatīšanas mehānisms — pēc tam ikviens pret jūsu vietrādi var palaist `omarchy plugin add` un tas pāris sekunžu laikā darbosies.

Lai palīdzētu cilvēkiem to patiesībā atrast, uzskaitiet to tīmekļa vietnē [plugins.omarchy.org](https://plugins.omarchy.org). Tas ir Omarchy čaulas spraudņu tirdzniecības laukums, un tā ir pirmā vieta, kur skatīties, kad prātojat, vai kāds jau nav uzbūvējis to logrīku, ko gatavojaties rakstīt. Pārlūkojiet to pirms sākšanas!
