# Ülemine riba

Riba ekraani ülaosas on Omarchy riba. See ei ole külge poltitud olekuriba, vaid osa Omarchy kestast, ühest pikaajalisest Quickshell protsessist, mis joonistab ka menüü, teavitused, OSD hüpikaknad ja lukustuskuva. Seepärast sobib see temaatiliselt täiuslikult kõigega muuga ja paneel avaneb kohe, selle asemel et käivitada uus rakendus.

See on ka ainus töölaua osa, mis on alati ekraanil, nii et tasub teada, mida kõik need väikesed glüüfid teevad.

## Mis sellel vaikimisi on

Ribal on kolm jaotist. Vasakul asuvad Omarchy logo (menüükäivitaja) ja tööalade indikaatorid. Keskel on olekuindikaatorid, kell, Elsewhen (maailmakell), ilm ja Omarchy värskenduse märk. Paremal: süsteemisalv, klaviatuuripaigutus (kui konfigureeritud on rohkem kui üks), agendid, bluetooth, võrk, heli, ekraan ja toide.

Mõned neist ilmuvad ainult siis, kui neil on midagi öelda. Klaviatuuripaigutus ilmub ainult siis, kui oled konfigureerinud rohkem kui ühe paigutuse. Värskendusmärk ilmub ainult siis, kui Omarchy värskendus ootab. Ja agentide ikoon ilmub esimest korda, kui Omarchy leiab masinast AI kodeerimise kasutust (vt [AI](17-ai.md)).

## Klõpsamine

Peaaegu iga vidin teeb vasaku, parema ja keskmise klõpsu korral midagi ning mitmed reageerivad kerimisele. See on osa, millest inimesed mööda vaatavad — parem ja keskmine nupp on kohad, kuhu on peidetud palju head kraami.

| Vidin | Vasak | Parem | Keskmine / kerimine |
| --- | --- | --- | --- |
| Menüü | Omarchy menüü | Uus terminal | — |
| Tööalad | Fokuseeri see tööala sellel kuvaril | — | Kerimine: järgmine/eelmine tööala |
| Kell | Kalendri hüpikaken | Vaheta sildi vormingut järjest | Keskmine: ajavööndi valija |
| Ilm | Ilmaprognoosi hüpikaken | Täielik ilm teavitusena | Keskmine: värskenda |
| Heli | Helipaneel | Vaigista | Keskmine: paneel · kerimine: helitugevus |
| Mikrofon | Vaigista mikrofon | — | Keskmine: helipaneel · kerimine: sisendi helitugevus |
| Võrk | Võrgupaneel | — | — |
| Bluetooth | Bluetoothi paneel | Lülita raadio sisse/välja | — |
| Ekraan | Ekraanipaneel | — | Kerimine: heledus |
| Toide | Toitepaneel | Lülita aku protsendi kuvamine sisse/välja | — |
| Meedia | Esita/peata | Kaanepildi hüpikaken | Keskmine: järgmine · kerimine: eelmine/järgmine |
| Agendid | Agentide paneel | Käivita oma agent | Keskmine: järgmine tellimus |
| Salv | Hõlju sahtli näitamiseks | Paremklõps noolel haldamiseks | — |
| Omarchy värskendus | Käivita värskendus | — | — |

Kõik selles tabelis ei ole sinu ribal karbist võttes. Meediavidin (MPRIS praegu esitatav, keriva loo ja esitajaga) ja mikrofonividin on mõlemad sisse ehitatud, kuid vaikimisi välja lülitatud — lisa need, kui soovid, nagu allpool kirjeldatud.

## Paneelid

Ribaikoonil klõpsamine avab paneeli, mis on korralik hüpikaken liugurite, loendite ja klaviatuuriga navigeerimisega, mitte kohtspikker. Igal neist on ka kiirklahv, nii et sa ei pea kunagi sihtima 16-pikslist glüüfi:

| Kiirklahv | Paneel |
| --- | --- |
| `Super + Ctrl + A` | Heli |
| `Super + Ctrl + N` | Võrk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ekraan |
| `Super + Ctrl + P` | Toide |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Maailmakell |
| `Super + Ctrl + 1-9` | Lülita parema jaotise n-ndat paneeli sisse/välja |

Paneelid ei ole ainult näidikud. Need on kohad, kus sa asja päriselt ära teed:

