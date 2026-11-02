# Gabhálacha Scáileáin & Taifeadadh

Gach rud is féidir leat a thógáil den scáileán, tá sé ar fad ag brath ar eochair Print Screen. Tógann eochair amháin léi féin pictiúr, agus tógann na modhnóirí taifeadadh, dath, nó an téacs atá taobh istigh de réigiún. Mura bhfuil eochair Print Screen ar bith ag do mhéarchlár, tógann `Super + Ctrl + Alt + C` an gabháil scáileáin chéanna, agus osclaíonn `Super + Ctrl + C` an tacar iomlán mar roghchlár.

| Eochair aicearra | Feidhm |
| ------ | -------- |
| `Print Screen` | Gabháil scáileáin |
| `Super + Ctrl + Alt + C` | Gabháil scáileáin |
| `Alt + Print Screen` | Taifeadadh scáileáin (nó stop an ceann atá ar siúl) |
| `Super + Print Screen` | Roghnóir datha |
| `Super + Ctrl + Print Screen` | Bain téacs as réigiún |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Super + Ctrl + .` | Traschódaigh pictiúr nó físeán |

## Gabhálacha scáileáin

Buail `Print Screen` (nó `Super + Ctrl + Alt + C`) agus gabhann Omasnap an monatóir atá faoi fhócas sula dtagann a fhorleagan i láthair, mar sin ní bhogann rud ar bith fút agus tú ag díriú. Tarraing réigiún saorfhoirme, cliceáil fuinneog chun í a ghabháil, nó cliceáil spás oscailte chun an monatóir iomlán a ghabháil. Brúigh `S` sula dtarraingíonn tú chun réigiún scrollála a ghabháil. D'athraigh tú d'intinn? Buail an eochair chéanna arís chun Omasnap a dhíbhe.

Tar éis duit limistéar a roghnú, sábhálann Omasnap an gabháil, cóipeálann sé chuig an ngearrthaisce í, agus taispeánann sé fógra lena mionsamhail, mar a dhéanann taifeadadh scáileáin sábháilte. Roghnaigh Open chun an seat sábháilte a fheiceáil i d'amharcóir íomhánna, nó Edit chun nótaí a chur leis.

Is féidir leis an eagarthóir nótaí saigheada, línte, cruthanna, buaicphointí, marcóirí uimhrithe, téacs, agus ceilt shlán a tharraingt; cuid den íomhá a bhearradh nó a ghearradh amach; a téacs a OCR; agus cúlra a chur leis. San eagarthóir, brúigh `Enter` chun an PNG críochnaithe a chóipeáil agus a shábháil, `Ctrl + C` chun é a chóipeáil gan é a shábháil, nó `Ctrl + S` chun é a shábháil gan é a chóipeáil.

Téann gabhálacha scáileáin sábháilte go dtí `~/Pictures/Screenshots` de réir réamhshocraithe, le hainm amhail `screenshot-2026-08-13_14-22-05-firefox.png`. Socraigh `OMASNAP_SCREENSHOT_DIR` chun eolaire eile a úsáid — féach [na Ceisteanna Coitianta](46-faq.md) chun a fháil amach cá gcuirtear athróga timpeallachta seisiúin. Cruthaíonn Omasnap an t-eolaire nuair a shábhálann sé an chéad seat. Socraigh `[output] autosave = false` in `~/.config/omasnap/omasnap.conf` chun sábháil uathoibríoch a dhíchumasú; ní chóipeáiltear na gabhálacha ansin ach amháin, agus taispeántar iad i réamhamharc ar feadh 10 soicind ar féidir leat a choinneáil ar an scáileán lena chnaipe pionnála nó le `Ctrl + P`.

Ón teirminéal, osclaíonn `omarchy screenshot` an forleagan céanna, agus is féidir leat a mhodh tosaigh a roghnú: `omarchy capture screenshot region`, `windows`, `fullscreen`, nó `scroll`. Cuireann an dara hargóint, `copy` nó `save`, an seat díreach chuig an gceann scríbe sin. Chun eagarthóireacht a dhéanamh roimh an aschur, úsáid `omarchy screenshot --editor=overlay` d'eagarthóir lánscáileáin nó `omarchy screenshot --editor=window` d'fhuinneog ar leith.

### An roghnóir a thiomáint ón méarchlár

Cé go bhfuil an roghnú suas, ní gá duit an luch a úsáid in aon chor:

| Eochair | Feidhm |
| --- | -------- |
| `S` | Scoránaigh mód réigiúin scrollála |
| `Super + Arrow keys` | Bog idir fuinneoga i mód Window |
| `Return` | Gabh an fhuinneog aibhsithe |
| `Ctrl + A` | Gabh an monatóir iomlán atá faoi fhócas |
| `R` | Athchuir an réigiún deireanach a tarraingíodh sa seisiún seo |
| `Esc` | Díbhe Omasnap |

Níl na ceangail seo ann ach amháin fad a bhíonn Omasnap ar oscailt, mar sin ní féidir leo teacht salach ar rud ar bith i do chumraíocht féin.

## Taifeadadh scáileáin

Osclaíonn `Alt + Print Screen` _Trigger > Capture > Screenrecord_, a fhiafraíonn cad ba mhaith leat ar an bhfuaimrian: gan fuaim ar bith, fuaim an deisce, deasc móide micreafón, nó deasc móide micreafón móide ceamara gréasáin. Ní thaispeántar an ceann deireanach sin ach amháin má tá ceamara plugáilte isteach agat i ndáiríre. Roghnaigh ceann amháin agus ligeann roghnóir taifeadta Omarchy duit réigiún a tharraingt nó fuinneog nó monatóir a chliceáil.

Ritheann an taifeadadh ar gpu-screen-recorder, a ionchódaíonn ar an GPU ag 60fps agus a thiteann siar ar an CPU más gá dó. Is é an toradh ná MP4 in `~/Videos`, darbh ainm `screenrecording-2026-08-13_14-22-05.mp4`. Socraigh `OMARCHY_SCREENRECORD_DIR` chun é sin a athrú — ach tabhair faoi deara, murab ionann agus eolaire na ngabhálacha scáileáin, go gcaithfidh an ceann seo a bheith ann cheana féin, nó diúltóidh an taifeadadh tosú.

Agus tú ag taifeadadh, tagann táscaire beag i láthair sa bharra. Cliceáil é chun stopadh. Is féidir leat stopadh freisin le `Alt + Print Screen` arís, nó leis an iontráil _Stop Screenrecording_ faoi _Trigger > Capture > Screenrecord_, nach dtagann i láthair ach amháin fad a bhíonn rud éigin á thaifeadadh i ndáiríre.

Déanann an stopadh beagán glanta sula dtugann sé an comhad duit: bearrtar an chéad fhráma, agus má tá fuaim ann déantar í a normalú go -14 LUFS agus an pléasc gabhála PipeWire ag an tús ceart balbhaithe amach. Ansin tagann fógra i láthair le mionsamhail ón taifeadadh. Cliceáil é chun an comhad a sheinm in mpv.

### An forleagan ceamara gréasáin

Nuair a dhéanann tú taifeadadh le ceamara gréasáin, tagann an ceamara i láthair mar fhuinneog phortráide phionnáilte, bhearrtha sa chúinne íochtair ar dheis de cibé rud atá á thaifeadadh agat. Má tá sé ina shuí ar bharr rud éigin a theastaíonn uait, athraigh a mhéid ar an toirt:

| Eochair aicearra | Feidhm |
| ------ | -------- |
| `Super + Alt + [` | Déan forleagan an cheamara gréasáin níos lú |
| `Super + Alt + ]` | Déan forleagan an cheamara gréasáin níos mó |

Tá trí mhéid ann — beag, meánach, agus mór — agus céimníonn na heochracha aicearra eatarthu. Is é an meánach an réamhshocrú. Tá siad comhréireach leis an taifeadadh, mar sin tógann an ceamara an sciar céanna den fhráma cibé an bhfuil tú ag taifeadadh monatóir 1080p nó monatóir 6K. Agus má thaifead tú réigiún seachas taispeáint iomlán, ancaireann an forleagan go cúinne an réigiúin sin seachas cúinne an mhonatóra, mar sin fanann sé taobh istigh den seat.

Is féidir leat é a ghlaoch go díreach freisin le `omarchy-capture-webcam-resize small`, nó `reset` chun dul ar ais go dtí an meánach.

## Téacs, cóid QR, agus dathanna

Roghnaíonn `Super + Ctrl + Print Screen` réigiún agus déanann sé OCR air chuig an ngearrthaisce. Tá sé sin clúdaithe i gceart in [Eastóscadh Téacs & Deachtú](11-text-extraction-dictation.md).

Déanann _Trigger > Capture > QR Code_ an cleas céanna le haghaidh cóid QR. Roghnaigh an réigiún ina bhfuil an cód, agus téann an luach díchódaithe chuig an ngearrthaisce. Ní lorgaíonn sé ach cóid QR — tá sé de nós ag ábhar dlúth scáileáin bréag-dearfach a dhéanamh mar bharrachód murach sin. Is fiú a fhios: téann an luach díchódaithe chuig an ngearrthaisce agus chuig áit ar bith eile. Ní phriontáiltear é, níl sé san fhógra, agus tá sé marcáilte mar rud íogair mar sin ní fhanann sé thart in [stair na gearrthaisce](08-unified-clipboard-history.md). Is gnách le cóid QR rúin a iompar — an URI `otpauth://` taobh thiar de chód socraithe 2FA, mar shampla — agus níor mhaith leat é sin i loga. Oibríonn greamú go breá fós.

