# Lülitid, jõudeolek ja ekraanisäästja

Paljud asjad, mida sa iga päev muudad, ei ole õigupoolest sätted. See on režiim, mille lülitad tunniks sisse ja siis jälle välja: öövalgus, kui töötad hilja, mitte segada, kui esitled, püsi ärkvel, kui midagi vaatad. Omarchy kutsub neid lülititeks ja need kõik töötavad ühtemoodi — kiirklahv, menüükirje ja käsk tabavad kõik sama lülitit.

### Lülitimenüü

`Super + Ctrl + O` avab otse _Trigger > Toggle_ või saad sinna kõndida Omarchy menüüst (`Super + Space`). Kõik selles loendis on lülitid, mida saad ümber lülitada, mõtlemata sellele, kus olek elab. Lülitid selle kohta, kuidas töölaud välja näeb, asuvad selle kõrval jaotises _Appearance_.

Terminalist on samad lülitid `omarchy toggle <thing>`. Käivita `omarchy toggle` üksinda, et näha kogu rühma.

| Lüliti | Kiirklahv | Käsk |
| ------ | ------ | ------- |
| Öövalgus | — | `omarchy toggle nightlight` |
| Vaigista märguanded | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Püsi ärkvel (jõudeolekul ei lukustu) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Krahhi jäädvustamine | — | `omarchy toggle crash-capture` |
| Ekraanisäästja | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) teema sünkroonimine | — | `omarchy toggle theme sync` |
| Menüüriba | `Super + Shift + Space` | `omarchy toggle bar` |
| Puuteplaat | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Puuteekraan | — | `omarchy toggle touchscreen` |
| Peatamine | — | `omarchy toggle suspend` |
| Hübriid-GPU | — | `omarchy toggle hybrid gpu` |

Puuteplaadi, puuteekraani ja hübriid-GPU lülitid elavad jaotises _Trigger > Hardware_ (`Super + Ctrl + H`), mitte jaotises Toggle, sest need ilmuvad ainult siis, kui sul see riistvara tegelikult olemas on. Puuteplaadi ja puuteekraani lülitid elavad Hyprlandi taaslaadimise üle — keelatud seadme nimi salvestatakse väikesesse olekufaili, mida Hyprland loeb käivitamisel, et see uuesti keelata.

_Appearance_ sisaldab menüüriba ja animatsioone ning mõnda asja, mis ei ole käsud `omarchy toggle`, kuid käituvad samamoodi: aku protsent ribal, tööruumide vaikepaigutus ja jaotises _Windows_ akende vahed (`Super + Shift + Backspace`) ning 1 akna ruudukujuline kuvasuhe (`Super + Ctrl + Backspace`).

Kui Hyprlandil ei ole joonistamiseks GPU-d ja see renderdab selle asemel CPU-l (llvmpipe), nagu Macidel, mille GPU-d veel ei toetata, enamikus virtuaalmasinates või kui graafikadraiver ei laadi, lülitab Omarchy selleks seansiks animatsioonid, hägususe ja varjud välja ning annab sulle sellest ühe korra märguandega teada. _Appearance > Animations On_ toob need tagasi ja Omarchy jätab selle meelde ka hilisemate seansside jaoks.

Enamik neist on lihtsalt lipufail kaustas `~/.local/state/omarchy/toggles/`. Kui tahad skriptis ühe põhjal hargneda, annab `omarchy-toggle-enabled` sulle väljundkoodi, selle asemel et sind otsima saata:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Lipud on nimetatud väljalülitatud oleku järgi — `screensaver-off`, `suspend-off`, `bar-off` — nii et nende olemasolu tähendab, et funktsioon on keelatud.

### Indikaatorid ribal

Kui režiim on sees, saad ülemise riba keskel kella kõrval väikese glüüfi. See on indikaatorite vidin ja see kannab dikteerimist, ekraani salvestamist, ootel meeldetuletusi, öövalgust, mitte segada režiimi ja ärkvel püsimist.

Passiivsed indikaatorid on peidetud. Hõlju kursoriga ükskõik kus ribal ja need ilmuvad tuhmilt nähtavale, nii et saad ühe sisse lülitamiseks sellel klõpsata, teadmata selle kiirklahvi. Aktiivsel klõpsamine lülitab selle uuesti välja. Kui eelistad näha neid kõiki kogu aeg, määra `alwaysShow` väärtuseks `true` kirjel `omarchy.indicators` failis `~/.config/omarchy/shell.json` — vaata [ülemine riba](05-the-top-bar.md), kuidas riba vidinaid seadistatakse.

### Öövalgus

Öövalgus soojendab ekraani 4000K-ni ja selle uuesti lülitamine paneb selle tagasi 6500K peale. Lülita seda lülitimenüüst (`Super + Ctrl + O`) või käsuga `omarchy toggle nightlight`. Seda juhib hyprsunset, mille lüliti käivitab sinu eest, kui see veel ei tööta.

