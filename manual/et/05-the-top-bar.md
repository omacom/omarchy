# Ülariba

Riba ekraani ülaservas on Omarchy riba. See ei ole külge poogitud olekuriba, vaid osa Omarchy kestast, sellest ühest pikalt töötavast Quickshelli protsessist, mis joonistab ka menüü, teavitused, OSD hüpikud ja lukustuskuva. Seepärast sobitub see teemaliselt täiuslikult kõige muuga ja seepärast avaneb paneel kohe, selle asemel et käivitada uus rakendus.

See on ka ainus töölaua osa, mis on alati ekraanil, nii et tasub teada, mida kõik need väikesed glüüfid teevad.

## Mis sellel vaikimisi on

Ribal on kolm jaotist. Vasakul istub Omarchy logo (menüükäivitaja) ja tööruumide indikaatorid. Keskel saad olekuindikaatorid, kella, Elsewheni (maailmakell), ilma ja Omarchy värskendusmärgi. Paremal: süsteemisalv, klaviatuuripaigutus (kui seadistatud on rohkem kui üks), agendid, bluetooth, võrk, heli, ekraan ja toide.

Mõni neist ilmub ainult siis, kui tal on midagi öelda. Klaviatuuripaigutus ilmub ainult siis, kui oled seadistanud rohkem kui ühe paigutuse. Värskendusmärk ilmub ainult siis, kui ootab Omarchy värskendus. Ja agentide ikoon ilmub esimest korda, kui Omarchy leiab masinast AI-koodimise kasutust (vt [AI](17-ai.md)).

## Klõpsates ringi

Peaaegu iga vidin teeb midagi vasaku, parema ja keskmise klõpsuga ning mitu reageerib kerimisele. See on osa, millest inimesed mööda vaatavad — parema ja keskmise nupu taga peitub palju head kraami.

| Vidin | Vasak | Parem | Keskmine / kerimine |
| --- | --- | --- | --- |
| Menüü | Omarchy menüü | Uus terminal | — |
| Tööruumid | Fokuseeri see tööruum sellel monitoril | — | Kerimine: järgmine/eelmine tööruum |
| Kell | Kalendri hüpik | Vaheta sildi vormingut ringis | Keskmine: ajavööndi valija |
| Ilm | Ilmaennustuse hüpik | Täielik ilm teavitusena | Keskmine: värskenda |
| Heli | Helipaneel | Vaigista | Keskmine: paneel · kerimine: helitugevus |
| Mikrofon | Vaigista mikrofon | — | Keskmine: helipaneel · kerimine: sisendi helitugevus |
| Võrk | Võrgupaneel | — | — |
| Bluetooth | Bluetoothi paneel | Lülita raadio sisse/välja | — |
| Ekraan | Ekraanipaneel | — | Kerimine: heledus |
| Toide | Toitepaneel | Lülita aku protsendi kuvamine sisse/välja | — |
| Meedia | Esita/peata | Albumikaane hüpik | Keskmine: järgmine · kerimine: eelmine/järgmine |
| Agendid | Agentide paneel | Käivita oma agent | Keskmine: järgmine tellimus |
| Salv | Sahtli näitamiseks hõlju kohal | Haldamiseks paremklõps noolel | — |
| Omarchy värskendus | Käivita värskendus | — | — |

Kõiki selles tabelis olevaid asju ei ole sinu ribal karbist võttes. Meediavidin (MPRIS praegu mängiv, keriva loo ja esitajaga) ja mikrofonividin on mõlemad sisse ehitatud, kuid vaikimisi väljas — lisa need, kui soovid, nagu allpool kirjeldatud.

## Paneelid

Ribaikoonil klõpsamine avab paneeli, mis on korralik hüpik liugurite, loendite ja klaviatuuriga navigeerimisega, mitte kohtspikker. Igal ühel on ka kiirklahv, nii et sa ei pea kunagi sihtima 16-pikslist glüüfi:

| Kiirklahv | Paneel |
| --- | --- |
| `Super + Ctrl + A` | Heli |
| `Super + Ctrl + N` | Võrk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ekraan |
| `Super + Ctrl + P` | Toide |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Maailmakell |
| `Super + Ctrl + 1-9` | Lülita sisse/välja n-s paneel paremas jaotises |

