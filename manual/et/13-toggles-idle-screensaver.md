# Lülitid, jõudeolek ja ekraanisäästja

Palju sellest, mida igapäevaselt muudad, pole päriselt seade. See on režiim, mille lülitad tunniks ajaks sisse ja uuesti välja: öövalgus, kui töötad hilja, ära sega, kui esitled, püsi ärkvel, kui midagi vaatad. Omarchy nimetab neid lülititeks ja need kõik toimivad samamoodi — kiirklahv, menüükirje ja käsk, kõik sama lüliti juurde jõudmas.

### Lülita menüü

`Super + Ctrl + O` avab _Käivita > Lülita_ otse või saad sinna kõndida Omarchy menüüst (`Super + Space`). Kõik selles loendis on lüliti, mida saad klõpsata, mõtlemata sellele, kus olek elab. Lülitid selle kohta, kuidas töölaud välja näeb, asuvad selle kõrval _Käivita > Välimus_ all.

Terminalist on samad lülitid `omarchy toggle <thing>`. Käivita `omarchy toggle` omaette, et kogu rühma näha.

| Lüliti | Kiirklahv | Käsk |
| ------ | ------ | ------- |
| Öövalgus | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Vaigista teavitused | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Püsi ärkvel (ilma jõude lukuta) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Krahhide salvestus | — | `omarchy toggle crash-capture` |
| Ekraanisäästja | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) teema sünk | — | `omarchy toggle theme sync` |
| Menüüriba | `Super + Shift + Space` | `omarchy toggle bar` |
| Puuteplaat | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Puuteekraan | — | `omarchy toggle touchscreen` |
| Uinak | — | `omarchy toggle suspend` |
| Hübriid GPU | — | `omarchy toggle hybrid gpu` |

Puuteplaadi, puuteekraani ja hübriid-GPU lülitid asuvad _Käivita > Riistvara_ all (`Super + Ctrl + H`), mitte Lülita all, kuna need ilmuvad ainult siis, kui sul see riistvara päriselt olemas on. Puuteplaadi ja puuteekraani omad elavad üle Hyprlandi uuesti laadimise — keelatud seadme nimi salvestatakse väikesesse olekufaili, mida Hyprland käivitamisel loeb, et selle uuesti keelata.

_Käivita > Välimus_ hoiab menüüriba ja animatsioone, pluss mõnda asja, mis ei ole `omarchy toggle` käsud, kuid käituvad samamoodi: aku protsent ribal, vaikimisi tööala paigutus, aknavahed (`Super + Shift + Backspace`) ja 1 akna ruudu kuvasuhe (`Super + Ctrl + Backspace`).

Enamik neist on lihtsalt märgisefail `~/.local/state/omarchy/toggles/` all. Kui soovid ühel skriptis hargneda, annab `omarchy-toggle-enabled` sulle väljumiskoodi, selle asemel et panna sind otsima:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Märgised on nimetatud väljalülitatud oleku järgi — `screensaver-off`, `suspend-off`, `bar-off` —, nii et nende olemasolu tähendab, et funktsioon on keelatud.

### Näidikud ribal

Kui režiim on sisse lülitatud, saad väikese glüüfi menüüriba keskel kella kõrval. See on näidikute vidin ja see kannab dikteerimist, ekraanisalvestust, ootel meeldetuletusi, öövalgust, ära sega ja püsi ärkvel.

Passiivsed näidikud on peidetud. Hõlju nende ümbritseva ala kohal ja need tuhmuvad sisse tuhmistatuna, nii et saad ühe sisse lülitamiseks klõpsata, teadmata selle kiirklahvi. Aktiivsel klõpsamine lülitab selle tagasi välja. Kui eelistad neid kogu aeg näha, sea `alwaysShow` väärtuseks `true` kirjel `omarchy.indicators` failis `~/.config/omarchy/shell.json` — vt [menüüriba](05-the-top-bar.md) selle kohta, kuidas riba vidinaid seadistatakse.

### Öövalgus

`Super + Ctrl + N` soojendab ekraani 4000K-ni ja selle uuesti vajutamine paneb selle tagasi 6500K-ni. Seda ajab hyprsunset, mille lüliti käivitab sinu eest, kui see juba ei tööta.