Vaikimisi ei tee hyprsunset sinu ekraaniga üldse midagi. `~/.config/hypr/hyprsunset.conf` tarnitakse identiteediprofiiliga just selleks, et ekraan jääks puutumata, kuni sa soojust küsid. Kui eelistad, et see lülituks kella järgi, asenda see ajaprofiiliga:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Seejärel käivita hyprsunset sisselogimisel, lisades `o.launch_on_start("hyprsunset")` faili `~/.config/hypr/autostart.lua`. Lüliti kasutatav 4000K/6500K paar on fikseeritud, nii et seadistusfail on koht, kuhu minna, kui tahad teistsugust temperatuuri.

### Mitte segada

`Super + Ctrl + Alt + ,` vaigistab märguanded. Kuni see on sees, ei ilmu ühtegi hüpikteadet ja läbikriipsutatud kella indikaator istub ribal, et sulle meelde tuletada, miks töölaud on vaikseks jäänud.

Midagi ei lähe siiski kaotsi. Vaigistatud märguanded hoitakse tagasi: too viimased paarid `Super + Shift + Alt + ,` abil ekraanile tagasi. Vaata ülejäänu kohta [teated](10-notices.md).

Kaks liiki sõnumeid pääsevad siiski läbi: Omarchy enda kinnitushüpikud millegi kohta, mida sa just tegid ("Teema vahetatud", "Ekraanipilt salvestatud"), ja käsurealt saadetud kriitilised hoiatused. Vestlusrakendused, mis märgivad kõik kriitiliseks, et end sinu ette sundida, ei kvalifitseeru.

### Jõudeolek

Jõudeoleku käitumine kuulub Omarchy kestale ja ajastused on ülemise taseme `idle` plokk failis `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Mõlemad numbrid on sekundid, mida loetakse hetkest, mil sa jõude jäid — mitte teineteisest. Nii et vaikeseadetega tuleb ekraanisäästja esile kahe ja poole minuti pärast ja lukustuskuva võtab viie minuti pärast üle, olenemata sellest, kas ekraanisäästja töötas või mitte. Salvesta fail ja kest võtab uued ajastused kohe kasutusele.

Kui jätad ekraanisäästja enne lukustamise tähtaega kõrvale, loetakse see aktiivsuseks ja ootel lukustamine tühistatakse. Sa ei jää lukustatuks selle eest, et oma masinale pilgu heidad.

Jõudeolekul lukustamise täielikuks peatamiseks lülitab `Super + Ctrl + I` — või `omarchy toggle idle` — ärkvel püsimise sisse ja ribale ilmub kohvitassi indikaator. See on see, mida vajutada enne pikka esitlust või buildi, mida jälgida tahad. Vajuta uuesti, et naasta tavarežiimi. `omarchy toggle idle status` prindib praeguse oleku JSON-ina, kui sul on seda skriptist vaja.

See puudutab lukustamist ja ekraanisäästjat, mitte toidet. Peatamisel ja talveunel on oma seadistus jaotises [süsteemi unerežiim](36-system-sleep.md).

### Ekraanisäästja

Omarchy ekraanisäästja on ASCII kunst, mis jookseb läbi juhuslike tekstiefektide, üks eksemplar iga monitori kohta. Mis tahes klahv või hiire liigutus väljub sellest.

Sa saad selle nõudmisel käivitada jaotisest _System > Screensaver_ (`Super + Esc`), mis sunnib selle esile isegi siis, kui oled jõudeoleku ekraanisäästja välja lülitanud. Vaikimisi ei ole sellega seotud ühtegi kiirklahvi.

`omarchy toggle screensaver` lülitab jõudeoleku oma välja, kui eelistad minna otse töötamiselt lukustatuks. Mis tahes klahv, klõps, kerimine või hiire liigutus sulgeb selle.

Logo, mille see joonistab, saad ise muuta jaotises _Appearance > Branding > Screensaver_. Laadi üles png või svg ja Omarchy teisendab selle ASCII-ks. Vaata [bränding](41-branding.md).

### Lukustuskuva

`Super + Ctrl + L` lukustab masina. See käivitab Omarchy kesta lukustuskuva, muudab ekraani tühjaks, lähtestab klaviatuuripaigutuse esimesele, et sa ei kirjutaks oma parooli vales tähestikus, ja — kui sul see töötab — lukustab lahkumisel 1Passwordi.

Lukustuskuva võtab vastu parooli ja see võtab vastu ka sõrmejälje, kui oled selle seadistanud. Seda ja teisi autentimisviise käsitletakse jaotises [riistvaraline autentimine](37-hardware-authentication.md).
