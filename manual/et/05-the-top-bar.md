# Menüüriba

Riba piki ekraani ülaosa on Omarchy riba. See pole külge poltidega kinnitatud olekuriba, vaid osa Omarchy kestast, ühest kauakestvast Quickshelli protsessist, mis joonistab ka menüü, teavitused, OSD hüpikaknad ja lukuekraani. Seepärast teemastub see kõike muud täiuslikult ja seepärast avaneb paneel hetkega, mitte ei käivita uut rakendust.

See on ka ainus töölaua osa, mis on alati ekraanil, nii et tasub teada, mida kõik need väikesed glüüfid teevad.

## Mis sellel vaikimisi on

Ribal on kolm sektsiooni. Vasakul asub Omarchy logo (menüü käivitaja) ja tööalanäidikud. Keskel saad olekunäidikud, kella, Elsewheni (maailmakella), ilma ja Omarchy uuendusmärgi. Paremal: klaviatuuripaigutus (kui rohkem kui üks on seadistatud), süsteemialus, agendid, bluetooth, võrk, heli, ekraan ja toide.

Mõned neist ilmuvad ainult siis, kui neil on midagi öelda. Klaviatuuripaigutus ilmub ainult siis, kui oled seadistanud rohkem kui ühe paigutuse. Uuendusmärk ilmub ainult siis, kui Omarchy uuendus ootab. Ja agentide ikoon ilmub esimest korda, kui Omarchy masinast AI programmeerimiskasutust leiab (vt [AI](17-ai.md)).

## Ringi klõpsamine

Peaaegu iga vidin teeb midagi vasaku, parema ja keskmise klõpsuga ning mitmed reageerivad kerimisele. See on osa, millest inimesed ilma jäävad — parem ja keskmine nupp on kohad, kus palju head kraami peitub.

| Vidin | Vasak | Parem | Keskmine / kerimine |
| --- | --- | --- | --- |
| Menüü | Omarchy menüü | Uus terminal | — |
| Tööalad | Fokuseeri see tööala | — | Kerimine: järgmine/eelmine tööala |
| Kell | Kalendri hüpik | Vaheta sildi vormingut | Keskmine: ajavööndi valija |
| Ilm | Prognoosi hüpik | Täielik ilm teavitusena | Keskmine: värskenda |
| Heli | Helipaneel | Vaigista | Keskmine: paneel · kerimine: helitugevus |
| Mikrofon | Vaigista mikrofon | — | Keskmine: helipaneel · kerimine: sisendi helitugevus |
| Võrk | Võrgupaneel | — | — |
| Bluetooth | Bluetoothi paneel | Lülita raadio | — |
| Ekraan | Ekraanipaneel | — | Kerimine: heledus |
| Toide | Toitepaneel | Lülita aku protsent | — |
| Meedia | Esita/peata | Kaanepildi hüpik | Keskmine: järgmine · kerimine: eelmine/järgmine |
| Agendid | Agentide paneel | Käivita oma agent | Keskmine: järgmine tellimus |
| Alus | Hõlju, et sahtel avada | Paremklõps noolel haldamiseks | — |
| Omarchy uuendus | Käivita uuendus | — | — |

Kõik selles tabelis pole su ribal karbist välja võttes. Meediavidin (MPRIS praegu mängiv, keriva loo ja artistiga) ja mikrofonividin on mõlemad sisse ehitatud, kuid vaikimisi välja lülitatud — lisa need, kui soovid, nagu allpool kirjeldatud.

## Paneelid

Riba ikoonil klõpsamine avab paneeli, mis on korralik hüpik koos liugrite, loendite ja klaviatuurinavigeerimisega, mitte vihje. Igalühel on ka kiirklahv, nii et sa ei pea kunagi 16-pikslisele glüüfile täpselt pihta saama:

| Kiirklahv | Paneel |
| --- | --- |
| `Super + Ctrl + A` | Heli |
| `Super + Ctrl + W` | Võrk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ekraan |
| `Super + Ctrl + P` | Toide |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Maailmakell |
| `Super + Ctrl + 1-9` | Lülita parema sektsiooni n-ndat paneeli |

Paneelid ei ole näidud. Need on kohad, kus sa asja päriselt ära teed:

- **Helil** on peahelitugevuse liugur, väljundseadme valija ja rakendusepõhine mikser, nii et saad selle ühe brauseri vahelehe vaiksemaks keerata, puudutamata kõike muud.
- **Võrk** otsib Wi-Fi-t, näitab signaali tugevust, ühendab ja laseb sul DNS-teenuse pakkuja valida.
- **Bluetooth** loetleb su seadmed koos ühendamise/lahtiühendamise ja akutase metega.
- **Toide** näitab aku statistikat, vahetab toiteprofiile (mäletab eraldi valikut aku ja võrgutoite jaoks) ja prindib mõningat süsteemiteavet.
- **Ekraanil** on heleduse liugur, teksti suurus, kuvari skaleerimise eelvalikud ja — kui sul on rohkem kui üks ekraan — kuvaripõhised juhtelemendid. Sügavama loo jaoks vt [kuvarid](33-monitors.md).
- **Kell** avab kuuvõrgu koos ISO-nädalnumbrite ja kuusammudega.

Iga paneel võtab vastu nii klaviatuuri kui ka hiire: nooled liiguvad, Return aktiveerib, Tab astub naaberpaneeli juurde ja Escape sulgeb.

`Super + Ctrl + 1-9` loendab paneele vasakult paremale paremas sektsioonis, jättes aluse vahele, kuna sellel pole oma paneeli. Nii et number vastab ikoonile, millele osutaksid.

### Tailscale ja Dropbox

Kaks vidinat ilmuvad ribale alles siis, kui paigaldad vastava teenuse **Paigalda → Teenus** alt, ja mõlema kohta tasub teada, sest need teevad rohkem kui pelgalt olekut raporteerivad.

**Tailscale'i** paneel ühendab ja lahutab tailneti, vahetab kontode vahel ja valib väljumissõlme (su oma masinad ja Mullvadi piirkonnad ilmuvad mõlemad selles loendis). See sirbib ka su masinaid — ja ühega valitud, `s` saadab sellele failid Taildropi kaudu, mis on kiireim viis fail telefoni või teisele sülearvutile liigutada. `c` kopeerib masina IP, `n` selle nime ja `d` selle täieliku DNS-nime. Igal masinareal on ka saatmisnupp, kui eelistad klõpsata. Sama terminalist on `omarchy tailscale send <machine> [file...]`.

**Dropboxi** paneel tegeleb sisselogimisega, näitab, kui palju salvestusruumi oled kasutanud, ja loetleb hiljuti sünkroniseeritud failid.

Kumma teenuse eemaldamine võtab selle vidina ribalt tagasi.

## Näidikud

Väike kobar keskel on näidikute vidin. Need on olekuglüüfid režiimidele, mille oled sisse lülitanud: ära sega, öövalgus, järjekorras olev [meeldetuletus](09-reminders.md), aktiivne ekraanisalvestus, püsi ärkvel ja [dikteerimine](11-text-extraction-dictation.md). Need süttivad, kui režiim on aktiivne, ja püsivad muidu eemal — hõlju kella vasakule (vertikaalsel ribal selle kohal), et passiivsetele piiluda. Näidikul klõpsamine lülitab selle režiimi. Üks veel on ainult olek: kaugseanss süttib punaselt, kui keegi on gliffi kaudu selle masinaga ühendatud.

Kui eelistad, et need oleksid alati nähtavad, sea vidinal `alwaysShow` väärtuseks `true`. Ja kui hoolid ainult mõnest neist, loetle need, mida soovid, `items`-is: `["Dnd", "Reminder", "NightLight"]`. Sul võib olla rohkem kui üks näidikute vidin, nii et erinevad sektsioonid saavad näidata erinevaid alamhulki.

