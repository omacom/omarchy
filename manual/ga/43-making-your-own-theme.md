# Do théama féin a dhéanamh

Is féidir leat do théamaí féin a chur le `~/.config/omarchy/themes`. Cóipeáil ceann de na cinn atá ann cheana mar bhonn (féach in `/usr/share/omarchy/themes`), ansin athraigh é mar is mian leat. Chomh fada is a bheidh do théama taobh istigh den fhillteán sin, beidh sé san áireamh sa roghchlár roghnúcháin téamaí.

Is é `colors.toml` an príomhchomhad a chaithfidh tú a athrú. Sainmhíníonn sé sin an tacar dathanna a úsáidtear ansin chun cumraíochtaí a ghiniúint don teirminéal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aipeanna Qt, soilsiú cúil an mhéarchláir, an modh ionchuir, an roghnóir comhroinnte scáileáin, deilbhíní na n-aipeanna, roinnt uirlisí AI (Claude, Pi, Hermes, T3 Code, Herdr), agus blaosc iomlán Omarchy (an barra uachtarach, an roghchlár, fógraí, OSD, agus an scáileán glasála).

Is féidir leat an aip Aether atá san áireamh a úsáid freisin chun téama nua a chruthú le comhéadan GUI deas chun imirt le dathanna agus cúlraí a chuardach. Tosaigh é ón ngreille aipeanna ar `Super + Alt + Space`.

### Cad is féidir a bheith i dtéama suiteáilte

Is féidir le téama a scríobhann tú féin in `~/.config/omarchy/themes` cibé rud is mian leat a bheith ann — is é do mheaisín agus do chomhad é, agus cuireann Omarchy é ar fad i bhfeidhm.

Coinníonn téama a shuiteálann tú ó repo duine eile le `omarchy theme install` gach rud a bhaineann le dath, agus cailleann sé an dornán comhad a rithfeadh cód ar do mheaisín: aon chomhad `.lua`, na cumraíochtaí teirminéil (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), agus `vscode.json`. Is é `hyprland.lua` téama ná Lua a ritheann do chumadóir ag logáil isteach, ainmníonn cumraíocht teirminéil an clár a thosaíonn do theirminéal, agus ainmníonn `vscode.json` breiseán VSCode atá le suiteáil. Ba cheart go n-athródh suiteáil téama duine éigin cuma do dheisce, ní cad a ritheann sí choíche.

Oibríonn gach rud eile go díreach mar a scríobh údar an téama é — coinntear `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, na cúlraí agus na réamhamhairc ar fad. Ní athghintear ó `colors.toml` ar do mheaisín ach an méid a fágadh ar lár.

Insíonn Omarchy an difríocht idir an dá cheann de réir an bhfuil a repo git féin taobh istigh den téama, agus is é sin a fhágann `omarchy theme install` ina dhiaidh nuair a chlónálann sé. Mar sin, fanann téama a scríobh tú i do sheilbh, agus fanann téama a tharraing tú ón idirlíon ina dhathanna amháin.

### Mód geal

Má tá téama i mód geal á dhéanamh agat, socraigh `mode = "light"` ag barr do `colors.toml`. Ansin beidh sé péireáilte go huathoibríoch le mód geal do na haipeanna ar fad. (Oibríonn an seanbhealach freisin, comhad folamh darb ainm `light.mode` a fhágáil ag fréamh do théama.)

### Íomhá dhíghlasála

Liostófar téamaí a chuirtear ar fáil le híomhánna `unlock.png` agus `preview-unlock.png` faoi _Cuma > Díghlasáil_. B'fhearr gur png trédhearcach a bheadh i do `unlock.png`. Agus is féidir leat an íomhá réamhamhairc a chruthú le `omarchy plymouth preview`.

### Téamaí a chur ar aipeanna nach gclúdaíonn Omarchy

Má úsáideann tú aip nach bhfuil ar an liosta sin, is féidir leat múineadh do Omarchy conas téama a chur uirthi tú féin le teimpléad. Fág comhad in `~/.config/omarchy/themed/` a ainmnítear as an gcumraíocht a ghineann sé móide síneadh `.tpl`, agus scríobh an chumraíocht le `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` go `{{ color15 }}`, agus an chuid eile den phailéad mar shealbhóirí áite. Gach uair a athraíonn tú téamaí, athghintear an comhad le dathanna an téama sin.

Tá `alacritty.toml.tpl.sample` lán-nótaithe san fhillteán sin le cóipeáil uaidh — liostaíonn sé gach athróg is féidir leat a úsáid, móide na modhnóirí `_strip` agus `_rgb` d'aipeanna ar mian leo a ndathanna gan an `#` nó mar RGB deachúil. Tugtar tosaíocht do do theimpléid thar theimpléid Omarchy féin, mar sin is féidir leat é seo a úsáid freisin chun an chaoi a gcuirtear téama ar aip ionsuite a shárú.

### Do théama a dháileadh

Más mian leat do théama a dháileadh ionas gur féidir le daoine eile é a úsáid, caithfidh tú é a chur ar fhreastalaí git poiblí, mar GitHub. Ansin is féidir le daoine é a shuiteáil le _Suiteáil > Stíl > Téama_ i roghchlár Omarchy ag úsáid an URL sin. Moltar duit an coinbhinsiún ainmniúcháin `omarchy-[themename]-theme` a leanúint, mar go dtaispeánfar an téama i gceart mar `[themename]` amháin sa roghchlár roghnúcháin téamaí tar éis na suiteála.

Éiríonn an `[themename]` atá fágtha ina ainm eolaire ar an téama, mar sin caithfidh sé a bheith ina cheann is féidir le Omarchy a láimhseáil go sábháilte: caithfidh sé tosú le litir, digit, nó fleiscín íochtair, agus féadfaidh litreacha, digití, `.`, `_`, `+`, agus `-` a bheith sa chuid eile. Déantar litreacha móra a thiontú go litreacha beaga duit, ach diúltaítear d'aon rud eile — spás, comhartha athfhriotail, carachtar neamh-Bhéarla — ag am na suiteála seachas é a thiontú ina ainm eolaire. Mar sin, suiteálann `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, agus `omarchy-c++-theme` ar fad gan fhadhb.

Cuimhnigh, a luaithe a shuiteáiltear ó repo é, go bhfágtar ar lár aon `.lua`, cumraíocht teirminéil nó `vscode.json` a sheolann sé, mar sin ná tóg an téama timpeall orthu siúd.

Is féidir leat do théama a chur le [leathanach na dtéamaí breise](https://omarchy.org/themes/) trí iarratas tarraingthe a sheoladh chuig [an repo omarchy-site](https://github.com/omacom-io/omarchy-site).
