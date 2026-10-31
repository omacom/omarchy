# Dotfiles

Cumraítear Omarchy go príomha trí na dotfiles mar a thugtar orthu a chónaíonn i `~/.config`. Meastar gur leatsa na comhaid sin le haghaidh do chuid athruithe. Baineann na comhaid a chónaíonn in `/usr/share/omarchy` le Omarchy féin, agus níor chóir duit a bheith ag útamáil leo. Más gá duit rud ar bith a athrú in `/usr/share/omarchy`, ba cheart duit an luach a fhorscríobh in `~/.config` ina ionad.

Is féidir na príomhchumraíochtaí a chur in eagar go díreach ó roghchlár Omarchy (`Super + Space`), mar _Setup > Keybindings_, _Setup > Input_, agus _Setup > Config > [file]_. Nuair a dhéanann tú ar an mbealach seo é, atosófar go huathoibríoch aon phróiseas a chaithfear a atosú tar éis eagarthóireachtaí cumraíochta tar éis duit an t-eagarthóir a fhágáil (Neovim de réir réamhshocraithe — `:wq`, cuimhnigh! — ach is féidir leat é sin a athrú via _Setup > Defaults > Editor_).

Seo liosta de na príomhchomhaid in `~/.config` agus an rud a rialaíonn siad:

| Comhad                  | Cuspóir              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | An phríomhchumraíocht Hyprland. Lódálann sí réamhshocruithe Omarchy móide do chomhaid fhorscríofa thíos. [Foghlaim tuilleadh faoi chumraíochtaí Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Do cheangail eochrach féin agus forscríobha ar na réamhshocruithe. |
| `~/.config/hypr/monitors.lua` | Socruithe monatóra nach gclúdaíonn an painéal monatóra, mar rothlú, modhanna breise, nó monatóir a choinneáil múchta. |
| `~/.config/hypr/input.lua` | Rialaíonn sé leagan amach do mhéarchláir, do lucha, agus socruithe do thaipéid. |
| `~/.config/hypr/looknfeel.lua` | Rialaíonn sé bearnaí, teorainneacha, beochana, agus an chuid eile den chuma. |
| `~/.config/hypr/autostart.lua` | Rialaíonn sé próisis bhreise a thosaítear leis an seisiún. |
| `~/.config/omarchy/shell.json` | Rialaíonn sé blaosc Omarchy: suíomh an bharra, leagan amach, agus giuirléidí, móide amanna an scáileáin choigilte, an ghlais, agus na neamhghníomhaíochta. |
| `~/.config/foot/foot.ini` | Rialaíonn sé do theirminéal (is é foot an réamhshocrú). |
| `~/.XCompose` | Sainíonn sé d'emoji mear-rochtana agus d'uathchríochnú ainm/ríomhphoist. Bí cinnte `omarchy-restart-xcompose` a rith tar éis duit athruithe a dhéanamh. |

Má dhéanann tú a lán athruithe sa deireadh chun do shocrú féin a mhionchoigeartú, is smaoineamh maith é cúltaca a dhéanamh de na dotfiles seo go léir. [Is bealach iontach é Stow chun é sin a dhéanamh](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### D'fheidhmchláir féin a thosú leis an seisiún

Má theastaíonn uait go rithfeadh rud éigin gach uair a logálann tú isteach — deamhan sioncronaithe, feidhmchlár comhrá, do script féin — cuir in `~/.config/hypr/autostart.lua` é:

```lua
o.launch_on_start("my-service")
```

Cuireann sin tús leis an ordú mar chuid den seisiún, agus mar sin glantar i gceart é nuair a logálann tú amach arís.

### Scripteanna a rith ar imeachtaí córais

Scaoileann Omarchy crúcaí ag dornán nóiméad, agus is féidir leat do scripteanna féin a chrochadh orthu. Cónaíonn siad in `~/.config/omarchy/hooks/<event>.d/`, eolaire amháin in aghaidh an imeachta, agus ritheann gach comhad inrite atá ann nuair a tharlaíonn an t-imeacht:

| Imeacht | Cathain a ritheann sé |
| ----- | ------------ |
| `post-boot` | Díreach tar éis don deasc a bheith tosaithe |
| `post-update` | Gar do dheireadh `omarchy update`, tar éis pacáistí, imircí, agus atosuithe seirbhíse, sula ndéantar uirlisí mise a nuashonrú |
| `pre-refresh-pacman` | Tar éis do `omarchy refresh pacman` cumraíocht na bpacáistí a athshioncronú, sula ndéanann sé pacáistí a nuashonrú; ritheann athrú cainéil é le linn na céime athnuachana céanna sin |
| `theme-set` | Tar éis athrú téama (ainm an téama in `$1`) |
| `font-set` | Tar éis athrú cló (ainm an chló in `$1`) |
| `battery-low` | Nuair a éiríonn an ceallraí íseal (céatadán in `$1`) |

Is é crúca `pre-refresh-pacman` an áit a mbaineann stórtha saincheaptha nó línte `IgnorePkg`, ós rud é go ritheann sé roimh idirbheart na bpacáistí. Ritheann an dá chrúca a bhaineann le nuashonrú mar d'úsáideoir tar éis do Omarchy a údarú sudo taiscthe a ghlanadh, mar sin teastaíonn a údarú féin ó chrúca a úsáideann `sudo` agus féadfaidh sé d'fhocal faire a iarraidh.

Tá comhad `.sample` i ngach ceann de na heolairí sin cheana féin a thaispeánann cruth crúca — bain an `.sample` den ainm chun é a chur ag obair. Chun script atá scríofa agat in áit eile a shuiteáil, úsáid `omarchy hook install post-boot ~/my-hook`, a chóipeálann isteach é agus a dhéanann inrite é.

### Do chuid iontrálacha roghchláir féin a chur leis

Is féidir roghchlár Omarchy (`Super + Space`) a leathnú le do shraitheanna féin trí `~/.config/omarchy/extensions/omarchy-menu.jsonc` a chur in eagar. Tá iontrálacha eochraithe le haitheantas poncaithe, agus is é an t-aitheantas a chuireann sa chrann iad, agus mar sin taispeántar `personal` ar an roghchlár fréimhe agus taispeántar `personal.notes` laistigh de:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Athúsáid aitheantas atá ann cheana agus forscríobhann tú an tsraith sin in ionad ceann nua a chur leis. Tagann an comhad le gach réimse atá ar fáil doiciméadaithe mar thráchtaí.

### Do chuid onnmhairí, feidhmeanna agus ailiasanna blaosc féin a chur leis

Tagann Omarchy le dornán ailiasanna eirgeanamaíocha agus feidhmeanna cabhracha, ach is an-choitianta é gur mian leat do chuid féin a chur leis. Ba cheart duit ailiasanna, feidhmeanna agus onnmhairí araon a chur in `~/.bashrc`. Ní fhorscríobhfar an comhad seo ar nuashonruithe. Más mian leat aon cheann de réamhshocruithe Omarchy a athrú, is féidir leat iad a chur anseo go sábháilte freisin.

### Athróga timpeallachta a shocrú don deasc

Baineann onnmhairí seisiúin deisce le `~/.config/uwsm/env.d/`. Ritheann na comhaid seo sula dtosaíonn do deasc, agus mar sin féadfaidh earráid bhlaosc tú a sheoladh ar ais chuig an scáileán logáil isteach. Coinnigh teirminéal atá ag obair ar oscailt agus tú á gcur in eagar. Chun forscríobh a dhíchumasú, bog amach as `env.d` é. Féach [aisghabháil logáil isteach](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) má chuireann athrú cosc ar logáil isteach.

### Comhaid inmheánacha Omarchy a athrú

Féach, is leatsa an ríomhaire seo. Is féidir leat cibé rud is mian leat a dhéanamh leis, ach mholfainn duit gan athruithe a dhéanamh ar na comhaid in `/usr/share/omarchy` go díreach. Baineann siad le pacáiste pacman Omarchy, agus mar sin forscríobhfar do chuid athruithe go simplí ar an gcéad nuashonrú eile. B'fhearr duit aon luachanna réamhshocraithe nach maith leat a fhorscríobh san fhillteán `~/.config/*` ina ionad.

Is féidir leat beagnach gach rud a athrú ar an mbealach sin, mar na ceangail eochrach réamhshocraithe. Cuir `~/.config/hypr/bindings.lua` in eagar chun, abair, [Obsidian](https://obsidian.md/) a ionadú le [Joplin](https://joplinapp.org/) (suiteáil le `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Baineann `o.rebind` an ceangal atá ann cheana sula gcuireann sé a ionad leis. Glacann sé na hargóintí céanna le `o.bind`, lena n-áirítear cúntóirí seolta agus roghanna ceangailte. Úsáid `o.bind` chun ceangal a chur leis, nó `hl.unbind` chun ceann a bhaint gan é a ionadú.

Má éilíonn tú a bheith ag hacáil ar chomhaid inmheánacha Omarchy, aistrigh chuig an gcainéal dev via _Update > Channel > Dev_. Nascann sé sin Omarchy le seiceáil amach git den chód foinse in `~/omarchy`, a bhfuil cead agat a athrú mar is mian le do chroí. Níl éinne anseo chun a rá leat cad ba cheart duit a dhéanamh!

### Aon athruithe a athshocrú

Má dhéanann tú praiseach de na cumraíochtaí sa deireadh, is féidir leat iad a thabhairt ar ais chuig na réamhshocruithe i gcónaí via _Update > Config_ i roghchlár Omarchy. Nó trí `omarchy reinstall configs` a rith chun gach rud a athshocrú.
