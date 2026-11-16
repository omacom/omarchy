# Connectors de l'intèrpret d'escriptori

L'escriptori d'Omarchy s'executa com un únic procés Quickshell de llarga durada anomenat `omarchy-shell`, i gairebé tot el que veus en pantalla és un connector a dins seu. La barra és un connector. També ho són els panells que en baixen, les superposicions a pantalla completa com el selector d'emojis i el gestor del porta-retalls, el mateix menú d'Omarchy, la pantalla de bloqueig, el diàleg de polkit i els serveis sense interfície que observen la teva bateria i escalfen la pantalla a la nit.

Això no és només un detall d'implementació. Vol dir que pots apagar peces de l'escriptori, intercanviar-les o escriure'n de pròpies sense tocar ni una línia del codi font d'Omarchy.

Els connectors oficials venen amb Omarchy i viuen a `$OMARCHY_PATH/shell/plugins/`. Qualsevol cosa que afegeixis tu mateix — els teus propis experiments, o alguna cosa que hagis trobat a GitHub — viu a `~/.config/omarchy/plugins/`. Tots dos es descobreixen de la mateixa manera a l'arrencada, però els integrats reben interfícies de l'intèrpret de confiança mentre que els connectors de tercers reben una interfície limitada restringida al seu propi servei i cicle de vida. Els clons dels integrats conserven només la configuració i les crides a la interfície d'usuari específiques de l'origen necessàries per al comportament original.

## Veure què tens

```
omarchy plugin list
```

Això imprimeix cada connector descobert amb el seu identificador, si està habilitat, si és oficial o de tercers, les seves menes i el seu nom de visualització. Afegeix-hi `--json` si ho estàs passant a alguna altra cosa.

