# Seatanna Scáileáin & Taifeadadh

Crochtar gach rud is féidir leat a ghlacadh den scáileán d'eochair Print Screen. Glacann eochair amháin léi féin pictiúr, agus glacann na modhnóirí taifeadadh, dath, nó an téacs taobh istigh de réigiún. Mura bhfuil eochair Print Screen ar bith ag do mhéarchlár, osclaíonn `Super + Ctrl + C` an tacar céanna mar roghchlár.

| Eochair ghasta | Feidhm |
| ------ | -------- |
| `Print Screen` | Seat scáileáin |
| `Alt + Print Screen` | Taifead scáileáin (nó stop an ceann atá ag rith) |
| `Super + Print Screen` | Roghnóir datha |
| `Super + Ctrl + Print Screen` | Asbhain téacs as réigiún |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Super + Ctrl + .` | Traschódáil pictiúr nó físeán |

## Seatanna scáileáin

Buail `Print Screen` agus gabhann Omasnap an monatóir dírithe sula dtaispeántar a fhorleagan, mar sin ní aistríonn rud ar bith fút fad is a dhíríonn tú. Tarraing réigiún saorfhoirme, cliceáil fuinneog chun í a ghabháil, nó cliceáil spás oscailte chun an monatóir ar fad a ghabháil. Brúigh `S` sula dtarraingíonn tú chun réigiún scrollaithe a ghabháil. D'athraigh tú d'intinn? Buail `Print Screen` arís chun Omasnap a dhíbhe.

Tar éis duit limistéar a roghnú, sábhálann Omasnap an ghabháil, cóipeálann sé chuig an ngearrthaisce í, agus taispeánann sé réamhamharc ar feadh 10 soicind. Úsáid cnaipe bioráin an réamhamhairc nó `Ctrl + P` chun í a choinneáil ar an scáileán, nó roghnaigh Edit chun í a anótáil.

Is féidir leis an eagarthóir anótála saigheada, línte, cruthanna, buaicphointí, marcóirí uimhrithe, téacs, agus ceiltí slána a tharraingt; cuid den íomhá a bhearradh nó a ghearradh amach; a téacs a OCRáil; agus cúlra a chur leis. San eagarthóir, brúigh `Enter` chun an PNG críochnaithe a chóipeáil agus a shábháil, `Ctrl + C` chun í a chóipeáil gan sábháil, nó `Ctrl + S` chun í a shábháil gan chóipeáil.

Tuiteann seatanna scáileáin sábháilte i `~/Pictures/Screenshots` de réir réamhshocraithe, le hainm ar nós `screenshot-2026-08-13_14-22-05-firefox.png`. Socraigh `OMASNAP_SCREENSHOT_DIR` chun eolaire eile a úsáid — féach [na Ceisteanna Coitianta](46-faq.md) maidir le cá háit le hathróga timpeallachta seisiúin a chur. Cruthaíonn Omasnap an t-eolaire nuair a shábhálann sé an chéad seat. Socraigh `[output] autosave = false` i `~/.config/omasnap/omasnap.conf` chun sábháil uathoibríoch a dhíchumasú.

Ón teirminéal, osclaíonn `omarchy screenshot` an forleagan céanna, agus is féidir leat a mhodh tosaigh a roghnú: `omarchy capture screenshot region`, `windows`, `fullscreen`, nó `scroll`. Scipeálann an dara argóint `copy` nó `save` an réamhamharc agus seolann sí an seat go díreach chuig an gceann scríbe sin. Chun cur in eagar roimh aschur, úsáid `omarchy screenshot --editor=overlay` d'eagarthóir lánscáileáin nó `omarchy screenshot --editor=window` d'fhuinneog ar leith.

### An roghnóir a thiomáint ón méarchlár

Fad is atá an roghnú suas, ní gá duit an luch a úsáid ar chor ar bith:

| Eochair | Feidhm |
| --- | -------- |
| `S` | Scoránaigh mód réigiúin scrollaithe |
| `Super + Arrow keys` | Bog idir fhuinneoga i Mód Fuinneoige |
| `Return` | Gabh an fhuinneog aibhsithe |
| `Ctrl + A` | Gabh an monatóir dírithe iomlán |
| `R` | Athchóirigh an réigiún deireanach a tarraingíodh sa seisiún seo |
| `Esc` | Díbhe Omasnap |

Ní bhíonn na ceangail seo ann ach fad is atá Omasnap oscailte, mar sin ní féidir leo imbhualadh le rud ar bith i do chumraíocht féin.

## Taifeadadh scáileáin

Osclaíonn `Alt + Print Screen` _Spreag > Gabh > Taifead scáileáin_, a fhiafraíonn cad atá uait ar an bhfuaimrian: gan fuaim, fuaim deisce, deasc móide micreafón, nó deasc móide micreafón móide ceamara gréasáin. Ní thaispeántar an ceann deireanach sin ach má tá ceamara plugáilte isteach agat i ndáiríre. Roghnaigh ceann agus ligeann roghnóir taifeadta Omarchy duit réigiún a tharraingt nó fuinneog nó monatóir a chliceáil.

Ritheann an taifeadadh ar gpu-screen-recorder, a ionchódaíonn ar an GPU ag 60fps agus a thiteann ar ais go dtí an CPU más gá. Is MP4 i `~/Videos` an toradh, darb ainm `screenrecording-2026-08-13_14-22-05.mp4`. Socraigh `OMARCHY_SCREENRECORD_DIR` chun é sin a athrú — ach tabhair faoi deara go bhfuil an ceann seo, murab ionann is eolaire na seatanna scáileáin, riachtanach a bheith ann cheana, nó diúltaíonn an taifeadadh tosú.

Fad is atá tú ag taifeadadh, taispeántar táscaire beag sa bharra. Cliceáil é chun stopadh. Is féidir leat stopadh le `Alt + Print Screen` arís freisin, nó leis an iontráil _Stop taifeadadh scáileáin_ faoi _Spreag > Gabh > Taifead scáileáin_, nach dtaispeántar ach fad is atá rud éigin ag taifeadadh i ndáiríre.

Déanann stopadh beagán glantacháin sula dtugann sé an comhad duit: bearrtar an chéad fhráma, agus má tá fuaim ann normalaítear go -14 LUFS í agus an preab gabhála PipeWire ag an tús maolaithe amach. Ansin taispeántar fógra le mioníomhá ón taifeadadh. Cliceáil é chun an comhad a sheinm i mpv.

### Forleagan an cheamara gréasáin

Nuair a thaifeadann tú le ceamara gréasáin, taispeántar an ceamara mar fhuinneog phortráide ghreamaithe, bhearrtha i gcúinne bun ar dheis cibé rud atá á thaifeadadh agat. Má tá sé ina shuí ar bharr rud éigin atá uait, athraigh a mhéid ar an eitilt:

| Eochair ghasta | Feidhm |
| ------ | -------- |
| `Super + Alt + [` | Déan forleagan an cheamara níos lú |
| `Super + Alt + ]` | Déan forleagan an cheamara níos mó |

Tá trí mhéid ann — beag, meánach, agus mór — agus céimníonn na heochracha gasta eatarthu. Is é meánach an réamhshocrú. Tá siad comhréireach leis an taifeadadh, mar sin tógann an ceamara an sciar céanna den fhráma cibé acu atá tú ag taifeadadh monatóir 1080p nó 6K. Agus má thaifead tú réigiún seachas taispeáint iomlán, ancaireann an forleagan le cúinne an réigiúin sin seachas cúinne an mhonatóra, mar sin fanann sé taobh istigh den seat.

Is féidir leat é a ghlaoch go díreach freisin le `omarchy-capture-webcam-resize small`, nó `reset` chun dul ar ais go meánach.

## Téacs, cóid QR, agus dathanna

Roghnaíonn `Super + Ctrl + Print Screen` réigiún agus OCRálann sé chuig an ngearrthaisce é. Clúdaítear é sin i gceart in [Asbhaint Téacs & Deachtú](11-text-extraction-dictation.md).

Déanann _Spreag > Gabh > Cód QR_ an cleas céanna do chóid QR. Roghnaigh an réigiún ina bhfuil an cód, agus téann an luach díchódaithe chuig an ngearrthaisce. Ní lorgaíonn sé ach cóid QR — tá an nós ag ábhar scáileáin dlúth bréag-dearfach a dhéanamh mar bharrachód murach sin. Is fiú a bheith ar an eolas: téann an luach díchódaithe chuig an ngearrthaisce agus ní chuig áit ar bith eile. Ní phriontáiltear é, níl sé san fhógra, agus tá sé marcáilte íogair mar sin ní fhanann sé timpeall i [stair ghearrthaisce](08-unified-clipboard-history.md). Iompraíonn cóid QR rúin go rialta — an URI `otpauth://` taobh thiar de chód socraithe 2FA, mar shampla — agus níl tú ag iarraidh é sin i loga. Oibríonn greamú go breá fós.

