# Monatóirí

Glacann Omarchy leis, de réir réamhshocraithe, go bhfuil tú ag rith ar thaispeáint de ghrád retina atá in ann 2x a dhéanamh. Is é sin a theastaíonn uait chun na clónna ríomhchlárúcháin deasa, géara sin a fháil. Is é sin a bhfuil beagnach gach ríomhaire glúine préimhe nua le scáileáin ardtaifigh optamaithe chuige. Is é sin ba mhaith leat a rith ar [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 27" 5K nó [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 32" 6K.

Ach mura bhfuil tú ag rith taispeáint le PPI de 218 nó os a chionn, beidh tú ag iarraidh socruithe an mhonatóra a athrú. Mar shampla, má tá 4K 27" nó 32" agat, is féidir leat scála codánach a roghnú dó ón bpainéal monatóra sa bharra uachtarach, nó an réamhshocrú a shocrú do gach monatóir trí `~/.config/hypr/monitors.lua` a oscailt agus athrú go dtí an moladh don teaglaim sin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Má tá taispeáint 1080p nó 1440p in úsáid agat, is dócha nach mbeidh uait ach scálú 1x a úsáid, agus an rud céanna do fheidhmchláir GTK agus X11, mar sin is féidir leat é seo a úsáid:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Baineann athruithe ar `GDK_SCALE` le feidhmchláir a thosaítear tar éis an athraithe (agus ní aithníonn GTK ach slánuimhreacha, mar sin coinnigh ag an tslánuimhir is gaire do scála do mhonatóra é). Mar sin bí cinnte go scoireann tú de na fuinneoga atá agat atá rómhór tar éis an athraithe (nó dún gach fuinneog le `Ctrl + Alt + Del`!).

Is féidir leat freisin céimniú go tapa trí na príomhchóimheasa scálaithe monatóra (1x, 1.25x, 1.6x, 2x, 3x, 4x) agus `Super + /` á úsáid chun dul níos airde agus `Super + Alt + /` chun dul níos ísle, nó ceann a roghnú ón bpainéal monatóra sa bharra uachtarach. Ní athraíonn siad seo ach an monatóir a bhfuil fócas agat air, mar sin is féidir le scáileán ríomhaire glúine agus taispeáint sheachtrach a scála féin a bheith ag gach ceann acu. Socraíonn an painéal taifeach gach monatóra freisin. Sábháiltear do roghanna don mhonatóir fisiciúil sin in `~/.local/state/omarchy/monitors/settings`, mar sin maireann siad tar éis aththosaithe agus leanann siad an monatóir go dtí cibé port nó dug a plugáiltear isteach ann ina dhiaidh sin é. Tá tosaíocht acu ar aon riail don mhonatóir céanna in `~/.config/hypr/monitors.lua`, nach gcuireann Omarchy in eagar riamh. Más fearr leat do mhonatóirí a shocrú go hiomlán sa chomhad sin, cuir `omarchy_monitor_panel_settings = false` leis, agus ní mhairfidh athruithe an phainéil ach go dtí go n-athlódálfaidh Hyprland. Ós rud é gur luach amháin é `GDK_SCALE` do gach scáileán, socraíonn scála roghnaithe é ón monatóir leis an scála is ísle, mar sin tagann feidhmchláir X11 amach beagán beag ar an scáileán níos dlúithe seachas rómhór ar an gceann eile.

### Téacs a dhéanamh níos mó nó níos lú

Athraíonn scálú monatóra méid gach rud. Más é _téacs_ níos mó nó níos lú amháin atá uait, tá cnapán amháin chuige sin:

```
omarchy display text size 14
```

Glacann sé sin méid picteilín idir 9 agus 20, agus bogann sé blaosc Omarchy, feidhmchláir GTK, agus do theirminéal le chéile, mar sin fanann an deasc ar fad i gcomhréir. Rith gan argóint é chun a fheiceáil cá bhfuil tú, agus `omarchy display text size reset` chun dul ar ais go dtí an réamhshocrú. Is é Foot an t-aon fhánaí amháin: níl bealach ar bith aige a chumraíocht a athlódáil, mar sin coinníonn teirminéil atá ar siúl a seanmhéid go dtí go n-osclaíonn tú ceann nua.

### Scáileáin ríomhaire glúine a shíneadh agus a scáthánú

Nuair a cheanglaíonn tú scáileán seachtrach le do ríomhaire glúine, síntear an taispeáint go huathoibríoch. Ach is féidir leat é sin a athrú go scáthánú ina ionad sin trí _Trigger > Hardware_ a úsáid i roghchlár Omarchy nó `Super + Ctrl + Alt + Delete`. Tá sé seo an-chabhrach go háirithe más teilgeoir é an scáileán seachtrach sin, agus más mian leat rud éigin a thaispeáint agus tú ag obair.

Nuair atá tú ag síneadh, múchfaidh dúnadh an chlúdaigh ar an ríomhaire glúine an scáileán inmheánach go huathoibríoch. Casfaidh oscailt an chlúdaigh ar ais air é. Is féidir leat é seo a rialú de láimh freisin trí _Trigger > Hardware_ a úsáid i roghchlár Omarchy nó `Super + Ctrl + Delete`.

### Scáileáin iolracha a shocrú

Oibríonn Hyprland go hiontach le scáileáin iolracha. Tarraingíonn an painéal monatóra sa bharra uachtarach iad san áit a suíonn siad: tarraing ceann in aghaidh taoibh ceann eile chun é a bhogadh ann, agus sábháiltear an socrú le socruithe eile gach monatóra. Maidir le haon rud nach gclúdaíonn an painéal, léigh tuilleadh faoi conas iad a leagan amach in [doiciméadúchán monatóirí Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy, téann siad seo in `~/.config/hypr/monitors.lua` mar iontrálacha `hl.monitor` — tagann samplaí tráchtaithe leis an gcomhad chun monatóir ar leith a phionnáil ar thaifeach, ar shuíomh, agus ar rothlú.

Tá a spásanna oibre 1 go 10 féin ag gach monatóir, mar sin ciallaíonn `Super + 1` i gcónaí an chéad spás oibre den mhonatóir a bhfuil tú air. Taobh thiar den radharc, uimhíonn Hyprland spásanna oibre trasna gach monatóra fós: faigheann scáileán do ríomhaire glúine (nó an chéad mhonatóir) 1–10, an chéad mhonatóir eile 11–20, agus mar sin de, agus coinníonn gach monatóir a bhloc gach uair a plugálann tú isteach é. Úsáid na huimhreacha sin má scríobhann tú [rialacha spáis oibre](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) nó rialacha fuinneoige do mhonatóir ar leith, mar sin is é spás oibre 12 an dara spás oibre de do dhara monatóir. Liostaíonn `~/.local/state/omarchy/monitors/workspaces` cén bloc atá ag gach monatóir.

Oibríonn na heochracha saighde trasna monatóirí a roinneann imeall i do leagan amach. Ní comharsana iad scáileáin nach dteagmhaíonn ach ag cúinne, nó a bhfuil bearna eatarthu, mar sin úsáid `Ctrl + Alt + Tab` chun dul eatarthu.

| Eochair aicearra | Trasna monatóirí |
| --- | --- |
| `Super + Arrow` | Bogann sé fócas go dtí an monatóir ar an taobh sin nuair nach bhfuil fuinneog ar bith fágtha sa treo sin |
| `Super + Shift + Arrow` | Malartaíonn sé le fuinneog ar an monatóir ar an taobh sin |
| `Super + Alt + Arrow` | Bogann sé an fhuinneog isteach i ngrúpa ar an monatóir ar an taobh sin |
| `Super + Shift + Ctrl + Arrow` | Bogann sé an fhuinneog go dtí an monatóir ar an taobh sin, ar an spás oibre atá á thaispeáint aige |
| `Super + Shift + Alt + Arrow` | Bogann sé an spás oibre go dtí an monatóir ar an taobh sin, ag coinneáil a uimhreach má tá sí saor |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Bogann sé fócas go dtí an chéad mhonatóir eile nó an monatóir roimhe sin, cibé leagan amach atá ann |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Fanann siad ar an monatóir a bhfuil tú air |

Is féidir leat breathnú ar [Hyprmon](https://github.com/erans/hyprmon/) freisin, más mian leat TUI chun cabhrú leat le suíomh scáileán iolrach.

### Gile a rialú

Rialaítear gile an mhonatóra leis na heochracha feidhme tiomnaithe do ghile suas/síos. Má choinníonn tú shift síos agus na heochracha seo á mbrú agat, rachaidh tú go dtí an ghile uasta nó íosta. Rialaíonn na heochracha an taispeáint a bhfuil fócas agat uirthi, mar sin déantar monatóirí seachtracha a labhraíonn DDC/CI a choigeartú ar an mbealach céanna le scáileán an ríomhaire glúine.

### Taispeáintí Apple

Má tá taispeáint Apple in úsáid agat, oibreoidh na heochracha rialta gile ar an méarchlár go huathoibríoch freisin, má tá fócas agat ar an taispeáint Apple. Déantar é seo tríd an ordú `asdcontrol`.

Tabhair faoi deara, má tá taispeáint Apple 6K XDR in úsáid agat, go bhféadfá scáileán fantaise a fheiceáil i do liostú `hyprctl monitors`. Is féidir leat é seo a mhúchadh le rud éigin cosúil le `hl.monitor({ output = "DP-2", disabled = true })` in `~/.config/hypr/monitors.lua`.

Ar mheaisíní Intel, ba cheart duit a bheith ag ceangal le taispeáintí Apple trí chábla rialta Thunderbolt a úsáid. Ar mheaisíní eile gan Thunderbolt, de ghnáth beidh ort [cábla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) a úsáid chun é a chur ag obair.