## Riba ümberpaigutamine

Riba seadistab ennast ise. Sa ei pea asjade liigutamiseks seadistusfaili avama.

Haara keske kandis tühja riba kohta ja lohista see teise ekraaniserva poole ja riba liigub sinna — vasak, parem, ülemine või alumine toimivad kõik ja iga vidin kohaneb (vertikaalsed ribad lähevad tagasi kompaktsetele ainult-ikoonidega vormidele). Klõpsa-ja-hoiab alustab sama lohistamist. Tee samal tühjal ruumil topeltvasakklõps, et riba taustal ringi läbi käia läbipaistvast klaasjani läbipaistmatuni. Ja lohista ükskõik millist vidinat, et seda ümber järjestada või teise sektsiooni visata.

Vidina, mida soovid käepärast hoida, kuid mitte kogu aeg silme ees, võid panna aluse sahtlisse: lohista see alusele ja sahtel avaneb, et see vastu võtta. See jääb sinna rakenduste ikoonide järele, ilmub iga kord, kui sahtel avaneb, ja hoiab sahtli avatuna, kuni selle paneel on üleval. Lohista see ribale tagasi, et see oma kohale panna.

Kui eelistad menüüst valida, on **Käivita → Välimus → Menüüriba** all asukoht ja **Riba taust** valib, kuidas riba joonistatakse: **Läbipaistmatu riba**, **Klaasriba** (läbipaistev, taustal olev hägustatud) või **Läbipaistev riba**.

Samadel asjadel on käsud, mida soovid [dotfiles](31-dotfiles.md) seadistuse jaoks:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Vidina täielikuks lisamiseks või eemaldamiseks kasuta pluginakäske. `omarchy plugin list` prindib iga vidina, mida kest teab, koos selle id-ga, ja seejärel:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Riba peitmine

`Super + Shift + Space` lülitab riba välja ja tagasi sisse, ilma kesta tapmata — paneelid ja kiirklahvid töötavad edasi, saad lihtsalt pikslid tagasi. See on ka menüüs **Käivita → Välimus → Menüüriba → Peida riba** all.

## Seadistusfail

Kõik see on salvestatud `~/.config/omarchy/shell.json`-i, `bar` võtme alla. Siin on kärbitud versioon:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Iga vidin on üks kirje ühes kolmest paigutusmassiivist ja selle seaded asuvad sellel kirjel teksti sees — pole eraldi seadetefaili ega `config` alamobjekti. Kella `format`, `formatAlt` (millele paremklõps ringi käib) ja `verticalFormat` asuvad kõik täpselt seal kirjel `{ "id": "omarchy.clock" }`.

`centerAnchor` nimetab selle ühe keskmise vidina, mis kinnitatakse täpselt ekraani keskele, nii et ülejäänud külgnevad sellega. Nii püsib kell täpselt keskel ka siis, kui ilm ja uuendusmärk tulevad ja lähevad. Sea selleks tühi string ja keskmine loend tsentreeritakse lihtsalt rühmana.

Üks reegel, mida tasub pähe õppida: **kui sul on oma `shell.json`, on see lõplik**. Kuni sa midagi ei kohanda, loeb kest Omarchy vaikefaili. Kohe kui lohistad vidinat, käivitad `omarchy bar` või muudad faili ise, kuulub see sulle — sügavat liitmist pole, nii et tulevaste Omarchy väljaannete uued vaikevidinad ei ilmu su ribale automaatselt. `omarchy bar defaults` paneb tarnitud paigutuse tagasi, millal iganes soovid puhast lehte.

Sama fail hoiab ka su jõudeaegu ülemisel tasemel, väljaspool `bar` võtit: `idle.screensaver` ja `idle.lock`, mõlemad sekundites sellest ajast, kui jõude jäid. Nii et vaikeekraanisäästja käivitub 150 sekundi ja lukk 300 sekundi kohal.
