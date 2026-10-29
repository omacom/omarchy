# Monatóirí

Glacann Omarchy leis go bhfuil tú ag rith ar thaispeáint de rang retina atá in ann 2x a láimhseáil de réir réamhshocraithe. Seo a theastaíonn uait chun na clónna ríomhchláraitheora deasa, géara sin a fháil. Is é a bhfuil beagnach gach ríomhaire glúine préimhe nua le scáileáin ardtaifigh optamaithe dó. Is é a theastódh uait a rith ar 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) nó 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ach mura bhfuil taispeáint agat le PPI de 218 nó os a chionn, beidh fonn ort socruithe an mhonatóra a athrú. Mar shampla, má tá 4K 27" nó 32" agat, is féidir leat scálú codánach a úsáid trí `~/.config/hypr/monitors.lua` a oscailt (trí _Socruithe > Monatóirí_ sa roghchlár Omarchy) agus athrú go dtí an moladh don teaglaim sin:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Má tá taispeáint 1080p nó 1440p in úsáid agat, is dócha nach mbeidh uait ach scálú 1x, mar sin is féidir leat é seo a úsáid:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Baineann athruithe ar `GDK_SCALE` le feidhmchláir a thosaítear tar éis an athraithe (agus ní ghlacann GTK ach le slánuimhreacha, mar sin coinnigh ag an tslánuimhir is gaire do scála do mhonatóra é). Mar sin déan cinnte go bhfágann tú na fuinneoga atá agat atá rómhór tar éis an athraithe (nó dún gach fuinneog le `Ctrl + Alt + Del`!).

Is féidir leat céimniú go tapa freisin trí na príomhchóimheasa scálaithe monatóra (1x, 1.25x, 1.6x, 2x, 3x, 4x) le `Super + /` chun dul níos airde agus `Super + Alt + /` chun dul níos ísle, nó ceann a roghnú ón bpainéal monatóra sa bharra ag an mbarr. Ní athraíonn siad seo ach an monatóir a bhfuil fócas air agat, mar sin is féidir a scála féin a bheith ag scáileán ríomhaire glúine agus ag taispeáint sheachtrach araon. Sábháiltear an rogha chuig `~/.config/hypr/monitors.lua` mar riail `hl.monitor` don mhonatóir sin, mar sin fanann sé tar éis aththosaithe agus bíonn tosaíocht aige ar `omarchy_monitor_scale`, a fhanann mar an scála do gach monatóir gan riail dá chuid féin. Ós rud é gur luach amháin é `GDK_SCALE` do gach scáileán, socraíonn na hathruithe seo é ón monatóir leis an scála is ísle, mar sin tagann feidhmchláir X11 amach beagáinín beag ar an scáileán níos dlúithe seachas rómhór ar an gceann eile.

### Téacs a dhéanamh níos mó nó níos lú

Athraíonn scálú monatóra méid gach rud. Mura bhfuil uait ach _téacs_ níos mó nó níos lú, tá cnaipe amháin chuige sin:

```
omarchy display text size 14
```

Glacann sé sin le méid picteilíní idir 9 agus 20, agus bogann sé blaosc Omarchy, feidhmchláir GTK, agus do theirminéal le chéile, mar sin fanann an deasc ar fad i gcomhréir. Rith gan argóint é chun a fheiceáil cá bhfuil tú, agus `omarchy display text size reset` chun dul ar ais chuig an réamhshocrú. Is é Foot an t-aon mhoilleadóir amháin: níl aon bhealach aige a chumraíocht a athlódáil, mar sin coinníonn teirminéil atá ag rith a seasmhéid go dtí go n-osclaíonn tú ceann nua.

### Taispeántais ríomhaire glúine a leathnú agus a scáthánú

Nuair a nascann tú scáileán seachtrach le do ríomhaire glúine, leathnaítear an taispeáint go huathoibríoch. Ach is féidir leat é sin a athrú go scáthánú ina ionad sin trí _Truicear > Crua-earraí_ a úsáid sa roghchlár Omarchy nó `Super + Ctrl + Alt + Delete`. Tá sé seo an-chabhrach go háirithe más teilgeoir é an scáileán seachtrach sin, agus más mian leat rud éigin a thaispeáint agus tú ag obair.

Nuair atá tú ag leathnú, má dhúnann tú clúdach an ríomhaire glúine, múchfar an scáileán inmheánach go huathoibríoch. Má osclaíonn tú an clúdach, casfar air arís é. Is féidir leat é seo a rialú de láimh freisin trí _Truicear > Crua-earraí_ a úsáid sa roghchlár Omarchy nó `Super + Ctrl + Delete`.