Vaikimisi ei tee hyprsunset su ekraaniga üldse midagi. `~/.config/hypr/hyprsunset.conf` tarnitakse identsusprofiiliga just selleks, et ekraan jääks puutumata, kuni soojust palud. Kui eelistad, et see lülituks kella järgi, asenda see ajaprofiiliga:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Seejärel käivita hyprsunset sisselogimisel, lisades `o.launch_on_start("hyprsunset")` faili `~/.config/hypr/autostart.lua`. Lüliti kasutatav 4000K/6500K paar on fikseeritud, nii et seadistusfail on koht, kuhu lähed, kui soovid teistsugust temperatuuri.

### Ära sega

`Super + Ctrl + ,` vaigistab teavitused. Ükski hüpik ei ilmu, kui see on sisse lülitatud, ja läbikriipsutatud kella näidik asub ribal, et meelde tuletada, miks töölaud vaikseks on jäänud.

Mitte miski ei lähe aga kaotsi. Vaigistatud teavitus kirjutatakse otse su teavituste ajaloosse, mis on täpselt see kanne, mida soovid, kui tagasi tuled ja mõtled, millest ilma jäid. Ava see `Super + Shift + Alt + ,` abil. Ülejäänud teavitusloo jaoks vt [märguanded](10-notices.md).

Kaks liiki sõnumeid pääsevad siiski läbi: Omarchy enda kinnitus-hüpikud millegi eest, mida just tegid ("Theme changed", "Screenshot saved"), ja käsurealt saadetud kriitilised hoiatused. Vestlusrakendused, mis tähistavad kõike kriitilisena, et end su ette sundida, ei kvalifitseeru.

### Jõudeolek

Omarchy kest omab jõudeoleku käitumist ja ajad on ülemise taseme `idle` plokk failis `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Mõlemad numbrid on sekundid, mis loetakse hetkest, mil jõude jäid — mitte teineteisest. Nii et vaikeväärtustega tuleb ekraanisäästja üles kahe ja poole minuti pärast ja lukuekraan võtab üle viie minuti kohal, olenemata sellest, kas ekraanisäästja töötas. Salvesta fail ja kest võtab uued ajad kohe üles.

Kui jätad ekraanisäästja enne luku tähtaega maha, loetakse seda tegevuseks ja ootel lukk tühistatakse. Sind ei lukustata välja masinale pilgu heitmise eest.

Et jõudeoleku korral lukustamine täielikult peatada, lülitab `Super + Ctrl + I` — või `omarchy toggle idle` — püsi ärkvel sisse ja kohvitassi näidik ilmub ribale. Seda tuleb vajutada enne pikka esitlust või ehitamist, mida soovid jälgida. Vajuta seda uuesti, et tavapärase juurde tagasi minna. `omarchy toggle idle status` prindib praeguse oleku JSON-ina, kui sul seda skriptist vaja on.

See puudutab lukustamist ja ekraanisäästjat, mitte toidet. Uinakul ja talveunel on oma seadistus dokumendis [süsteemi uni](36-system-sleep.md).

### Ekraanisäästja

Omarchy ekraanisäästja on ASCII kunst, mis jookseb läbi juhuslike tekstiefektide, üks eksemplar kuvari kohta. Mis tahes klahv või hiireliigutus lahkub sellest.

Saad selle nõudmisel käivitada _Süsteem > Ekraanisäästja_ alt (`Super + Esc`), mis sunnib selle üles isegi siis, kui oled jõude-ekraanisäästja välja lülitanud. Sellel pole vaikimisi kiirklahvi seotud.

`omarchy toggle screensaver` on see, mis jõudeoleku oma välja lülitab, kui eelistad minna otse töötamisest lukustatuks. See vajab terminali, mida teab seadistada — Alacritty, Foot, Ghostty või Kitty — ja ütleb seda, kui su vaiketerminal on midagi muud.

Logo, mille see joonistab, on sinu muuta _Stiil > Ekraanisäästja_ alt. Laadi üles png või svg ja Omarchy teisendab selle ASCII-ks. Vt [bränding](41-branding.md).

### Lukuekraan

`Super + Ctrl + L` lukustab masina. See käivitab lukuekraani Omarchy kestast, tühjendab ekraani, lähtestab su klaviatuuripaigutuse esimesele, et sa ei trükiks parooli vales tähestikus, ja — kui see sul töötab — lukustab 1Passwordi väljapääsul.

Lukuekraan võtab parooli ja see võtab ka sõrmejälje, kui oled selle seadistanud. See ja muud autentimisviisid on käsitletud dokumendis [riistvaraline autentimine](37-hardware-authentication.md).
