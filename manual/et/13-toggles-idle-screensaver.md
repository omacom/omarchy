# Lülitid, jõudeolek ja ekraanisäästja

Suur osa sellest, mida sa iga päev muudad, ei ole õieti seade. See on režiim, mille lülitad tunniks ajaks sisse ja siis jälle välja: öövalgus, kui töötad hilja, ära-sega-režiim, kui esitled, ärkvel püsimine, kui midagi vaatad. Omarchy nimetab neid lülititeks ja need kõik toimivad ühtemoodi — kiirklahv, menüükirje ja käsk, mis kõik tabavad sama lülitit.

### Lülitite menüü

`Super + Ctrl + O` avab otse _Trigger > Toggle_ või saad sinna jõuda Omarchy menüüst (`Super + Space`). Kõik selles loendis on lülitid, mida saad ümber lülitada, ilma et peaksid mõtlema, kus olekut hoitakse. Lülitid selle kohta, kuidas töölaud välja näeb, asuvad selle kõrval, _Appearance_ all.

Terminalist on samad lülitid `omarchy toggle <thing>`. Käivita `omarchy toggle` üksinda, et näha kogu rühma.

| Lüliti | Kiirklahv | Käsk |
| ------ | ------ | ------- |
| Öövalgus | — | `omarchy toggle nightlight` |
| Teavituste vaigistamine | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Püsi ärkvel (jõudeolekul ei lukustu) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Krahhide jäädvustamine | — | `omarchy toggle crash-capture` |
| Ekraanisäästja | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) teema sünkroonimine | — | `omarchy toggle theme sync` |
| Menüüriba | `Super + Shift + Space` | `omarchy toggle bar` |
| Puuteplaat | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Puuteekraan | — | `omarchy toggle touchscreen` |
| Peatamine | — | `omarchy toggle suspend` |
| Hübriid-GPU | — | `omarchy toggle hybrid gpu` |

Puuteplaadi, puuteekraani ja hübriid-GPU lülitid asuvad _Trigger > Hardware_ (`Super + Ctrl + H`) all, mitte Toggle'i all, sest need ilmuvad ainult siis, kui sul selline riistvara tegelikult olemas on. Puuteplaadi ja puuteekraani lülitid jäävad püsima ka pärast Hyprlandi uuesti laadimist — keelatud seadme nimi salvestatakse väikesesse olekufaili, mida Hyprland loeb käivitamisel, et seade uuesti keelata.

_Appearance_ sisaldab menüüriba ja animatsioone, lisaks mõnda asja, mis ei ole `omarchy toggle` käsud, kuid käituvad samamoodi: aku protsent ribal, tööruumi vaikepaigutus ning _Windows_ all aknavahed (`Super + Shift + Backspace`) ja ühe akna ruudukujuline kuvasuhe (`Super + Ctrl + Backspace`).

Enamik neist on lihtsalt lipufail kaustas `~/.local/state/omarchy/toggles/`. Kui soovid skriptis ühe põhjal hargneda, annab `omarchy-toggle-enabled` sulle järele otsimise asemel väljundkoodi:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Lipud on nimetatud väljalülitatud oleku järgi — `screensaver-off`, `suspend-off`, `bar-off` — nii et nende olemasolu tähendab, et funktsioon on keelatud.

### Näidikud ribal

Kui režiim on sees, saad ülariba keskele kella kõrvale väikese tähise. See on näidikute vidin ja see kannab dikteerimist, ekraani salvestamist, ootel meeldetuletusi, öövalgust, ära-sega-režiimi ja ärkvel püsimist.

Mitteaktiivsed näidikud on peidetud. Hõlju kursoriga ükskõik kus ribal ja need ilmuvad tuhmilt nähtavale, nii et saad ühele klõpsata selle sisselülitamiseks, ilma selle kiirklahvi teadmata. Aktiivsele klõpsamine lülitab selle uuesti välja. Kui eelistad neid kõiki kogu aeg näha, määra failis `~/.config/omarchy/shell.json` kirje `omarchy.indicators` puhul `alwaysShow` väärtuseks `true` — vaata [ülariba](05-the-top-bar.md), et näha, kuidas riba vidinaid konfigureeritakse.

### Öövalgus

Öövalgus soojendab ekraani 4000K-ni ja selle uuesti lülitamine paneb selle tagasi 6500K peale. Lülita seda lülitite menüüst (`Super + Ctrl + O`) või käsuga `omarchy toggle nightlight`. Seda juhib hyprsunset, mille lüliti käivitab sinu eest, kui see veel ei tööta.

