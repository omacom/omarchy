# Plugain na slige

Ruithidh deasg Omarchy mar aon phròiseas Quickshell fad-beò air a bheil `omarchy-shell`, agus tha cha mhòr a h-uile càil a chì thu air an sgrìn na phlugan na bhroinn. 'S e plugan a th' anns a' bhàr. Agus mar sin na panailean a thuiteas sìos uaithe, na tar-chòmhdachaidhean làn-sgrìn mar an taghadair emoji agus manaidsear an stòr-bhùird, clàr-taice Omarchy fhèin, an sgrìn-ghlasaidh, còmhradh polkit, agus na seirbheisean gun eadar-aghaidh a chumas sùil air a' bhataraidh agad agus a bhlàthaicheas an sgrìn agad air an oidhche.

Chan e dìreach mion-phuing buileachaidh a tha sin. Tha e a' ciallachadh gun urrainn dhut pìosan dhen deasg a chur dheth, feadhainn eile a chur nan àite, no an fheadhainn agad fhèin a sgrìobhadh gun suathadh ri aon loidhne de chòd tùsail Omarchy.

Thig na plugain chiad-phàrtaidh le Omarchy agus tha iad a' fuireach ann an `$OMARCHY_PATH/shell/plugins/`. Tha rud sam bith a chuireas tu fhèin ris — na deuchainnean agad fhèin, no rudeigin a lorg thu air GitHub — a' fuireach ann an `~/.config/omarchy/plugins/`. Lorgar an dà sheòrsa san aon dòigh aig an tòiseachadh, ach gheibh na plugain thogte eadar-aghaidhean earbsach na slige, fhad 's a gheibh plugain threas-phàrtaidh eadar-aghaidh chuingichte a tha cuingichte ris an t-seirbheis is ri cuairt-beatha aca fhèin. Cha chùm clonaichean de phlugain thogte ach an rèiteachadh sònraichte dhan tùs agus na gairmean UI a tha a dhìth airson giùlan an tùs-phlugain.

## Faic na th' agad

```
omarchy plugin list
```

Clò-bhuailidh sin gach plugan a chaidh a lorg leis an id aige, a bheil e an comas, an e plugan chiad-phàrtaidh no treas-phàrtaidh a th' ann, na seòrsaichean aige agus an t-ainm-taisbeanaidh aige. Cuir `--json` ris ma tha thu ga bhiadhadh do rudeigin eile.

