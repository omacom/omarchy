# Mga Plugin ng Shell

Ang Omarchy desktop ay tumatakbo bilang isang solong matagalang proseso ng Quickshell na tinatawag na `omarchy-shell`, at halos lahat ng nakikita mo sa screen ay isang plugin sa loob nito. Ang bar ay isang plugin. Gayundin ang mga panel na bumababa mula dito, ang mga fullscreen overlay tulad ng emoji picker at clipboard manager, ang Omarchy menu mismo, ang lock screen, ang polkit dialog, at ang mga headless service na nagbabantay sa iyong baterya at nagpapainit sa screen mo sa gabi.

Hindi lang iyon isang detalye ng implementasyon. Ibig sabihin niyon ay maaari mong i-off ang mga piraso ng desktop, palitan ang mga ito, o isulat ang sarili mo nang hindi humahawak ng kahit isang linya ng source ng Omarchy.

Ang mga first-party plugin ay kasama ng Omarchy at nakatira sa `$OMARCHY_PATH/shell/plugins/`. Anumang idaragdag mo mismo — ang sarili mong mga eksperimento, o isang bagay na nakita mo sa GitHub — ay nakatira sa `~/.config/omarchy/plugins/`. Parehong natutuklasan sa parehong paraan sa pagsisimula, pero tumatanggap ang mga built-in ng mga pinagkakatiwalaang shell interface habang tumatanggap ang mga third-party plugin ng limitadong interface na nakatuon sa sarili nilang serbisyo at lifecycle. Pinapanatili lang ng mga clone ng mga built-in ang source-specific na configuration at mga UI call na kailangan para sa orihinal na pag-uugali.

## Pagtingin sa kung ano ang mayroon ka

```
omarchy plugin list
```

Ini-print niyon ang bawat natuklasang plugin kasama ang id nito, kung naka-enable ito, kung ito ay first-party o third-party, ang mga uri nito, at ang display name nito. Idagdag ang `--json` kung ipapakain mo ito sa ibang bagay.