Els identificadors de connector tenen espai de noms. Els integrats comencen tots amb `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — i aquell espai de noms està reservat, de manera que un connector de tercers no el podrà reclamar mai.

## Activar-los i desactivar-los

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

O fes servir el menú: _Configuració > Connectors_ té Habilita, Deshabilita, Afegeix, Clona i Elimina, cadascú amb un selector que només ofereix els connectors que tenen sentit per a aquella acció.

L'estat d'habilitació es desa a `~/.config/omarchy/shell.json`, i la regla difereix lleugerament per a les dues menes de connector. Un connector de tercers està habilitat exactament quan el seu identificador apareix en algun lloc d'aquell fitxer — com a entrada de disposició de la barra, com a entrada a `plugins[]`, o com a `bar.id`. Els connectors oficials que no són ginys de la barra funcionen a l'inrevés: estan activats per defecte i només s'apaguen si apareixen a `disabledPlugins[]`.

Un connector de barra completa no té cap estat d'apagada. Sempre hi ha exactament una barra, de manera que la substitueixes habilitant-ne una altra. La col·locació dels ginys de la barra es tracta a [la barra superior](05-the-top-bar.md).

## Afegir un connector des de git

Un connector de tercers és simplement un repositori git amb un `manifest.json` a l'arrel.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Abans de fer res, et diu clarament que els connectors s'executen com a codi arbitrari i sense contenidor dins del teu procés d'intèrpret de llarga durada, et mostra l'URL i et demana que ho confirmis. Pren-t'ho seriosament. La interfície de connectors de tercers no exposa directament els serveis d'autenticació, i una barra de substitució rep només capacitats limitades per a la interfície d'usuari sense autenticació configurada. Els connectors visuals continuen compartint l'escena QML de l'intèrpret i poden recórrer objectes pare normals, mentre que tot el codi de connector s'executa amb tot allò a què el teu compte d'usuari pot arribar. L'estat d'autenticació es protegeix per separat mantenint aquells serveis fora del graf d'objectes de l'amfitrió accessible. Només afegeix repositoris que estiguis disposat a executar, i llegeix-los abans d'habilitar-los.

Una barra de substitució pot renderitzar els ginys instal·lats, però els ginys de tercers amb servei poden tenir una funcionalitat reduïda allà perquè la barra no té permís per demanar l'objecte de servei en directe d'un altre connector. Torna a la `omarchy.bar` integrada si un giny com aquest necessita el seu servei company.

Després clona el repositori en un directori de preparació, valida el manifest, rebutja la instal·lació si un altre connector ja reclama aquell identificador i el mou a `~/.config/omarchy/plugins/<id>/`. Sense `--enable` et demana si el vols activat ara, i pots dir que no i anar a llegir el codi primer. No executa mai res del connector, no executa mai cap ganxo d'instal·lació i no demana mai sudo: clona fitxers, comprova el manifest i commuta un bit per IPC.

Actualitzar és un pull d'avanç ràpid d'aquella mateixa còpia:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Sense cap identificador, actualitza cada connector gestionat per git que tinguis. Et mostra la diferència abans d'aplicar-la, es nega a actualitzar si tens canvis locals que no pot avançar ràpid, i fa marxa enrere si la revisió nova falla la validació.

```
omarchy plugin remove acme.weather
```

L'eliminació deshabilita primer el connector i després l'elimina si és una còpia git (el repositori continua sent a l'origen) o en treu l'enllaç si és un enllaç simbòlic. Una carpeta de connector feta a mà sense cap repositori git es mou a una còpia de seguretat amb marca de temps dins del directori de connectors en lloc d'eliminar-se del tot.

## Clonar un integrat per modificar-lo

Aquesta és la meva part preferida. Si vols canviar com es comporta un giny integrat, no editis els fitxers de sota de `$OMARCHY_PATH` — aquells pertanyen al paquet i la propera actualització els sobreescriurà. Clona'l en el seu lloc:

```
omarchy plugin clone omarchy.clock
```

Això copia tot el connector a `~/.config/omarchy/plugins/dhh.clock` (el teu nom d'usuari, no el meu), el reanomena a "My Clock", l'habilita i fa passar l'intèrpret de l'integrat a la teva còpia — conservant la posició i la configuració d'un giny de barra existent. Afegeix-hi `--edit` per obrir el directori nou al teu `$EDITOR` immediatament, que és el que fa per tu l'opció _Configuració > Connectors > Clona un connector_ del menú.

El prefix de nom d'usuari fa que l'identificador del teu clon sigui teu, de manera que compartir-lo no xoca amb el de ningú més. Les crides fetes a l'identificador integrat original es redirigeixen al teu clon, de manera que res del que es referia a `omarchy.clock` necessita actualització. I si en fas un embolic, `omarchy plugin remove dhh.clock` torna a posar l'integrat.

Desar un fitxer en qualsevol lloc de sota de `~/.config/omarchy/plugins/` torna a carregar automàticament el codi del connector, de manera que pots deixar l'editor obert i veure com arriben els teus canvis.

## Escriure el teu propi

Un connector és un directori amb un `manifest.json` i una mica de QML. El manifest declara `schemaVersion: 1`, un `id`, un `name`, una `version`, una o més `kinds` i un objecte `entryPoints` que apunta al fitxer QML de cada mena:

| Mena | Què és |
|------|------------|
| `bar-widget` | Un component que la barra activa pot col·locar en una secció |
| `panel` | Una finestra flotant persistent o invocada |
| `overlay` | Una superposició a pantalla completa |
| `menu` | Una superfície de menú invocada |
| `service` | Un singleton sense interfície d'usuari |
| `bar` | Una barra completa que substitueix la integrada |

Un connector pot declarar diverses menes alhora: el connector multimèdia és alhora un `service` i un `bar-widget`. Els ginys de barra reben un bloc `barWidget` addicional amb un nom de visualització, una categoria, un `defaultSection` opcional i `allowMultiple`, que diu si té sentit tenir-ne més d'un a la barra. La majoria de ginys el posen a `false`; els separadors i els indicadors el posen a `true`.

Abans de publicar res, comprova-ho:

```
omarchy plugin validate ./my-plugin
```

Això executa les mateixes comprovacions que fa l'intèrpret en carregar: la versió de l'esquema, els camps obligatoris, un identificador que no sigui reservat, punts d'entrada que siguin rutes relatives segures i que existeixin de debò, un punt d'entrada per a cada mena que hagis reclamat i cap enllaç simbòlic enlloc dins de la carpeta.

Per al desenvolupament de connectors, consulta la [referència de l'intèrpret](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) i el [catàleg de connectors oficials](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Compartir el teu amb el món

Un cop hagis fet alguna cosa que t'agradi, posa-ho en un repositori git públic. Aquest és tot el mecanisme de distribució: llavors qualsevol pot executar `omarchy plugin add` contra el teu URL i tenir-lo en funcionament en qüestió de segons.

Per ajudar la gent a trobar-lo de debò, llista'l a [plugins.omarchy.org](https://plugins.omarchy.org). Aquest és el mercat de connectors de l'intèrpret d'Omarchy, i és el primer lloc on cal mirar quan et preguntes si algú ja ha creat el giny que estàs a punt d'escriure. Fes-hi un cop d'ull abans de començar!
