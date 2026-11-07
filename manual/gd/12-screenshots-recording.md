# Glacaidhean-sgrìn & clàradh

Tha a h-uile rud as urrainn dhut a ghlacadh far na sgrìn an crochadh air an iuchair Print Screen. Glacaidh an iuchair leatha fhèin dealbh, agus glacaidh na h-atharraichearan clàradh, dath no an teacsa am broinn raoin. Mur eil iuchair Print Screen idir air a' mheur-chlàr agad, glacaidh `Super + Ctrl + Alt + C` an aon ghlacadh-sgrìn, agus fosglaidh `Super + Ctrl + C` an t-seata gu lèir mar chlàr-taice.

| Iuchair-ghrad | Gnìomh |
| ------ | -------- |
| `Print Screen` | Glacadh-sgrìn |
| `Super + Ctrl + Alt + C` | Glacadh-sgrìn |
| `Alt + Print Screen` | Clàradh na sgrìn (no cuir stad air an fhear a tha a' dol) |
| `Super + Print Screen` | Roghnaichear dhathan |
| `Super + Ctrl + Print Screen` | Às-tarraing teacsa à raon |
| `Super + Ctrl + C` | Clàr-taice a' ghlacaidh |
| `Super + Ctrl + .` | Tar-chòdaich dealbh no video |

## Glacaidhean-sgrìn

Brùth `Print Screen` (no `Super + Ctrl + Alt + C`) agus glacaidh Omasnap am monatair le fòcas mus nochd an tar-chòmhdachadh aige, ach nach gluais dad fodhad fhad 's a tha thu ag amas. Slaod raon saor, briog air uinneag gus a glacadh, no briog air àite falamh gus am monatair slàn a ghlacadh. Brùth `S` mus tarraing thu gus raon a ghabhas sgroladh a ghlacadh. Na do bheachd air atharrachadh? Brùth an aon iuchair a-rithist gus Omasnap a leigeil seachad.

Nuair a thaghas tu raon, sàbhailidh Omasnap an glacadh, nì e lethbhreac dheth dhan stòr-bhòrd agus seallaidh e brath le dealbhag dheth, dìreach mar a nì clàradh sgrìn a chaidh a shàbhaladh. Tagh Fosgail gus an glacadh a chaidh a shàbhaladh fhaicinn san t-sealladair dhealbhan agad, no Deasaich gus notaichean a chur ris.

'S urrainn do dheasaiche nan notaichean saighdean, loidhnichean, cruthan, soillseachaidhean, comharran le àireamhan, teacsa agus dubh-às tèarainte a tharraing; pìos dhen dealbh a bhearradh no a ghearradh às; OCR a dhèanamh air an teacsa aige; agus cùlaibh a chur ris. San deasaiche, brùth `Enter` gus lethbhreac dhen PNG chrìochnaichte a dhèanamh agus a shàbhaladh, `Ctrl + C` gus lethbhreac a dhèanamh gun a shàbhaladh, no `Ctrl + S` gus a shàbhaladh gun lethbhreac a dhèanamh.

Thèid glacaidhean-sgrìn a shàbhaladh ann an `~/Pictures/Screenshots` a ghnàth, le ainm mar `screenshot-2026-08-13_14-22-05-firefox.png`. Suidhich `OMASNAP_SCREENSHOT_DIR` gus pasgan eile a chleachdadh — faic [na CÀBHA](46-faq.md) airson far an cuir thu caochladairean àrainneachd an t-seisein. Cruthaichidh Omasnap am pasgan nuair a shàbhaileas e a' chiad ghlacadh. Suidhich `[output] autosave = false` ann an `~/.config/omasnap/omasnap.conf` gus sàbhaladh fèin-obrachail a chur à comas; cha dèanar ach lethbhreac dhe na glacaidhean an uairsin, agus thèid an sealltainn ann an ro-shealladh fad 10 diogan a ghabhas cumail air an sgrìn le putan a' phrìneachaidh aige no le `Ctrl + P`.

On tèirmineal, fosglaidh `omarchy screenshot` an aon tar-chòmhdachadh, agus is urrainn dhut am modh tòiseachaidh aige a thaghadh: `omarchy capture screenshot region`, `windows`, `fullscreen` no `scroll`. Ma chuireas tu `copy` no `save` mar dhàrna argamaid, thèid an glacadh dìreach dhan cheann-uidhe sin. Gus a dheasachadh ron às-chur, cleachd `omarchy screenshot --editor=overlay` airson deasaiche làn-sgrìn no `omarchy screenshot --editor=window` airson uinneag fa leth.

### Stiùireadh an roghnaicheir leis a' mheur-chlàr

Fhad 's a tha an taghadh fosgailte, cha leig thu leas an luchag a chleachdadh idir:

| Iuchair | Gnìomh |
| --- | -------- |
| `S` | Toglaich am modh raoin a ghabhas sgroladh |
| `Super + Arrow keys` | Gluais eadar na h-uinneagan sa mhodh uinneige |
| `Return` | Glac an uinneag a tha soillsichte |
| `Ctrl + A` | Glac am monatair slàn le fòcas |
| `R` | Aisig an raon mu dheireadh a tharraing thu san t-seisean seo |
| `Esc` | Leig seachad Omasnap |

Chan eil na ceanglaichean seo ann ach fhad 's a tha Omasnap fosgailte, mar sin chan urrainn dhaibh bualadh an aghaidh dad san rèiteachadh agad fhèin.

## Clàradh na sgrìn

Fosglaidh `Alt + Print Screen` _Cuir gu dol > Glac > Clàraich an sgrìn_, a dh'fhaighnicheas dè tha thu ag iarraidh air an fhuaim: gun fhuaim, fuaim an deasga, an deasg agus am micreofon, no an deasg, am micreofon agus an camara-lìn. Cha nochd an tè mu dheireadh ach ma tha camara ceangailte agad dha-rìribh. Tagh tè dhiubh agus leigidh roghnaichear clàraidh Omarchy leat raon a shlaodadh no briogadh air uinneag no monatair.

Ruithidh an clàradh air gpu-screen-recorder, a nì còdachadh air a' GPU aig 60fps agus a thilleas chun a' CPU ma bhios aige ri. Is e MP4 ann an `~/Videos` a gheibh thu, air a bheil an t-ainm `screenrecording-2026-08-13_14-22-05.mp4`. Suidhich `OMARCHY_SCREENRECORD_DIR` gus sin atharrachadh — ach thoir an aire, eu-coltach ri pasgan nan glacaidhean-sgrìn, gum feum am pasgan seo a bhith ann mu thràth, air neo diùltaidh an clàradh tòiseachadh.

Fhad 's a tha thu a' clàradh, nochdaidh comharra beag sa bhàr. Briog air gus stad. 'S urrainn dhut stad cuideachd le `Alt + Print Screen` a-rithist, no leis an innteart _Cuir stad air clàradh na sgrìn_ fo _Cuir gu dol > Glac > Clàraich an sgrìn_, nach nochd ach fhad 's a tha rudeigin ga chlàradh dha-rìribh.

Nì stad beagan sgioblachaidh mus toir e dhut am faidhle: thèid a' chiad fhrèam a bhearradh, agus ma tha fuaim ann, thèid a normalachadh gu -14 LUFS agus thèid am brag glacaidh PipeWire aig an dearbh thoiseach a mhùchadh. An uairsin nochdaidh brath le dealbhag on chlàradh. Briog air gus am faidhle a chluich ann an mpv.

### Tar-chòmhdachadh a' chamara-lìn

Nuair a nì thu clàradh le camara-lìn, nochdaidh an camara mar uinneag portraid phrìnichte bhearrte san oisean gu h-ìosal air an taobh deas de ge b' e dè a tha thu a' clàradh. Ma tha e na shuidhe air muin rudeigin a tha a dhìth ort, atharraich a mheud san spot:

| Iuchair-ghrad | Gnìomh |
| ------ | -------- |
| `Super + Alt + [` | Lùghdaich tar-chòmhdachadh a' chamara-lìn |
| `Super + Alt + ]` | Meudaich tar-chòmhdachadh a' chamara-lìn |

Tha trì meudan ann — beag, meadhanach agus mòr — agus gluaisidh na h-iuchraichean-grada eatarra. Is e meadhanach a' bhun-roghainn. Tha iad co-rèireach ris a' chlàradh, mar sin gabhaidh an camara an aon chuibhreann dhen fhrèam co-dhiù a tha thu a' clàradh monatair 1080p no fear 6K. Agus ma chlàraich thu raon seach uidheam-taisbeanaidh slàn, thèid an tar-chòmhdachadh a cheangal ri oisean an raoin sin seach ri oisean a' mhonatair, ach am fuirich e am broinn a' ghlacaidh.

'S urrainn dhut a ghairm gu dìreach cuideachd le `omarchy-capture-webcam-resize small`, no `reset` gus tilleadh gu meadhanach.

## Teacsa, còdan QR agus dathan

Taghaidh `Super + Ctrl + Print Screen` raon agus nì e OCR air dhan stòr-bhòrd. Tha sin air a mhìneachadh gu ceart ann an [Às-tarraing teacsa & deachdadh](11-text-extraction-dictation.md).

Nì _Cuir gu dol > Glac > Còd QR_ an aon chleas le còdan QR. Tagh an raon sa bheil an còd, agus thèid an luach dì-chòdaichte dhan stòr-bhòrd. Cha choimhead e ach airson còdan QR — air neo bidh susbaint dhùmhail na sgrìn buailteach a bhith air a meas gu mearachdach mar chòd-bàr. Fiach fios a bhith agad: thèid an luach dì-chòdaichte dhan stòr-bhòrd agus a-mhàin ann. Cha tèid a chlò-bhualadh, chan eil e sa bhrath, agus tha e comharraichte mar rud mothachail ach nach fan e ann an [eachdraidh an stòr-bhùird](08-unified-clipboard-history.md). Bidh rùintean an lùib chòdan QR gu tric — an URI `otpauth://` air cùlaibh còd suidheachaidh 2FA, mar eisimpleir — agus chan eil thu ag iarraidh sin ann an loga. Obraichidh a chur ann gu math fhathast.

Tionndaidhidh `Super + Print Screen` (no _Cuir gu dol > Glac > Dath_) an cùrsair gu sùghadair-dhathan. Briog air rud sam bith air an sgrìn agus thèid an dath air an stòr-bhòrd. Brùth an iuchair-ghrad a-rithist gus tarraing às gun dad a thaghadh.

## Tar-chòdachadh mus co-roinn thu

Bidh clàradh sgrìn 4K no HEIC amh on fhòn agad ro mhòr gu tric airson a chur dìreach. Càraidh `Super + Ctrl + .` (no _Cuir gu dol > Tar-chòdaich_) sin. Bheir e dhut roghnaichear fhaidhlichean doilleir thar `~/Pictures` agus `~/Videos`, agus an uairsin faighnichidh e airson fòrmat is meud.

Thèid dealbhan gu jpg no png aig àrd, meadhanach no ìosal, a chuireas crìoch air an leud aig 3160, 2160 agus 1080 piogsail. Thèid videothan gu mp4 no gif beòthaichte aig 4k, 1080p no 720p. Thèid am faidhle iompaichte a sgrìobhadh ri taobh an fhaidhle thùsail leis an dùmhlachd-bhreacaidh san ainm — `demo-1080p.mp4` — agus thèid lethbhreac dhen t-slighe a chur air an stòr-bhòrd mar URI faidhle, ach an urrainn dhut a chur ann dìreach ann an aplacaid a ghabhas ri faidhlichean air an leigeil às.

Obraichidh e on tèirmineal cuideachd, ma tha fios agad mu thràth dè tha thu ag iarraidh: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Tha `omarchy transcode ascii` ann cuideachd, a thionndaidheas dealbh gu ealain ASCII — tha am fear sin sa mhòr-chuid airson [branndadh](41-branding.md).

## Ga chur gu àiteigin

Nuair a bhios am faidhle agad, fosglaidh `Super + Ctrl + S` an clàr-taice Co-roinn agus cuiridh e gu uidheam eile air an lìonra agad e le LocalSend. Faic [GUIs](22-guis.md) airson sin.
