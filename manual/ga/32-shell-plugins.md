# Forlíontáin Blaoisce

Ritheann deasc Omarchy mar phróiseas Quickshell fadó amháin ar a dtugtar `omarchy-shell`, agus is forlíontán taobh istigh de beagnach gach rud a fheiceann tú ar an scáileán. Is forlíontán é an barra. Mar sin is iad na painéil a thiteann síos uaidh, na forleaganacha lánscáileáin ar nós an roghnóra emoji agus an bhainisteora gearrthaisce, roghchlár Omarchy féin, an scáileán glasa, an dialóg polkit, agus na seirbhísí gan cheann a fhéachann ar do cheallraí agus a théann do scáileán san oíche.

Ní mionsonra cur chun feidhme amháin é sin. Ciallaíonn sé gur féidir leat píosaí den deasc a mhúchadh, iad a mhalartú amach, nó do chuid féin a scríobh gan líne de fhoinse Omarchy a theagmháil.

Tagann na forlíontáin chéadpháirtí le Omarchy agus cónaíonn siad in `$OMARCHY_PATH/shell/plugins/`. Cónaíonn aon rud a chuireann tú leat féin — do thurgnaimh féin, nó rud éigin a fuair tú ar GitHub — in `~/.config/omarchy/plugins/`. Aimsítear an dá cheann ar an mbealach céanna ag am tosaithe, ach faigheann na cinn ionsuite comhéadain iontaofa blaoisce agus faigheann forlíontáin tríú páirtí comhéadan teoranta atá dírithe ar a seirbhís agus saolré féin. Coinníonn clóna ionsuite ach an chumraíocht shonrach don fhoinse agus glaonna UI atá ag teastáil don iompar bunaidh.

## Féachaint ar a bhfuil agat

```
omarchy plugin list
```

Clónn sé sin gach forlíontán aimsithe lena id, cibé acu an bhfuil sé cumasaithe, cibé acu an chéadpháirtí nó tríú páirtí é, a chineálacha, agus a ainm taispeána. Cuir `--json` leis más rud é go bhfuil tú á bheathú chuig rud eile.