Paneelid ei ole näidikud. Seal sa tegelikult teedki asja ära:

- **Heli** paneelil on peamine helitugevuse liugur, väljundseadme valija ja rakendusepõhine mikser, nii et saad keerata maha selle ühe brauserikaardi, puudutamata kõike muud.
- **Võrk** skannib Wi-Fi-võrke, näitab signaali tugevust, loob ühenduse ja laseb sul valida DNS-teenusepakkuja.
- **Bluetooth** loetleb sinu seadmed koos ühendamise/ühenduse katkestamise ja akutasemetega.
- **Toide** näitab aku statistikat, vahetab toiterežiime (see jätab meelde eraldi valiku aku ja AC jaoks) ja prindib veidi süsteemiteavet.
- **Ekraan** kannab heleduse liugurit, teksti suurust, monitori skaleerimise eelseadeid ja — kui sul on rohkem kui üks ekraan — monitoripõhiseid juhtnuppe. Sügavama loo jaoks vt [monitorid](33-monitors.md).
- **Kell** avab kuuvõrgustiku ISO nädalanumbrite ja kuude kaupa liikumisega.
- **Maailmakell** hoiab rida iga linna kohta koos selle ilma ja sellega, kuidas selle päev läheb. Otsing leiab nii linnu kui ka ajavööndeid, nii et Fort Lauderdale on Fort Lauderdale, mitte New York. Kui ülaosas olev rida nimetab vale linna, klõpsa sellel ja ütle, kus sa oled; vali koht teises ajavööndis ja süsteemikell liigub sinna kaasa, mis on reisimisel käepärane. Hõlju linna kohal ja klõpsa isikunuppu, et öelda, kes seal elab — tavalised nimed või `@` GitHubi kasutajanimesid, et nende näod kaasa tuua.

Iga paneel võtab vastu nii klaviatuuri kui ka hiire: nooled liiguvad, Return aktiveerib, Tab liigub kõrvalpaneelile ja Escape sulgeb.

`Super + Ctrl + 1-9` loendab paneele vasakult paremale paremas jaotises, jättes salve vahele, kuna sellel pole oma paneeli. Nii vastab number ikoonile, millele sa sihiksid.

### Tailscale ja Dropbox

Kaks vidinat veel ilmuvad ribale alles siis, kui paigaldad vastava teenuse **Paigalda → Teenus** kaudu, ja mõlemat tasub teada, sest need teevad rohkem kui ainult olekut raporteerivad.

**Tailscale'i** paneel ühendab tailneti ja katkestab selle ühenduse, vahetab kontode vahel ja valib väljundisõlme (sinu enda masinad ja Mullvadi piirkonnad ilmuvad mõlemad sellesse loendisse). See sirbib ka sinu masinaid — ja kui üks on valitud, saadab `s` sellele Taildropi kaudu faile, mis on kiireim viis faili telefoni või teise sülearvutisse liigutamiseks. `c` kopeerib masina IP, `n` selle nime ja `d` selle täieliku DNS-nime. Igal masinareal on ka saatmisnupp, kui eelistad klõpsata. Sama asi terminalist on `omarchy tailscale send <machine> [file...]`.

**Dropboxi** paneel tegeleb sisselogimisega, näitab, kui palju salvestusruumi oled kasutanud, ja loetleb hiljuti sünkroonitud faile.

Kummagi teenuse eemaldamine võtab selle vidina ribalt tagasi ära.

## Indikaatorid

Väike kobar keskel on indikaatorite vidin. Need on olekuglüüfid režiimidele, mille oled sisse lülitanud: ära sega, öövalgus, järjekorras olev [meeldetuletus](09-reminders.md), aktiivne ekraanisalvestus, püsi ärkvel ja [dikteerimine](11-text-extraction-dictation.md). Need süttivad, kui režiim on aktiivne, ja püsivad muidu eemal — hõlju ükskõik kus ribal, et heita pilk mitteaktiivsetele. Indikaatoril klõpsamine lülitab selle režiimi sisse/välja. Üks veel on ainult olek: kaugseanss süttib punaselt, kuni keegi on selle masinaga gliffi kaudu ühendatud.

