# Zgornja vrstica

Pas vzdolž vrha zaslona je vrstica Omarchy. Ni privita statusna vrstica, ampak del lupine Omarchy, edinega dolgo živečega procesa Quickshell, ki riše tudi meni, obvestila, pojavna okna OSD in zaklenjeni zaslon. Zato se popolnoma ujema z vsem ostalim in zato se plošča odpre takoj, namesto da bi zagnala novo aplikacijo.

Je tudi edini del namizja, ki je vedno na zaslonu, zato je vredno vedeti, kaj počnejo vsi ti majhni glifi.

## Kaj je privzeto na njej

Vrstica ima tri razdelke. Na levi sta logotip Omarchy (zaganjalnik menija) in kazalniki delovnih površin. Na sredini dobite kazalnike stanja, uro, Elsewhen (svetovno uro), vreme in značko za posodobitev Omarchy. Na desni: sistemska vrstica, postavitev tipkovnice (kadar je konfiguriranih več), agenti, bluetooth, omrežje, zvok, zaslon in napajanje.

Nekaj od teh se prikaže le, kadar imajo kaj povedati. Postavitev tipkovnice se prikaže le, če ste konfigurirali več postavitev. Značka za posodobitev se prikaže le, kadar čaka posodobitev Omarchy. Ikona agentov pa se prikaže prvič, ko Omarchy najde uporabo kodiranja z AI na napravi (glejte [AI](17-ai.md)).

## Klikanje naokoli

Skoraj vsak pripomoček naredi nekaj ob levem, desnem in srednjem kliku, več pa se jih odzove tudi na drsenje. To je del, ki ga ljudje zgrešijo — na desnem in srednjem gumbu se skriva veliko dobrega.

| Pripomoček | Levi | Desni | Srednji / drsenje |
| --- | --- | --- | --- |
| Meni | Meni Omarchy | Nov terminal | — |
| Delovne površine | Osredotoči to delovno površino na tem monitorju | — | Drsenje: naslednja/prejšnja delovna površina |
| Ura | Pojavno okno koledarja | Preklopi obliko oznake | Srednji: izbirnik časovnega pasu |
| Vreme | Pojavno okno napovedi | Celotno vreme kot obvestilo | Srednji: osveži |
| Zvok | Plošča za zvok | Utišaj | Srednji: plošča · drsenje: glasnost |
| Mikrofon | Utišaj mikrofon | — | Srednji: plošča za zvok · drsenje: vhodna glasnost |
| Omrežje | Plošča za omrežje | — | — |
| Bluetooth | Plošča za Bluetooth | Vklopi/izklopi radio | — |
| Zaslon | Plošča za zaslon | — | Drsenje: svetlost |
| Napajanje | Plošča za napajanje | Preklopi odstotek baterije | — |
| Mediji | Predvajaj/premor | Pojavno okno z naslovnico | Srednji: naslednje · drsenje: prejšnje/naslednje |
| Agenti | Plošča za agente | Zaženi svojega agenta | Srednji: naslednja naročnina |
| Sistemska vrstica | Zadržite kazalec, da razkrijete predal | Desni klik na ševron za upravljanje | — |
| Posodobitev Omarchy | Zaženi posodobitev | — | — |

Ni vse v tej tabeli privzeto na vaši vrstici. Pripomoček za medije (MPRIS zdaj predvaja, s premikajočo se skladbo in izvajalcem) in pripomoček za mikrofon sta vgrajena, a privzeto izklopljena — dodajte ju, če ju želite, kot je opisano spodaj.

## Plošče

Klik na ikono vrstice odpre ploščo, ki je pravo pojavno okno z drsniki, seznami in navigacijo s tipkovnico namesto namiga orodja. Vsaka ima tudi bližnjico, tako da vam nikoli ni treba meriti na 16-pikselni glif:

| Bližnjica | Plošča |
| --- | --- |
| `Super + Ctrl + A` | Zvok |
| `Super + Ctrl + N` | Omrežje |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Zaslon |
| `Super + Ctrl + P` | Napajanje |
| `Super + Ctrl + Alt + D` | Koledar |
| `Super + Ctrl + Alt + E` | Svetovna ura |
| `Super + Ctrl + 1-9` | Preklopi n-to ploščo v desnem razdelku |

Plošče niso izpisi. Na njih dejansko naredite stvar:

