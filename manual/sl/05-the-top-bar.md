# Zgornja vrstica

Trak na vrhu tvojega zaslona je vrstica Omarchy. Ni privijačena vrstica stanja, temveč del lupine Omarchy, enega samega dolgo delujočega procesa Quickshell, ki riše tudi meni, obvestila, pojavna okna OSD in zaklenjeni zaslon. Zato se tematsko popolnoma ujema z vsem ostalim in zato se plošča odpre takoj, namesto da bi zagnala novo aplikacijo.

Je tudi edini kos namizja, ki je vedno na zaslonu, zato je vredno vedeti, kaj počnejo vsi tisti mali glifi.

## Kaj je privzeto na njej

Vrstica ima tri razdelke. Na levi sedita logotip Omarchy (zaganjalnik menija) in kazalniki delovnih prostorov. V sredini dobiš kazalnike stanja, uro, Elsewhen (svetovno uro), vreme in značko za posodobitev Omarchy. Na desni: sistemski pladenj, postavitev tipkovnice (kadar je nastavljena več kot ena), agenti, bluetooth, omrežje, zvok, zaslon in napajanje.

Nekateri od teh se prikažejo le, kadar imajo kaj povedati. Postavitev tipkovnice se prikaže le, če si nastavil več kot eno postavitev. Značka za posodobitev se prikaže le, kadar te čaka posodobitev Omarchy. In ikona agentov se prikaže prvič, ko Omarchy na napravi najde uporabo kodiranja z AI (glej [AI](17-ai.md)).

## Klikanje naokrog

Skoraj vsak pripomoček naredi nekaj ob levem, desnem in srednjem kliku, več pa se jih odzove tudi na drsenje. To je tisti del, ki ga ljudje spregledajo — desni in srednji gumb sta tista, kjer se skriva veliko dobrega.

| Pripomoček | Levi | Desni | Srednji / drsenje |
| --- | --- | --- | --- |
| Meni | Meni Omarchy | Nov terminal | — |
| Delovni prostori | Osredotoči ta delovni prostor na tem zaslonu | — | Drsenje: naslednji/prejšnji delovni prostor |
| Ura | Pojavno okno koledarja | Kroži obliko zapisa oznake | Srednji: izbirnik časovnega pasu |
| Vreme | Pojavno okno napovedi | Celotno vreme kot obvestilo | Srednji: osveži |
| Zvok | Plošča za zvok | Utišaj | Srednji: plošča · drsenje: glasnost |
| Mikrofon | Utišaj mikrofon | — | Srednji: plošča za zvok · drsenje: vhodna glasnost |
| Omrežje | Plošča za omrežje | — | — |
| Bluetooth | Plošča za Bluetooth | Preklopi radio | — |
| Zaslon | Plošča za zaslon | — | Drsenje: svetlost |
| Napajanje | Plošča za napajanje | Preklopi odstotek baterije | — |
| Predstavnost | Predvajanje/pavza | Pojavno okno naslovnice | Srednji: naslednja · drsenje: prejšnja/naslednja |
| Agenti | Plošča za agente | Zaženi svojega agenta | Srednji: naslednja naročnina |
| Pladenj | Zadrži kazalec, da razkriješ predal | Desni klik na puščico za upravljanje | — |
| Posodobitev Omarchy | Zaženi posodobitev | — | — |

Vse v tej tabeli ni na tvoji vrstici takoj po namestitvi. Pripomoček za predstavnost (MPRIS za trenutno predvajanje, z drsečo skladbo in izvajalcem) in pripomoček za mikrofon sta oba vgrajena, vendar privzeto izklopljena — dodaj ju, če ju želiš, kot je opisano spodaj.

## Plošče

Klik ikone v vrstici odpre ploščo, ki je pravo pojavno okno z drsniki, seznami in navigacijo s tipkovnico, ne le namig. Vsaka ima tudi bližnjico na tipkovnici, tako da ti nikoli ni treba meriti v 16-pikselni glif:

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

Plošče niso izpisi. Na njih dejansko narediš tisto stvar:

- **Zvok** ima glavni drsnik za glasnost, izbirnik izhodne naprave in mešalnik za posamezne aplikacije, tako da lahko utišaš tisti en zavihek brskalnika, ne da bi se dotikal vsega drugega.
- **Omrežje** išče Wi-Fi, pokaže moč signala, se poveže in ti omogoči izbiro ponudnika DNS.
- **Bluetooth** našteje tvoje naprave, z možnostjo povezave/prekinitve povezave in ravnmi baterije.
- **Napajanje** pokaže statistiko baterije, preklaplja profile napajanja (zapomni si ločeno izbiro za baterijo in AC) in izpiše nekaj sistemskih informacij.
- **Zaslon** prinaša drsnik za svetlost, velikost besedila, prednastavitve za merilo zaslona in — kadar imaš več kot en zaslon — kontrolnike za posamezne zaslone. Za globljo zgodbo glej [zasloni](33-monitors.md).
- **Ura** odpre mesečno mrežo s številkami tednov po ISO in pomikanjem po mesecih.
- **Svetovna ura** vodi vrstico za vsako mesto, z njegovim vremenom in s tem, kako mu gre dan. Iskanje najde tako mesta kot časovne pasove, tako da je Fort Lauderdale Fort Lauderdale in ne New York. Če vrstica na vrhu imenuje napačno mesto, jo klikni in povej, kje si; izberi nekje v drugem časovnem pasu in sistemska ura se premakne tja tudi, kar je priročno, kadar potuješ. Zadrži kazalec nad mestom in klikni gumb osebe, da poveš, kdo tam živi — navadna imena ali `@` uporabniška imena GitHub, da z njimi pripelješ tudi njihove obraze.

Vsaka plošča sprejme tako tipkovnico kot miško: puščice premikajo, Return aktivira, Tab premakne na sosednjo ploščo in Escape zapre.

`Super + Ctrl + 1-9` šteje plošče od leve proti desni v desnem razdelku in preskoči pladenj, saj nima lastne plošče. Tako se številka ujema z ikono, na katero bi pokazal.

### Tailscale in Dropbox

Dva dodatna pripomočka se pojavita na vrstici le, ko iz **Install → Service** namestiš ustrezno storitev, in o obeh je vredno vedeti, saj počneta več kot le poročata o stanju.

Plošča **Tailscale** poveže in prekine tailnet, preklaplja med računi in izbere izhodno vozlišče (na tem seznamu se pojavijo tako tvoje lastne naprave kot regije Mullvad). Brska tudi po tvojih napravah — in kadar je ena izbrana, `s` pošlje datoteke vanjo prek Taildrop, kar je najhitrejši način za premik datoteke na tvoj telefon ali drug prenosnik. `c` kopira IP naprave, `n` njeno ime in `d` njeno polno ime DNS. Na vsaki vrstici naprave je tudi gumb za pošiljanje, če raje klikaš. Enako iz terminala naredi `omarchy tailscale send <machine> [file...]`.

Plošča **Dropbox** obravnava prijavo, pokaže, koliko prostora za shranjevanje si porabil, in našteje nedavno sinhronizirane datoteke.

Odstranitev katere koli storitve njen pripomoček znova odstrani iz vrstice.

## Kazalniki

Mali grozd v sredini je pripomoček kazalnikov. To so glifi stanja za načine, ki si jih vklopil: ne moti, nočna luč, čakajoči [opomnik](09-reminders.md), aktivno snemanje zaslona, ostani buden in [narekovanje](11-text-extraction-dictation.md). Zasvetijo, kadar je način aktiven, sicer pa ostanejo vstran — zadrži kazalec tik ob njih, kjer bi sedeli neaktivni, da pokukaš vanje. Klik kazalnika preklopi ta način. Še eden je le za stanje: oddaljena seja sveti rdeče, medtem ko je nekdo na to napravo povezan prek gliff.

Če želiš, da so vedno vidni, na pripomočku nastavi `alwaysShow` na `true`. In če te zanimajo le nekateri od njih, naštej tiste, ki jih želiš, v `items`: `["Dnd", "Reminder", "NightLight"]`. Imaš lahko več kot en pripomoček kazalnikov, tako da lahko različni razdelki prikazujejo različne podnabore.

## Preurejanje vrstice

Vrstica se nastavi sama. Za premikanje stvari ti ni treba odpreti nastavitvene datoteke.

