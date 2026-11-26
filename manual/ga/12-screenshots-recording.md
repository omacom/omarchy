# Gabhálacha Scáileáin & Taifeadadh

Braitheann gach rud is féidir leat a ghabháil den scáileán ar an eochair Print Screen. Tógann eochair amháin aici féin pictiúr, agus tógann na modhnóirí taifeadadh, dath, nó an téacs taobh istigh de réigiún. Mura bhfuil eochair Print Screen ar do mhéarchlár ar chor ar bith, tógann `Super + Ctrl + Alt + C` an gabháil scáileáin chéanna, agus osclaíonn `Super + Ctrl + C` an tacar iomlán mar roghchlár.

| Aicearra | Feidhm |
| ------ | -------- |
| `Print Screen` | Gabháil scáileáin |
| `Super + Ctrl + Alt + C` | Gabháil scáileáin |
| `Alt + Print Screen` | Taifeadadh scáileáin (nó cuir stop leis an gceann atá ar siúl) |
| `Super + Print Screen` | Roghnóir dathanna |
| `Super + Ctrl + Print Screen` | Bain téacs as réigiún |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Super + Ctrl + .` | Traschódaigh pictiúr nó físeán |

## Gabhálacha Scáileáin

Buail `Print Screen` (nó `Super + Ctrl + Alt + C`) agus gabhann Omasnap an monatóir atá i bhfócas sula dtagann a fhorleagan i láthair, mar sin ní aistríonn aon rud fút agus tú ag díriú. Tarraing réigiún saorfhoirme, cliceáil fuinneog chun í a ghabháil, nó cliceáil spás oscailte chun an monatóir iomlán a ghabháil. Brúigh `S` sula dtarraingíonn tú chun réigiún scrollaithe a ghabháil. D'athraigh tú d'intinn? Buail an eochair chéanna arís chun Omasnap a dhíbhe.

Tar éis duit réigiún a roghnú, sábhálann Omasnap an ghabháil, cóipeálann sé chuig an ngearrthaisce í, agus taispeánann sé fógra lena mionsamhail, mar a dhéanann taifeadadh scáileáin sábháilte. Roghnaigh Open chun an seat sábháilte a fheiceáil i do bhreathnóir íomhánna, nó Edit chun nótaí a chur leis.

Is féidir leis an eagarthóir nótaí saigheada, línte, cruthanna, aibhsiú, marcóirí uimhrithe, téacs, agus ceilt shlán a tharraingt; cuid den íomhá a bhearradh nó a ghearradh amach; a téacs a OCR; agus cúlra a chur leis. San eagarthóir, brúigh `Enter` chun an PNG críochnaithe a chóipeáil agus a shábháil, `Ctrl + C` chun é a chóipeáil gan sábháil, nó `Ctrl + S` chun é a shábháil gan cóipeáil.

Téann gabhálacha scáileáin sábháilte go `~/Pictures/Screenshots` de réir réamhshocraithe, le hainm amhail `screenshot-2026-08-13_14-22-05-firefox.png`. Socraigh `OMASNAP_SCREENSHOT_DIR` chun eolaire eile a úsáid — féach [na Ceisteanna Coitianta](46-faq.md) chun a fháil amach cá gcuirtear athróga timpeallachta seisiúin. Cruthaíonn Omasnap an t-eolaire nuair a shábhálann sé an chéad seat. Socraigh `[output] autosave = false` in `~/.config/omasnap/omasnap.conf` chun sábháil uathoibríoch a dhíchumasú; ní dhéantar ach cóipeáil ar ghabhálacha ansin, agus taispeántar i réamhamharc ar feadh 7 soicind iad is féidir leat a choinneáil ar an scáileán lena chnaipe pionnála nó le `Ctrl + P`.

Ón teirminéal, osclaíonn `omarchy screenshot` an forleagan céanna, agus is féidir leat a mhodh tosaithe a roghnú: `omarchy capture screenshot region`, `windows`, `fullscreen`, nó `scroll`. Seolann an dara argóint `copy` nó `save` an seat díreach chuig an gceann scríbe sin. Chun é a chur in eagar roimh an aschur, úsáid `omarchy screenshot --editor=overlay` le haghaidh eagarthóir lánscáileáin nó `omarchy screenshot --editor=window` le haghaidh fuinneog ar leith.

### An roghnóir a thiomáint ón méarchlár

Fad atá an roghnú ar bun, ní gá duit an luch a úsáid ar chor ar bith:

| Eochair | Feidhm |
| --- | -------- |
| `S` | Athraigh mód an réigiúin scrollaithe |
| `Super + Arrow keys` | Bog idir fuinneoga i mód Window |
| `Return` | Gabh an fhuinneog aibhsithe |
| `Ctrl + A` | Gabh an monatóir iomlán atá i bhfócas |
| `R` | Athchuir an réigiún deireanach a tarraingíodh sa seisiún seo |
| `Esc` | Díbhe Omasnap |

Níl na ceangaltáin seo ann ach fad atá Omasnap oscailte, mar sin ní féidir leo teacht salach ar aon rud i do chumraíocht féin.

## Taifeadadh scáileáin

Osclaíonn `Alt + Print Screen` _Trigger > Capture > Screenrecord_, a fhiafraíonn cad ba mhaith leat ar an bhfuaimrian: gan fuaim, fuaim deisce, deasc móide micreafón, nó deasc móide micreafón móide ceamara gréasáin. Ní thaispeántar an ceann deireanach sin ach amháin má tá ceamara plugáilte isteach agat i ndáiríre. Roghnaigh ceann agus ligeann roghnóir taifeadta Omarchy duit réigiún a tharraingt nó fuinneog nó monatóir a chliceáil.

Ritheann an taifeadadh ar gpu-screen-recorder, a ionchódaíonn ar an GPU ag 60fps agus a thiteann ar ais chuig an CPU más gá; ar GPUanna nach dtacaíonn sé leo, amhail ceann Apple Silicon, taifeadann Omarchy le wf-recorder ina ionad. Is MP4 i `~/Videos` an toradh, ar a dtugtar `screenrecording-2026-08-13_14-22-05.mp4`. Socraigh `OMARCHY_SCREENRECORD_DIR` chun é sin a athrú — ach tabhair faoi deara, murab ionann agus eolaire na ngabhálacha scáileáin, go gcaithfidh an ceann seo a bheith ann cheana féin, nó diúltaíonn an taifeadadh tosú.

Fad atá tú ag taifeadadh, tagann táscaire beag i láthair sa bharra. Cliceáil é chun stopadh. Is féidir leat stopadh freisin le `Alt + Print Screen` arís, nó leis an iontráil _Stop Screenrecording_ faoi _Trigger > Capture > Screenrecord_, nach dtaispeántar ach fad atá rud éigin ag taifeadadh i ndáiríre.

Déanann an stopadh beagán glantacháin sula dtugann sé an comhad duit: bearrtar an chéad fhráma, agus má tá fuaim ann déantar í a normalú go -14 LUFS agus an pléasc gabhála PipeWire ag an tús féin á balbhú. Ansin tagann fógra i láthair le mionsamhail ón taifeadadh. Roghnaigh _Open_ chun an comhad a sheinm in Omaview, nó _Cut_ chun é a bhearradh in Omacut.

### Forleagan an cheamara gréasáin

Nuair a thaifeadann tú le ceamara gréasáin, tagann an ceamara i láthair mar fhuinneog phortráide phionnáilte, bhearrtha sa chúinne íochtair ar dheis de cibé rud atá á thaifeadadh agat. Má tá sé ina shuí ar bharr rud éigin a theastaíonn uait, athraigh a mhéid ar an toirt:

| Aicearra | Feidhm |
| ------ | -------- |
| `Super + Alt + [` | Déan forleagan an cheamara gréasáin níos lú |
| `Super + Alt + ]` | Déan forleagan an cheamara gréasáin níos mó |

Tá trí mhéid ann — beag, meánach, agus mór — agus céimníonn na haicearraí eatarthu. Is é an meánach an réamhshocrú. Tá siad i gcomhréir leis an taifeadadh, mar sin glacann an ceamara an sciar céanna den fhráma cibé an bhfuil monatóir 1080p nó monatóir 6K á thaifeadadh agat. Agus má thaifead tú réigiún seachas taispeáint iomlán, ancaireann an forleagan go cúinne an réigiúin sin seachas cúinne an mhonatóra, mar sin fanann sé taobh istigh den seat.

Is féidir leat glaoch go díreach air freisin le `omarchy-capture-webcam-resize small`, nó le `reset` chun dul ar ais go dtí an meánach.

## Téacs, cóid QR, agus dathanna

Roghnaíonn `Super + Ctrl + Print Screen` réigiún agus OCRann sé chuig an ngearrthaisce é. Clúdaítear é sin i gceart in [Eastóscadh Téacs & Deachtú](11-text-extraction-dictation.md).

Déanann _Trigger > Capture > QR Code_ an cleas céanna le haghaidh cóid QR. Roghnaigh an réigiún ina bhfuil an cód, agus téann an luach díchódaithe chuig an ngearrthaisce. Ní lorgaíonn sé ach cóid QR — tugann ábhar dlúth scáileáin toradh dearfach bréagach mar bharrachód go minic murach sin. Is fiú a fhios: téann an luach díchódaithe chuig an ngearrthaisce agus chuig aon áit eile. Ní phriontáiltear é, níl sé san fhógra, agus marcáiltear íogair é mar sin ní fhanann sé thart in [stair na gearrthaisce](08-unified-clipboard-history.md). Bíonn rúin go rialta i gcóid QR — an URI `otpauth://` taobh thiar de chód socraithe 2FA, mar shampla — agus níor mhaith leat é sin i loga. Oibríonn greamú go breá fós.

