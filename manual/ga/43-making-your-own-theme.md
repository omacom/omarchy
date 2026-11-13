# Ag déanamh do théama féin

Is féidir leat do théamaí féin a chur le `~/.config/omarchy/themes`. Cóipeáil ceann de na cinn atá ann cheana mar bhunús (féach in `/usr/share/omarchy/themes`), ansin athraigh é mar is mian leat. Fad a bheidh do théama istigh sa fhillteán sin, beidh sé san áireamh sa roghchlár roghnúcháin téamaí.

Is é `colors.toml` an príomhchomhad a chaithfidh tú a athrú. Sainíonn sé sin an tacar dathanna a úsáidtear ansin chun cumraíochtaí a ghiniúint don teirminéal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, agus don bhlaosc Omarchy ar fad (an barra uachtarach, an roghchlár, fógraí, OSD, agus an scáileán glais).

Is féidir leat an feidhmchlár Aether atá san áireamh a úsáid freisin chun téama nua a chruthú ag baint úsáide as comhéadan álainn GUI chun triail a bhaint as dathanna agus chun cúlraí a chuardach. Tosaigh é ón eangach feidhmchlár ar `Super + Alt + Space`.

### Cad is féidir a bheith i dtéama suiteáilte

Is féidir le téama a scríobhann tú féin in `~/.config/omarchy/themes` rud ar bith is mian leat a bheith ann — is leatsa an meaisín agus an comhad, agus cuireann Omarchy é ar fad i bhfeidhm.

Coinníonn téama a shuiteálann tú ó stór duine eile le `omarchy theme install` gach rud a bhaineann le dath, agus cailleann sé an dornán beag comhad a rithfeadh cód ar do mheaisín: aon chomhad `.lua`, cumraíochtaí an teirminéil (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), agus `vscode.json`. Is é `hyprland.lua` téama ná Lua a ritheann do chumadóir ag logáil isteach, ainmníonn cumraíocht teirminéil an clár a thosaíonn do theirminéal, agus ainmníonn `vscode.json` síneadh VSCode le suiteáil. Ba cheart go n-athródh suiteáil téama duine éigin an chuma atá ar do dheasc, ní an rud a ritheann sé choíche.

Oibríonn gach rud eile fós díreach mar a scríobh údar an téama é — coinnítar `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, na cúlraí agus na réamhamhairc ar fad. Ní athghintear ar do mheaisín ach an méid a fágadh ar lár, ó `colors.toml`.

Déanann Omarchy idirdhealú idir an dá cheann de réir an bhfuil a stór git féin istigh sa téama, agus is é sin a fhágann `omarchy theme install` ina dhiaidh nuair a chlónálann sé. Mar sin fanann téama a scríobh tú leatsa, agus fanann ceann a tharraing tú ón idirlíon ina dhathanna amháin.

### Mód geal

Má tá téama mód geal á dhéanamh agat, socraigh `mode = "light"` ag barr do `colors.toml`. Ansin péireálfar go huathoibríoch é le mód geal do na feidhmchláir ar fad. (Oibríonn an seanbhealach fós freisin, comhad folamh darb ainm `light.mode` a fhágáil ag fréamh do théama.)

### Íomhá dhíghlasála

Liostófar téamaí a sholáthraítear le híomhánna `unlock.png` agus `preview-unlock.png` faoi _Cuma > Díghlasáil_. B'fhearr gur png trédhearcach a bheadh i do `unlock.png`. Agus is féidir leat an íomhá réamhamhairc a chruthú ag baint úsáide as `omarchy plymouth preview`.

### Feidhmchláir nach gcumhdaíonn Omarchy a théamú

Má úsáideann tú feidhmchlár nach bhfuil ar an liosta sin, is féidir leat a mhúineadh do Omarchy é a théamú tú féin le teimpléad. Fág comhad in `~/.config/omarchy/themed/` ainmnithe i ndiaidh na cumraíochta a ghineann sé móide síneadh `.tpl`, agus scríobh an chumraíocht le `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` go `{{ color15 }}`, agus an chuid eile den phailéad mar shealbhóirí áite. Gach uair a athraíonn tú téamaí, athghintear an comhad le dathanna an téama sin.

Tá `alacritty.toml.tpl.sample` lán-nótaí tráchta san fhillteán sin ar féidir leat cóip a dhéanamh uaidh — liostaíonn sé gach athróg is féidir leat a úsáid, móide na modhnóirí `_strip` agus `_rgb` d'fheidhmchláir a dteastaíonn a ndathanna uathu gan an `#` nó mar RGB deachúil. Tugtar tús áite do do theimpléid thar theimpléid Omarchy féin, mar sin is féidir leat é seo a úsáid freisin chun sárú a dhéanamh ar an gcaoi a dtéamaítear feidhmchlár ionsuite.

### Do théama a dháileadh

Más mian leat do théama a dháileadh ionas gur féidir le daoine eile é a úsáid, caithfidh tú é a chur ar fhreastalaí git poiblí, cosúil le GitHub. Ansin is féidir le daoine é a shuiteáil ag baint úsáide as _Suiteáil > Stíl > Téama_ sa roghchlár Omarchy ag baint úsáide as an URL sin. Moltar go leanfá coinbhinsiún ainmniúcháin `omarchy-[themename]-theme`, mar go dtaispeánfar an téama i gceart mar `[themename]` amháin sa roghchlár roghnúcháin téamaí tar éis na suiteála.

Éiríonn an `[themename]` sin atá fágtha ina ainm eolaire don téama, mar sin caithfidh sé a bheith ina cheann ar féidir le Omarchy a láimhseáil go sábháilte: caithfidh sé tosú le litir, digit, nó fleiscín íochtair, agus is féidir litreacha, digití, `.`, `_`, `+`, agus `-` a bheith sa chuid eile. Íslítear ceannlitreacha duit, ach diúltaítear aon rud eile — spás, comhartha athfhriotail, carachtar neamh-Bhéarla — ag am na suiteála seachas é a thiontú ina ainm eolaire. Mar sin suiteálann `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, agus `omarchy-c++-theme` go léir gan fadhb.

Cuimhnigh, a luaithe a shuiteáiltear ó stór é, go bhfágtar aon `.lua`, cumraíocht teirminéil nó `vscode.json` a sheolann sé ar lár, mar sin ná tóg an téama timpeall orthu sin.

Is féidir leat do théama a chur leis [an leathanach téamaí breise](https://omarchy.org/themes/) trí iarratas tarraingthe a sheoladh chuig [stór omarchy-site](https://github.com/omacom-io/omarchy-site).
