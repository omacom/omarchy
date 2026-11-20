# Lülitid, jõudeolek ja ekraanisäästja

Palju sellest, mida sa iga päev muudad, ei ole tegelikult seade. See on režiim, mille lülitad tunniks ajaks sisse ja siis jälle välja: öövalgus, kui töötad hilja, mitte segada režiim, kui esitled, ärkvel püsimine, kui midagi vaatad. Omarchy nimetab neid lülititeks ja need kõik töötavad samamoodi — kiirklahv, menüüpunkt ja käsk tabavad kõik ühte ja sama lülitit.

### Lülitite menüü

`Super + Ctrl + O` avab otse _Päästik > Lüliti_ või saad sinna kõndida Omarchy menüüst (`Super + Space`). Kõik selles loendis olevad asjad on lülitid, mida saad ümber lülitada, mõtlemata sellele, kus olek elab. Lülitid selle kohta, kuidas töölaud välja näeb, asuvad selle kõrval, _Välimus_ all.

Terminalist on samad lülitid `omarchy toggle <thing>`. Käivita `omarchy toggle` üksinda, et näha kogu rühma.

| Lüliti | Kiirklahv | Käsk |
| ------ | ------ | ------- |
| Öövalgus | — | `omarchy toggle nightlight` |
| Vaigista teavitused | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Püsi ärkvel (jõudeolekul ei lukustata) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Kokkujooksmise jäädvustamine | — | `omarchy toggle crash-capture` |
| Ekraanisäästja | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) teema sünkroonimine | — | `omarchy toggle theme sync` |
| Menüüriba | `Super + Shift + Space` | `omarchy toggle bar` |
| Täisekraan-töölaud (ilma ribata, ilma vahedeta) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animatsioonid, hägusus ja varjud | — | `omarchy toggle animations` |
| Puuteplaat | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Puuteekraan | — | `omarchy device touchscreen` |
| Peatamine | — | `omarchy toggle suspend` |
| Hübriid-GPU | — | `omarchy device gpu hybrid` |

Puuteplaadi, puuteekraani ja hübriid-GPU lülitid elavad _Lüliti_ asemel _Päästik > Riistvara_ (`Super + Ctrl + H`) all, kuna need ilmuvad ainult siis, kui sul see riistvara tegelikult olemas on. Puuteplaadi ja puuteekraani omad jäävad Hyprland uuesti laadimisest ellu — keelatud seadme nimi salvestatakse väikesesse olekufaili, mida Hyprland käivitamisel loeb, et see uuesti keelata.

_Välimus_ hoiab menüüriba ja animatsioone ning lisaks mõnda asja, mis ei ole `omarchy toggle` käsud, aga käituvad samamoodi: aku protsent ribal, tööruumide vaikepaigutus ja _Aknad_ all aknavahed (`Super + Shift + Backspace`) ja 1 akna ruudukujuline kuvasuhe (`Super + Ctrl + Backspace`).

Kui Hyprlandil ei ole GPU-d, millega joonistada, ja see renderdab selle asemel CPU-ga (llvmpipe), nagu Macidel, mille GPU-d veel ei toetata, enamikus virtuaalmasinates või kui graafikadraiver ei laadi, lülitab Omarchy selle sessiooni ajaks animatsioonid, hägususe ja varjud välja ja ütleb sulle seda korra teavitusega. _Välimus > Animatsioonid sees_ toob need tagasi ja Omarchy jätab selle ka hilisemate sessioonide jaoks meelde.

Enamik neist on lihtsalt lipufail kausta `~/.local/state/omarchy/toggles/` all. Kui tahad skriptis mõne põhjal hargneda, annab `omarchy-toggle-enabled` sulle otsimise asemel väljundkoodi:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Lipud on nimetatud väljalülitatud oleku järgi — `screensaver-off`, `suspend-off`, `bar-off` — nii et nende olemasolu tähendab, et funktsioon on keelatud.

### Näidikud ribal

Kui režiim on sees, saad ülemise riba keskele kella kõrvale väikese kujutise. See on näidikute vidin ja see kannab ekraanisalvestust, ootel meeldetuletusi, öövalgust, mitte segada režiimi ja ärkvel püsimist, lisaks hoiatusi, kui paroolita sudo on sees või keegi on kaugsessiooniga ühendatud.

Mitteaktiivsed näidikud on peidetud. Hõlju kursoriga ükskõik kus ribal ja need tuhmuvad sisse, nii et saad ühele klõpsata, et see sisse lülitada, ilma selle kiirklahvi teadmata. Aktiivsele klõpsamine lülitab selle uuesti välja. Kui eelistad neid kõiki kogu aeg näha, määra `alwaysShow` väärtuseks `true` kirjel `omarchy.indicators` failis `~/.config/omarchy/shell.json` — vaata [ülemist riba](05-the-top-bar.md), kuidas riba vidinaid konfigureeritakse.

### Öövalgus