Casann `Super + Print Screen` (nó _Trigger > Capture > Color_) an cúrsóir ina bhraonadóir súile. Cliceáil aon rud ar an scáileán agus téann an dath chuig an ngearrthaisce. Brúigh an aicearra arís chun tarraingt siar gan roghnú.

## Traschódáil sula roinneann tú

Is minic a bhíonn taifeadadh scáileáin 4K nó HEIC amh ó do ghuthán rómhór le seoladh díreach. Réitíonn `Super + Ctrl + .` (nó _Trigger > Transcode_) é sin. Cuireann sé roghnóir comhad doiléir ar fáil duit thar `~/Pictures` agus `~/Videos`, ansin iarrann sé formáid agus méid.

Téann pictiúir go jpg nó png ag ard, meánach, nó íseal, a chuireann uasteorainn 3160, 2160, agus 1080 picteilín ar an leithead. Téann físeáin go mp4 nó gif beoite ag 4k, 1080p, nó 720p. Scríobhtar an comhad tiontaithe in aice leis an mbunchomhad agus an taifeach san ainm — `demo-1080p.mp4` — agus cóipeáiltear an chonair chuig an ngearrthaisce mar URI comhaid, mar sin is féidir leat é a ghreamú go díreach isteach in aip a ghlacann le comhaid a leagtar isteach.

Oibríonn sé ón teirminéal freisin, má tá a fhios agat cheana féin cad atá uait: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Tá `omarchy transcode ascii` ann freisin, a chasann íomhá ina healaín ASCII — is le haghaidh [brandála](41-branding.md) an ceann sin den chuid is mó.

## É a sheoladh áit éigin

Nuair atá an comhad agat, osclaíonn `Super + Ctrl + S` an roghchlár Share agus seolann sé chuig gléas eile ar do líonra é trí LocalSend. Féach [GUIs](22-guis.md) chuige sin.
