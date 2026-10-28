# Monatóirí

Glacann Omarchy leis de réir réamhshocraithe go bhfuil tú ag rith ar thaispeántas de ghrád retina atá in ann 2x a dhéanamh. Seo a theastaíonn uait chun na clónna ríomhchláraitheora deasa géara sin a fháil. Seo a bhfuil beagnach gach ríomhaire glúine préimhe nua le scáileáin ardtaifigh optamaithe lena aghaidh. Seo a bheadh uait a rith ar [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 27" 5K nó [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 32" 6K.

Ach mura bhfuil tú ag rith taispeántas le PPI de 218 nó os a chionn, beidh fonn ort socruithe an mhonatóra a athrú. Mar shampla, má tá 4K 27" nó 32" agat, is féidir leat scálú codánach a úsáid trí `~/.config/hypr/monitors.lua` a oscailt (trí _Socrú > Monatóirí_ i roghchlár Omarchy) agus athrú go dtí an moladh don teaglaim sin:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Má tá taispeántas 1080p nó 1440p á úsáid agat, is dócha nach mbeidh uait ach scálú 1x a úsáid, mar sin is féidir leat seo a úsáid:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Baineann athruithe ar `GDK_SCALE` le feidhmchláir a thosaítear tar éis an athraithe (agus ní ghlacann GTK ach le slánuimhreacha, mar sin coinnigh ag an tslánuimhir is gaire do scála do mhonatóra é). Mar sin déan cinnte go scoireann tú de na fuinneoga atá agat atá rómhór tar éis an athraithe (nó dún gach fuinneog le `Ctrl + Alt + Del`!).

Is féidir leat céimniú go tapa freisin trí na príomhchóimheasa scálaithe monatóra (1x, 1.25x, 1.6x, 2x, 3x, 4x) le `Super + /` chun dul níos airde agus `Super + Alt + /` chun dul níos ísle, nó ceann a roghnú ón bpainéal monatóra sa bharra ag an mbarr. Ní athraíonn siad seo ach an monatóir a bhfuil fócas agat air, mar sin is féidir a scála féin a bheith ag scáileán ríomhaire glúine agus ag taispeántas seachtrach. Sábháiltear an rogha go `~/.config/hypr/monitors.lua` mar riail `hl.monitor` don mhonatóir sin, mar sin fanann sé i bhfeidhm tar éis atosaigh agus tá tosaíocht aige ar `omarchy_monitor_scale`, a fhanann mar an scála do gach monatóir gan riail dá chuid féin.

### Téacs a dhéanamh níos mó nó níos lú

Athraíonn scálú monatóra méid gach rud. Mura dteastaíonn uait ach _téacs_ níos mó nó níos lú, tá aon chnap amháin chuige sin:

```
omarchy display text size 14
```

Glacann sé sin le méid picteilín idir 9 agus 20, agus bogann sé blaosc Omarchy, feidhmchláir GTK, agus do theirminéal le chéile, mar sin fanann an deasc ar fad i gcomhréir. Rith gan argóint é chun a fháil amach cá bhfuil tú, agus `omarchy display text size reset` chun dul ar ais go dtí an réamhshocrú. Is é Foot an t-aon sraoilleán amháin: níl aon bhealach aige a chumraíocht a athlódáil, mar sin coinníonn teirminéil atá ag rith a seánmhéid go dtí go n-osclaíonn tú ceann nua.

### Taispeántais ríomhaire glúine a shíneadh agus a scáthánú

Nuair a nascann tú scáileán seachtrach le do ríomhaire glúine, síneadh an taispeántas go huathoibríoch. Ach is féidir leat é sin a athrú go scáthánú ina ionad sin trí _Truicear > Crua-earraí_ a úsáid i roghchlár Omarchy nó `Super + Ctrl + Alt + Delete`. Tá sé seo an-chabhrach go háirithe más teilgeoir é an scáileán seachtrach sin, agus más mian leat rud éigin a thaispeáint agus tú ag obair.

Nuair atá tú ag síneadh, múchfaidh dúnadh an chlúdaigh ar an ríomhaire glúine an scáileán inmheánach go huathoibríoch. Cuirfidh oscailt an chlúdaigh ar siúl arís é. Is féidir leat é seo a rialú de láimh freisin trí _Truicear > Crua-earraí_ a úsáid i roghchlár Omarchy nó `Super + Ctrl + Delete`.

### Ilscáileáin a shocrú

Oibríonn Hyprland go hiontach le hilscáileáin. Léigh níos mó faoi conas iad a leagan amach i [ndoiciméadúchán monatóirí Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy, téann siad seo isteach i `~/.config/hypr/monitors.lua` mar iontrálacha `hl.monitor` — tagann samplaí tráchtaithe leis an gcomhad chun monatóir sonrach a cheangal le taifeach, suíomh, agus rothlú.

Tá spásanna oibre 1 go 10 dá chuid féin ag gach monatóir, mar sin ciallaíonn `Super + 1` i gcónaí an chéad spás oibre den mhonatóir ar a bhfuil tú. Taobh thiar de na cúlraí, uimhíonn Hyprland spásanna oibre thar gach monatóir fós: faigheann scáileán do ríomhaire glúine (nó an chéad mhonatóir) 1–10, faigheann an chéad mhonatóir eile 11–20, agus mar sin de, agus coinníonn gach monatóir a bhloc gach uair a phlugálann tú isteach é. Úsáid na huimhreacha sin má scríobhann tú [rialacha spáis oibre](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) nó rialacha fuinneoige do mhonatóir sonrach, mar sin is é spás oibre 12 an dara spás oibre de do dhara monatóir. Liostaíonn `~/.local/state/omarchy/monitor-workspaces` cén bloc atá ag gach monatóir.

Oibríonn na heochracha saighde thar mhonatóirí a roinneann ciumhais i do leagan amach. Ní comharsana iad scáileáin nach dteagmhaíonn ach ag cúinne, nó a bhfuil bearna eatarthu, mar sin úsáid `Ctrl + Alt + Tab` chun bogadh eatarthu.

| Eochair aicsin | Thar mhonatóirí |
| --- | --- |
| `Super + Arrow` | Bogann sé fócas go dtí an monatóir ar an taobh sin a luaithe is nach bhfuil fuinneog fágtha sa treo sin |
| `Super + Shift + Arrow` | Malartaíonn sé le fuinneog ar an monatóir ar an taobh sin |
| `Super + Alt + Arrow` | Bogann sé an fhuinneog isteach i ngrúpa ar an monatóir ar an taobh sin |
| `Super + Shift + Ctrl + Arrow` | Bogann sé an fhuinneog go dtí an monatóir ar an taobh sin, ar an spás oibre atá á thaispeáint aige |
| `Super + Shift + Alt + Arrow` | Bogann sé an spás oibre go dtí an monatóir ar an taobh sin, ag coinneáil a uimhreach má tá sé saor |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Bogann sé fócas go dtí an chéad mhonatóir eile nó an monatóir roimhe sin, is cuma cén leagan amach atá ann |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Fanann siad ar an monatóir ar a bhfuil tú |

Is féidir leat breathnú freisin ar [Hyprmon](https://github.com/erans/hyprmon/), más mian leat TUI chun cabhrú leat ilscáileáin a shuíomh.

### Gile a rialú

Rialaítear gile an mhonatóra leis na heochracha feidhme tiomnaithe do ghile suas/síos. Má choinníonn tú shift síos agus na heochracha seo á mbrú agat, rachaidh tú go dtí an ghile uasta nó íosta. Rialaíonn na heochracha an taispeántas a bhfuil fócas agat air, mar sin déantar monatóirí seachtracha a labhraíonn DDC/CI a choigeartú ar an mbealach céanna leis an scáileán ríomhaire glúine.

### Taispeántais Apple

Má tá taispeántas Apple á úsáid agat, oibreoidh na gnátheochracha gile méarchláir go huathoibríoch freisin, má tá fócas agat ar an taispeántas Apple. Déantar é seo tríd an ordú `asdcontrol`.

Tabhair faoi deara, má tá taispeántas Apple 6K XDR á úsáid agat, go bhféadfá scáileán taibhseach a fheiceáil i do liostú `hyprctl monitors`. Is féidir leat é seo a mhúchadh le rud éigin cosúil le `hl.monitor({ output = "DP-2", disabled = true })` trí _Socrú > Monatóirí_.

Ar mheaisíní Intel, ba cheart duit a bheith ag nascadh le taispeántais Apple trí ghnáthchábla Thunderbolt a úsáid. Ar mheaisíní eile gan Thunderbolt, de ghnáth beidh ort [cábla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) a úsáid chun go n-oibreoidh sé.