- **Heli** puhul on peamine helitugevuse liugur, väljundseadme valija ja rakendusepõhine mikser, nii et saad selle ühe brauserikaardi vaiksemaks keerata, puudutamata kõike muud.
- **Võrk** otsib Wi-Fi võrke, näitab signaali tugevust, loob ühenduse ja laseb sul valida DNS-i pakkuja.
- **Bluetooth** loetleb sinu seadmed koos ühendamise/lahutamise ja akutasemetega.
- **Toide** näitab aku statistikat, vahetab toiteprofiile (see jätab aku ja AC jaoks eraldi valiku meelde) ja kuvab veidi süsteemiinfot.
- **Ekraan** sisaldab heleduse liugurit, teksti suurust, kuvari skaleerimise eelseadistusi ja — kui sul on rohkem kui üks ekraan — iga kuvari juhtnuppe. Sügavama loo jaoks vaata [kuvareid](33-monitors.md).
- **Kell** avab kuuvõrgustiku ISO nädalanumbrite ja kuude kaupa liikumisega.
- **Maailmakell** hoiab iga linna jaoks ühte rida koos selle ilma ja sellega, kuidas selle päev läheb. Otsing leiab nii linnu kui ka ajavööndeid, nii et Fort Lauderdale on Fort Lauderdale, mitte New York. Kui ülaosas olev rida nimetab valet linna, klõpsa sellel ja ütle, kus sa oled; vali koht teises ajavööndis ja süsteemikell liigub samuti sinna, mis on reisimisel mugav. Hõlju linna kohal ja klõpsa inimese nuppu, et öelda, kes seal elab — tavalised nimed või `@` GitHubi kasutajanimed, et tuua kaasa ka nende näod.

Iga paneel võtab vastu nii klaviatuuri kui ka hiire: nooled liigutavad, Return aktiveerib, Tab liigub naaberpaneelile ja Escape sulgeb.

`Super + Ctrl + 1-9` loendab paneele vasakult paremale paremas jaotises, jättes salve vahele, kuna sellel pole oma paneeli. Nii vastab number ikoonile, millele sa osutaksid.

### Tailscale ja Dropbox

Veel kaks vidinat ilmuvad ribale alles siis, kui installid vastava teenuse jaotisest **Install → Service**, ja mõlemat tasub teada, sest need teevad rohkem kui ainult olekut raporteerivad.

**Tailscale** paneel ühendab tailnetiga ja lahutab sellest, vahetab kontode vahel ja valib väljumisõlme (selles loendis kuvatakse nii sinu oma masinad kui ka Mullvadi piirkonnad). See sirbib ka sinu masinaid — ja kui üks on valitud, saadab `s` sellele faile Taildropi kaudu, mis on kiireim viis faili telefoni või teise sülearvutisse liigutamiseks. `c` kopeerib masina IP, `n` selle nime ja `d` selle täieliku DNS-nime. Igal masina real on ka saatmisnupp, kui eelistad klõpsata. Sama asi terminalist on `omarchy tailscale send <machine> [file...]`.

**Dropbox** paneel tegeleb sisselogimisega, näitab, kui palju salvestusruumi oled kasutanud, ja loetleb hiljuti sünkroonitud faile.

Kummagi teenuse eemaldamine võtab selle vidina ribalt tagasi maha.

## Indikaatorid

Väike kobar keskel on indikaatorite vidin. Need on olekuglüüfid režiimide jaoks, mille oled sisse lülitanud: mitte segada, öövalgus, järjekorras olev [meeldetuletus](09-reminders.md), aktiivne ekraani salvestamine, ärkvel püsimine ja [dikteerimine](11-text-extraction-dictation.md). Need süttivad, kui režiim on aktiivne, ja püsivad muidu eemal — hõlju nende kõrval, kus passiivsed asuksid, et neid piiluda. Indikaatoril klõpsamine lülitab selle režiimi sisse/välja. Veel üks on ainult olek: kaugseanss süttib punaselt, kui keegi on selle masinaga gliffi kaudu ühendatud.

Kui eelistad, et need oleksid alati nähtavad, määra vidinal `alwaysShow` väärtuseks `true`. Ja kui hoolid ainult mõnest neist, loetle soovitud `items` all: `["Dnd", "Reminder", "NightLight"]`. Sul võib olla rohkem kui üks indikaatorite vidin, nii et erinevad jaotised saavad näidata erinevaid alamhulki.

## Riba ümberkorraldamine

Riba konfigureerib ennast ise. Asjade liigutamiseks ei pea sa konfiguratsioonifaili avama.

