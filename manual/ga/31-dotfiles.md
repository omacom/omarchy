# Dotfiles

Is trí na dotfiles mar a thugtar orthu a chónaíonn in `~/.config` a chumraítear Omarchy go príomha. Meastar gur leatsa na comhaid sin le haghaidh do chuid athruithe féin. Baineann na comhaid a chónaíonn in `/usr/share/omarchy` le Omarchy féin, agus níor chóir duit a bheith ag cur isteach orthu siúd. Más gá duit rud ar bith in `/usr/share/omarchy` a athrú, ba chóir duit an luach a fhorscríobh in `~/.config` ina ionad sin.

Is féidir na príomhchumraíochtaí a chur in eagar go díreach ó roghchlár Omarchy (`Super + Space`), amhail _Setup > Keyboard > Keybindings_, _Setup > Input_, agus _Setup > Config > [file]_. Nuair a dhéanann tú ar an mbealach seo é, atosófar go huathoibríoch aon phróiseas a chaithfear a atosú tar éis eagarthóireacht cumraíochta tar éis duit an t-eagarthóir a scor (Neovim de réir réamhshocraithe — `:wq`, cuimhnigh! — ach is féidir leat é sin a athrú trí _Setup > Defaults > Editor_).

Seo liosta de na príomhchomhaid in `~/.config` agus a rialaíonn siad:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | An phríomhchumraíocht Hyprland. Lódálann sí réamhshocruithe Omarchy móide do chomhaid fhorscríofa thíos. [Tuilleadh eolais faoi chumraíochtaí Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Do cheangail eochrach féin agus forscríbhinní ar na réamhshocruithe. |
| `~/.config/hypr/monitors.lua` | Socruithe monatóra nach gclúdaíonn painéal an mhonatóra, amhail rothlú, modhanna breise, nó monatóir a choinneáil múchta. |
| `~/.config/hypr/input.lua` | Rialaíonn sé leagan amach do mhéarchláir, do luch agus socruithe do thaipéid. |
| `~/.config/hypr/looknfeel.lua` | Rialaíonn sé bearnaí, imill, beochan, agus an chuid eile den chuma. |
| `~/.config/hypr/autostart.lua` | Rialaíonn sé próisis bhreise a thosaítear leis an seisiún. |
| `~/.config/omarchy/shell.json` | Rialaíonn sé blaosc Omarchy: suíomh an bharra, leagan amach, agus giuirléidí, móide uainiúcháin an tsábhálaí scáileáin, an ghlais, agus an díomhaointis. |
| `~/.config/foot/foot.ini` | Rialaíonn sé do theirminéal (is é foot an réamhshocrú). |
| `~/.XCompose` | Sainmhíníonn sé d'emoji mearrochtana agus uathchríochnú ainm/ríomhphoist. Bí cinnte `omarchy-restart-xcompose` a rith tar éis athruithe a dhéanamh. |

Má dhéanann tú go leor athruithe sa deireadh chun do shocrú féin a mhionchoigeartú, is smaoineamh maith é cúltaca a dhéanamh de na dotfiles seo go léir. [Is bealach iontach é Stow chun é sin a dhéanamh](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### D'aipeanna féin a thosú leis an seisiún

Más mian leat rud éigin a rith gach uair a logálann tú isteach — deamhain sioncronaithe, aip chomhrá, do script féin — cuir in `~/.config/hypr/autostart.lua` é:

```lua
o.launch_on_start("my-service")
```

Tosaíonn sé sin an t-ordú mar chuid den seisiún, mar sin glantar suas i gceart é nuair a logálann tú amach arís.

### Scripteanna a rith ar imeachtaí córais

Scaoileann Omarchy crúcaí ag dornán tráthanna, agus is féidir leat do scripteanna féin a chrochadh orthu. Cónaíonn siad in `~/.config/omarchy/hooks/<event>.d/`, eolaire amháin in aghaidh an imeachta, agus ritheann gach comhad inrite atá istigh ann nuair a tharlaíonn an t-imeacht:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Díreach tar éis don deasc a bheith tosaithe |
| `post-update` | Ag druidim le deireadh `omarchy update`, tar éis pacáistí, aistrithe, agus atosuithe seirbhíse, sula ndéantar uirlisí mise a nuashonrú |
| `pre-refresh-pacman` | Tar éis do `omarchy refresh pacman` cumraíocht na bpacáistí a athshioncronú, sula ndéanann sé pacáistí a nuashonrú; ritheann athrú cainéil é le linn an chéim athnuachana chéanna sin |
| `theme-set` | Tar éis athrú téama (ainm an téama in `$1`) |
| `font-set` | Tar éis athrú cló (ainm an chló in `$1`) |
| `battery-low` | Nuair a éiríonn an ceallraí íseal (céatadán in `$1`) |

Is sa chrúca `pre-refresh-pacman` a bhaineann stórtha saincheaptha nó línte `IgnorePkg`, ós rud é go ritheann sé roimh an idirbheart pacáiste. Ritheann an dá chrúca a bhaineann le nuashonrú mar d'úsáideoir tar éis do Omarchy a údarú sudo taiscthe a ghlanadh, mar sin teastaíonn a údarú féin ó chrúca a úsáideann `sudo` agus d'fhéadfadh sé d'fhocal faire a iarraidh.

Tá comhad `.sample` i ngach ceann de na heolairí sin cheana a thaispeánann cruth crúca — bain an `.sample` den ainm chun é a chur ag obair. Chun script atá scríofa agat in áit eile a shuiteáil, bain úsáid as `omarchy hook install post-boot ~/my-hook`, a chóipeálann isteach é agus a dhéanann inrite é.

### Do hiontrálacha roghchláir féin a chur leis

Is féidir roghchlár Omarchy (`Super + Space`) a leathnú le do shraitheanna féin trí `~/.config/omarchy/extensions/omarchy-menu.jsonc` a chur in eagar. Déantar iontrálacha a eochairiú le haitheantas poncaithe, agus is é an t-aitheantas a chuireann sa chrann iad, mar sin taispeántar `personal` ar an bhfréamhroghchlár agus taispeántar `personal.notes` laistigh de:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Athúsáid aitheantas atá ann cheana agus forscríobhann tú an tsraith sin in ionad ceann nua a chur leis. Tagann an comhad le gach réimse atá ar fáil doiciméadaithe mar thuairimí.

### D'easpórtálacha blaosc, feidhmeanna, agus ailiasanna féin a chur leis

Tagann Omarchy le bunch ailiasanna eirgeanamaíocha agus feidhmeanna cabhracha, ach is an-choitianta é gur mian leat do chinn féin a chur leis. Ba chóir duit ailiasanna, feidhmeanna, agus easpórtálacha araon a chur in `~/.bashrc`. Ní fhorscríobhfar an comhad seo ar nuashonruithe. Más mian leat aon cheann de réamhshocruithe Omarchy a athrú, is féidir leat iad a chur anseo go sábháilte freisin.

### Athróga timpeallachta a shocrú don deasc

Baineann easpórtálacha seisiúin deisce le `~/.config/uwsm/env.d/`. Ritheann na comhaid seo sula dtosaíonn do deasc, mar sin is féidir le hearráid blaosc tú a sheoladh ar ais go dtí an scáileán logála isteach. Coinnigh teirminéal atá ag obair ar oscailt agus tú á gcur in eagar. Chun forscríobh a dhíchumasú, bog amach as `env.d` é. Féach [aisghabháil logála isteach](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) má chuireann athrú cosc ar logáil isteach.

### Comhaid inmheánacha Omarchy a athrú

Féach, is leatsa an ríomhaire seo. Is féidir leat cibé rud is mian leat a dhéanamh leis, ach mholfainn duit gan athruithe a dhéanamh ar na comhaid in `/usr/share/omarchy` go díreach. Baineann siad le pacáiste pacman Omarchy, mar sin forscríobhfar do chuid athruithe go simplí ar an gcéad nuashonrú eile. B'fhearr duit aon réamhluachanna nach dtaitníonn leat a fhorscríobh san fhillteán `~/.config/*` ina ionad sin.

Is féidir leat beagnach gach rud a athrú ar an mbealach sin, amhail na ceangail eochrach réamhshocraithe. Níl le déanamh ach `~/.config/hypr/bindings.lua` a chur in eagar chun, abair, [Joplin](https://joplinapp.org/) a chur in ionad [Obsidian](https://obsidian.md/) (suiteáil le `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Baineann `o.rebind` an ceangal atá ann cheana sula gcuireann sé a ionadaí leis. Glacann sé na hargóintí céanna le `o.bind`, lena n-áirítear cúntóirí seolta agus roghanna ceangail. Bain úsáid as `o.bind` chun ceangal a chur leis, nó `hl.unbind` chun ceann a bhaint gan ceann a chur ina ionad.

Má éilíonn tú a bheith ag hacáil ar chomhaid inmheánacha Omarchy, aistrigh go dtí an cainéal dev trí _Update > Channel > Dev_. Nasctar Omarchy leis sin le seiceáil amach git den chód foinse in `~/omarchy`, a bhfuil cead agat a athrú mar is mian le do chroí. Níl aon duine anseo a déarfaidh leat cad atá le déanamh agat!

### Aon athruithe a athshocrú

Má dhéanann tú praiseach de na cumraíochtaí sa deireadh, is féidir leat iad a chur ar ais go dtí na réamhshocruithe i gcónaí trí _Update > Config_ i roghchlár Omarchy. Nó trí `omarchy reinstall configs` a rith chun gach rud a athshocrú.
