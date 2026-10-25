# Gabhálacha Scáileáin & Taifeadadh

Baineann gach rud is féidir leat a ghabháil den scáileán leis an eochair Print Screen. Tógann eochair ina haonar pictiúr, agus tógann na modhnóirí taifeadadh, dath, nó an téacs taobh istigh de réigiún. Mura bhfuil eochair Print Screen ar chor ar bith ag do mhéarchlár, tógann `Super + Ctrl + Alt + C` an gabháil scáileáin chéanna, agus osclaíonn `Super + Ctrl + C` an tsraith iomlán mar roghchlár.

| Eochair Ghairid | Feidhm |
| ------ | -------- |
| `Print Screen` | Gabháil scáileáin |
| `Super + Ctrl + Alt + C` | Gabháil scáileáin |
| `Alt + Print Screen` | Taifeadadh scáileáin (nó stop an ceann atá ar siúl) |
| `Super + Print Screen` | Roghnóir datha |
| `Super + Ctrl + Print Screen` | Bain téacs as réigiún |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Super + Ctrl + .` | Tras-chódaigh pictiúr nó físeán |

## Gabhálacha Scáileáin

Brúigh `Print Screen` (nó `Super + Ctrl + Alt + C`) agus gabhann Omasnap an monatóir faoi fhócas sula dtagann a fhorleagan i láthair, ionas nach mbogann aon rud fút agus tú ag díriú. Tarraing réigiún saorfhoirme, cliceáil fuinneog chun í a ghabháil, nó cliceáil spás oscailte chun an monatóir iomlán a ghabháil. Brúigh `S` sula dtarraingíonn tú chun réigiún scrollaithe a ghabháil. Ar athraigh tú d'intinn? Brúigh an eochair chéanna arís chun Omasnap a dhíbhe.

Tar éis duit limistéar a roghnú, sábhálann Omasnap an ghabháil, cóipeálann sé chuig an ngearrthaisce í, agus taispeánann sé réamhamharc ar feadh 10 soicind. Úsáid cnaipe bioráin an réamhamhairc nó `Ctrl + P` chun í a choinneáil ar an scáileán, nó roghnaigh Edit chun nótaí a chur uirthi.

Is féidir leis an eagarthóir nótaí saigheada, línte, cruthanna, aibhsiú, marcóirí uimhrithe, téacs, agus ceilt shlán a tharraingt; cuid den íomhá a bhearradh nó a ghearradh amach; OCR a dhéanamh ar a téacs; agus cúlra a chur leis. San eagarthóir, brúigh `Enter` chun an PNG críochnaithe a chóipeáil agus a shábháil, `Ctrl + C` chun é a chóipeáil gan é a shábháil, nó `Ctrl + S` chun é a shábháil gan é a chóipeáil.

Tagann gabhálacha scáileáin sábháilte i dtír in `~/Pictures/Screenshots` de réir réamhshocraithe, le hainm ar nós `screenshot-2026-08-13_14-22-05-firefox.png`. Socraigh `OMASNAP_SCREENSHOT_DIR` chun eolaire eile a úsáid — féach [an FAQ](46-faq.md) le fáil amach cá gcuirfear athróga timpeallachta seisiúin. Cruthaíonn Omasnap an t-eolaire nuair a shábhálann sé an chéad ghreim. Socraigh `[output] autosave = false` in `~/.config/omasnap/omasnap.conf` chun sábháil uathoibríoch a dhíchumasú.

Ón teirminéal, osclaíonn `omarchy screenshot` an forleagan céanna, agus is féidir leat a mhodh tosaigh a roghnú: `omarchy capture screenshot region`, `windows`, `fullscreen`, nó `scroll`. Seachnaíonn an dara argóint `copy` nó `save` an réamhamharc agus seolann sí an ghreim díreach chuig an gceann scríbe sin. Chun eagarthóireacht a dhéanamh roimh an aschur, úsáid `omarchy screenshot --editor=overlay` le haghaidh eagarthóir lánscáileáin nó `omarchy screenshot --editor=window` le haghaidh fuinneog ar leith.

### An roghnóir a thiomáint ón méarchlár

Fad atá an roghnú suas, ní gá duit an luch a úsáid ar chor ar bith:

| Eochair | Feidhm |
| --- | -------- |
| `S` | Athraigh mód an réigiúin scrollaithe |
| `Super + Arrow keys` | Bog idir fuinneoga i mód Window |
| `Return` | Gabh an fhuinneog aibhsithe |
| `Ctrl + A` | Gabh an monatóir iomlán faoi fhócas |
| `R` | Athchóirigh an réigiún deireanach a tarraingíodh sa seisiún seo |
| `Esc` | Díbhe Omasnap |

Níl na ceangail seo ann ach fad atá Omasnap oscailte, mar sin ní féidir leo teacht salach ar aon rud i do chumraíocht féin.

## Taifeadadh scáileáin

Osclaíonn `Alt + Print Screen` _Trigger > Capture > Screenrecord_, a fhiafraíonn cad ba mhaith leat ar an bhfuaimrian: gan fuaim, fuaim deisce, deasc móide micreafón, nó deasc móide micreafón móide ceamara gréasáin. Ní thaispeántar an ceann deireanach sin ach amháin má tá ceamara plugáilte isteach agat i ndáiríre. Roghnaigh ceann agus ligeann roghnóir taifeadta Omarchy duit réigiún a tharraingt nó fuinneog nó monatóir a chliceáil.

Ritheann an taifeadadh ar gpu-screen-recorder, a ionchódaíonn ar an GPU ag 60fps agus a thiteann ar ais chuig an CPU más gá dó. Is MP4 in `~/Videos` an toradh, darb ainm `screenrecording-2026-08-13_14-22-05.mp4`. Socraigh `OMARCHY_SCREENRECORD_DIR` chun é sin a athrú — ach tabhair faoi deara, murab ionann agus eolaire na ngabhálacha scáileáin, go gcaithfidh an ceann seo a bheith ann cheana féin, nó diúltaíonn an taifeadadh tosú.

Fad atá tú ag taifeadadh, tagann táscaire beag i láthair sa bharra. Cliceáil é chun stopadh. Is féidir leat stopadh freisin le `Alt + Print Screen` arís, nó leis an iontráil _Stop Screenrecording_ faoi _Trigger > Capture > Screenrecord_, nach dtagann i láthair ach fad atá rud éigin ag taifeadadh i ndáiríre.

Déanann stopadh beagán slachtmhara sula dtugann sé an comhad duit: bearrtar an chéad fhráma, agus má tá fuaim ann déantar í a normalú go -14 LUFS agus balbhaítear an pop ghabhála PipeWire ag an tús ar fad. Ansin tagann fógra i láthair le mionsamhail ón taifeadadh. Cliceáil é chun an comhad a sheinm in mpv.

### Forleagan an cheamara gréasáin

Nuair a thaifeadann tú le ceamara gréasáin, tagann an ceamara i láthair mar fhuinneog phortráide bioráilte, bearrtha sa chúinne íochtair ar dheis de cibé rud atá á thaifeadadh agat. Má tá sé ina shuí ar bharr rud éigin a theastaíonn uait, athraigh a mhéid ar an toirt:

| Eochair Ghairid | Feidhm |
| ------ | -------- |
| `Super + Alt + [` | Déan forleagan an cheamara gréasáin níos lú |
| `Super + Alt + ]` | Déan forleagan an cheamara gréasáin níos mó |

Tá trí mhéid ann — beag, meánach, agus mór — agus céimníonn na heochracha gairide eatarthu. Is é an meánach an réamhshocrú. Tá siad comhréireach leis an taifeadadh, mar sin tógann an ceamara an sciar céanna den fhráma cibé an bhfuil tú ag taifeadadh monatóir 1080p nó monatóir 6K. Agus má thaifead tú réigiún seachas taispeáint iomlán, ancaireann an forleagan le cúinne an réigiúin sin seachas le cúinne an mhonatóra, mar sin fanann sé taobh istigh den ghreim.

Is féidir leat é a ghlaoch go díreach freisin le `omarchy-capture-webcam-resize small`, nó `reset` chun dul ar ais go dtí an meánach.

## Téacs, cóid QR, agus dathanna

Roghnaíonn `Super + Ctrl + Print Screen` réigiún agus déanann sé OCR air chuig an ngearrthaisce. Clúdaítear é sin i gceart in [Eastóscadh Téacs & Deachtú](11-text-extraction-dictation.md).

Déanann _Trigger > Capture > QR Code_ an cleas céanna le haghaidh cóid QR. Roghnaigh an réigiún ina bhfuil an cód, agus téann an luach díchódaithe chuig an ngearrthaisce. Ní lorgaíonn sé ach cóid QR — bíonn sé de nós ag ábhar dlúth scáileáin dearfach bréagach a thabhairt mar bharrachód murach sin. Is fiú a fhios: téann an luach díchódaithe chuig an ngearrthaisce agus chuig áit ar bith eile. Ní phriontáiltear é, níl sé san fhógra, agus marcáiltear íogair é ionas nach bhfanann sé thart in [stair na gearrthaisce](08-unified-clipboard-history.md). Iompraíonn cóid QR rúin go rialta — an URI `otpauth://` taobh thiar de chód socraithe 2FA, mar shampla — agus níor mhaith leat é sin i loga. Oibríonn greamú go breá fós.