Haara keskmise ümbruses tühjast riba laigust ja lohista see teise ekraaniserva poole ning riba liigub sinna — vasak, parem, ülemine või alumine serv sobivad kõik ja iga vidin kohandub (vertikaalsed ribad taanduvad kompaktsetele ainult ikoonidega vormidele). Klõps-ja-hoia käivitab sama lohistamise. Tee topeltvasakklõps samal tühjal ruumil, et vahetada riba tausta järjest läbipaistvast klaasjaks ja läbipaistmatuks. Ja lohista mis tahes vidinat, et seda ümber järjestada või teise jaotisse visata; teised vidinad libisevad lahku, et teha ruumi sinna, kuhu see maandub.

Riba keskosa on kast: mis iganes selle sees on, püsib ühe rühmana keskel ja selle mõlemal küljel olevad vidinad ripuvad selle servade küljes. Vidina lohistamise ajal kuvatakse kast kontuurina või, kui see on tühi, joonena üle riba, ja saad selle sisse või selle kõrvale kukutada. Kui kukutamine maanduks kasti, kasvab kast vidina vastuvõtmiseks.

Vidin, mida soovid käepärast, kuid mitte alati nähtaval, võib minna salve sahtlisse: lohista see salvele ja sahtel avaneb selle vastuvõtmiseks. See istub seal rakenduseikoonide järel, ilmub alati, kui sahtel ilmub, ja hoiab oma sahtli avatuna, kui selle paneel on üleval. Lohista see ribale tagasi, et see tagasi panna.

Kui eelistad menüüst valida, on jaotises **Appearance → Menu Bar** asukoht ja **Bar Background** valib, kuidas riba joonistatakse: **Opaque Bar**, **Glassy Bar** (läbipaistev, taga olev hägustatud) või **Clear Bar**.

Samatel asjadel on käsud, mida soovid [dotfiles](31-dotfiles.md) seadistuse jaoks:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Vidina täielikuks lisamiseks või eemaldamiseks kasuta pistikprogrammi käske. `omarchy plugin list` prindib iga vidina, mida kest teab, koos selle id-ga, ja seejärel:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Riba peitmine

`Super + Shift + Space` lülitab riba välja ja tagasi sisse kesta tapmata — paneelid ja kiirklahvid töötavad edasi, saad lihtsalt pikslid tagasi. See on ka menüüs jaotise **Appearance → Menu Bar → Hide Bar** all.

## Konfiguratsioonifail

Kõik see on salvestatud faili `~/.config/omarchy/shell.json` võtme `bar` alla. Siin on kärbitud versioon:

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

Iga vidin on üks kirje ühes viiest paigutuse massiivist ja selle seaded asuvad sellel kirjel reasiseselt — eraldi seadete faili ei ole ja `config` alamobjekti ei ole. Kella `format`, `formatAlt` (millele paremklõps järjest vahetab) ja `verticalFormat` elavad kõik otse seal kirjel `{ "id": "omarchy.clock" }`.

`center` on riba keskel olev kast: kõik selle sees on ekraanil ühe rühmana keskel. `centerBegin` ja `centerEnd` ripuvad kasti mõlemal küljel, nii püsib kell täpselt keskel isegi siis, kui ilm ja värskendusmärk tulevad ja lähevad. Pane `center` alla rohkem kui üks vidin ja need on koos keskel; jäta see tühjaks ja `centerBegin` ning `centerEnd` kohtuvad riba keskel.

Üks reegel, mis tasub endale selgeks teha: **kui sul on oma `shell.json`, on see kanooniline**. Kuni sa midagi ei kohanda, loeb kest Omarchy vaikefaili. Hetkel, kui lohistad vidinat, käivitad `omarchy bar` või muudad faili ise, kuulub see sulle — sügavat liitmist ei toimu, nii et uued vaikimisi vidinad tulevastes Omarchy väljaannetes ei ilmu sinu ribale automaatselt. `omarchy bar defaults` paneb tarnitud paigutuse tagasi alati, kui soovid puhtalt lehelt alustada.

Sama fail hoiab ka sinu jõudeaja ajastusi ülemisel tasemel, väljaspool `bar` võtit: `idle.screensaver` ja `idle.lock`, mõlemad sekundites alates jõudeolekusse minekust. Nii käivitub vaikimisi ekraanisäästja 150 sekundi ja lukk 300 sekundi pärast.
