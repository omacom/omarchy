# Ag déanamh do théama féin

Is féidir leat do théamaí féin a chur le `~/.config/omarchy/themes`. Níl ort ach ceann de na cinn atá ann cheana a chóipeáil mar bhunús (féach in `/usr/share/omarchy/themes`), ansin é a athrú mar is mian leat. Chomh fada is atá do théama taobh istigh den fhillteán sin, beidh sé san áireamh sa roghchlár roghnaithe téamaí.

Is é `colors.toml` an príomhchomhad a chaithfidh tú a athrú. Sainmhíníonn sé sin an tacar dathanna a úsáidtear ansin chun cumraíochtaí a ghiniúint don teirminéal (Foot/Alacritty/Ghostty/Kitty), do btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aipeanna Qt, do sholas cúlra an mhéarchláir, don mhodh ionchuir, don roghnóir comhroinnte scáileáin, d'íocóin na n-aipeanna, do roinnt uirlisí AI (Claude, Pi, Hermes, T3 Code, Herdr), agus do bhlaosc iomlán Omarchy (an barra barr, an roghchlár, fógraí, OSD, agus an scáileán glais).

Is féidir leat an feidhmchlár Aether atá san áireamh a úsáid freisin chun téama nua a chruthú ag baint úsáide as comhéadan álainn GUI chun triail a bhaint as dathanna agus cúlraí a chuardach. Níl ort ach é a thosú ón eangach aipeanna ar `Super + Alt + Space`.

### Cad is féidir a bheith i dtéama suiteáilte

I dtéama a scríobhann tú féin in `~/.config/omarchy/themes` is féidir pé rud is maith leat a bheith — is é do mheaisín é agus is é do chomhad é, agus cuireann Omarchy é ar fad i bhfeidhm.

Coinníonn téama a shuiteálann tú ó repo duine eile le `omarchy theme install` gach rud a bhaineann le dath, agus cailleann sé an dornán comhad a rithfeadh cód ar do mheaisín: aon chomhad `.lua`, cumraíochtaí an teirminéil (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), agus `vscode.json`. Is Lua é `hyprland.lua` téama a ritheann do chumadóir ag logáil isteach, ainmníonn cumraíocht teirminéil an clár a thosaíonn do theirminéal, agus ainmníonn `vscode.json` síneadh VSCode atá le suiteáil. Ba chóir go n-athródh suiteáil téama duine éigin an chuma atá ar do dheasc, ní an rud a ritheann sí choíche.

Oibríonn gach rud eile fós díreach mar a scríobh údar an téama é — coimeádtar `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, na cúlraí agus na réamhamhairc ar fad. Ní athghintear ó `colors.toml` ar do mheaisín ach an méid a cuireadh ar leataobh.

Déanann Omarchy idirdhealú idir an dá cheann de réir an bhfuil a repo git féin taobh istigh den téama, agus sin a fhágann `omarchy theme install` ina dhiaidh nuair a chlónálann sé. Mar sin fanann téama a scríobh tú leatsa, agus fanann ceann a tharraing tú ón idirlíon ina dhathanna.

### Mód éadrom

Más téama móid éadroim atá á dhéanamh agat, socraigh `mode = "light"` ag barr do `colors.toml`. Ansin péireálfar go huathoibríoch é le mód éadrom do na haipeanna ar fad. (Oibríonn an seanbhealach fós freisin, comhad folamh darb ainm `light.mode` a fhágáil i bhfréamh do théama.)

### Scáileáin tosaithe agus logála isteach

Tarraingíonn an scáileán a iarrann pasfhocal an tiomántáin ag an tosú, agus an scáileán logála isteach, lógó Omarchy i ndath `accent` do théama ar a `background`, leis an réimse pasfhocail ina `foreground` agus `red` le haghaidh pasfhocal mícheart. Níl aon rud breise le cur ar fáil dóibh: ní úsáideann Omarchy `unlock.png` nó `preview-unlock.png` téama a thuilleadh. Ar Mhacanna Apple Silicon, coinníonn scáileán pasfhocail an tiomántáin cuma réamhshocraithe Omarchy is cuma cén téama atá ann.

### Téamaí a chur ar aipeanna nach gclúdaíonn Omarchy

Má úsáideann tú aip nach bhfuil sa liosta sin, is féidir leat a mhúineadh do Omarchy conas í a théamú tú féin le teimpléad. Fág comhad in `~/.config/omarchy/themed/` ainmnithe i ndiaidh na cumraíochta a ghineann sé móide síneadh `.tpl`, agus scríobh an chumraíocht le `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` go `{{ color15 }}`, agus an chuid eile den phailéad mar áitchoimeádáin. Gach uair a athraíonn tú téamaí, athghintear an comhad le dathanna an téama sin.

Tá `alacritty.toml.tpl.sample` lántráchta san fhillteán sin ar féidir leat cóipeáil uaidh — liostaíonn sé gach athróg is féidir leat a úsáid, móide na modhnóirí `_strip` agus `_rgb` d'aipeanna ar mian leo a ndathanna gan an `#` nó mar RGB deachúlach. Tá tosaíocht ag do theimpléid thar theimpléid Omarchy féin, mar sin is féidir leat é seo a úsáid freisin chun an dóigh a dtéamaítear aip ionsuite a shárú.

### Do théama a dháileadh

Más mian leat do théama a dháileadh ionas gur féidir le daoine eile é a úsáid, ní mór duit é a chur ar fhreastalaí git poiblí, cosúil le GitHub. Ansin is féidir le daoine é a shuiteáil tríd _Install > Style > Theme_ sa roghchlár Omarchy ag baint úsáide as an URL sin. Moltar duit coinbhinsiún ainmniúcháin `omarchy-[themename]-theme` a leanúint, mar go dtaispeánfar an téama i gceart mar `[themename]` amháin sa roghchlár roghnaithe téamaí tar éis na suiteála.

Éiríonn an `[themename]` atá fágtha ina ainm eolaire ar an téama, mar sin caithfidh sé a bheith ar cheann is féidir le Omarchy a thabhairt thart go sábháilte: caithfidh sé tosú le litir, le digit, nó le fostríoc, agus is féidir leis an gcuid eile litreacha, digití, `.`, `_`, `+`, agus `-` a choinneáil. Íslítear litreacha móra ar do shon, ach diúltaítear d'aon rud eile — spás, comhartha athfhriotail, carachtar neamh-Bhéarla — ag am na suiteála seachas é a thiontú ina ainm eolaire. Mar sin suiteálann `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, agus `omarchy-c++-theme` ar fad gan fadhb.

Cuimhnigh, nuair a bheidh sé suiteáilte ó repo, go gcaillfear aon `.lua`, cumraíocht teirminéil nó `vscode.json` a chuireann sé ar fáil, mar sin ná tóg an téama timpeall orthu sin.

Is féidir leat do théama a chur leis [an leathanach téamaí breise](https://omarchy.org/themes/) trí iarratas tarraingthe a sheoladh chuig [an repo omarchy-site](https://github.com/omacom-io/omarchy-site).