- **Zvok** ima glavni drsnik za glasnost, izbirnik izhodne naprave in mešalnik za posamezne aplikacije, tako da lahko utišate tisti en zavihek brskalnika, ne da bi se dotaknili vsega drugega.
- **Omrežje** išče Wi-Fi, prikazuje moč signala, povezuje in vam omogoča izbiro ponudnika DNS.
- **Bluetooth** navede vaše naprave s povezavo/prekinitvijo in ravnmi baterije.
- **Napajanje** prikazuje statistiko baterije, preklaplja profile napajanja (zapomni si ločeno izbiro za baterijo in AC) in izpiše nekaj informacij o sistemu.
- **Zaslon** ima drsnik za svetlost, velikost besedila, prednastavitve skaliranja monitorja in — kadar imate več zaslonov — kontrolnike za posamezen monitor. Glejte [monitorji](33-monitors.md) za globljo zgodbo.
- **Ura** odpre mesečno mrežo s številkami tednov ISO in pomikanjem po mesecih.
- **Svetovna ura** ima vrstico za vsako mesto, z njegovim vremenom in tem, kako mu gre dan. Iskanje najde tudi mesta, ne le časovne pasove, zato je Fort Lauderdale Fort Lauderdale in ne New York. Če vrstica na vrhu imenuje napačno mesto, jo kliknite in povejte, kje ste; izberite kraj v drugem časovnem pasu in tudi sistemska ura se premakne tja, kar pride prav med potovanjem. Zadržite kazalec nad mestom in kliknite gumb osebe, da poveste, kdo tam živi — navadna imena ali ročaje `@` GitHub, da pripeljete zraven njihove obraze.

Vsaka plošča sprejme tipkovnico kot tudi miško: puščice se premikajo, Return aktivira, Tab se pomakne na sosednjo ploščo, Escape pa zapre.

`Super + Ctrl + 1-9` šteje plošče od leve proti desni v desnem razdelku, pri čemer preskoči sistemsko vrstico, saj ta nima svoje plošče. Tako se številka ujema z ikono, na katero bi pokazali.

### Tailscale in Dropbox

Še dva pripomočka se na vrstici prikažeta le, ko iz **Namesti → Storitev** namestite ustrezno storitev, in oba je vredno poznati, ker naredita več kot le poročata o stanju.

Plošča **Tailscale** povezuje in prekinja tailnet, preklaplja med računi in izbere izhodno vozlišče (vaše lastne naprave in regije Mullvad so oboje na tem seznamu). Prebrska tudi vaše naprave — in ko je ena izbrana, `s` pošlje datoteke nanjo prek Taildrop, kar je najhitrejši način za premik datoteke na telefon ali drug prenosnik. `c` kopira IP naprave, `n` njeno ime in `d` njeno polno ime DNS. Na vsaki vrstici naprave je tudi gumb za pošiljanje, če raje klikate. Enako iz terminala je `omarchy tailscale send <machine> [file...]`.

Plošča **Dropbox** skrbi za prijavo, prikazuje, koliko prostora za shranjevanje ste porabili, in navede nedavno sinhronizirane datoteke.

Če katero od storitev odstranite, gre z vrstice tudi njen pripomoček.

## Kazalniki

Mala skupina na sredini je pripomoček kazalnikov. To so glifi stanja za načine, ki ste jih vklopili: ne moti, nočna luč, [opomnik](09-reminders.md) v čakalni vrsti, aktivno snemanje zaslona, ostani buden in [narekovanje](11-text-extraction-dictation.md). Zasvetijo, kadar je način aktiven, sicer pa se umaknejo s poti — zadržite kazalec kjer koli na vrstici, da pokukate v neaktivne. Klik na kazalnik preklopi ta način. Še eden je samo za stanje: oddaljena seja sveti rdeče, medtem ko je nekdo povezan s to napravo prek gliff.

Če želite, da so vedno vidni, nastavite `alwaysShow` na `true` na pripomočku. In če vas zanimajo le nekateri, navedite želene v `items`: `["Dnd", "Reminder", "NightLight"]`. Imate lahko več kot en pripomoček kazalnikov, tako da lahko različni razdelki prikazujejo različne podnabore.

## Preurejanje vrstice

Vrstica se konfigurira sama. Za premikanje stvari vam ni treba odpreti konfiguracijske datoteke.

