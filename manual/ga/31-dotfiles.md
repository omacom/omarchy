# Dotfiles

Cumraítear Omarchy go príomha trí na dotfiles mar a thugtar orthu a chónaíonn in `~/.config`. Meastar gur leatsa na comhaid sin le haghaidh do chuid athruithe féin. Baineann na comhaid a chónaíonn in `/usr/share/omarchy` le Omarchy féin, agus níor cheart duit a bheith ag cur isteach orthu sin. Más gá duit rud ar bith in `/usr/share/omarchy` a athrú, ba cheart duit an luach a fhorscríobh in `~/.config` ina ionad.

Is féidir na príomhchumraíochtaí a chur in eagar díreach ón roghchlár Omarchy (`Super + Space`), amhail _Setup > Keybindings_, _Setup > Input_, agus _Setup > Config > [file]_. Nuair a dhéanann tú ar an mbealach sin é, atosófar go huathoibríoch aon phróiseas ar gá é a atosú tar éis eagarthóireacht cumraíochta nuair a éiríonn tú as an eagarthóir (Neovim de réir réamhshocraithe — `:wq`, cuimhnigh! — ach is féidir leat é sin a athrú trí _Setup > Defaults > Editor_).

Seo liosta de na príomhchomhaid in `~/.config` agus a rialaíonn siad:

| Comhad                  | Cuspóir              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | An phríomhchumraíocht Hyprland. Lódálann sí réamhshocruithe Omarchy móide do chomhaid sháraithe thíos. [Faigh tuilleadh eolais faoi chumraíochtaí Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Do cheangail eochrach féin agus sáruithe ar na réamhshocruithe. |
| `~/.config/hypr/monitors.lua` | Socruithe monatóra nach gclúdaíonn an painéal monatóra, amhail rothlú, modhanna breise, nó monatóir a choinneáil múchta. |
| `~/.config/hypr/input.lua` | Rialaíonn sé leagan amach do mhéarchláir, do lucha agus do cheap tadhaill. |
| `~/.config/hypr/looknfeel.lua` | Rialaíonn sé bearnaí, imill, beochan, agus an chuid eile den chuma. |
| `~/.config/hypr/autostart.lua` | Rialaíonn sé próisis bhreise a thosaítear leis an seisiún. |
| `~/.config/omarchy/shell.json` | Rialaíonn sé sliogán Omarchy: suíomh an bharra, leagan amach, agus giuirléidí, móide amanna an scáileáin shábhála, an ghlais, agus na tréimhse díomhaoin. |
| `~/.config/foot/foot.ini` | Rialaíonn sé do theirminéal (is é foot an réamhshocrú). |
| `~/.XCompose` | Sainíonn sé d'emoji mear-rochtana agus d'uathchríochnú ainm/ríomhphoist. Bí cinnte `omarchy-restart-xcompose` a rith tar éis duit athruithe a dhéanamh. |

Má dhéanann tú go leor athruithe sa deireadh chun do shocrú féin a mhionchoigeartú, is smaoineamh maith é cúltaca a dhéanamh de na dotfiles seo go léir. [Is bealach iontach é Stow chun é sin a dhéanamh](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Ag tosú d'fheidhmchláir féin leis an seisiún

Más mian leat go rithfeadh rud éigin gach uair a logálann tú isteach — deamhan sioncronaithe, feidhmchlár comhrá, do script féin — cuir in `~/.config/hypr/autostart.lua` é:

```lua
o.launch_on_start("my-service")
```

Tosaíonn sé sin an t-ordú mar chuid den seisiún, agus mar sin glantar i gceart é nuair a logálann tú amach arís.

### Scripteanna a rith ar imeachtaí córais

Cuireann Omarchy crúcaí ar siúl ag corrláimhe tráthanna, agus is féidir leat do scripteanna féin a chrochadh orthu. Cónaíonn siad in `~/.config/omarchy/hooks/<event>.d/`, eolaire amháin in aghaidh an imeachta, agus ritheann gach comhad inrite atá ann nuair a tharlaíonn an t-imeacht:

| Imeacht | Cathain a ritheann sé |
| ----- | ------------ |
| `post-boot` | Díreach tar éis don deasc a bheith tosaithe |
| `post-update` | Ag druidim le deireadh `omarchy update`, tar éis pacáistí, imircí, agus atosuithe seirbhíse, sula ndéantar uirlisí mise a nuashonrú |
| `pre-refresh-pacman` | Tar éis do `omarchy refresh pacman` cumraíocht na bpacáistí a athshioncronú, sula ndéanann sé pacáistí a nuashonrú; ritheann athrú cainéil é le linn na céime athnuachana céanna sin |
| `theme-set` | Tar éis athrú téama (ainm an téama in `$1`) |
| `font-set` | Tar éis athrú cló (ainm an chló in `$1`) |
| `battery-low` | Nuair a éiríonn an ceallraí íseal (an céatadán in `$1`) |

Is é an crúca `pre-refresh-pacman` an áit ar cheart stórtha saincheaptha nó línte `IgnorePkg` a chur, ós rud é go ritheann sé roimh idirbheart na bpacáistí. Ritheann an dá chrúca a bhaineann le nuashonrú mar d'úsáideoir tar éis do Omarchy a údarú sudo taiscthe a ghlanadh, mar sin teastaíonn a údarú féin ó chrúca a úsáideann `sudo` agus d'fhéadfadh sé d'fhocal faire a iarraidh ort.

Tá comhad `.sample` i ngach ceann de na heolairí sin cheana a thaispeánann cruth crúca — bain an `.sample` den ainm chun é a chur ag obair. Chun script atá scríofa agat in áit eile a shuiteáil, bain úsáid as `omarchy hook install post-boot ~/my-hook`, a chóipeálann isteach é agus a dhéanann inrite é.

### Do roghanna roghchláir féin a chur leis

Is féidir an roghchlár Omarchy (`Super + Space`) a leathnú le do shraitheanna féin trí `~/.config/omarchy/extensions/omarchy-menu.jsonc` a chur in eagar. Déantar eochair de chuid na n-iontrálacha le id poncaithe, agus is é an id a chuireann sa chrann iad, mar sin taispeántar `personal` ar an roghchlár fréimhe agus taispeántar `personal.notes` taobh istigh de:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Athúsáid id atá ann cheana agus forscríobhfaidh tú an tsraith sin in ionad ceann nua a chur leis. Tagann an comhad le gach réimse atá ar fáil doiciméadaithe mar nótaí tráchta.

### Do chuid onnmhairithe, feidhmeanna, agus ailiasanna sliogáin féin a chur leis

Tagann Omarchy le lear ailiasanna eirgeanamaíochta agus feidhmeanna cabhracha, ach is an-choitianta é gur mhaith leat do chinn féin a chur leis. Ba cheart duit ailiasanna, feidhmeanna, agus onnmhairithe araon a chur in `~/.bashrc`. Ní fhorscríobhfar an comhad seo le nuashonruithe. Más mian leat aon cheann de réamhshocruithe Omarchy a athrú, is féidir leat iad a chur anseo go sábháilte freisin.

### Comhaid inmheánacha Omarchy a athrú

Féach, is leatsa an ríomhaire seo. Is féidir leat pé rud is mian leat a dhéanamh leis, ach mholfainn duit gan athruithe a dhéanamh ar na comhaid in `/usr/share/omarchy` go díreach. Baineann siad le pacáiste pacman Omarchy, mar sin forscríobhfar do chuid athruithe go simplí ag an gcéad nuashonrú eile. Is fearr duit go mór aon luach réamhshocraithe nach maith leat a fhorscríobh san fhillteán `~/.config/*` ina ionad.

Is féidir leat beagnach gach rud a athrú ar an mbealach sin, amhail na ceangail eochrach réamhshocraithe. Níl le déanamh ach `~/.config/hypr/bindings.lua` a chur in eagar chun, abair, [Joplin](https://joplinapp.org/) a chur in ionad [Obsidian](https://obsidian.md/) (suiteáil le `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Baineann `o.rebind` an ceangal atá ann cheana sula gcuireann sé a ionad leis. Glacann sé na hargóintí céanna le `o.bind`, lena n-áirítear cabhróirí seolta agus roghanna ceangail. Bain úsáid as `o.bind` chun ceangal a chur leis, nó as `hl.unbind` chun ceann a bhaint gan ceann a chur ina ionad.

Má tá tú meáite ar hackáil a dhéanamh ar chomhaid inmheánacha Omarchy, aistrigh go dtí an cainéal dev trí _Update > Channel > Dev_. Nascann sé sin Omarchy le seiceáil amach git den chód foinse in `~/omarchy`, a bhfuil cead do chroí agat a athrú mar is mian leat. Níl aon duine anseo chun a rá leat cad ba cheart duit a dhéanamh!

### Aon athruithe a athshocrú

Má dhéanann tú praiseach de na cumraíochtaí sa deireadh, is féidir leat iad a chur ar ais go dtí na réamhshocruithe i gcónaí trí _Update > Config_ sa roghchlár Omarchy. Nó trí `omarchy reinstall configs` a rith chun gach rud a athshocrú.
