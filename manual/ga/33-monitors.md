# Monatóirí

Glacann Omarchy leis go bhfuil tú ag rith ar thaispeána de chineál retina atá in ann 2x de réir réamhshocraithe. Sin a theastaíonn uait chun na clónna deasa géara ríomhchláraitheora sin a fháil. Sin a bhfuil beagnach gach ríomhaire glúine préimhe nua le scáileáin ardtaifigh optamaithe dó. Sin a ba mhaith leat a rith ar 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) nó 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ach mura bhfuil tú ag rith taispeána le PPI de 218 nó os a chionn, ba mhaith leat socruithe an mhonatóra a athrú. Mar shampla, má tá 27" nó 32" 4K agat, is féidir leat scálú codáin a úsáid trí `~/.config/hypr/monitors.lua` a oscailt (trí _Socrú > Monatóirí_ sa roghchlár Omarchy) agus aistriú chuig an moladh don teaglaim sin:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Má tá taispeána 1080p nó 1440p in úsáid agat, is dócha go mbeidh tú díreach ag iarraidh scálú 1x a úsáid, mar sin is féidir leat úsáid a bhaint as:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Baineann athruithe ar `GDK_SCALE` le feidhmchláir a thosaíodh tar éis an athraithe (agus ní onóraíonn GTK ach slánuimhreacha, mar sin coimeád é ag an tslánuimhir is gaire de scála do mhonatóra). Mar sin cinntigh go bhfágann tú na fuinneoga atá rómhór agat tar éis an athraithe (nó dún gach fuinneog le `Ctrl + Alt + Del`!).

Is féidir leat céimniú go tapa trí na príomhchóimheasa scálaithe monatóra (1x, 1.25x, 1.6x, 2x, 3x, 4x) trí `Super + /` a úsáid chun dul níos airde agus `Super + Alt + /` chun dul níos ísle. Má tá an chumraíocht réamhshocraithe agat, mairfidh na hathruithe seo thar atosú freisin.

### Téacs a dhéanamh níos mó nó níos lú

Athraíonn scálú monatóra méid gach rud. Más rud é nach bhfuil uait ach _téacs_ níos mó nó níos lú, tá cnaipe amháin chuige sin:

```
omarchy display text size 14
```

Glacann sé sin méid picteilíní idir 9 agus 20, agus bogann sé blaosc Omarchy, feidhmchláir GTK, agus do theirminéal le chéile, mar sin fanann an deasc iomlán i gcomhréir. Rith é gan argóint chun a fheiceáil cá bhfuil tú, agus `omarchy display text size reset` chun dul ar ais chuig an réamhshocrú. Is é Foot an stragglaire amháin: níl bealach aige a chumraíocht a athlódáil, mar sin coimeádann teirminéil atá ag rith a seansméid go dtí go n-osclóidh tú ceann nua.

### Taispeántais ríomhaire glúine a shíneadh agus a scáthánú

Nuair a nascann tú scáileán seachtrach le do ríomhaire glúine, síneadh an taispeána go huathoibríoch. Ach is féidir leat é sin a athrú go scáthánú ina ionad trí _Spreag > Crua-earraí_ sa roghchlár Omarchy nó `Super + Ctrl + Alt + Delete` a úsáid. Tá sé seo úsáideach go háirithe más teilgeoir é an scáileán seachtrach sin, agus go dteastaíonn uait rud éigin a thaispeáint agus tú ag obair.

Nuair atá tú ag síneadh, múchfaidh dúnadh an chláir ar an ríomhaire glúine an scáileán inmheánach go huathoibríoch. Casfaidh oscailt an chláir air ar ais é. Is féidir leat é seo a rialú de láimh freisin trí _Spreag > Crua-earraí_ sa roghchlár Omarchy nó `Super + Ctrl + Delete` a úsáid.

### Ilscáileáin a shocrú

Oibríonn Hyprland go hiontach le ilscáileáin. Léigh tuilleadh faoi conas iad a leagan amach i [doiciméadacht monatóra Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Is féidir leat [spásanna oibre sonracha a cheangal le monatóirí sonracha](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) freisin. In Omarchy, téann na rialacha seo in `~/.config/hypr/monitors.lua` mar iontrálacha `hl.monitor` — tagann an comhad le samplaí anótáilte chun monatóir sonrach a greamú chuig taifeach, suíomh, agus rothlú.

Is féidir leat seiceáil amach [Hyprmon](https://github.com/erans/hyprmon/) freisin, más mian leat TUI chun cabhrú leat le suíomh ilscáileáin.

### Gile a rialú

Rialaítear gile monatóra leis na heochracha feidhme tiomnaithe do ghile suas/síos. Má choinníonn tú shift síos agus tú ag brú orthu seo, rachaidh tú go huasghile nó íosghile. Rialaíonn na heochracha an taispeána ar a bhfuil fócas agat, mar sin coigeartaítear monatóirí seachtracha a labhraíonn DDC/CI ar an mbealach céanna le scáileán an ríomhaire glúine.

### Taispeántais Apple

Má tá taispeána Apple in úsáid agat, oibreoidh na heochracha rialta gile méarchláir go huathoibríoch freisin, má tá fócas agat ar thaispeána Apple. Déantar é seo tríd an ordú `asdcontrol`.

Tabhair faoi deara má tá taispeána Apple 6K XDR in úsáid agat, go bhféadfá scáileán taibhse a fheiceáil i do liostaithe `hyprctl monitors`. Is féidir leat é seo a mhúchadh le rud ar nós `hl.monitor({ output = "DP-2", disabled = true })` trí _Socrú > Monatóirí_.

Ar mheaisíní Intel, ba chóir duit a bheith ag nascadh le taispeántais Apple ag úsáid cábla Thunderbolt rialta. Ar mheaisíní eile gan Thunderbolt, de ghnáth caithfidh tú [cábla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) a úsáid chun é a chur ag obair.