Primite prazen del vrstice okoli sredine in ga povlecite proti drugemu robu zaslona in vrstica se premakne tja — levo, desno, zgoraj ali spodaj deluje vse, vsak pripomoček pa se prilagodi (navpične vrstice preidejo na kompaktne oblike samo z ikonami). Klik-in-zadrži začne enak vlek. Dvakrat levo kliknite isti prazen prostor, da preklopite ozadje vrstice od prozornega do steklenega do neprozornega. In povlecite kateri koli pripomoček, da ga preuredite ali vržete v drug razdelek; drugi pripomočki se razmaknejo, da naredijo prostor, kjer bo pristal.

Sredina vrstice je okvir: kar je v njem, ostane na sredini kot ena skupina, pripomočki na obeh straneh pa visijo z njegovih robov. Med vlečenjem pripomočka se okvir prikaže kot obris ali kot črta čez vrstico, kadar je prazen, in lahko spustite vanj ali ob njega. Kadar bi spust pristal v okvirju, okvir zraste in vzame pripomoček vanj.

Pripomoček, ki ga želite imeti pri roki, a ne vedno na očeh, lahko gre v predal sistemske vrstice: povlecite ga na sistemsko vrstico in predal se odpre, da ga sprejme. Tam sedi za ikonami aplikacij, prikaže se, kadar koli se prikaže predal, in drži svoj predal odprt, medtem ko je njegova plošča odprta. Povlecite ga nazaj na vrstico, da ga vrnete.

Če raje izbirate iz menija, ima **Videz → Vrstica menija** položaj, **Ozadje vrstice** pa izbere, kako je vrstica narisana: **Neprozorna vrstica**, **Steklena vrstica** (prozorna, s tem, kar je za njo, zamegljenim) ali **Prozorna vrstica**.

Iste stvari imajo ukaze, kar želite za nastavitev [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Za dodajanje ali odstranjevanje pripomočka v celoti uporabite ukaze vtičnikov. `omarchy plugin list` izpiše vsak pripomoček, ki ga lupina pozna, z njegovim id, nato pa:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Skrivanje vrstice

`Super + Shift + Space` preklopi vrstico izklopljeno in nazaj vklopljeno, ne da bi ubil lupino — plošče in bližnjice še naprej delujejo, le piksle dobite nazaj. Je tudi v meniju pod **Videz → Vrstica menija → Skrij vrstico**.

## Konfiguracijska datoteka

Vse je shranjeno v `~/.config/omarchy/shell.json`, pod ključem `bar`. Tukaj je okleščena različica:

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

Vsak pripomoček je en vnos v eni od petih tabel postavitve, njegove nastavitve pa sedijo neposredno na tem vnosu — ni ločene datoteke z nastavitvami in ni podobjekta `config`. `format`, `formatAlt` (na kar preklopi desni klik) in `verticalFormat` ure živijo tam na `{ "id": "omarchy.clock" }`.

`center` je okvir na sredini vrstice: vse v njem je na zaslonu na sredini kot ena skupina. `centerBegin` in `centerEnd` visita na obeh straneh okvirja, tako ura ostane točno na sredini, tudi ko vreme in značka za posodobitev prihajata in odhajata. Dajte več kot en pripomoček v `center` in bodo skupaj na sredini; pustite ga praznega in `centerBegin` ter `centerEnd` se srečata na sredini vrstice.

Eno pravilo, ki si ga je vredno zapomniti: **ko imate svoj `shell.json`, je kanoničen**. Dokler ničesar ne prilagodite, lupina bere privzeto datoteko Omarchy. V trenutku, ko povlečete pripomoček, zaženete `omarchy bar` ali sami uredite datoteko, je vaša — ni globokega združevanja, zato se novi privzeti pripomočki v prihodnjih izdajah Omarchy ne bodo samodejno prikazali na vaši vrstici. `omarchy bar defaults` vrne privzeto postavitev, kadar koli želite čist začetek.

Ista datoteka hrani tudi vaše čase nedejavnosti na zgornji ravni, zunaj ključa `bar`: `idle.screensaver` in `idle.lock`, oboje v sekundah od vaše nedejavnosti. Privzeti ohranjevalnik zaslona se tako vklopi pri 150 sekundah, zaklepanje pa pri 300.
