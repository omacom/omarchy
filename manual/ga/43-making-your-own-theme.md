# Do théama féin a dhéanamh

Is féidir leat do théamaí féin a chur le `~/.config/omarchy/themes`. Cóipeáil ceann de na cinn atá ann cheana mar bhonn (féach in `/usr/share/omarchy/themes`), ansin athraigh é mar is mian leat. Chomh fada agus a bhíonn do théama istigh sa fhillteán sin, beidh sé san áireamh i roghchlár roghnúcháin na dtéamaí.

Is é `colors.toml` an príomhchomhad a chaithfidh tú a athrú. Sainmhíníonn sé sin an tacar dathanna a úsáidtear ansin chun cumraíochtaí a ghiniúint don teirminéal (Foot/Alacritty/Ghostty/Kitty), do btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, agus do bhlaosc iomlán Omarchy (an barra uachtarach, an roghchlár, fógraí, OSD, agus an scáileán glais).

Is féidir leat an feidhmchlár Aether atá san áireamh a úsáid freisin chun téama nua a chruthú trí chomhéadan deas GUI a úsáid chun spraoi a bheith agat le dathanna agus cúlraí a chuardach. Tosaigh é ón eangach feidhmchlár ar `Super + Alt + Space`.

### Cad is féidir a bheith i dtéama suiteáilte

I dtéama a scríobhann tú féin in `~/.config/omarchy/themes` is féidir a bheith mar is mian leat — is leatsa an meaisín agus is leatsa an comhad, agus cuireann Omarchy é ar fad i bhfeidhm.

I dtéama a shuiteálann tú ó stór duine eile le `omarchy theme install` coinnítear gach rud a bhaineann le dath, agus cailltear an dornán comhad a rithfeadh cód ar do mheaisín: aon chomhad `.lua`, na cumraíochtaí teirminéil (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), agus `vscode.json`. Is Lua é `hyprland.lua` téama a ritheann do chumadóir ag logáil isteach, ainmníonn cumraíocht teirminéil an clár a thosaíonn do theirminéal, agus ainmníonn `vscode.json` síneadh VSCode atá le suiteáil. Ba chóir go n-athródh suiteáil téama duine éigin an chuma atá ar do dheasc, ní an méid a ritheann sí choíche.

Oibríonn gach rud eile go díreach mar a scríobh údar an téama é — coimeádtar `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, na cúlraí agus na réamhamhairc ar fad. Ní athghintear ó `colors.toml` ar do mheaisín ach an méid a caitheadh amach.

Insíonn Omarchy an difríocht idir an dá cheann de réir an bhfuil a stór git féin istigh sa téama, agus sin a fhágann `omarchy theme install` ina dhiaidh nuair a chlónálann sé. Mar sin fanann téama a scríobh tú leatsa, agus fanann ceann a tharraing tú ón idirlíon ina dhathanna amháin.

### Mód geal

Má tá téama móid gheal á dhéanamh agat, socraigh `mode = "light"` ag barr do `colors.toml`. Ansin péireálfar go huathoibríoch é le mód geal do na feidhmchláir ar fad. (Oibríonn an seanbhealach freisin, is é sin comhad folamh darb ainm `light.mode` a fhágáil i bhfréamh do théama.)

### Dathanna na ndeilbhíní

Más mian leat deilbhíní an bhainisteora comhad a mheaitseáil le dathanna do théama, cuir comhad darb ainm `icons.theme` leis ina bhfuil ainm an tacair deilbhíní is mian leat a úsáid. De réir réamhshocraithe, is iad na roghanna: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Íomhá dhíghlasála

Liostálfar téamaí a soláthraítear le híomhánna `unlock.png` agus `preview-unlock.png` faoi _Dealramh > Díghlasáil_. B'fhearr gur png trédhearcach a bheadh i do `unlock.png`. Agus is féidir leat an íomhá réamhamhairc a chruthú le `omarchy plymouth preview`.

### Téamaí a chur ar fheidhmchláir nach gclúdaíonn Omarchy

Má úsáideann tú feidhmchlár nach bhfuil ar an liosta sin, is féidir leat a mhúineadh do Omarchy é a théamú leat féin le teimpléad. Fág comhad in `~/.config/omarchy/themed/` a ainmnítear as an gcumraíocht a ghineann sé móide síneadh `.tpl`, agus scríobh an chumraíocht le `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` go `{{ color15 }}`, agus an chuid eile den phailéad mar áitshealbhóirí. Gach uair a athraíonn tú téamaí, athghintear an comhad le dathanna an téama sin.

Tá `alacritty.toml.tpl.sample` lán-nótáilte sa fhillteán sin ar féidir leat cóipeáil uaidh — liostaíonn sé gach athróg is féidir leat a úsáid, móide na modhnóirí `_strip` agus `_rgb` d'fheidhmchláir a dteastaíonn a ndathanna uathu gan an `#` nó mar RGB deachúil. Tugtar tús áite do do theimpléid thar theimpléid Omarchy féin, mar sin is féidir leat é seo a úsáid freisin chun an dóigh a dtéamaítear feidhmchlár ionsuite a shárú.

### Do théama a dháileadh

Más mian leat do théama a dháileadh ionas gur féidir le daoine eile é a úsáid, ní mór duit é a chur ar fhreastalaí poiblí git, amhail GitHub. Ansin is féidir le daoine é a shuiteáil tríd _Suiteáil > Stíl > Téama_ a úsáid i roghchlár Omarchy agus an URL sin a úsáid. Moltar duit coinbhinsiún ainmniúcháin `omarchy-[themename]-theme` a leanúint, mar go dtaispeánfar an téama i gceart mar `[themename]` amháin i roghchlár roghnúcháin na dtéamaí tar éis na suiteála.

Éiríonn an `[themename]` atá fágtha sin ina ainm eolaire ar an téama, mar sin caithfidh sé a bheith ina cheann is féidir le Omarchy a láimhseáil go sábháilte: caithfidh sé tosú le litir, digit, nó fostríoc, agus is féidir litreacha, digití, `.`, `_`, `+`, agus `-` a bheith sa chuid eile. Déantar ceannlitreacha a thiontú go litreacha beaga duit, ach diúltaítear d'aon rud eile — spás, comhartha athfhriotail, carachtar neamh-Bhéarla — ag am na suiteála seachas é a thiontú ina ainm eolaire. Mar sin suiteálann `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, agus `omarchy-c++-theme` ar fad gan fadhb.

Cuimhnigh, a luaithe a shuiteálfar ó stór é, go gcaithfear amach aon `.lua`, cumraíocht teirminéil nó `vscode.json` a sheolann sé, mar sin ná tóg an téama timpeall orthu sin.

Is féidir leat do théama a chur le [leathanach na dtéamaí breise](https://omarchy.org/themes/) trí iarratas tarraingthe a sheoladh chuig [stór omarchy-site](https://github.com/omacom-io/omarchy-site).