Naka-namespace ang mga plugin id. Ang mga built-in ay lahat nagsisimula sa `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — at nakareserba ang namespace na iyon, kaya hindi ito kailanman maaangkin ng isang third-party plugin.

## Pag-on at pag-off sa mga ito

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

O gamitin ang menu: ang _Setup > Plugins_ ay may Enable, Disable, Add, Clone, at Remove, bawat isa ay may picker na nag-aalok lang ng mga plugin na may katuturan para sa aksyong iyon.

Naka-store ang enabled state sa `~/.config/omarchy/shell.json`, at medyo magkaiba ang panuntunan para sa dalawang uri ng plugin. Ang isang third-party plugin ay naka-enable eksakto kapag lumalabas ang id nito saanman sa file na iyon — bilang isang bar layout entry, bilang isang entry sa `plugins[]`, o bilang `bar.id`. Ang mga first-party plugin na hindi bar widget ay kabaligtaran: naka-on sila bilang default at namamatay lang sa pamamagitan ng pagiging nakalista sa `disabledPlugins[]`.

Ang isang buong bar plugin ay walang off state. Palaging may eksaktong isang bar, kaya pinapalitan mo ito sa pamamagitan ng pagpapagana ng isa pa. Saklaw ang paglalagay ng bar widget sa [top bar](05-the-top-bar.md).

## Pagdaragdag ng plugin mula sa git

Ang isang third-party plugin ay isang git repo lang na may `manifest.json` sa root nito.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Bago ito gumawa ng anuman, sinasabi nito sa iyo nang malinaw na ang mga plugin ay tumatakbo bilang arbitrary at hindi naka-sandbox na code sa loob ng iyong matagalang proseso ng shell, ipinapakita sa iyo ang URL, at humihingi sa iyong kumpirmahin. Seryosohin iyon. Hindi direktang inilalantad ng third-party plugin interface ang mga serbisyo ng authentication, at ang isang kapalit na bar ay tumatanggap lang ng limitadong kakayahan para sa naka-configure na non-authentication UI. Ibinabahagi pa rin ng mga visual plugin ang QML scene ng shell at maaari nilang lakaran ang mga ordinaryong parent object, habang ang lahat ng plugin code ay tumatakbo kasama ang lahat ng maaabot ng iyong user account. Hiwalay na pinoprotektahan ang authentication state sa pamamagitan ng pag-iingat sa mga serbisyong iyon sa labas ng maaabot na host object graph. Magdagdag lang ng mga repo na handa kang patakbuhin, at basahin ang mga ito bago mo paganahin.

Maaaring i-render ng isang kapalit na bar ang mga naka-install na widget, pero ang mga service-backed na third-party widget ay maaaring may nabawasang functionality roon dahil hindi pinapayagan ang bar na humiling ng live service object ng isa pang plugin. Bumalik sa built-in na `omarchy.bar` kung kailangan ng naturang widget ang kasama nitong serbisyo.

Pagkatapos ay kino-clone nito ang repo papunta sa isang staging directory, bina-validate ang manifest, tumatanggi sa install kung inaangkin na ng isa pang plugin ang id na iyon, at inililipat ito papunta sa `~/.config/omarchy/plugins/<id>/`. Nang walang `--enable` ay itinatanong nito kung gusto mo itong naka-on ngayon, at maaari kang tumanggi at basahin muna ang code. Hindi ito kailanman nagpapatakbo ng anuman mula sa plugin, hindi kailanman nag-e-execute ng install hook, at hindi kailanman humihingi ng sudo — nagko-clone ito ng mga file, sinusuri ang manifest, at nagpapalit ng isang bit sa IPC.

Ang pag-update ay isang fast-forward pull ng parehong checkout na iyon:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Nang walang id ay ina-update nito ang bawat git-managed plugin na mayroon ka. Ipinapakita nito sa iyo ang diff bago ito ilapat, tumatangging mag-update kung mayroon kang mga lokal na pagbabago na hindi nito ma-fast-forward, at nagro-rollback kung mabigo ang bagong revision sa validation.

```
omarchy plugin remove acme.weather
```

Dina-disable muna ng pag-alis ang plugin, pagkatapos ay tinatanggal ito kung ito ay isang git checkout (nasa upstream pa rin ang repo) o ina-unlink ito kung ito ay isang symlink. Ang isang hand-made plugin folder na walang git repo ay inililipat sa isang naka-timestamp na backup sa loob ng plugins directory sa halip na direktang tanggalin.

## Pag-clone ng isang built-in para baguhin ito

Ito ang paborito kong bahagi. Kung gusto mong baguhin kung paano kumikilos ang isang built-in na widget, huwag i-edit ang mga file sa ilalim ng `$OMARCHY_PATH` — pagmamay-ari iyon ng package at papatungan sila ng susunod na update. I-clone ito sa halip:

```
omarchy plugin clone omarchy.clock
```

Kinokopya niyon ang buong plugin papunta sa `~/.config/omarchy/plugins/dhh.clock` (ang username mo, hindi akin), pinapangalanan itong "My Clock", pinagagana ito, at inililipat ang shell mula sa built-in papunta sa kopya mo — pinapanatili ang posisyon at mga setting ng isang umiiral na bar widget. Idagdag ang `--edit` para buksan kaagad ang bagong direktoryo sa iyong `$EDITOR`, na siyang ginagawa ng _Setup > Plugins > Clone Plugin_ ng menu para sa iyo.

Pinapanatili ng username prefix na iyo ang id ng clone mo, kaya ang pagbabahagi nito ay hindi sumasalungat sa sinuman. Ang mga tawag na ginawa sa orihinal na built-in id ay iniruruta sa clone mo, kaya walang anumang tumukoy sa `omarchy.clock` ang kailangang i-update. At kung magulo mo ito, ibabalik ng `omarchy plugin remove dhh.clock` ang built-in.

Ang pag-save ng file saanman sa ilalim ng `~/.config/omarchy/plugins/` ay awtomatikong nire-reload ang plugin code, kaya maaari mong iwanang bukas ang editor at panoorin ang iyong mga pagbabago na dumating.

## Pagsulat ng sarili mo

Ang isang plugin ay isang direktoryo na may `manifest.json` at ilang QML. Ipinapahayag ng manifest ang `schemaVersion: 1`, isang `id`, `name`, `version`, isa o higit pang `kinds`, at isang `entryPoints` object na tumuturo sa QML file para sa bawat uri:

| Uri | Ano ito |
|------|------------|
| `bar-widget` | Isang component na maaaring ilagay ng aktibong bar sa isang seksyon |
| `panel` | Isang persistent o tinawag na floating window |
| `overlay` | Isang fullscreen overlay |
| `menu` | Isang tinawag na menu surface |
| `service` | Isang headless singleton na walang UI |
| `bar` | Isang buong bar na pumapalit sa built-in |

Maaaring magpahayag ang isang plugin ng maraming uri nang sabay-sabay — ang media plugin ay parehong `service` at `bar-widget`. Nakakakuha ang mga bar widget ng karagdagang `barWidget` block na may display name, isang kategorya, isang opsyonal na `defaultSection`, at `allowMultiple`, na nagsasabi kung may katuturan bang magkaroon ng higit sa isa sa bar. Itinatakda ito ng karamihan ng mga widget sa `false`; itinatakda ito ng mga spacer at indicator sa `true`.

Bago ka mag-publish ng anuman, suriin ito:

```
omarchy plugin validate ./my-plugin
```

Pinapatakbo niyon ang parehong mga pagsuri na ginagawa ng shell sa load time: ang bersyon ng schema, ang mga kinakailangang field, isang id na hindi nakareserba, mga entry point na ligtas na relative path at talagang umiiral, isang entry point para sa bawat uri na inangkin mo, at walang mga symlink saanman sa loob ng folder.

Para sa plugin development, tingnan ang [shell reference](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) at [first-party plugin catalog](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Pagbabahagi ng iyo sa mundo

Kapag nakagawa ka na ng isang bagay na gusto mo, ilagay ito sa isang pampublikong git repo. Iyon ang buong mekanismo ng pamamahagi — maaaring patakbuhin ng kahit sino ang `omarchy plugin add` laban sa URL mo at patakbuhin ito sa loob ng ilang segundo.

Para matulungan ang mga tao na talagang mahanap ito, ilista ito sa [plugins.omarchy.org](https://plugins.omarchy.org). Iyon ang marketplace para sa mga Omarchy shell plugin, at ito ang unang lugar na titingnan kapag nagtataka ka kung may nakagawa na ng widget na isusulat mo pa lang. I-browse ito bago ka magsimula!
