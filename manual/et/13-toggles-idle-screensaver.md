# Lülitid, tegevusetus ja ekraanisäästja

Suur osa sellest, mida sa iga päev muudad, ei ole õieti seade. See on režiim, mille lülitad tunniks sisse ja siis jälle välja: öövalgus, kui töötad hilja, mitte segada, kui esitled, püsi ärkvel, kui midagi vaatad. Omarchy nimetab neid lülititeks ja need kõik töötavad ühtemoodi — kiirklahv, menüüvalik ja käsk tabavad kõik sama lülitit.

### Lülitite menüü

`Super + Ctrl + O` avab otse _Trigger > Toggle_ või saad sinna jõuda Omarchy menüüst (`Super + Space`). Kõik selles loendis on lülitid, mida saad ümber lülitada, mõtlemata sellele, kus olek elab. Lülitid selle kohta, kuidas töölaud välja näeb, asuvad selle kõrval jaotises _Appearance_.

Terminalist on samad lülitid `omarchy toggle <thing>`. Käivita `omarchy toggle` omaette, et näha kogu rühma.

| Lüliti | Kiirklahv | Käsk |
| ------ | ------ | ------- |
| Öövalgus | — | `omarchy toggle nightlight` |
| Vaigista teavitused | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Püsi ärkvel (tegevusetusel ei lukustu) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Krahhi jäädvustamine | — | `omarchy toggle crash-capture` |
| Ekraanisäästja | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) teema sünkroonimine | — | `omarchy toggle theme sync` |
| Menüüriba | `Super + Shift + Space` | `omarchy toggle bar` |
| Puuteplaat | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Puuteekraan | — | `omarchy device touchscreen` |
| Uinak | — | `omarchy toggle suspend` |
| Hübriid-GPU | — | `omarchy toggle hybrid gpu` |

Puuteplaadi, puuteekraani ja hübriid-GPU lülitid asuvad jaotise Toggle asemel jaotises _Trigger > Hardware_ (`Super + Ctrl + H`), sest need ilmuvad ainult siis, kui sul see riistvara tegelikult olemas on. Puuteplaadi ja puuteekraani lülitid jäävad Hyprlandi taaslaadimise järel alles — keelatud seadme nimi salvestatakse väikesesse olekufaili, mida Hyprland loeb käivitamisel, et seade uuesti keelata.

_Appearance_ sisaldab menüüriba ja animatsioone ning paari asja, mis ei ole `omarchy toggle` käsud, kuid käituvad samamoodi: aku protsent ribal, tööruumide vaikepaigutus ja jaotises _Windows_ akende vahed (`Super + Shift + Backspace`) ning ühe akna ruudukujuline kuvasuhe (`Super + Ctrl + Backspace`).

Kui Hyprlandil ei ole joonistamiseks GPU-d ja see renderdab selle asemel CPU-l (llvmpipe), nagu Macidel, mille GPU ei ole veel toetatud, enamikus virtuaalmasinates või kui graafikadraiver ei laadi, lülitab Omarchy selle seansi ajaks animatsioonid, hägususe ja varjud välja ning annab sulle sellest ühe korra teavitusega teada. _Appearance > Animations On_ toob need tagasi ja Omarchy jätab selle meelde ka hilisemate seansside jaoks.

Enamik neist on lihtsalt lipufail kaustas `~/.local/state/omarchy/toggles/`. Kui tahad skriptis mõne põhjal hargneda, annab `omarchy-toggle-enabled` sulle väljumiskoodi, selle asemel et peaksid ise otsima minema:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Lipud on nimetatud väljalülitatud oleku järgi — `screensaver-off`, `suspend-off`, `bar-off` — nii et nende olemasolu tähendab, et funktsioon on keelatud.

### Näidikud ribal

Kui režiim on sisse lülitatud, saad ülemise riba keskele kella kõrvale väikese tähise. See on näidikute vidin ja see kannab dikteerimist, ekraani salvestamist, ootel meeldetuletusi, öövalgust, mitte segada režiimi ja ärkvel püsimist.

Mitteaktiivsed näidikud on peidetud. Hõlju ribal ükskõik kus ja need ilmuvad tuhmilt nähtavale, nii et saad mõne sisse lülitamiseks sellel klõpsata, teadmata selle kiirklahvi. Aktiivsel näidikul klõpsamine lülitab selle uuesti välja. Kui eelistad näha neid kõiki kogu aeg, määra failis `~/.config/omarchy/shell.json` kirje `omarchy.indicators` väljal `alwaysShow` väärtuseks `true` — vaata [ülemine riba](05-the-top-bar.md), et teada saada, kuidas riba vidinaid seadistatakse.

### Öövalgus

