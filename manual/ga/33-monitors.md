# Monatóirí

Glacann Omarchy leis de réir réamhshocraithe go bhfuil tú ag rith ar thaispeáint de ghrád retina atá in ann 2x a dhéanamh. Sin a theastaíonn uait chun na clónna ríomhchláraitheora deasa, géara sin a fháil. Sin a bhfuil beagnach gach ríomhaire glúine préimhe nua le scáileáin ardtaifigh optamaithe ina leith. Sin a bheadh uait a rith ar 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) nó 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ach mura bhfuil tú ag rith taispeáint le PPI de 218 nó níos airde, beidh tú ag iarraidh na socruithe monatóra a athrú. Mar shampla, má tá 4K 27" nó 32" agat, is féidir leat scála codánach a roghnú dó ón bpainéal monatóra sa bharra uachtarach, nó an réamhshocrú a shocrú do gach monatóir trí `~/.config/hypr/monitors.lua` a oscailt agus athrú go dtí an moladh don teaglaim sin:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Má tá taispeáint 1080p nó 1440p á húsáid agat, is dócha nach mbeidh uait ach scálú 1x a úsáid, agus an rud céanna d'fheidhmchláir GTK agus X11, mar sin is féidir leat úsáid a bhaint as:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Baineann athruithe ar `GDK_SCALE` le feidhmchláir a thosaítear tar éis an athraithe (agus ní thugann GTK aird ach ar shlánuimhreacha, mar sin coinnigh ag an tslánuimhir is gaire do scála do mhonatóra é). Mar sin déan cinnte go scoireann tú de na fuinneoga atá agat atá rómhór tar éis an athraithe (nó dún gach fuinneog le `Ctrl + Alt + Del`!).

Is féidir leat dul go tapa freisin trí na príomhchóimheasa scálaithe monatóra (1x, 1.25x, 1.6x, 2x, 3x, 4x) ag úsáid `Super + /` chun dul níos airde agus `Super + Alt + /` chun dul níos ísle, nó ceann a roghnú ón bpainéal monatóra sa bharra uachtarach. Ní athraíonn siad seo ach an monatóir a bhfuil fócas agat air, mar sin is féidir a scála féin a bheith ag scáileán ríomhaire glúine agus ag taispeáint sheachtrach araon. Socraíonn an painéal taifeach gach monatóra freisin. Sábháiltear do roghanna don mhonatóir fisiciúil sin in `~/.local/state/omarchy/monitors/settings`, mar sin maireann siad thar atosaigh agus leanann siad an monatóir chuig cibé port nó dug a phlugáiltear isteach ann ina dhiaidh sin é. Tá tosaíocht acu ar aon riail don mhonatóir céanna in `~/.config/hypr/monitors.lua`, nach gcuireann Omarchy in eagar riamh. Ós rud é gur luach amháin é `GDK_SCALE` do na scáileáin go léir, socraíonn scála roghnaithe é ón monatóir leis an scála is ísle, mar sin tagann feidhmchláir X11 amach beagáinín beag ar an scáileán níos dlúithe seachas rómhór ar an gceann eile.

### Téacs a dhéanamh níos mó nó níos lú

Athraíonn scálú monatóra méid gach rud. Más é _téacs_ níos mó nó níos lú amháin atá uait, tá cnaipe aonair amháin chuige sin:

```
omarchy display text size 14
```

Glacann sé sin méid picteilíní idir 9 agus 20, agus bogann sé blaosc Omarchy, feidhmchláir GTK, agus do theirminéal le chéile, mar sin fanann an deasc ar fad i gcomhréir. Rith gan argóint é chun a fheiceáil cá bhfuil tú, agus `omarchy display text size reset` chun dul ar ais go dtí an réamhshocrú. Is é Foot an t-aon fhánaí amháin: níl aon bhealach aige a chumraíocht a athlódáil, mar sin coimeádann teirminéil atá ar siúl a seanmhéid go dtí go n-osclaíonn tú ceann nua.

### Taispeáintí ríomhaire glúine a shíneadh agus a scáthánú

Nuair a nascann tú scáileán seachtrach le do ríomhaire glúine, síneadh an taispeáint go huathoibríoch. Ach is féidir leat é sin a athrú go scáthánú ina ionad sin ag úsáid _Trigger > Hardware_ i roghchlár Omarchy nó `Super + Ctrl + Alt + Delete`. Tá sé seo an-chabhrach go háirithe más teilgeoir é an scáileán seachtrach sin, agus más mian leat rud éigin a thaispeáint agus tú ag obair.

Nuair atá tú ag síneadh, múchfaidh dúnadh an chlúdaigh ar an ríomhaire glúine an scáileán inmheánach go huathoibríoch. Casfaidh oscailt an chlúdaigh ar ais air é. Is féidir leat é seo a rialú de láimh freisin ag úsáid _Trigger > Hardware_ i roghchlár Omarchy nó `Super + Ctrl + Delete`.