Tha ainm-spàsan aig ids nam plugan. Tòisichidh na plugain thogte uile le `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — agus tha an t-ainm-spàs sin glèidhte, mar sin chan urrainn do phlugan treas-phàrtaidh grèim fhaighinn air gu bràth.

## An cur air is dheth

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

No cleachd an clàr-taice: tha _Cuir plugan an comas_, _Cuir plugan à comas_, _Cuir plugan ris_, _Clonaich plugan_ agus _Thoir plugan air falbh_ ann an _Suidheachadh > Plugain_, gach fear le taghadair nach tairg ach na plugain a tha ciallach dhan ghnìomh sin.

Thèid staid a' chomais a stòradh ann an `~/.config/omarchy/shell.json`, agus tha an riaghailt beagan eadar-dhealaichte airson an dà sheòrsa plugain. Bidh plugan treas-phàrtaidh an comas dìreach nuair a nochdas an id aige an àiteigin san fhaidhle sin — mar nì ann an co-dhealbhachd a' bhàir, mar nì ann am `plugins[]`, no mar `bar.id`. Tha plugain chiad-phàrtaidh nach e widgets bàir a th' annta an rathad eile mun cuairt: bidh iad air mar bhun-roghainn agus cha tèid iad dheth ach ma bhios iad air an liosta ann an `disabledPlugins[]`.

Chan eil staid dheth idir aig plugan bàir slàn. Bidh dìreach aon bhàr ann an-còmhnaidh, mar sin cuiridh tu fear eile na àite le bhith a' cur fear eile an comas. Tha suidheachadh nan widgets bàir air a mhìneachadh ann an [am bàr gu h-àrd](05-the-top-bar.md).

## Plugan a chur ris o git

Chan eil ann am plugan treas-phàrtaidh ach ionad-tasgaidh git le `manifest.json` aig a fhreumh.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Mus dèan e càil, innsidh e dhut gu soilleir gu bheil plugain a' ruith mar chòd neo-chuingichte gun bhogsa-gainmhich am broinn pròiseas fad-beò na slige agad, seallaidh e an URL dhut, agus iarraidh e ort a dhearbhadh. Gabh sin gu dàirire. Cha nochd eadar-aghaidh nam plugan treas-phàrtaidh seirbheisean dearbhaidh gu dìreach, agus chan fhaigh bàr ionaid ach comasan cuingichte airson UI rèitichte nach buin ri dearbhadh. Tha plugain lèirsinneach fhathast a' co-roinneadh sealladh QML na slige agus 's urrainn dhaibh coiseachd tro oibseactan pàrant àbhaisteach, agus ruithidh còd gach plugain leis a h-uile càil as urrainn dhan chunntas-chleachdaiche agad ruigsinn. Tha staid an dearbhaidh air a dìon fa leth le bhith a' cumail nan seirbheisean sin taobh a-muigh graf nan oibseactan òstair a ghabhas ruigsinn. Na cuir ris ach ionadan-tasgaidh a tha thu deònach a ruith, agus leugh iad mus cuir thu an comas iad.

'S urrainn do bhàr ionaid widgets stàlaichte a reandaradh, ach dh'fhaoidte nach obraich widgets treas-phàrtaidh a tha an urra ri seirbheis cho math an sin, oir chan fhaod am bàr oibseact seirbheis beò plugain eile iarraidh. Till gu `omarchy.bar` togte ma tha feum aig widget mar sin air an t-seirbheis cho-cheangailte aige.

An uairsin nì e clonadh dhen ionad-tasgaidh do phasgan ullachaidh, dearbhaidh e am manifest, diùltaidh e an stàladh ma tha plugan eile ag agairt na h-aon id mu thràth, agus gluaisidh e e gu `~/.config/omarchy/plugins/<id>/`. Às aonais `--enable` faighnichidh e a bheil thu ga iarraidh air an-dràsta, agus faodaidh tu "chan eil" a ràdh agus a dhol a leughadh a' chòd an toiseach. Cha ruith e rud sam bith on phlugan gu bràth, cha chuir e dubhan stàlaidh gu dol gu bràth, agus chan iarr e sudo gu bràth — nì e clonadh de dh'fhaidhlichean, sgrùdaidh e am manifest, agus toglaichidh e bìdeag thar IPC.

'S e pull fast-forward dhen aon lethbhreac sin a th' ann an ùrachadh:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Às aonais id, ùraichidh e gach plugan fo stiùireadh git a th' agad. Seallaidh e an diff dhut mus cuir e an sàs e, diùltaidh e ùrachadh ma tha atharraichean ionadail agad nach urrainn dha fast-forward a dhèanamh seachad orra, agus tillidh e air ais mura soirbhich leis an lèirmheas ùr leis an dearbhadh.

```
omarchy plugin remove acme.weather
```

Cuiridh an toirt air falbh am plugan à comas an toiseach, an uairsin sguabaidh e às e mas e lethbhreac git a th' ann (tha an t-ionad-tasgaidh fhathast shuas an abhainn) no bheir e an ceangal air falbh mas e symlink a th' ann. Ma tha pasgan plugain air a dhèanamh le làimh gun ionad-tasgaidh git, thèid a ghluasad gu lethbhreac-glèidhidh le stampa-ama am broinn pasgan nam plugan seach a sguabadh às gu buileach.

## Plugan togte a chlonadh gus atharrachadh

Seo am pàirt as fheàrr leam. Ma tha thu airson giùlan widget thogte atharrachadh, na deasaich na faidhlichean fo `$OMARCHY_PATH` — buinidh iad sin dhan phacaid agus sgrìobhaidh an ath ùrachadh thairis orra. Clonaich e na àite:

```
omarchy plugin clone omarchy.clock
```

Nì sin lethbhreac dhen phlugan slàn gu `~/.config/omarchy/plugins/dhh.clock` (d' ainm-cleachdaiche fhèin, chan e am fear agamsa), cuiridh e "My Clock" mar ainm air, cuiridh e an comas e, agus atharraichidh e an t-slige on phlugan thogte gun lethbhreac agad — a' cumail ionad is roghainnean widget bàir a tha ann mu thràth. Cuir `--edit` ris gus am pasgan ùr fhosgladh san `$EDITOR` agad sa bhad, agus 's e sin na nì _Suidheachadh > Plugain > Clonaich plugan_ sa chlàr-taice dhut.

Cumaidh an ro-leasachan ainm-cleachdaiche id a' chlòin agad dhut fhèin, mar sin ma cho-roinneas tu e, cha bhuail e ri id duine sam bith eile. Thèid gairmean gu id a' phlugain thogte thùsail a stiùireadh dhan chlòn agad, mar sin cha leig thu leas rud sam bith a thug iomradh air `omarchy.clock` ùrachadh. Agus ma nì thu brochan dheth, cuiridh `omarchy plugin remove dhh.clock` am plugan togte air ais.

Ma shàbhaileas tu faidhle àite sam bith fo `~/.config/omarchy/plugins/`, ath-luchdaichidh còd a' phlugain gu fèin-obrachail, mar sin 's urrainn dhut an deasaiche fhàgail fosgailte agus coimhead air na h-atharraichean agad a' tighinn gu buil.

## Sgrìobh an fheadhainn agad fhèin

'S e pasgan le `manifest.json` agus beagan QML a th' ann am plugan. Bidh am manifest ag ainmeachadh `schemaVersion: 1`, `id`, `name`, `version`, aon `kinds` no barrachd, agus oibseact `entryPoints` a chomharraicheas am faidhle QML do gach seòrsa:

| Seòrsa | Dè th' ann |
|------|------------|
| `bar-widget` | Co-phàirt as urrainn dhan bhàr ghnìomhach a chur ann an earrann |
| `panel` | Uinneag air fleòdradh a bhios ann an-còmhnaidh no a ghairmear |
| `overlay` | Tar-chòmhdachadh làn-sgrìn |
| `menu` | Uachdar clàir-thaice a ghairmear |
| `service` | Singleton gun eadar-aghaidh gun UI |
| `bar` | Bàr slàn a thèid an àite a' bhàir thogte |

'S urrainn do phlugan iomadh seòrsa ainmeachadh aig an aon àm — tha plugan nam meadhanan na `service` agus na `bar-widget` le chèile. Gheibh widgets bàir bloca `barWidget` a bharrachd le ainm-taisbeanaidh, roinn-seòrsa, `defaultSection` roghainneil, agus `allowMultiple`, a dh'innseas a bheil e ciallach barrachd air aon dhiubh a bhith air a' bhàr. Suidhichidh a' mhòr-chuid de dh'widgets e gu `false`; suidhichidh beàrnadairean agus taisbeanairean e gu `true`.

Mus foillsich thu dad, dèan sgrùdadh air:

```
omarchy plugin validate ./my-plugin
```

Ruithidh sin na h-aon sgrùdaidhean a nì an t-slige aig àm an luchdaidh: tionndadh an sgeama, na raointean riatanach, id nach eil glèidhte, puingean-inntrigidh a tha nan slighean dàimheach sàbhailte agus a tha ann dha-rìribh, puing-inntrigidh airson gach seòrsa a dh'agair thu, agus gun symlink sam bith am broinn a' phasgain.

Airson leasachadh phlugan, faic [iomradh na slige](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) agus [catalog nam plugan chiad-phàrtaidh](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Co-roinn an fheadhainn agad ris an t-saoghal

Nuair a bhios tu air rudeigin a dhèanamh as toil leat, cuir ann an ionad-tasgaidh git poblach e. Sin an dòigh sgaoilidh air fad — 's urrainn do dhuine sam bith `omarchy plugin add` a ruith an aghaidh an URL agad an uairsin agus bidh e a' ruith aca ann am diogan.

Gus cuideachadh le daoine a lorg e, cuir e air liosta aig [plugins.omarchy.org](https://plugins.omarchy.org). 'S e sin am margadh airson plugain slige Omarchy, agus 's e a' chiad àite an coimhead thu nuair a tha thu a' cnuasachd an do thog cuideigin an widget a tha thu an impis sgrìobhadh mu thràth. Brabhsaich e mus tòisich thu!