Iompaíonn `Super + Print Screen` (nó _Spreag > Gabh > Dath_) an cúrsóir ina bhraonaire. Cliceáil rud ar bith ar an scáileán agus tuirlingíonn an dath ar an ngearrthaisce. Brúigh an eochair ghasta arís chun tarraingt siar gan roghnú.

## Traschódáil sula roinneann tú

Is minic a bhíonn taifeadadh scáileáin 4K nó HEIC amh de do ghuthán ró-mhór le seoladh go díreach. Socraíonn `Super + Ctrl + .` (nó _Spreag > Traschódáil_) é sin. Tairgeann sé roghnóir comhad doiléir duit thar `~/Pictures` agus `~/Videos`, ansin iarrann sé formáid agus méid.

Téann pictiúir go jpg nó png ag ard, meánach, nó íseal, a chuireann uasteorainn leis an leithead ag 3160, 2160, agus 1080 picteilín. Téann físeáin go mp4 nó gif beochana ag 4k, 1080p, nó 720p. Scríobhtar an comhad tiontaithe in aice leis an mbunaidh leis an taifeach san ainm — `demo-1080p.mp4` — agus cóipeáiltear an chonair chuig an ngearrthaisce mar URI comhaid, mar sin is féidir leat é a ghreamú go díreach isteach in aip a ghlacann le titim comhad.

Oibríonn sé ón teirminéal freisin, má tá a fhios agat cheana cad atá uait: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Tá `omarchy transcode ascii` ann freisin, a iompaíonn íomhá ina healaín ASCII — is do [brandáil](41-branding.md) den chuid is mó atá an ceann sin.

## É a sheoladh áit éigin

Nuair atá an comhad agat, osclaíonn `Super + Ctrl + S` roghchlár Roinn agus seolann sé chuig gléas eile ar do líonra é trí LocalSend. Féach [GUIanna](22-guis.md) faoi sin.
