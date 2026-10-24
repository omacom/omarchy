# Do théama féin a dhéanamh

Is féidir leat do théamaí féin a chur le `~/.config/omarchy/themes`. Ní gá duit ach ceann de na cinn atá ann cheana a chóipeáil mar bhunús (féach in `/usr/share/omarchy/themes`), ansin athraigh é go do dhíchealltaitneamh. Chomh fada is atá do théama taobh istigh den fhillteán sin, beidh sé san áireamh sa roghchlár roghnaithe téama.

Is é `colors.toml` an príomhchomhad a chaithfidh tú a athrú. Sainmhíníonn sé sin an tacar dathanna a úsáidtear ansin chun cumraíochtaí a ghiniúint don teirminéal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, agus blaosc iomlán Omarchy (barra barr, roghchlár, fógraí, OSD, agus scáileán glais).

Is féidir leat an feidhmchlár Aether atá san áireamh a úsáid freisin chun téama nua a chruthú ag baint úsáide as comhéadan GUI álainn chun súgradh le dathanna agus cúlraí a chuardach. Ní gá duit ach é a thosú ón eangach feidhmchlár ar `Super + Alt + Space`.

### Cad is féidir a bheith i dtéama suiteáilte

Is féidir le téama a scríobhann tú féin i `~/.config/omarchy/themes` cibé rud is mian leat a bheith ann — is do mheaisín é agus do chomhad é, agus cuireann Omarchy é go léir i bhfeidhm.

Coinníonn téama a shuiteálann tú ó repo duine éigin eile le `omarchy theme install` gach rud atá ina dhath, agus cailleann sé an dornán comhad a rithfeadh cód ar do mheaisín: aon chomhad `.lua`, na cumraíochtaí teirminéil (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), agus `vscode.json`. Is Lua é `hyprland.lua` téama a ritheann do chumadóir ag am logála isteach, ainmníonn cumraíocht teirminéil an clár a thosaíonn do theirminéal, agus ainmníonn `vscode.json` síneadh VSCode le suiteáil. Ba chóir go n-athródh téama duine éigin a shuiteáil cuma do dheisce, riamh a ritheann sé.

Oibríonn gach rud eile go díreach fós mar a scríobh údar an téama é — coinnítear `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, na cúlraí agus na réamhamhairc go léir. Ní athghintear ach an méid a scaoileadh ó `colors.toml` ar do mheaisín.

Insíonn Omarchy an difríocht eatarthu de réir an bhfuil a repo git féin ag an téama istigh ann, is é sin an méid a fhágann `omarchy theme install` ina dhiaidh nuair a chlónálann sé. Mar sin fanann téama a scríobh tú leat féin, agus fanann ceann a tharraing tú den idirlíon ina dhathanna.

### Mód solais

Má tá téama móid solais á dhéanamh agat, socraigh `mode = "light"` ag barr do `colors.toml`. Ansin péireálfar go huathoibríoch é le mód solais do na feidhmchláir go léir. (Oibríonn an seanbhealach chun comhad folamh ar a dtugtar `light.mode` a chur uaigneas i bhfréamh do théama fós freisin.)

### Dathanna deilbhíní

Más mian leat deilbhíní an bhainisteora comhad a mheaitseáil le dath do théama, cuir comhad ar a dtugtar `icons.theme` leis le hainm an tacair deilbhíní is mian leat a úsáid. De réir réamhshocraithe, is iad na roghanna: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Íomhá díghlasála

Liostófar téamaí a sholáthraítear le híomhánna `unlock.png` agus `preview-unlock.png` faoi _Stíl > Díghlasáil_. B'fhearr gur png trédhearcach a bheadh i do `unlock.png`. Agus is féidir leat an íomhá réamhamhairc a chruthú ag baint úsáide as `omarchy plymouth preview`.

### Feidhmchláir nach gclúdaíonn Omarchy a théamú

Má úsáideann tú feidhmchlár nach bhfuil sa liosta sin, is féidir leat Omarchy a mhúineadh chun é a théamú tú féin le teimpléad. Buail comhad i `~/.config/omarchy/themed/` ainmnithe i ndiaidh na cumraíochta a ghineann sé móide síneadh `.tpl`, agus scríobh an chumraíocht le `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` trí `{{ color15 }}`, agus an chuid eile den phailéad mar áitchoimeádaithe. Gach uair a athraíonn tú téamaí, athghintear an comhad le dathanna an téama sin.

Tá `alacritty.toml.tpl.sample` lántraithe sa fhillteán sin le cóipeáil uaidh — liostaíonn sé gach athróg is féidir leat a úsáid, móide na modhnóirí `_strip` agus `_rgb` le haghaidh feidhmchlár ar mian leo a gcuid dathanna gan an `#` nó mar RGB deachúlach. Glacann do theimpléid tosaíocht ar theimpléid Omarchy féin, mar sin is féidir leat é seo a úsáid freisin chun sárú a dhéanamh ar an gcaoi a dtéamáiltear feidhmchlár ionsuite.

### Do théama a dháileadh

Más mian leat do théama a dháileadh ionas gur féidir le daoine eile é a úsáid, caithfidh tú é a chur ar fhreastalaí git poiblí, cosúil le GitHub. Ansin is féidir le daoine é a shuiteáil ag baint úsáide as _Suiteáil > Style > Theme_ sa roghchlár Omarchy ag baint úsáide as an URL sin. Moltar go leanfá coinbhinsiún ainmniúcháin `omarchy-[themename]-theme`, óir taispeánfar an téama i gceart mar `[themename]` amháin sa roghchlár roghnaithe téama tar éis na suiteála.

Éiríonn an t-iarmhar sin `[themename]` ina ainm comhadlainne don téama, mar sin caithfidh sé a bheith ina cheann is féidir le Omarchy a thabhairt timpeall go sábháilte: caithfidh sé tosú le litir, digit, nó bunlíne, agus féadfaidh litreacha, digití, `.`, `_`, `+`, agus `-` a bheith sa chuid eile. Íslítear ceannlitreacha duit, ach diúltaítear aon rud eile — spás, comhartha athfhriotail, carachtar neamh-Bhéarla — ag am suiteála seachas é a iompú ina ainm comhadlainne. Mar sin suiteálann `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, agus `omarchy-c++-theme` go léir go maith.

Cuimhnigh, a luaithe a shuiteáiltear ó repo é, go scaoiltear aon `.lua`, cumraíocht teirminéil nó `vscode.json` a sheolann sé, mar sin ná tóg an téama timpeall orthu sin.

Is féidir leat do théama a chur le [leathanach na dtéamaí breise](https://omarchy.org/themes/) trí iarratas tarraingthe a sheoladh chuig [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
