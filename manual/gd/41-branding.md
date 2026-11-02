# Branndadh

Leigidh Omarchy leat suaicheantas a' chompanaidh agad no dealbh pearsanta a chur air sgrìn fuasgladh a' bhùtaidh, air an t-sàbhalaiche-sgrìn agus air an sgrìn "Mu dhèidhinn".

### Fuasgladh a' bhùtaidh

'S urrainn dhut `omarchy plymouth preview` a chleachdadh airson faicinn mar a bhiodh an suaicheantas is na dathan agad a' coimhead. Gabhaidh e dath a' chùlaibh, dath an teacsa, suaicheantas png agus slighe airson dealbh an ro-shealladh:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

An uairsin, cuir an suidheachadh an sàs le `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, agus gheibh sgrìn clàradh a-steach SDDM na h-aon dathan is an aon suaicheantas cuideachd. Ma tha thu airson tilleadh mar a bha, cleachd `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Sàbhalaiche-sgrìn

'S urrainn dhut an suaicheantas a chleachdas an sàbhalaiche-sgrìn atharrachadh fo _Coltas > Branndadh > Sàbhalaiche-sgrìn_. 'S e suaicheantas ASCII a th' ann, mar sin 's urrainn dhut an teacsa a dheasachadh gu dìreach, ach 's urrainn dhut dealbh png no svg a thoirt dha cuideachd, is iompaichidh sinne gu ASCII e. Tha e gu math spaideil.

 ![branding-screensaver](images/branding-screensaver.webp)

Tha trì nithean sa chlàr-taice sin:

- Fosglaidh **Deasaich an teacsa** `~/.config/omarchy/branding/screensaver.txt` san deasaiche agad. Sgrìobh no cuir ann rud sam bith as toil leat — ealain ASCII, d' ainm, droch fhacal. Sàbhail is fàg e, is tòisichidh an sàbhalaiche-sgrìn sa bhad ach am faic thu e.
- Fosglaidh **Suidhich o dhealbh** roghnaichear fhaidhlichean airson png no svg, iompaichidh e gu ASCII e is seallaidh e an toradh dhut. Obraichidh suaicheantasan le cumadh soilleir mòran nas fheàrr na dealbhan-camara.
- Cuiridh **Aisig a' bhun-roghainn** suaicheantas Omarchy air ais.

### An sgrìn "Mu dhèidhinn"

Tha na h-aon trì roghainnean fo _Coltas > Branndadh > Mu dhèidhinn_ airson na sgrìn _Mu dhèidhinn_ a gheibh thu o chlàr-taice Omarchy, is obraichidh iad dìreach mar an ceudna — 's e `~/.config/omarchy/branding/about.txt` am faidhle, agus nochdaidh uinneag "Mu dhèidhinn" an dèidh gach atharrachaidh. Thèid ealain "Mu dhèidhinn" iompachadh gu meud nas lugha na ealain an t-sàbhalaiche-sgrìn, on a dh'fheumas i a dhol am broinn uinneige seach an sgrìn agad a lìonadh.

Fhad 's a bhios an uinneag fosgailte, sìnidh boillsgeadh uaine thar na h-ealain gach beagan dhiogan agus fàgaidh e na stad i a-rithist. Gheibh an ealain agad fhèin e cuideachd, fhad 's a bhios gach caractar innte aon cholbh a leud — agus bidh gach rud a nì _Suidhich o dhealbh_ mar sin. Fanaidh ealain a chaidh a thogail à emoji no caractaran dà-leud na stad, agus an sgrìn cuideachd ma chumas tu rèiteachadh fastfetch agad fhèin: ann an suidheachaidhean mar sin, chan e fàilligeadh a th' ann an suaicheantas na stad ach am beòthachadh a' cumail a-mach às an rathad, oir nan sleamhnaicheadh boillsgeadh tarsainn orra, rachadh an còrr dhen loidhne dhan àite chearr.

 ![branding-about](images/branding-about.webp)

### Dealbhan iompachadh thu fhèin

Chan eil an dà roghainn _Suidhich o dhealbh_ a' dèanamh ach `omarchy transcode ascii` a ghairm, agus 's urrainn dhut sin a ruith gu dìreach ma tha thu ag iarraidh smachd air an iompachadh:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Gabhaidh e `--width` agus `--height` ann an colbhan is sreathan an tèirmineil, `--mode` a tha an dàrna cuid `braille` (am bun-roghainn, is tòrr nas mionaidiche) no `block`, ceudad `--threshold` gus co-dhùnadh dè na piogsailean a tha nam pàirt dhen t-suaicheantas, agus `--invert` airson nuair a bhios an suaicheantas agad soilleir air cùlaibh dorcha. Ma thig iompachadh a-mach na mheall, 's e an stairsneach am putan a tha ri thionndadh mar as trice.

### Faclan an àite suaicheantais

Tarraingidh `omarchy ascii` teacsa ann an Delta Corps Priest 1, an cruth-clò FIGlet anns an deach comharra-facail Omarchy fhèin a tharraing, ach an urrainn do shàbhalaiche-sgrìn rudeigin a ràdh seach dealbh a shealltainn:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Gabhaidh e an teacsa mar argamaidean, no leughaidh e o phìob e mura faigh e gin. Chan eil sa chruth-chlò ach litrichean is beàrnan — chaidh a tharraing gun àireamhan no puingeachadh — mar sin thèid rud sam bith eile a leigeil seachad is ainmeachadh air stderr seach a shlugadh gu sàmhach.
