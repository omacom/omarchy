# Dotfiles

Cumraítear Omarchy go príomha trí na dotfiles, mar a thugtar orthu, atá i `~/.config`. Meastar gur leatsa na comhaid sin le haghaidh do chuid athruithe. Is le Omarchy féin na comhaid atá in `/usr/share/omarchy`, agus níor cheart duit a bheith ag cur isteach orthu siúd. Más gá duit rud ar bith in `/usr/share/omarchy` a athrú, ba cheart duit an luach a fhorscríobh in `~/.config` ina ionad.

Is féidir na príomhchumraíochtaí a chur in eagar go díreach ó roghchlár Omarchy (`Super + Space`), mar shampla _Socruithe > Méarchlár > Ceangail Eochrach_, _Socruithe > Ionchur_, agus _Socruithe > Cumraíocht > [file]_. Nuair a dhéanann tú ar an mbealach seo é, atosófar go huathoibríoch aon phróiseas ar gá é a atosú tar éis eagarthóireachta cumraíochta nuair a fhágann tú an t-eagarthóir (Neovim de réir réamhshocraithe — `:wq`, cuimhnigh! — ach is féidir leat é sin a athrú trí _Socruithe > Réamhshocruithe > Eagarthóir_).

Seo liosta de na príomhchomhaid in `~/.config` agus a rialaíonn siad:

| Comhad | Cuspóir |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | An phríomhchumraíocht Hyprland. Lódálann sí réamhshocruithe Omarchy móide do chomhaid fhorscríofa thíos. [Tuilleadh eolais faoi chumraíochtaí Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Do cheangail eochrach féin agus forscríobha ar na réamhshocruithe. |
| `~/.config/hypr/monitors.lua` | Socruithe monatóra nach gclúdaíonn painéal an mhonatóra, amhail rothlú, móid bhreise, nó monatóir a choinneáil múchta. |
| `~/.config/hypr/input.lua` | Rialaíonn sé leagan amach do mhéarchláir, do luchóg, agus socruithe do thaipéid. |
| `~/.config/hypr/looknfeel.lua` | Rialaíonn sé bearnaí, imill, beochan, agus an chuid eile den chuma. |
| `~/.config/hypr/autostart.lua` | Rialaíonn sé próisis bhreise a thosaítear leis an seisiún. |
| `~/.config/omarchy/shell.json` | Rialaíonn sé blaosc Omarchy: suíomh an bharra, an leagan amach, agus na giuirléidí, móide uainiúcháin an spárálaí scáileáin, an ghlais, agus an díomhaointis. |
| `~/.config/foot/foot.ini` | Rialaíonn sé do theirminéal (is é foot an réamhshocrú). |
| `~/.XCompose` | Sainmhíníonn sé d'emoji mhearrochtana agus d'uathchríochnú ainm/ríomhphoist. Bí cinnte `omarchy-restart-xcompose` a rith tar éis duit athruithe a dhéanamh. |

Má dhéanann tú go leor athruithe sa deireadh chun do shocrú féin a mhionathrú, is smaoineamh maith é cúltaca a dhéanamh de na dotfiles seo go léir. [Is bealach iontach é Stow chun é sin a dhéanamh](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### D'aipeanna féin a thosú leis an seisiún

Más mian leat rud éigin a rith gach uair a logálann tú isteach — deamhan sioncronaithe, aip chomhrá, do script féin — cuir in `~/.config/hypr/autostart.lua` é:

```lua
o.launch_on_start("my-service")
```

Tosaíonn sé sin an t-ordú mar chuid den seisiún, mar sin glantar suas i gceart é nuair a logálann tú amach arís.

### Scripteanna a rith ar theagmhais chórais

Cuireann Omarchy crúcaí i ngníomh ag roinnt moma intí, agus is féidir leat do scripteanna féin a chrochadh orthu. Tá siad in `~/.config/omarchy/hooks/<event>.d/`, eolaire amháin in aghaidh an teagmhais, agus ritheann gach comhad ann nach gcríochnaíonn le `.sample` le bash nuair a tharlaíonn an teagmhas:

| Teagmhas | Cathain a ritheann sé |
| ----- | ------------ |
| `post-boot` | Díreach tar éis don deasc a bheith tosaithe |
| `post-update` | Ag druidim le deireadh `omarchy update`, tar éis pacáistí, aistrithe, agus atosuithe seirbhíse, sula ndéantar uirlisí mise a nuashonrú |
| `pre-refresh-pacman` | Tar éis do `omarchy refresh pacman` cumraíocht na bpacáistí a athshioncronú, sula ndéanann sé pacáistí a nuashonrú; ritheann athrú cainéil é le linn na céime athnuachana céanna sin |
| `theme-set` | Tar éis athrú téama (ainm an téama in `$1`) |
| `font-set` | Tar éis athrú cló (ainm an chló in `$1`) |
| `battery-low` | Nuair a éiríonn an ceallraí íseal (an céatadán in `$1`) |

Is sa chrúca `pre-refresh-pacman` a bhaineann stórtha saincheaptha nó línte `IgnorePkg`, ó ritheann sé roimh idirbheart na bpacáistí. Ritheann an dá cheann mar d'úsáideoir. Ritheann `post-update` fad atá údarú sudo `omarchy update` fós úr, mar sin ní iarrfaidh crúca a úsáideann `sudo` d'fhocal faire arís ort; ritheann `pre-refresh-pacman` díreach tar éis do `omarchy refresh pacman` sudo a úsáid é féin.

Tá comhad `.sample` i ngach ceann de na heolairí sin cheana a thaispeánann cruth crúca — bain an `.sample` den ainm chun é a chur ag obair. Chun script atá scríofa agat in áit eile a shuiteáil, úsáid `omarchy hook install post-boot ~/my-hook`, a chóipeálann isteach é agus a dhéanann inrite é.

### Do hiontrálacha roghchláir féin a chur leis

Is féidir roghchlár Omarchy (`Super + Space`) a leathnú le do róna féin trí `~/.config/omarchy/extensions/omarchy-menu.jsonc` a chur in eagar. Tá iontrálacha eochraithe ag aitheantas poncáilte, agus is é an t-aitheantas a chuireann sa chrann iad, mar sin taispeántar `personal` ar an roghchlár fréimhe agus taispeántar `personal.notes` laistigh de:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Má athúsáideann tú aitheantas atá ann cheana, forscríobhfaidh tú an ró sin in ionad ceann nua a chur leis. Tagann an comhad agus na réimsí go léir atá ar fáil doiciméadaithe mar nótaí tráchta ann.

### D'easpórtálacha, feidhmeanna, agus ailiasanna blaosc féin a chur leis

Tagann roinnt mhaith ailiasanna eirgeanamaíochta agus feidhmeanna cabhracha le Omarchy, ach is an-choitianta é gur mian leat do chinn féin a chur leis. Ba cheart duit ailiasanna, feidhmeanna, agus easpórtálacha araon a chur in `~/.bashrc`. Ní fhorscríobhfar an comhad seo ar nuashonruithe. Más mian leat aon cheann de réamhshocruithe Omarchy a athrú, is féidir leat iad a chur anseo go sábháilte freisin.

### Athróga timpeallachta a shocrú don deasc

Is in `~/.config/uwsm/env.d/` a bhaineann easpórtálacha seisiúin deisce. Ritheann na comhaid seo sula dtosaíonn do deasc, mar sin is féidir le hearráid bhlaosc tú a sheoladh ar ais go dtí scáileán na logála isteach. Coinnigh teirminéal atá ag obair ar oscailt fad a bhíonn tú á gcur in eagar. Chun forscríobh a dhíchumasú, bog amach as `env.d` é. Féach [aisghabháil logála isteach](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) má chuireann athrú cosc ar logáil isteach.

### Comhaid inmheánacha Omarchy a athrú

Féach, is leatsa an ríomhaire seo. Is féidir leat cibé rud is mian leat a dhéanamh leis, ach mholfainn duit gan athruithe a dhéanamh ar na comhaid in `/usr/share/omarchy` go díreach. Is le pacáiste pacman Omarchy iad, mar sin forscríobhfar do chuid athruithe go simplí ar an gcéad nuashonrú eile. B'fhearr duit aon luachanna réamhshocraithe nach dtaitníonn leat a fhorscríobh san fhillteán `~/.config/*` ina ionad.

Is féidir leat beagnach gach rud a athrú ar an mbealach sin, amhail na ceangail eochrach réamhshocraithe. Níl le déanamh ach `~/.config/hypr/bindings.lua` a chur in eagar chun, abair, [Obsidian](https://obsidian.md/) a mhalartú le [Joplin](https://joplinapp.org/) (suiteáil le `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Bainann `o.rebind` an ceangal atá ann cheana sula gcuireann sé a ionad leis. Glacann sé na hargóintí céanna le `o.bind`, lena n-áirítear cúntóirí seolta agus roghanna ceangail. Úsáid `o.bind` chun ceangal a chur leis, nó `hl.unbind` chun ceann a bhaint gan ceann a chur ina ionad.

Má sheasann tú ar hackáil a dhéanamh ar chomhaid inmheánacha Omarchy, athraigh go dtí an cainéal dev trí _Nuashonrú > Cainéal > Dev_. Nascann sé sin Omarchy le seiceáil amach git den chód foinseach in `~/omarchy`, a bhfuil cead do chroí agat a athrú. Níl aon duine anseo chun a rá leat cad ba cheart duit a dhéanamh!

### Aon athruithe a athshocrú

Má dhéanann tú praiseach de na cumraíochtaí sa deireadh, is féidir leat iad a chur ar ais go dtí na réamhshocruithe i gcónaí trí _Nuashonrú > Cumraíocht_ i roghchlár Omarchy. Nó trí `omarchy reinstall configs` a rith chun gach rud a athshocrú.