Öövalgus soojendab ekraani 4000K-ni ja selle uuesti lülitamine paneb selle tagasi 6500K peale. Lülita seda lülitite menüüst (`Super + Ctrl + O`) või käsuga `omarchy toggle nightlight`. Seda juhib hyprsunset, mille lüliti käivitab sinu eest, kui see juba ei tööta.

Vaikimisi ei tee hyprsunset sinu ekraaniga üldse midagi. `~/.config/hypr/hyprsunset.conf` tarnitakse identiteediprofiiliga just selleks, et ekraan jääks puutumata, kuni soojust palud. Kui eelistad, et see lülitub kella järgi, asenda see ajaprofiiliga:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Seejärel käivita hyprsunset sisselogimisel, lisades faili `~/.config/hypr/autostart.lua` rea `o.launch_on_start("hyprsunset")`. Lüliti kasutatav 4000K/6500K paar on fikseeritud, nii et seadistusfail on koht, kuhu minna, kui tahad teistsugust temperatuuri.

### Mitte segada

`Super + Ctrl + Alt + ,` vaigistab teavitused. Kuni see on sisse lülitatud, ei hüppa ühtegi hüpikteadet ette ja läbikriipsutatud kellukese näidik istub ribal, et tuletada meelde, miks töölaud on vaikseks jäänud.

Midagi ei lähe aga kaduma. Vaigistatud teavitused hoitakse kinni: pane viimased paar käsuga `Super + Shift + Alt + ,` uuesti ekraanile. Ülejäänu kohta vaata [teavitused](10-notices.md).

Kahte liiki sõnumid pääsevad siiski läbi: Omarchy enda kinnitavad hüpikteated millegi kohta, mida just tegid ("Theme changed", "Screenshot saved"), ja käsurealt saadetud kriitilised hoiatused. Vestlusrakendused, mis märgivad kõik kriitiliseks, et end sinu ette suruda, ei kvalifitseeru.

### Tegevusetus

Omarchy kest omab tegevusetuse käitumist ja ajastused on failis `~/.config/omarchy/shell.json` ülemise taseme `idle` plokk:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Mõlemad numbrid on sekundid, mida loetakse hetkest, mil jäid tegevusetuks — mitte teineteisest. Nii et vaikeväärtustega ilmub ekraanisäästja kahe ja poole minuti pärast ja lukustusekraan võtab viie minuti kohal üle, olenemata sellest, kas ekraanisäästja töötas. Salvesta fail ja kest võtab uued ajastused kohe kasutusele.

Kui jätad ekraanisäästja enne lukustuse tähtaega kõrvale, loetakse see tegevuseks ja ootel lukustus tühistatakse. Sind ei lukustata välja selle eest, et masinale pilgu heitsid.

Et tegevusetusel lukustamine täielikult peatada, lülitab `Super + Ctrl + I` — või `omarchy toggle idle` — ärkvel püsimise sisse ja ribale ilmub kohvitassi näidik. Seda tasub vajutada enne pikka esitlust või kompileerimist, mida vaadata tahad. Vajuta seda uuesti, et normaalsuse juurde tagasi minna. `omarchy toggle idle status` prindib praeguse oleku JSON-ina, kui sul on seda skriptist vaja.

See puudutab lukustamist ja ekraanisäästjat, mitte toidet. Uinakul ja talveunel on oma seadistus jaotises [süsteemi unerežiim](36-system-sleep.md).

### Ekraanisäästja

Omarchy ekraanisäästja on ASCII kunst, mis jookseb läbi juhuslike tekstiefektide, üks eksemplar iga monitori kohta. Iga klahvivajutus või hiire liigutamine väljub sellest.

Saad selle nõudmisel käivitada jaotisest _System > Screensaver_ (`Super + Esc`), mis sunnib selle ette isegi siis, kui oled tegevusetuse ekraanisäästja välja lülitanud. Vaikimisi ei ole sellele kiirklahvi seotud.

`omarchy toggle screensaver` lülitab tegevusetuse oma välja, kui eelistad minna otse töötamisest lukustatuks. Iga klahv, klõps, kerimine või hiire liigutamine sulgeb selle.

Logo, mille see joonistab, saad ise muuta jaotises _Appearance > Branding > Screensaver_. Laadi üles png või svg ja Omarchy teisendab selle ASCII-ks. Vaata [bränding](41-branding.md).

### Lukustusekraan

`Super + Ctrl + L` lukustab masina. See käivitab Omarchy kesta lukustusekraani, tumestab ekraani, lähtestab klaviatuuripaigutuse esimesele, et sa ei kirjutaks oma parooli vales tähestikus, ja — kui see sul töötab — lukustab lahkumisel 1Passwordi.

Lukustusekraan võtab parooli ja võtab ka sõrmejälje, kui oled selle seadistanud. Seda ja teisi autentimisviise käsitletakse jaotises [riistvaraline autentimine](37-hardware-authentication.md).