Vaikimisi ei tee hyprsunset sinu ekraaniga üldse midagi. `~/.config/hypr/hyprsunset.conf` sisaldab identiteediprofiili just selleks, et ekraan jääks puutumata, kuni sa soojust palud. Kui eelistad, et see lülituks kella järgi, asenda see ajaprofiiliga:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Seejärel käivita hyprsunset sisselogimisel, lisades faili `~/.config/hypr/autostart.lua` rea `o.launch_on_start("hyprsunset")`. Lüliti kasutatav 4000K/6500K paar on fikseeritud, nii et kui soovid teist temperatuuri, tuleb sul minna konfiguratsioonifaili juurde.

### Ära sega

`Super + Ctrl + Alt + ,` vaigistab teavitused. Kui see on sees, ei ilmu ühtegi hüpikteavitust ja läbikriipsutatud kellukese näidik istub ribal, et tuletada sulle meelde, miks töölaud on vaikseks jäänud.

Midagi ei lähe siiski kaduma. Vaigistatud teavitused hoitakse tagasi: too viimased mõned käsuga `Super + Shift + Alt + ,` uuesti ekraanile. Ülejäänu kohta vaata [teated](10-notices.md).

Kahte liiki sõnumid pääsevad siiski läbi: Omarchy enda kinnitusteated millegi kohta, mida sa just tegid ("Theme changed", "Screenshot saved"), ja käsurealt saadetud kriitilised hoiatused. Vestlusrakendused, mis märgivad kõik kriitiliseks, et end sinu ette suruda, ei kvalifitseeru.

### Jõudeolek

Omarchy kest omab jõudeoleku käitumist ja ajastused on failis `~/.config/omarchy/shell.json` ülemise taseme `idle` plokk:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Mõlemad numbrid on sekundid, mida loetakse hetkest, mil sa jõude jäid — mitte üksteisest. Nii et vaikeväärtustega tuleb ekraanisäästja üles kahe ja poole minuti pärast ja lukustuskuva võtab viie minuti kohal üle, olenemata sellest, kas ekraanisäästja töötas või mitte. Salvesta fail ja kest võtab uued ajastused kohe kasutusele.

Kui suled ekraanisäästja enne lukustamise tähtaega, loetakse seda tegevuseks ja ootel lukustamine tühistatakse. Sind ei lukustata välja selle eest, et sa oma masinale pilgu heitsid.

Jõudeolekul lukustamise täielikuks peatamiseks lülitab `Super + Ctrl + I` — või `omarchy toggle idle` — ärkvel püsimise sisse ja ribale ilmub kohvitassi näidik. Seda tuleb vajutada enne pikka esitlust või järgeehitust, mida soovid jälgida. Vajuta uuesti, et naasta tavarežiimi. `omarchy toggle idle status` prindib praeguse oleku JSON-ina, kui vajad seda skriptist.

See käib lukustamise ja ekraanisäästja kohta, mitte toite kohta. Peatamisel ja talveunel on oma seadistus jaotises [süsteemi unerežiim](36-system-sleep.md).

### Ekraanisäästja

Omarchy ekraanisäästja on ASCII-kunst, mis jookseb läbi juhuslike tekstiefektide, üks eksemplar iga monitori kohta. Mis tahes klahv või hiire liigutus väljub sellest.

Saad selle nõudmisel käivitada jaotisest _System > Screensaver_ (`Super + Esc`), mis sunnib selle üles isegi siis, kui oled jõudeoleku ekraanisäästja välja lülitanud. Sellele ei ole vaikimisi kiirklahvi seotud.

`omarchy toggle screensaver` on see, mis lülitab jõudeoleku oma välja, kui eelistad minna otse töötamisest lukustatud olekusse. See vajab terminali, mida ta oskab konfigureerida — Alacritty, Foot, Ghostty või Kitty — ja ütleb sulle nii, kui sinu vaiketerminal on midagi muud.

Logo, mida see joonistab, saad ise muuta jaotises _Appearance > Branding > Screensaver_. Laadi üles png või svg ja Omarchy teisendab selle ASCII-ks. Vaata [bränding](41-branding.md).

### Lukustuskuva

`Super + Ctrl + L` lukustab masina. See käivitab Omarchy kesta lukustuskuva, tumestab ekraani, lähtestab klaviatuuripaigutuse esimesele, et sa ei kirjutaks oma parooli vales tähestikus, ja — kui sul see töötab — lukustab väljumisel 1Passwordi.

Lukustuskuva võtab parooli ja võtab ka sõrmejälje, kui oled selle seadistanud. Seda ja teisi autentimisviise käsitletakse jaotises [riistvaraline autentimine](37-hardware-authentication.md).