Casann `Super + Print Screen` (nó _Trigger > Capture > Color_) an cúrsóir ina bhrathadóir súile. Cliceáil aon rud ar an scáileán agus tagann an dath i dtír ar an ngearrthaisce. Brúigh an eochair ghairid arís chun cúlú gan roghnú.

## Tras-chódú sula roinneann tú

Is minic a bhíonn taifeadadh scáileáin 4K nó HEIC amh ó do ghuthán rómhór le seoladh díreach. Deisíonn `Super + Ctrl + .` (nó _Trigger > Transcode_) é sin. Cuireann sé roghnóir comhad doiléir ar fáil duit thar `~/Pictures` agus `~/Videos`, ansin iarrann sé formáid agus méid.

Téann pictiúir go jpg nó png ag ard, meánach, nó íseal, a chuireann uasteorainn 3160, 2160, agus 1080 picteilín ar an leithead. Téann físeáin go mp4 nó gif beoite ag 4k, 1080p, nó 720p. Scríobhtar an comhad tiontaithe in aice leis an mbunchomhad agus an taifeach san ainm — `demo-1080p.mp4` — agus cóipeáiltear an chonair chuig an ngearrthaisce mar URI comhaid, ionas gur féidir leat é a ghreamú go díreach isteach in aip a ghlacann le comhaid a thiteann isteach.

Oibríonn sé ón teirminéal freisin, má tá a fhios agat cheana féin cad atá uait: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Tá `omarchy transcode ascii` ann freisin, a chasann íomhá ina healaín ASCII — is le haghaidh [brandála](41-branding.md) is mó atá an ceann sin.

## É a sheoladh áit éigin

Nuair atá an comhad agat, osclaíonn `Super + Ctrl + S` an roghchlár Share agus seolann sé chuig gléas eile ar do líonra é via LocalSend. Féach [GUIanna](22-guis.md) chuige sin.