Primi prazen del vrstice okoli sredine in ga povleci proti drugemu robu zaslona in vrstica se premakne tja — levo, desno, zgoraj ali spodaj, vse deluje in vsak pripomoček se prilagodi (navpične vrstice se vrnejo na kompaktne oblike le z ikonami). Klik in zadržanje začne enako vlečenje. Dvojni levi klik na istem praznem prostoru kroži ozadje vrstice od prozornega do steklenega do neprozornega. In povleci kateri koli pripomoček, da ga preurediš ali vržeš v drugi razdelek; drugi pripomočki se razmaknejo, da naredijo prostor, kjer bo pristal.

Sredina vrstice je okvir: karkoli je v njem, ostane centrirano kot ena skupina, pripomočki na obeh njegovih straneh pa visijo ob njegovih robovih. Medtem ko vlečeš pripomoček, se okvir pokaže kot oris ali kot črta čez vrstico, kadar je prazen, in lahko ga spustiš vanj ali ob njega. Kadar bi spust pristal v okvirju, okvir zraste, da pripomoček sprejme.

Pripomoček, ki ga želiš imeti pri roki, a ne vedno na očeh, lahko gre v predal pladnja: povleci ga na pladenj in predal se odpre, da ga sprejme. Tam sedi za ikonami aplikacij, prikaže se, kadar koli se prikaže predal, in drži svoj predal odprt, medtem ko je njegova plošča odprta. Povleci ga nazaj na vrstico, da ga vrneš.

Če raje izbiraš iz menija, ima **Appearance → Menu Bar** položaj, **Bar Background** pa izbere, kako je vrstica izrisana: **Opaque Bar**, **Glassy Bar** (prosojna, s tem, kar je za njo, zamegljenim) ali **Clear Bar**.

Enake stvari imajo ukaze, kar je tisto, kar želiš za namestitev [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Če želiš pripomoček povsem dodati ali odstraniti, uporabi ukaze za vtičnike. `omarchy plugin list` izpiše vsak pripomoček, ki ga lupina pozna, skupaj z njegovim id, nato pa:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Skrivanje vrstice

`Super + Shift + Space` preklopi vrstico izklopljeno in znova vklopljeno, ne da bi ubil lupino — plošče in bližnjice delujejo še naprej, le piksle dobiš nazaj. Je tudi v meniju pod **Appearance → Menu Bar → Hide Bar**.

## Nastavitvena datoteka

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

Vsak pripomoček je en vnos v eni od petih matrik postavitve, njegove nastavitve pa sedijo neposredno na tem vnosu — ni ločene datoteke z nastavitvami in ni podobjekta `config`. `format`, `formatAlt` (na kar kroži desni klik) in `verticalFormat` ure živijo prav tam, na `{ "id": "omarchy.clock" }`.

`center` je okvir na sredini vrstice: vse v njem je na zaslonu centrirano kot ena skupina. `centerBegin` in `centerEnd` visita ob obeh straneh okvirja, tako ura ostane točno na sredini, tudi ko vreme in oznaka za posodobitev prihajata in odhajata. V `center` vstavi več kot en pripomoček in centrirani so skupaj; pusti ga praznega in `centerBegin` ter `centerEnd` se srečata na sredini vrstice.

Eno pravilo si je vredno vtisniti: **ko imaš svoj `shell.json`, je kanoničen**. Dokler ničesar ne prilagodiš, lupina bere privzeto datoteko Omarchy. V trenutku, ko povlečeš pripomoček, zaženeš `omarchy bar` ali sam urediš datoteko, je tvoja — ni globokega spajanja, tako da se novi privzeti pripomočki v prihodnjih izdajah Omarchy ne bodo samodejno pojavili na tvoji vrstici. `omarchy bar defaults` dobavljeno postavitev postavi nazaj, kadar koli želiš čist začetek.

Ista datoteka hrani tudi tvoje časovne nastavitve nedejavnosti na zgornji ravni, zunaj ključa `bar`: `idle.screensaver` in `idle.lock`, obe v sekundah, odkar si nedejaven. Tako se privzeti ohranjevalnik zaslona vklopi v 150 sekundah in zaklepanje v 300.