Kui eelistad, et need oleksid alati nähtavad, sea vidinal `alwaysShow` väärtuseks `true`. Ja kui hoolid ainult mõnest neist, loetle soovitud `items` all: `["Dnd", "Reminder", "NightLight"]`. Sul võib olla rohkem kui üks indikaatorite vidin, nii et eri jaotised saavad näidata eri alamhulki.

## Riba ümberkorraldamine

Riba seadistab ennast ise. Sa ei pea asjade liigutamiseks konfiguratsioonifaili avama.

Haara ribal keskosa ümbruses tühjast lapist ja lohista see teise ekraaniserva poole ja riba liigub sinna — vasak, parem, ülemine või alumine toimivad kõik ja iga vidin kohandub (vertikaalsed ribad langevad tagasi kompaktsetele ainult ikooniga vormidele). Klõps ja all hoidmine alustab sama lohistamist. Topelt-vasakklõps samal tühjal ruumil vahetab riba tausta ringis läbipaistvast klaasjaks ja läbipaistmatuks. Ja lohista ükskõik millist vidinat, et see ümber järjestada või teise jaotisse visata; teised vidinad libisevad lahku, et teha ruumi kohta, kuhu see maandub.

Riba keskosa on kast: mis iganes selles on, püsib ühe rühmana keskel ja selle mõlemal küljel olevad vidinad ripuvad selle servade küljes. Vidinat lohistades näidatakse kasti kontuurina või, kui see on tühi, joonena üle riba, ja sa saad kukutada selle sisse või selle kõrvale. Kui kukutamine maanduks kastis, kasvab kast, et vidin sisse võtta.

Vidin, mida soovid käepärast, kuid mitte alati nähtaval hoida, võib minna salve sahtlisse: lohista see salvele ja sahtel avaneb, et see vastu võtta. See istub seal rakenduseikoonide järel, ilmub alati, kui sahtel ilmub, ja hoiab oma sahtli avatuna, kuni selle paneel on üleval. Lohista see ribale tagasi, et see tagasi panna.

Kui eelistad menüüst valida, on **Välimus → Menüüriba** all asukoht ja **Riba taust** valib, kuidas riba joonistatakse: **Läbipaistmatu riba**, **Klaasjas riba** (läbipaistev, taga olev hägustatud) või **Läbipaistev riba**.

Samatel asjadel on käsud, mida sa soovid [dotfiles](31-dotfiles.md) seadistuse jaoks:

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

`Super + Shift + Space` lülitab riba välja ja tagasi sisse kesta tapmata — paneelid ja kiirklahvid töötavad edasi, saad lihtsalt pikslid tagasi. See on ka menüüs **Välimus → Menüüriba → Peida riba** all.

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

Iga vidin on üks kirje ühes viiest paigutusmassiivist ja selle seaded istuvad sellel kirjel reasiseselt — eraldi seadete faili pole ja `config` alamobjekti pole. Kella `format`, `formatAlt` (millele paremklõps ringis vahetab) ja `verticalFormat` elavad kõik sealsamas `{ "id": "omarchy.clock" }` peal.

`center` on kast riba keskel: kõik selles keskendatakse ekraanil ühe rühmana. `centerBegin` ja `centerEnd` ripuvad kasti mõlemal küljel, mistõttu kell püsib surnud keskel, isegi kui ilm ja värskendusmärk tulevad ja lähevad. Pane `center` alla rohkem kui üks vidin ja need keskendatakse koos; jäta see tühjaks ja `centerBegin` ja `centerEnd` kohtuvad riba keskel.

Üks reegel, mis tasub omaks võtta: **kui sul on oma `shell.json`, on see kanoniline**. Kuni sa midagi ei kohanda, loeb kest Omarchy vaikefaili. Hetkel, kui lohistad vidinat, käivitad `omarchy bar` või redigeerid faili ise, kuulub see sulle — sügavat ühendamist ei toimu, nii et tulevaste Omarchy väljalasete uued vaikimisi vidinad ei ilmu sinu ribale automaatselt. `omarchy bar defaults` paneb tarnitud paigutuse tagasi alati, kui soovid puhast lehte.

Sama fail hoiab ka sinu jõudeaja ajastusi ülemisel tasemel, väljaspool `bar` võtit: `idle.screensaver` ja `idle.lock`, mõlemad sekundites alates jõudeolekusse minekust. Nii käivitub vaikimisi ekraanisäästja 150 sekundi ja lukk 300 sekundi järel.
