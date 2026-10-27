# Monatóirí

Glacann Omarchy leis go bhfuil tú ag rith ar thaispeántas de chineál retina le cumas 2x de réir réamhshocraithe. Sin a theastaíonn uait chun na clónna ríomhchláraitheora deasa, géara sin a fháil. Sin an rud a bhfuil beagnach gach ríomhaire glúine préimhe nua le scáileáin ardtaifigh optamaithe dó. Sin an rud ar mhaith leat a rith ar [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 27" 5K nó [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 32" 6K.

Ach mura bhfuil tú ag rith taispeántais le PPI de 218 nó os a chionn, beidh fonn ort socruithe an mhonatóra a athrú. Mar shampla, má tá 4K 27" nó 32" agat, is féidir leat scálú codánach a úsáid trí `~/.config/hypr/monitors.lua` a oscailt (trí _Setup > Monitors_ i roghchlár Omarchy) agus athrú go dtí an moladh don teaglaim sin:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Má tá taispeántas 1080p nó 1440p in úsáid agat, is dócha nach mbeidh uait ach scálú 1x, mar sin is féidir leat é seo a úsáid:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Baineann athruithe ar `GDK_SCALE` le feidhmchláir a thosaítear tar éis an athraithe (agus ní ghlacann GTK ach le slánuimhreacha, mar sin coinnigh ag an tslánuimhir is gaire do scála do mhonatóra é). Mar sin bí cinnte go scoireann tú de na fuinneoga atá agat agus atá rómhór tar éis an athraithe (nó dún gach fuinneog le `Ctrl + Alt + Del`!).

Is féidir leat céimniú go tapa freisin trí na príomhchóimheasa scálaithe monatóra (1x, 1.25x, 1.6x, 2x, 3x, 4x) le `Super + /` chun dul níos airde agus `Super + Alt + /` chun dul níos ísle. Má tá an chumraíocht réamhshocraithe agat, fanfaidh na hathruithe seo i bhfeidhm tar éis aththosaithe freisin.

### Téacs a dhéanamh níos mó nó níos lú

Athraíonn scálú monatóra méid gach rud. Más _téacs_ níos mó nó níos lú amháin atá uait, tá aon chnap amháin ann chuige sin:

```
omarchy display text size 14
```

Glacann sé sin le méid picteilíní idir 9 agus 20, agus bogann sé blaosc Omarchy, feidhmchláir GTK, agus do theirminéal le chéile, ionas go bhfanann an deasc ar fad i gcomhréir. Rith gan argóint é chun a fháil amach cá bhfuil tú, agus `omarchy display text size reset` chun dul ar ais go dtí an réamhshocrú. Is é Foot an t-aon fhánaí amháin: níl aon bhealach aige a chumraíocht a athlódáil, mar sin coimeádann teirminéil atá ar siúl a seansméid go dtí go n-osclaíonn tú ceann nua.

### Scáileáin ríomhaire glúine a leathnú agus a scáthánú

Nuair a nascann tú scáileán seachtrach le do ríomhaire glúine, leathnaítear an taispeántas go huathoibríoch. Ach is féidir leat é sin a athrú go scáthánú ina ionad sin trí _Trigger > Hardware_ i roghchlár Omarchy nó `Super + Ctrl + Alt + Delete` a úsáid. Tá sé seo an-chabhrach go háirithe más teilgeoir atá sa scáileán seachtrach sin, agus más mian leat rud éigin a thaispeáint agus tú ag obair.

Nuair atá tú ag leathnú, múchfaidh dúnadh an chlúdaigh ar an ríomhaire glúine an scáileán inmheánach go huathoibríoch. Cuirfidh oscailt an chlúdaigh ar siúl arís é. Is féidir leat é seo a rialú de láimh freisin trí _Trigger > Hardware_ i roghchlár Omarchy nó `Super + Ctrl + Delete` a úsáid.

### Ilscáileáin a shocrú

Oibríonn Hyprland go hiontach le hilscáileáin. Léigh tuilleadh faoi conas iad a leagan amach i [ndoiciméadacht monatóirí Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy, téann siad seo in `~/.config/hypr/monitors.lua` mar iontrálacha `hl.monitor` — tagann samplaí tráchtaithe leis an gcomhad chun monatóir ar leith a phionnáil ar thaifeach, suíomh, agus rothlú ar leith.

Tá spásanna oibre 1 go 10 dá chuid féin ag gach monatóir, mar sin ciallaíonn `Super + 1` i gcónaí an chéad spás oibre den mhonatóir a bhfuil tú air. Taobh thiar den radharc, uimhríonn Hyprland spásanna oibre ar fud na monatóirí go léir i gcónaí: faigheann scáileán do ríomhaire glúine (nó an chéad mhonatóir) 1–10, an chéad mhonatóir eile 11–20, agus mar sin de, agus coimeádann gach monatóir a bhloc gach uair a phlugálann tú isteach é. Úsáid na huimhreacha sin má scríobhann tú [rialacha spáis oibre](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) nó rialacha fuinneoge do mhonatóir ar leith, ionas gurb é spás oibre 12 an dara spás oibre de do dhara monatóir. Liostaíonn `~/.local/state/omarchy/monitor-workspaces` cén bloc atá ag gach monatóir.

Oibríonn na heochracha saigheada trasna monatóirí a roinneann ciumhais i do leagan amach. Ní comharsana iad scáileáin nach dteagmhaíonn ach ag cúinne, nó a bhfuil bearna eatarthu, mar sin úsáid `Ctrl + Alt + Tab` chun dul eatarthu.

| Eochair aicearra | Trasna monatóirí |
| --- | --- |
| `Super + Arrow` | Bogann sé an fócas go dtí an monatóir ar an taobh sin nuair nach bhfuil aon fhuinneog fágtha sa treo sin a thuilleadh |
| `Super + Shift + Arrow` | Malartaíonn sé le fuinneog ar an monatóir ar an taobh sin |
| `Super + Alt + Arrow` | Bogann sé an fhuinneog isteach i ngrúpa ar an monatóir ar an taobh sin |
| `Super + Shift + Ctrl + Arrow` | Bogann sé an fhuinneog go dtí an monatóir ar an taobh sin, ar an spás oibre atá á thaispeáint aige |
| `Super + Shift + Alt + Arrow` | Bogann sé an spás oibre go dtí an monatóir ar an taobh sin, ag coimeád a uimhreach má tá sí saor |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Bogann sé an fócas go dtí an chéad mhonatóir eile nó an monatóir roimhe, is cuma faoin leagan amach |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Fanann siad ar an monatóir a bhfuil tú air |

Is féidir leat breathnú ar [Hyprmon](https://github.com/erans/hyprmon/) freisin, más mian leat TUI chun cabhrú leat ilscáileáin a shuíomh.

### Gile a rialú

Rialaítear gile an mhonatóra leis na heochracha feidhme tiomnaithe do ghile suas/síos. Má choinníonn tú Shift síos agus na heochracha seo á mbrú agat, rachaidh tú go dtí an ghile uasta nó íosta. Rialaíonn na heochracha an taispeántas a bhfuil fócas agat air, mar sin déantar monatóirí seachtracha a labhraíonn DDC/CI a choigeartú ar an mbealach céanna le scáileán an ríomhaire glúine.

### Taispeántais Apple

Má tá taispeántas Apple in úsáid agat, oibreoidh na gnátheochracha gile méarchláir go huathoibríoch freisin, má tá fócas agat ar thaispeántas Apple. Déantar é seo tríd an ordú `asdcontrol`.

Tabhair faoi deara, má tá taispeántas Apple 6K XDR in úsáid agat, go bhféadfá scáileán taibhse a fheiceáil i do liostú `hyprctl monitors`. Is féidir leat é seo a mhúchadh le rud éigin cosúil le `hl.monitor({ output = "DP-2", disabled = true })` trí _Setup > Monitors_.

Ar mheaisíní Intel, ba cheart duit a bheith ag nascadh le taispeántais Apple le gnáthchábla Thunderbolt. Ar mheaisíní eile gan Thunderbolt, de ghnáth beidh ort [cábla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) a úsáid chun go n-oibreoidh sé.