### Ilscáileáin a shocrú

Oibríonn Hyprland go hiontach le hilscáileáin. Tarraingíonn an painéal monatóra sa bharra uachtarach iad san áit ina suíonn siad: tarraing ceann in aghaidh thaobh ceann eile chun é a bhogadh ann, agus sábháiltear an socrú le socruithe eile gach monatóra. Maidir le haon rud nach gclúdaíonn an painéal, léigh tuilleadh faoi conas iad a leagan amach i [doiciméadúchán monatóra Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy, téann siad seo in `~/.config/hypr/monitors.lua` mar iontrálacha `hl.monitor` — tagann samplaí le nótaí tráchta leis an gcomhad chun monatóir ar leith a phionnáil le taifeach, suíomh, agus rothlú.

Tá spásanna oibre 1 go 10 dá chuid féin ag gach monatóir, mar sin ciallaíonn `Super + 1` i gcónaí an chéad spás oibre den mhonatóir a bhfuil tú air. Taobh thiar de na cúlraí, uimhríonn Hyprland spásanna oibre ar fud na monatóirí go léir fós: faigheann scáileán do ríomhaire glúine (nó an chéad mhonatóir) 1–10, an chéad mhonatóir eile 11–20, agus mar sin de, agus coimeádann gach monatóir a bhloc gach uair a phlugálann tú isteach é. Úsáid na huimhreacha sin má scríobhann tú [rialacha spáis oibre](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) nó rialacha fuinneoige do mhonatóir ar leith, mar sin is é spás oibre 12 an dara spás oibre de do dhara monatóir. Liostaíonn `~/.local/state/omarchy/monitors/workspaces` cén bloc atá ag gach monatóir.

Oibríonn na heochracha saighde ar fud monatóirí a roinneann imeall i do leagan amach. Ní comharsana iad scáileáin nach dteagmhaíonn ach ag cúinne, nó a bhfuil bearna eatarthu, mar sin úsáid `Ctrl + Alt + Tab` chun dul eatarthu.

| Eochair ghiorraithe | Ar fud monatóirí |
| --- | --- |
| `Super + Arrow` | Bogann sé fócas chuig an monatóir ar an taobh sin a luaithe nach bhfuil aon fhuinneog fágtha sa treo sin |
| `Super + Shift + Arrow` | Malartaíonn sé le fuinneog ar an monatóir ar an taobh sin |
| `Super + Alt + Arrow` | Bogann sé an fhuinneog isteach i ngrúpa ar an monatóir ar an taobh sin |
| `Super + Shift + Ctrl + Arrow` | Bogann sé an fhuinneog chuig an monatóir ar an taobh sin, ar an spás oibre atá á thaispeáint aige |
| `Super + Shift + Alt + Arrow` | Bogann sé an spás oibre chuig an monatóir ar an taobh sin, ag coinneáil a uimhreach má tá sí saor |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Bogann sé fócas chuig an gcéad mhonatóir eile nó an monatóir roimhe, cibé leagan amach atá ann |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Fanann siad ar an monatóir a bhfuil tú air |

Is féidir leat breathnú ar [Hyprmon](https://github.com/erans/hyprmon/) freisin, más maith leat TUI chun cabhrú leat le suíomh ilscáileán.

### Gile a rialú

Rialaítear gile an mhonatóra leis na heochracha feidhme tiomnaithe do ghile suas/síos. Má choinníonn tú shift síos agus tú ag brú iad seo, rachaidh tú go dtí an ghile uasta nó íosta. Rialaíonn na heochracha an taispeáint a bhfuil fócas agat uirthi, mar sin coigeartaítear monatóirí seachtracha a labhraíonn DDC/CI ar an mbealach céanna le scáileán an ríomhaire glúine.

### Taispeáintí Apple

Má tá taispeáint Apple á húsáid agat, oibreoidh na gnátheochracha gile méarchláir go huathoibríoch freisin, má tá fócas agat ar thaispeáint Apple. Déantar é seo tríd an ordú `asdcontrol`.

Tabhair faoi deara, má tá taispeáint Apple 6K XDR á húsáid agat, go bhféadfadh tú scáileán taibhse a fheiceáil i do liostú `hyprctl monitors`. Is féidir leat é seo a mhúchadh le rud éigin cosúil le `hl.monitor({ output = "DP-2", disabled = true })` in `~/.config/hypr/monitors.lua`.

Ar mheaisíní Intel, ba chóir duit a bheith ag nascadh le taispeáintí Apple ag úsáid gnáthchábla Thunderbolt. Ar mheaisíní eile gan Thunderbolt, de ghnáth beidh ort [cábla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) a úsáid chun é a chur ag obair.
