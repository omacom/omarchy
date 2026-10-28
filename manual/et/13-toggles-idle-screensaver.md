# Lülitid, tegevusetus ja ekraanisäästja

Suur osa sellest, mida sa päevast päeva muudad, ei ole õieti seade. See on režiim, mille lülitad tunniks ajaks sisse ja siis jälle välja: öövalgus, kui töötad hilja, ära sega, kui esitled, püsi ärkvel, kui midagi vaatad. Omarchy nimetab neid lülititeks ja need kõik töötavad ühtemoodi — kiirklahv, menüükirje ja käsk, mis kõik vajutavad sama lülitit.

### Lülitite menüü

`Super + Ctrl + O` avab otse _Trigger > Toggle_, või saad sinna kõndida Omarchy menüüst (`Super + Space`). Kõik selles loendis on lülitid, mida saad vajutada, mõtlemata sellele, kus olek elab. Lülitid selle kohta, kuidas töölaud välja näeb, istuvad selle kõrval, _Appearance_ all.

Terminalist on samad lülitid `omarchy toggle <thing>`. Käivita `omarchy toggle` omaette, et näha kogu rühma.

| Toggle | Hotkey | Command |
| ------ | ------ | ------- |
| Öövalgus | — | `omarchy toggle nightlight` |
| Vaigista märguanded | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Püsi ärkvel (tegevusetusel ei lukusta) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Krahhi salvestamine | — | `omarchy toggle crash-capture` |
| Ekraanisäästja | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) teema sünkroonimine | — | `omarchy toggle theme sync` |
| Menüüriba | `Super + Shift + Space` | `omarchy toggle bar` |
| Puuteplaat | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Puuteekraan | — | `omarchy toggle touchscreen` |
| Peatamine | — | `omarchy toggle suspend` |
| Hübriid-GPU | — | `omarchy toggle hybrid gpu` |

Puuteplaadi, puuteekraani ja hübriid-GPU lülitid elavad _Trigger > Hardware_ all (`Super + Ctrl + H`), mitte Toggle all, sest need ilmuvad ainult siis, kui sul selline riistvara päriselt on. Puuteplaadi ja puuteekraani omad elavad Hyprland taaslaadimise üle — keelatud seadme nimi salvestatakse väikesesse olekufaili, mida Hyprland loeb käivitamisel, et see uuesti keelata.

_Appearance_ hoiab menüüriba ja animatsioone ning paari asja, mis ei ole `omarchy toggle` käsud, kuid käituvad samamoodi: aku protsent ribal, tööruumi vaikepaigutus ja _Windows_ all akende vahed (`Super + Shift + Backspace`) ning 1 akna ruudukujuline suhe (`Super + Ctrl + Backspace`).

Enamik neist on lihtsalt lipufail `~/.local/state/omarchy/toggles/` all. Kui tahad skriptis ühe põhjal hargneda, annab `omarchy-toggle-enabled` sulle väljundkoodi, selle asemel et sind otsima saata:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Lipud on nimetatud väljalülitatud oleku järgi — `screensaver-off`, `suspend-off`, `bar-off` — nii et nende olemasolu tähendab, et funktsioon on keelatud.

### Näidikud ribal

Kui režiim on sees, saad ülariba keskele kella kõrvale väikese glüüfi. See on näidikute vidin ja see kannab dikteerimist, ekraani salvestamist, ootel meeldetuletusi, öövalgust, ära sega režiimi ja ärkvel püsimist.

Mitteaktiivsed näidikud on peidetud. Liigu hiirega ükskõik kuhu ribale ja need ilmuvad tuhmilt, nii et saad ühele klõpsata, et see sisse lülitada, ilma selle kiirklahvi teadmata. Aktiivsele klõpsamine lülitab selle jälle välja. Kui eelistad näha neid kõiki kogu aeg, sea `~/.config/omarchy/shell.json` failis kirje `omarchy.indicators` juures `alwaysShow` väärtuseks `true` — vaata [ülemist riba](05-the-top-bar.md), kuidas riba vidinaid seadistatakse.

### Öövalgus

Öövalgus soojendab ekraani 4000K-ni ja selle uuesti lülitamine paneb selle tagasi 6500K peale. Lülita seda lülitite menüüst (`Super + Ctrl + O`) või käsuga `omarchy toggle nightlight`. Seda juhib hyprsunset, mille lüliti käivitab sinu eest, kui see juba ei tööta.

