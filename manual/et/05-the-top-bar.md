# Ülemine riba

Ekraani ülaosas olev riba on Omarchy riba. See ei ole külge poltitud olekuriba, vaid osa Omarchy kestast, ühest pikaajalisest Quickshell protsessist, mis joonistab ka menüü, teavitused, OSD hüpikud ja lukustuskuva. Seepärast sobitub see teemalt täiuslikult kõige muuga ja paneel avaneb kohe, selle asemel et uut rakendust käivitada.

See on ka ainus töölaua osa, mis on alati ekraanil, nii et tasub teada, mida kõik need väikesed glüüfid teevad.

## Mis sellel vaikimisi on

Ribal on kolm jaotist. Vasakul istub Omarchy logo (menüükäivitaja) ja tööalade näitajad. Keskel on olekunäitajad, kell, Elsewhen (maailmakell), ilm ja Omarchy värskendusmärk. Paremal: süsteemisalv, klaviatuuripaigutus (kui on seadistatud rohkem kui üks paigutus või sisestusmeetod), agendid, bluetooth, võrk, heli, ekraan ja toide.

Mõned neist ilmuvad ainult siis, kui neil on midagi öelda. Klaviatuuripaigutus ilmub ainult siis, kui oled seadistanud rohkem kui ühe paigutuse või sisestusmeetodi. Värskendusmärk ilmub ainult siis, kui Omarchy värskendus ootab.

## Klõpsamine

Peaaegu iga vidin teeb vasaku, parema ja keskmise klõpsu korral midagi ning mitmed reageerivad kerimisele. See on osa, millest inimesed mööda vaatavad — parem ja keskmine nupp on need, kuhu on peidetud palju head kraami.

| Vidin | Vasak | Parem | Keskmine / kerimine |
| --- | --- | --- | --- |
| Menüü | Omarchy menüü | Uus terminal | — |
| Tööalad | Fokuseeri see tööala sellel monitoril | — | Kerimine: järgmine/eelmine tööala |
| Kell | Kalendri hüpik | Vaheta sildiformaati tsükliliselt | Keskmine: ajavööndi valija |
| Maailmakell | Maailmakella paneel | Värskenda | Keskmine: värskenda |
| Ilm | Ilmaprognoosi hüpik | Täielik ilm teavitusena | Keskmine: värskenda |
| Heli | Heli paneel | Vaigista | Keskmine: paneel · kerimine: helitugevus |
| Mikrofon | Vaigista mikrofon | — | Keskmine: heli paneel · kerimine: sisendi helitugevus |
| Võrk | Võrgupaneel | — | — |
| Bluetooth | Bluetoothi paneel | Lülita raadio sisse/välja | — |
| Ekraan | Ekraanipaneel | — | Kerimine: heledus |
| Toide | Toitepaneel | Lülita aku protsent sisse/välja | — |
| Meedia | Esita/peata | Albumikaane hüpik | Keskmine: järgmine · kerimine: eelmine/järgmine |
| Agendid | Agentide paneel | Käivita oma agent | Keskmine: värskenda kasutust |
| Salv | Hõlju, et sahtel paljastada | Paremklõps noolel, et hallata | — |
| Omarchy värskendus | Käivita värskendus | — | — |

Kõik selles tabelis ei ole sinu ribal karbist võttes. Meediavidin (MPRIS praegu mängitav, koos keriva loo ja esitajaga) ja mikrofonividin on mõlemad sisse ehitatud, kuid vaikimisi välja lülitatud — lisa need soovi korral, nagu allpool kirjeldatud.

## Paneelid

Ribaikoonil klõpsamine avab paneeli, mis on korralik hüpik liugurite, loendite ja klaviatuuriga navigeerimisega, mitte lihtsalt kohtspikker. Igal neist on ka kiirklahv, nii et sa ei pea kunagi sihtima 16-pikslilist glüüfi:

| Kiirklahv | Paneel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | Toggle the nth panel in the right section |

Paneelid ei ole lihtsalt näidikud. Need on kohad, kus sa asja päriselt ära teed:

- **Heli** sisaldab peamist helitugevuse liugurit, väljundseadme valijat ja rakendustepõhist mikserit, nii et saad selle ühe brauserikaardi vaiksemaks keerata ilma kõike muud puudutamata.
- **Võrk** skannib Wi-Fi võrke, näitab signaali tugevust, loob ühenduse ja laseb sul DNS pakkujat valida.
- **Bluetooth** loetleb sinu seadmed koos ühendamise/ühenduse katkestamise ja aku tasemetega.
- **Toide** näitab aku statistikat, vahetab toiteprofiile (see mäletab eraldi valikut aku ja AC jaoks) ja prindib veidi süsteemiinfot.
- **Ekraan** sisaldab heleduse liugurit, teksti suurust, monitori skaleerimise eelseadeid ja — kui sul on rohkem kui üks ekraan — monitoripõhiseid juhtnuppe. Põhjalikuma loo jaoks vaata [monitorid](33-monitors.md).
- **Kell** avab kuuvõrgustiku ISO nädalanumbrite ja kuu vahetamisega.
- **Maailmakell** hoiab iga linna jaoks üht rida koos selle ilma ja sellega, kuidas selle päev läheb. Otsing leiab nii linnu kui ka ajavööndeid, nii et Fort Lauderdale on Fort Lauderdale, mitte New York. Kui ülaosas olev rida nimetab vale linna, klõpsa sellel ja ütle, kus sa oled; vali koht teises ajavööndis ja süsteemikell kolib sinna ka, mis on reisimisel käepärane. Hõlju linna kohal ja klõpsa inimese nuppu, et öelda, kes seal elab — lihtsad nimed või `@` GitHubi kasutajanimed, et tuua kaasa ka nende näod.

Iga paneel võtab vastu nii klaviatuuri kui ka hiire: nooled liigutavad, Return aktiveerib, Tab liigub naaberpaneelile ja Escape sulgeb.

`Super + Ctrl + 1-9` loendab paneele vasakult paremale paremas jaotises, jättes salve vahele, kuna sellel pole oma paneeli. Nii vastab number ikoonile, millele sa sihiksid.

### Tailscale and Dropbox

Kaks vidinat ilmuvad ribale alles siis, kui installid vastava teenuse **Install → Service** alt, ja mõlemat tasub tunda, sest need teevad rohkem kui lihtsalt olekut näitavad.

**Tailscale** paneel ühendab tailnetiga ja katkestab sellega ühenduse, vahetab kontode vahel ja valib väljundsõlme (selles loendis ilmuvad nii sinu enda masinad kui ka Mullvad piirkonnad). See sirbib ka sinu masinaid — ja kui üks on valitud, saadab `s` sellele Taildropi kaudu faile, mis on kiireim viis faili telefoni või teise sülearvutisse liigutamiseks. `c` kopeerib masina IP, `n` selle nime ja `d` selle täieliku DNS nime. Igal masina real on ka saatmisnupp, kui eelistad klõpsata. Sama asi terminalist on `omarchy tailscale send <machine> [file...]`.

**Dropbox** paneel tegeleb sisselogimisega, näitab, kui palju salvestusruumi oled kasutanud, ja loetleb hiljuti sünkroonitud faile.

Kummagi teenuse eemaldamine võtab selle vidina ribalt jälle maha.

## Näitajad

Väike kogum keskel on näitajate vidin. Need on olekuglüüfid režiimide jaoks, mille oled sisse lülitanud: ära sega, öövalgus, järjekorras olev [meeldetuletus](09-reminders.md), aktiivne ekraani salvestamine ja ärkvel püsimine, lisaks hoiatused, kui paroolita sudo on sisse lülitatud või keegi on kaugseansiga ühendatud. Need süttivad, kui režiim on aktiivne, ja püsivad muidu eemal — hõlju täpselt nende kõrval, kus mitteaktiivsed asuksid, et neid piiluda. Näitajal klõpsamine lülitab selle režiimi sisse/välja. Üks on ainult oleku jaoks: kaugseanss süttib punaselt, kui keegi on selle masinaga gliffi kaudu ühendatud.

Kui eelistad, et need oleksid alati nähtavad, sea vidinal `alwaysShow` väärtuseks `true`. Ja kui hoolid ainult mõnest neist, loetle soovitud `items` all: `["Dnd", "Reminder", "NightLight"]`. Sul võib olla rohkem kui üks näitajate vidin, nii et eri jaotised saavad näidata eri alamhulki.

## Riba ümberkorraldamine

Riba seadistab ennast ise. Sa ei pea asjade liigutamiseks konfiguratsioonifaili avama.