Tá idanna forlíontáin ainmspásáite. Tosaíonn na cinn ionsuite go léir le `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — agus tá an t-ainmspás sin in áirithe, mar sin ní féidir le forlíontán tríú páirtí é a éileamh riamh.

## Iad a chur air agus a mhúchadh

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Nó úsáid an roghchlár: tá Enable, Disable, Add, Clone, agus Remove ag _Socrú > Forlíontáin_, gach ceann le roghnóir nach dtairgeann ach na forlíontáin a bhfuil ciall leo don ghníomh sin.

Stóráiltear staid chumasaithe in `~/.config/omarchy/shell.json`, agus tá an riail beagán difriúil don dá chineál forlíontáin. Tá forlíontán tríú páirtí cumasaithe go díreach nuair a thaispeántar a id áit éigin sa chomhad sin — mar iontráil leagan amach barra, mar iontráil in `plugins[]`, nó mar `bar.id`. Is ar an mbealach eile atá forlíontáin chéadpháirtí nach giuirléidí barra iad: tá siad air de réir réamhshocraithe agus ní mhúchtar iad ach trí bheith liostaithe in `disabledPlugins[]`.

Níl aon staid mhúchta ar bith ag forlíontán iomlán barra. Tá barra amháin go díreach ann i gcónaí, mar sin ionadaíonn tú é trí cheann eile a chumasú. Clúdaítear socrú giuirléidí barra in [an barra barr](05-the-top-bar.md).

## Forlíontán a chur leis ó git

Níl i bhforlíontán tríú páirtí ach stóras git le `manifest.json` ag a fhréamh.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Sula ndéanann sé rud ar bith, insíonn sé duit go soiléir go ritheann forlíontáin mar chód treallach neamh-sandboxáilte taobh istigh de do phróiseas blaoisce fadó, taispeánann sé an URL duit, agus iarrann sé ort deimhniú. Glac é sin dáiríre. Ní nochtann comhéadan forlíontáin tríú páirtí seirbhísí fíordheimhnithe go díreach, agus ní fhaigheann barra ionadach ach cumais teoranta le haghaidh UI neamh-fhíordheimhnithe cumraithe. Roinneann forlíontáin amhairc radharc QML na blaoisce fós agus is féidir leo gnáthrudaí tuismitheora a shiúl, agus ritheann gach cód forlíontáin le gach rud is féidir le do chuntas úsáideora a bhaint amach. Cosnaítear staid fíordheimhnithe ar leithligh trí na seirbhísí sin a choinneáil lasmuigh de ghraf rudaí óstach inrochtana. Ná cuir leis ach stórais atá tú toilteanach a rith, agus léigh iad sula gcumasaítear iad.

Is féidir le barra ionadach giuirléidí suiteáilte a rindreáil, ach d'fhéadfadh feidhmiúlacht laghdaithe a bheith ag giuirléidí tríú páirtí le tacaíocht seirbhíse ann toisc nach bhfuil cead ag an mbarra rud seirbhíse beo forlíontáin eile a iarraidh. Aistrigh ar ais chuig `omarchy.bar` ionsuite má tá a seirbhís choimhdeachta ag teastáil ó ghiuirléid dá sórt.

Ansin clónálann sé an stóras isteach in eolaire stáitsithe, bailíochtaíonn sé an manifest, diúltaíonn sé an tsuiteáil má éilíonn forlíontán eile an id sin cheana, agus bogann sé isteach in `~/.config/omarchy/plugins/<id>/` é. Gan `--enable` iarrann sé cibé acu ar mhaith leat é air anois, agus is féidir leat diúltú agus dul an cód a léamh ar dtús. Ní ritheann sé rud ar bith ón bhforlíontán riamh, ní fhorghníomhaíonn sé crúca suiteála riamh, agus ní iarrann sé sudo riamh — clónálann sé comhaid, seiceálann sé an manifest, agus casann sé giotán thar IPC.

Is éard is nuashonrú ann ná tarraingt ar aghaidh go tapa den seiceáil amach chéanna sin:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Gan id nuashonraíonn sé gach forlíontán atá á bhainistiú ag git atá agat. Taispeánann sé an diff duit sula gcuireann sé i bhfeidhm é, diúltaíonn sé nuashonrú má tá athruithe áitiúla agat nach féidir leis dul tharstu ar aghaidh go tapa, agus rollann sé ar ais má theipeann ar an athbhreithniú nua sa bhailíochtú.

```
omarchy plugin remove acme.weather
```

Díchumasaíonn baint an forlíontán ar dtús, ansin scriosann sé é más seiceáil amach git é (tá an stóras fós suas an sruth) nó dícheanglaíonn sé é más symlink é. Bogtar filleán forlíontáin lámhdhéanta gan stóras git chuig cúltaca le stampa ama taobh istigh d'eolaire na bhforlíontán in ionad é a scriosadh go hiomlán.

## Ionsuite a chlônáil chun é a mhodhnú

Seo an chuid is fearr liom. Más mian leat a athrú conas a iompraíonn giuirléid ionsuite é féin, ná cuir na comhaid faoi `$OMARCHY_PATH` in eagar — baineann siad sin leis an bpacáiste agus forscríobhfaidh an chéad nuashonrú eile iad. Clónáil é ina ionad:

```
omarchy plugin clone omarchy.clock
```

Cóipeálann sé sin an forlíontán iomlán isteach in `~/.config/omarchy/plugins/dhh.clock` (d'ainm úsáideora, ní m'ainmse), athainmníonn sé go "My Clock" é, cumasaíonn sé é, agus aistríonn sé an blaosc anonn ón gceann ionsuite chuig do chóipe — ag coimeád suíomh agus socruithe giuirléid barra reatha. Cuir `--edit` leis chun an eolaire nua a oscailt i do `$EDITOR` láithreach, rud a dhéanann _Socrú > Forlíontáin > Clone Plugin_ an roghchláir duit.

Coinníonn réimír an ainm úsáideora id do chlóna leatsa, mar sin ní imbhuaileann a chomhroinnt le haon duine eile. Déantar glaonna ar an id ionsuite bunaidh a ródú chuig do chlón, mar sin ní gá aon rud a thagair do `omarchy.clock` a nuashonrú. Agus má dhéanann tú praiseach de, cuireann `omarchy plugin remove dhh.clock` an ceann ionsuite ar ais.

Athlódálann sábháil comhaid áit ar bith faoi `~/.config/omarchy/plugins/` cód an fhorlíontáin go huathoibríoch, mar sin is féidir leat an t-eagarthóir a fhágáil ar oscailt agus féachaint ar d'athruithe ag teacht i dtír.

## Do chuid féin a scríobh

Is eolaire é forlíontán le `manifest.json` agus roinnt QML. Dearbhaíonn an manifest `schemaVersion: 1`, `id`, `name`, `version`, cineál amháin nó níos mó `kinds`, agus rud `entryPoints` ag díriú ar an gcomhad QML do gach cineál:

| Cineál | Cad é |
|------|------------|
| `bar-widget` | Comhpháirt is féidir leis an mbarra gníomhach a leagan isteach i roinn |
| `panel` | Fuinneog ar snámh leanúnach nó ar glaodh |
| `overlay` | Forleagan lánscáileáin |
| `menu` | Dromchla roghchláir ar glaodh |
| `service` | Singleton gan cheann gan UI |
| `bar` | Barra iomlán a ionadaíonn an ceann ionsuite |

Is féidir le forlíontán roinnt cineálacha a dhearbhú ag an am céanna — is `service` agus `bar-widget` araon é forlíontán na meán. Faigheann giuirléidí barra bloc breise `barWidget` le hainm taispeána, catagóir, `defaultSection` roghnach, agus `allowMultiple`, rud a deir cibé an bhfuil ciall níos mó ná ceann amháin a bheith ar an mbarra. Socraíonn formhór na ngiuirléidí go `false` é; socraíonn spásálaí agus táscairí go `true` é.

Sula bhfoilsíonn tú rud ar bith, seiceáil é:

```
omarchy plugin validate ./my-plugin
```

Ritheann sé sin na seiceálacha céanna a ritheann an blaosc ag am lódála: leagan na scéime, na réimsí riachtanacha, id nach bhfuil in áirithe, pointí iontrála atá ina gconairí coibhneasta sábháilte agus atá ann i ndáiríre, pointe iontrála do gach cineál a d'éiligh tú, agus gan symlinks áit ar bith taobh istigh den fhillteán.

Le haghaidh forbartha forlíontán, féach an [tagairt blaoisce](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) agus [catalóg forlíontán chéadpháirtí](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Do chuid a chomhroinnt leis an domhan

Nuair a dhéanann tú rud éigin a thaitníonn leat, cuir i stóras git poiblí é. Sin an mheicníocht dáileacháin iomlán — is féidir le duine ar bith `omarchy plugin add` a rith i gcoinne do URL ansin agus é a bheith ag rith i soicindí.

Chun cabhrú le daoine é a aimsiú i ndáiríre, liostaigh é ag [plugins.omarchy.org](https://plugins.omarchy.org). Sin an margadh le haghaidh forlíontán blaoisce Omarchy, agus is é an chéad áit le féachaint nuair a bhíonn tú ag déanamh iontais ar thóg duine éigin an ghiuirléid atá tú ar tí a scríobh cheana. Brabhsáil é sula dtosaíonn tú!