Vaikimisi ei tee hyprsunset sinu ekraaniga üldse midagi. `~/.config/hypr/hyprsunset.conf` tuleb identiteediprofiiliga just selleks, et ekraan püsiks puutumata, kuni soojust küsid. Kui eelistad, et see lülituks kella järgi, asenda see ajaprofiiliga:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Seejärel käivita hyprsunset sisselogimisel, lisades `o.launch_on_start("hyprsunset")` faili `~/.config/hypr/autostart.lua`. Lüliti kasutatav 4000K/6500K paar on fikseeritud, nii et seadistusfail on koht, kuhu minna, kui tahad teistsugust temperatuuri.

### Ära sega

`Super + Ctrl + Alt + ,` vaigistab märguanded. Sel ajal, kui see on sees, ei hüppa ühtegi teadet esile ja läbikriipsutatud kella näidik istub ribal, et tuletada meelde, miks töölaud on vaikseks jäänud.

Midagi ei lähe siiski kaotsi. Vaigistatud märguanded hoitakse tagasi: pane viimased paarid `Super + Shift + Alt + ,` abil ekraanile tagasi. Ülejäänu kohta vaata [märguandeid](10-notices.md).

Kahte liiki sõnumid pääsevad siiski läbi: Omarchy enda kinnitusteated millegi kohta, mida just tegid ("Theme changed", "Screenshot saved"), ja käsurealt saadetud kriitilised hoiatused. Vestlusrakendused, mis märgivad kõik kriitiliseks, et end sinu ette suruda, ei kvalifitseeru.

### Tegevusetus

Omarchy kest omab tegevusetuse käitumist ja ajastused on ülemise taseme `idle` plokk failis `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Mõlemad numbrid on sekundid, mida loetakse hetkest, mil jäid tegevusetuks — mitte teineteisest. Nii et vaikeseadetega tuleb ekraanisäästja ette kahe ja poole minuti pärast ja lukustuskuva võtab viie minuti kohal üle, olenemata sellest, kas ekraanisäästja töötas. Salvesta fail ja kest võtab uued ajastused kohe kasutusele.

Kui lükkad ekraanisäästja enne lukustustähtaega ära, loeb see tegevuseks ja ootel lukustus tühistatakse. Sind ei lukustata välja selle eest, et oma masinale pilgu heidad.

Et tegevusetusel lukustamine täielikult peatada, lülitab `Super + Ctrl + I` — või `omarchy toggle idle` — sisse ärkvel püsimise ja ribale ilmub kohvitassi näidik. See on see, mida vajutada enne pikka esitlust või ehitust, mida tahad jälgida. Vajuta uuesti, et normaalsuse juurde tagasi minna. `omarchy toggle idle status` prindib praeguse oleku JSON-ina, kui sul on seda skriptist vaja.

See käib lukustamise ja ekraanisäästja, mitte toite kohta. Peatamisel ja talveunel on oma seadistus [süsteemi unes](36-system-sleep.md).

### Ekraanisäästja

Omarchy ekraanisäästja on ASCII kunst, mis jookseb läbi juhuslike tekstiefektide, üks eksemplar iga monitori kohta. Mis tahes klahv või hiireliigutus väljub sellest.

Saad selle nõudmisel käivitada _System > Screensaver_ alt (`Super + Esc`), mis surub selle ette isegi siis, kui oled tegevusetuse ekraanisäästja välja lülitanud. Vaikimisi ei ole sellele kiirklahvi seotud.

`omarchy toggle screensaver` on see, mis tegevusetuse oma välja lülitab, kui eelistad minna töötamisest otse lukustatuks. Mis tahes klahv, klõps, kerimine või hiireliigutus sulgeb selle.

Logo, mille see joonistab, saad ise muuta, _Appearance > Branding > Screensaver_ all. Laadi üles png või svg ja Omarchy teisendab selle ASCII-ks. Vaata [brändingut](41-branding.md).

### Lukustuskuva

`Super + Ctrl + L` lukustab masina. See käivitab Omarchy kesta lukustuskuva, tumestab ekraani, lähtestab klaviatuuripaigutuse esimesele, et sa ei trükiks oma parooli vales tähestikus, ja — kui see sul töötab — lukustab väljaminekul 1Password.

Lukustuskuva võtab parooli ja võtab ka sõrmejälje, kui oled selle seadistanud. See ja muud autentimisviisid on kaetud [riistvaralises autentimises](37-hardware-authentication.md).