Haara tühjast kohast riba keskosa ümbruses ja lohista see teise ekraaniserva poole ning riba kolib sinna — vasak, parem, ülemine või alumine serv töötab kõik, ja iga vidin kohandub (vertikaalsed ribad taanduvad kompaktsetele ainult ikooniga vormidele). Klõps-ja-hoia alustab sama lohistamist. Tee topeltklõps vasaku nupuga samal tühjal kohal, et riba tausta tsükliliselt vahetada läbipaistvast klaasjaks ja läbipaistmatuks. Ja lohista iga vidinat, et see ümber järjestada või teise jaotisse visata; teised vidinad libisevad laiali, et teha ruumi sinna, kuhu see maandub.

Riba keskosa on kast: mis iganes selle sees on, püsib ühe rühmana keskel, ja selle mõlemal küljel olevad vidinad ripuvad selle servade küljes. Kui vidinat lohistad, kuvatakse kast kontuurina või joonena üle riba, kui see on tühi, ja saad selle sisse või selle kõrvale kukutada. Kui kukutamine maanduks kasti, kasvab kast, et vidin sisse võtta.

Vidin, mida soovid käepärast hoida, kuid mitte alati vaateväljas, võib minna salve sahtlisse: lohista see salvele ja sahtel avaneb, et see vastu võtta. See istub seal rakenduste ikoonide järel, ilmub alati, kui sahtel ilmub, ja hoiab oma sahtlit avatuna, kuni selle paneel on üleval. Lohista see tagasi ribale, et see tagasi panna.

Kui eelistad menüüst valida, on **Appearance → Menu Bar** all asukoht ja **Bar Background** valib, kuidas riba joonistatakse: **Opaque Bar**, **Glassy Bar** (läbipaistev, taga olev hägustatud) või **Clear Bar**.

Samadel asjadel on käsud, mis on see, mida soovid [dotfiles](31-dotfiles.md) seadistuse jaoks:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Vidina täielikuks lisamiseks või eemaldamiseks kasuta pluginakäske. `omarchy plugin list` prindib iga vidina, mida kest teab, koos selle id-ga, ja seejärel:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Riba peitmine

`Super + Shift + Space` lülitab riba välja ja tagasi sisse ilma kesta tapmata — paneelid ja kiirklahvid töötavad edasi, saad lihtsalt pikslid tagasi. See on ka menüüs **Appearance → Menu Bar → Hide Bar** all.

## Konfiguratsioonifail

Kõik see on salvestatud `~/.config/omarchy/shell.json` faili `bar` võtme alla. Siin on kärbitud versioon:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Iga vidin on üks kirje ühes viiest paigutusmassiivist ja selle seaded asuvad sellel kirjel reasiseselt — eraldi seadete faili ei ole ja `config` alamobjekti ei ole. Kella `format`, `formatAlt` (see, millele paremklõps tsükliliselt vahetab) ja `verticalFormat` elavad kõik otse seal `{ "id": "omarchy.clock" }` peal.

`center` on riba keskosas olev kast: kõik selle sees on ekraanil ühe rühmana keskel. `centerBegin` ja `centerEnd` ripuvad kasti mõlemal küljel, mistõttu kell püsib täpselt keskel isegi siis, kui ilm ja värskendusmärk tulevad ja lähevad. Pane `center` alla rohkem kui üks vidin ja need on koos keskel; jäta see tühjaks ja `centerBegin` ja `centerEnd` kohtuvad riba keskel.

Üks reegel, mis tasub endale selgeks teha: **kui sul on oma `shell.json`, on see kanoniline**. Kuni sa midagi ei kohanda, loeb kest Omarchy vaikefaili. Hetkel, kui lohistad vidinat, käivitad `omarchy bar` või redigeerid faili ise, kuulub see sulle — sügavat ühendamist ei toimu, nii et tulevaste Omarchy väljalasete uued vaikimisi vidinad ei ilmu sinu ribale automaatselt. `omarchy bar defaults` paneb tarnitud paigutuse tagasi, kui iganes soovid puhtalt lehelt alustada.

Sama fail hoiab ka sinu jõudeaja ajastusi ülemisel tasemel, väljaspool `bar` võtit: `idle.screensaver` ja `idle.lock`, mõlemad sekundites alates jõudeolekusse minekust. Nii käivitub vaikimisi ekraanisäästja 150 sekundi pärast ja lukk 300 sekundi pärast.