### Ilscáileáin a shocrú

Oibríonn Hyprland go hiontach le hilscáileáin. Léigh tuilleadh faoi conas iad a leagan amach i [ndoiciméadacht monatóra Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy, téann siad seo i `~/.config/hypr/monitors.lua` mar iontrálacha `hl.monitor` — tagann samplaí le tráchtaireacht leis an gcomhad chun monatóir ar leith a phionnáil chuig taifeach, suíomh, agus rothlú.

Tá spásanna oibre 1 go 10 dá chuid féin ag gach monatóir, mar sin ciallaíonn `Super + 1` i gcónaí an chéad spás oibre den mhonatóir a bhfuil tú air. Taobh thiar de na cúlraí, uimhríonn Hyprland spásanna oibre fós trasna na monatóirí ar fad: faigheann scáileán do ríomhaire glúine (nó an chéad mhonatóir) 1–10, an chéad mhonatóir eile 11–20, agus mar sin de, agus coinníonn gach monatóir a bhloc gach uair a phlugálann tú isteach é. Úsáid na huimhreacha sin má scríobhann tú [rialacha spáis oibre](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) nó rialacha fuinneoge do mhonatóir ar leith, mar sin is é spás oibre 12 an dara spás oibre de do dhara monatóir. Liostaíonn `~/.local/state/omarchy/monitor-workspaces` cén bloc atá ag gach monatóir.

Oibríonn na heochracha saighde trasna monatóirí a roinneann imeall i do leagan amach. Ní comharsana iad scáileáin nach dteagmhaíonn ach ag cúinne, nó a bhfuil bearna eatarthu, mar sin úsáid `Ctrl + Alt + Tab` chun dul eatarthu.

| Eochair te | Trasna monatóirí |
| --- | --- |
| `Super + Arrow` | Bogann sé fócas chuig an monatóir ar an taobh sin a luaithe is nach bhfuil aon fhuinneog fágtha sa treo sin |
| `Super + Shift + Arrow` | Malartaíonn sé le fuinneog ar an monatóir ar an taobh sin |
| `Super + Alt + Arrow` | Bogann sé an fhuinneog isteach i ngrúpa ar an monatóir ar an taobh sin |
| `Super + Shift + Ctrl + Arrow` | Bogann sé an fhuinneog chuig an monatóir ar an taobh sin, ar an spás oibre atá á thaispeáint aige |
| `Super + Shift + Alt + Arrow` | Bogann sé an spás oibre chuig an monatóir ar an taobh sin, ag coinneáil a uimhreach má tá sí saor |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Bogann sé fócas chuig an gcéad mhonatóir eile nó an monatóir roimhe, is cuma cén leagan amach atá ann |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Fanann siad ar an monatóir a bhfuil tú air |

Is féidir leat [Hyprmon](https://github.com/erans/hyprmon/) a sheiceáil amach freisin, más mian leat TUI chun cabhrú leat ilscáileáin a shuíomh.

### Gile a rialú

Rialaítear gile an mhonatóra leis na heochracha feidhme tiomnaithe do ghile suas/anuas. Má choinníonn tú shift síos agus tú á mbrú seo, rachaidh tú chuig an ngile uasta nó íosta. Rialáíonn na heochracha an taispeáint a bhfuil fócas air agat, mar sin coigeartaítear monatóirí seachtracha a labhraíonn DDC/CI ar an mbealach céanna le scáileán an ríomhaire glúine.

### Taispeántais Apple

Má tá taispeáint Apple in úsáid agat, oibreoidh na heochracha rialta gile méarchláir go huathoibríoch freisin, má tá fócas agat ar thaispeáint Apple. Déantar é seo tríd an ordú `asdcontrol`.

Tabhair faoi deara, má tá taispeáint Apple 6K XDR in úsáid agat, go bhféadfá scáileán bréige a fheiceáil i do liostú `hyprctl monitors`. Is féidir leat é seo a mhúchadh le rud éigin cosúil le `hl.monitor({ output = "DP-2", disabled = true })` trí _Socruithe > Monatóirí_.

Ar mheaisíní Intel, ba cheart duit a bheith ag nascadh le taispeántais Apple le cábla rialta Thunderbolt. Ar mheaisíní eile gan Thunderbolt, de ghnáth beidh ort [cábla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) a úsáid chun go n-oibreoidh sé.