Öövalgus soojendab ekraani 4000K-ni ja selle uuesti lülitamine paneb selle tagasi 6500K peale. Lülita seda lülitite menüüst (`Super + Ctrl + O`) või käsuga `omarchy toggle nightlight`. Seda juhib hyprsunset, mille lüliti käivitab sinu eest, kui see juba ei tööta.

Vaikimisi ei tee hyprsunset sinu ekraaniga üldse midagi. `~/.config/hypr/hyprsunset.conf` tuleb identiteediprofiiliga just selleks, et ekraan jääks puutumata, kuni sa soojust küsid. Kui eelistad, et see lülituks kella järgi, asenda see ajaprofiiliga:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Seejärel käivita hyprsunset sisselogimisel, lisades `o.launch_on_start("hyprsunset")` faili `~/.config/hypr/autostart.lua`. Lüliti kasutatav 4000K/6500K paar on fikseeritud, nii et konfiguratsioonifail on koht, kuhu minna, kui tahad teistsugust temperatuuri.

### Mitte segada

`Super + Ctrl + Alt + ,` vaigistab teavitused. Kuni see on sees, ei ilmu ühtegi riba ja läbikriipsutatud kella näidik istub ribal, et sulle meelde tuletada, miks töölaud on vaiksemaks jäänud.

Midagi ei lähe aga kaduma. Vaigistatud teavitused hoitakse tagasi: pane viimased paar tükki `Super + Shift + Alt + ,` abil uuesti ekraanile. Ülejäänu kohta vaata [teateid](10-notices.md).

Kolme liiki sõnumid pääsevad ikka läbi: Omarchy enda kinnitusteaded millegi kohta, mida sa just tegid ("Theme changed", "Screenshot saved"), käsurealt saadetud kriitilised hoiatused ja kinnituskoodid. Vestlusrakendused, mis märgivad kõik kriitiliseks, et end sinu ette sundida, ei kvalifitseeru.

### Jõudeolek

Omarchy kest omab jõudeoleku käitumist ja ajastused on ülemise taseme `idle` plokk failis `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Mõlemad numbrid on sekundid, mida loetakse hetkest, mil sa jõude jäid — mitte üksteisest. Nii et vaikeseadetega tuleb ekraanisäästja üles kahe ja poole minuti pärast ja lukustuskuva võtab viie minuti kohal üle, olenemata sellest, kas ekraanisäästja töötas või mitte. Salvesta fail ja kest võtab uued ajastused kohe kasutusele.

Kui lükkad ekraanisäästja enne lukustamise tähtaega kõrvale, loetakse see aktiivsuseks ja ootel lukustus tühistatakse. Sind ei lukustata välja selle eest, et sa oma masinale pilgu heidad.

Et jõudeolekul lukustamine täielikult peatada, lülitab `Super + Ctrl + I` — või `omarchy toggle idle` — ärkvel püsimise sisse ja ribale ilmub kohvitassi näidik. See on see, mida vajutada enne pikka esitlust või järge, mida vaadata tahad. Vajuta seda uuesti, et normaalsuse juurde tagasi minna. `omarchy toggle idle status` prindib praeguse oleku JSON-ina, kui sul seda skriptist vaja on.

See puudutab lukustamist ja ekraanisäästjat, mitte toidet. Peatamisel ja talveunel on oma seadistus [süsteemi unerežiimis](36-system-sleep.md).

### Ekraanisäästja

Omarchy ekraanisäästja on ASCII-kunst, mis läbib juhuslikke tekstiefekte, iga monitori kohta üks eksemplar. Suvaline klahv või hiire liigutus väljub sellest.

Saad selle nõudmisel käivitada _Süsteem > Ekraanisäästja_ (`Super + Esc`) alt, mis sunnib selle üles isegi siis, kui oled jõudeoleku ekraanisäästja välja lülitanud. Sellele ei ole vaikimisi kiirklahvi seotud.

`omarchy toggle screensaver` on see, mis jõudeoleku oma välja lülitab, kui eelistad minna otse töötamisest lukustatuks. Suvaline klahv, klõps, kerimine või hiire liigutus sulgeb selle.

Logo, mida see joonistab, on sinu muuta, _Välimus > Bränding > Ekraanisäästja_ all. Laadi üles png või svg ja Omarchy teisendab selle ASCII-ks. Vaata [brändingut](41-branding.md).

### Lukustuskuva

`Super + Ctrl + L` lukustab masina. See käivitab Omarchy kestast lukustuskuva, tühjendab ekraani, lähtestab sinu klaviatuuripaigutuse esimesele, et sa ei kirjutaks oma parooli vales tähestikus, ja — kui sul see töötab — lukustab väljapääsul 1Passwordi.

Lukustuskuva võtab parooli ja see võtab ka sõrmejälje, kui oled selle seadistanud. See ja muud autentimisviisid on kaetud [riistvaralises autentimises](37-hardware-authentication.md).
