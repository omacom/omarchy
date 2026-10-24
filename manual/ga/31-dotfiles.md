# Dotfiles

Cumraítear Omarchy go príomha trí na dotfiles mar a thugtar orthu a chónaíonn in `~/.config`. Meastar gur leatsa iad sin le haghaidh d'athruithe. Baineann na comhaid a chónaíonn in `/usr/share/omarchy` le Omarchy féin, agus níor chóir duit a bheith ag cur isteach orthu. Más gá duit rud ar bith in `/usr/share/omarchy` a athrú, ba chóir duit an luach in `~/.config` a fhor-scríobh ina ionad.

Is féidir na príomhchumraíochtaí a chur in eagar díreach ón roghchlár Omarchy (`Super + Space`), ar nós _Socrú > Monatóirí_, _Socrú > Naisc Eochrach_, _Socrú > Ionchur_, agus _Socrú > Cumraíocht > [file]_. Nuair a dhéanann tú amhlaidh, déanfar aon phróiseas a chaithfidh atosú tar éis athruithe cumraíochta go huathoibríoch tar éis duit an t-eagarthóir a fhágáil (Neovim de réir réamhshocraithe — `:wq`, cuimhnigh! — ach is féidir leat é sin a athrú trí _Socrú > Réamhshocruithe > Eagarthóir_).

Seo liosta de na príomhchomhaid in `~/.config` agus cad a rialaíonn siad:

| Comhad                  | Cuspóir              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | An phríomhchumraíocht Hyprland. Lódálann sé réamhshocruithe Omarchy móide do chomhaid sáraithe thíos. [Foghlaim níos mó faoi chumraíochtaí Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Do naisc eochrach féin agus sáruithe ar na réamhshocruithe. |
| `~/.config/hypr/monitors.lua` | Rialaíonn sé do mhonatóirí, taifeach, agus suíomh. |
| `~/.config/hypr/input.lua` | Rialaíonn sé leagan amach do mhéarchláir, luch, agus socruithe eochaircheapa. |
| `~/.config/hypr/looknfeel.lua` | Rialaíonn sé bearnaí, teorainneacha, beochana, agus an chuid eile den chuma. |
| `~/.config/hypr/autostart.lua` | Rialaíonn sé próisis bhreise a thosaíodh leis an seisiún. |
| `~/.config/omarchy/shell.json` | Rialaíonn sé blaosc Omarchy: suíomh barra, leagan amach, agus giuirléidí, móide uainiúcháin choigilteora scáileáin, glasa, agus díomhaoin. |
| `~/.config/foot/foot.ini` | Rialaíonn sé do theirminéal (is é foot an réamhshocrú). |
| `~/.XCompose` | Sainmhíníonn sé do emoji rochtana gasta agus uathchríochnú ainm/ríomhphoist. Cinntigh go rithfidh tú `omarchy-restart-xcompose` tar éis athruithe a dhéanamh. |

Má dhéanann tú a lán athruithe chun do shocrú féin a mhionathrú, is smaoineamh maith é cúltaca a dhéanamh de na dotfiles seo go léir. [Is bealach iontach é Stow chun é sin a dhéanamh](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### D'aipeanna féin a thosú leis an seisiún

Más mian leat go ritheann rud éigin gach uair a logáilann tú isteach — deamhan sioncronaithe, aip comhrá, do script féin — cuir in `~/.config/hypr/autostart.lua` é:

```lua
o.launch_on_start("my-service")
```

Tosaíonn sé sin an t-ordú mar chuid den seisiún, mar sin déantar é a ghlanadh i gceart nuair a logáilann tú amach arís.

### Scriptí a rith ar theagmhais chórais

Scaoileann Omarchy crúcaí ag dornán tráthanna, agus is féidir leat do scriptí féin a chrochadh díobh. Cónaíonn siad in `~/.config/omarchy/hooks/<event>.d/`, eolaire amháin in aghaidh an teagmhais, agus ritheann gach comhad inrite ann nuair a tharlaíonn an teagmhas:

| Teagmhas | Cathain a ritheann sé |
| ----- | ------------ |
| `post-boot` | Díreach tar éis don deasc tosú |
| `post-update` | Ag druidim le deireadh `omarchy update`, tar éis pacáistí, imircí, agus atosuithe seirbhíse, sula nuashonraítear uirlisí mise |
| `pre-refresh-pacman` | Tar éis do `omarchy refresh pacman` cumraíocht an phacáiste a athshioncronú, sula nuashonraíonn sé pacáistí; ritheann athrú bealaigh é le linn an chéim athnuachan chéanna sin |
| `theme-set` | Tar éis athrú téama (ainm téama in `$1`) |
| `font-set` | Tar éis athrú cló (ainm cló in `$1`) |
| `battery-low` | Nuair a éiríonn an ceallraí íseal (céatadán in `$1`) |

Is é an crúca `pre-refresh-pacman` an áit a mbaineann stórais saincheaptha nó línte `IgnorePkg`, ós rud é go ritheann sé roimh idirbheart an phacáiste. Ritheann an dá chrúca a bhaineann le nuashonrú mar d'úsáideoir tar éis do Omarchy a údarú sudo taiscthe a ghlanadh, mar sin teastaíonn a údarú féin ó chrúca a úsáideann `sudo` agus b'fhéidir go n-iarriaidh sé do phasfhocal.

Tá comhad `.sample` i ngach ceann de na heolairí sin cheana ag taispeáint cruth crúca — bain an `.sample` den ainm chun é a chur ag obair. Chun script a scríobh tú áit eile a shuiteáil, úsáid `omarchy hook install post-boot ~/my-hook`, rud a chóipeálann isteach é agus a dhéanann inrite é.

### Do iontrálacha roghchláir féin a chur leis

Is féidir roghchlár Omarchy (`Super + Space`) a leathnú le do rónna féin trí `~/.config/omarchy/extensions/omarchy-menu.jsonc` a chur in eagar. Déantar iontrálacha a eochair le id poncáilte, agus is é an id a chuireann iad sa chrann, mar sin taispeántar `personal` ar an bhfréamhroghchlár agus taispeántar `personal.notes` taobh istigh de:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Athúsáid id reatha agus sáraíonn tú an ró sin in ionad ceann nua a chur leis. Tagann an comhad leis na réimsí go léir atá ar fáil doiciméadaithe mar thréithe.

### Do easpórtálacha, feidhmeanna, agus ailiasanna blaoisce féin a chur leis

Tagann Omarchy le go leor ailiasanna eirgeanamaíochta agus feidhmeanna cabhracha, ach tá sé an-choitianta a bheith ag iarraidh do chinn féin a chur leis. Ba chóir duit ailiasanna, feidhmeanna, agus easpórtálacha a chur in `~/.bashrc`. Ní fhor-scríobhfar an comhad seo ar nuashonruithe. Más mian leat aon cheann de réamhshocruithe Omarchy a athrú, is féidir leat iad a chur anseo go sábháilte freisin.

### Comhaid inmheánacha Omarchy a athrú

Féach, is leatsa an ríomhaire seo. Is féidir leat cibé rud is mian leat a dhéanamh leis, ach chomhairlínn gan athruithe a dhéanamh ar na comhaid in `/usr/share/omarchy` go díreach. Baineann siad le pacáiste pacman Omarchy, mar sin ní dhéanfar ach d'athruithe a fhor-scríobh ar an gcéad nuashonrú eile. B'fhearr duit aon luachanna réamhshocraithe nach dtaitníonn leat a fhor-scríobh san fhillteán `~/.config/*` ina ionad.

Is féidir leat beagnach gach rud a athrú ar an mbealach sin, ar nós na naisc eochrach réamhshocraithe. Cuir `~/.config/hypr/bindings.lua` in eagar chun, abair, [Joplin](https://joplinapp.org/) a chur in ionad [Obsidian](https://obsidian.md/) (suiteáil le `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Baineann `o.rebind` an nasc reatha sula gcuireann sé a ionadach leis. Glacann sé na hargóintí céanna le `o.bind`, lena n-áirítear cúntóirí lainseála agus roghanna nasctha. Úsáid `o.bind` chun nasc a chur leis, nó `hl.unbind` chun ceann a bhaint gan é a ionadú.

Má áitíonn tú ar chomhaid inmheánacha Omarchy a hacáil, aistrigh chuig an mbealach dev trí _Nuashonraigh > Bealach > Dev_. Nascann sé sin Omarchy le seiceáil amach git den chód foinse in `~/omarchy`, ar féidir leat é a athrú mar is mian leat. Níl aon duine anseo chun a insint duit cad atá le déanamh!

### Aon athruithe a athshocrú

Má dhéanann tú praiseach de na cumraíochtaí sa deireadh, is féidir leat iad a aischur chuig na réamhshocruithe i gcónaí trí _Nuashonraigh > Cumraíocht_ sa roghchlár Omarchy. Nó trí `omarchy reinstall configs` a rith chun gach rud a athshocrú.