Casann `Super + Print Screen` (nó _Trigger > Capture > Color_) an cúrsóir ina shúileog. Cliceáil rud ar bith ar an scáileán agus tiocfaidh an dath ar an ngearrthaisce. Brúigh an eochair aicearra arís chun tarraingt siar gan ceann a phiocadh.

## Traschódú sula roinneann tú

Is minic a bhíonn taifeadadh scáileáin 4K nó HEIC amh ó do ghuthán rómhór le cur díreach. Deisíonn `Super + Ctrl + .` (nó _Trigger > Transcode_) é sin. Cuireann sé roghnóir doiléir comhad ar fáil duit thar `~/Pictures` agus `~/Videos`, agus ansin fiafraíonn sé formáid agus méid díot.

Téann pictiúir go jpg nó png ag ard, meánach, nó íseal, a chuireann uasteorainn 3160, 2160, agus 1080 picteilín ar an leithead. Téann físeáin go mp4 nó gif beoite ag 4k, 1080p, nó 720p. Scríobhtar an comhad tiontaithe in aice leis an mbunchomhad agus an taifeach san ainm — `demo-1080p.mp4` — agus cóipeáiltear an cosán chuig an ngearrthaisce mar URI comhaid, mar sin is féidir leat é a ghreamú go díreach isteach in aip a ghlacann le comhaid a thiteann isteach.

Oibríonn sé ón teirminéal freisin, má tá a fhios agat cheana féin cad ba mhaith leat: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Tá `omarchy transcode ascii` ann freisin, a chasann íomhá ina healaín ASCII — is don [bhrandáil](41-branding.md) is mó a úsáidtear an ceann sin.

## É a chur áit éigin

Nuair a bhíonn an comhad agat, osclaíonn `Super + Ctrl + S` an roghchlár Share agus cuireann sé chuig gléas eile ar do líonra é via LocalSend. Féach [GUIs](22-guis.md) chuige sin.
