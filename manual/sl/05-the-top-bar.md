# Zgornja vrstica

Trak vzdolž vrha zaslona je vrstica Omarchy. Ni privijačena vrstica stanja, ampak del lupine Omarchy, enega dolgo živečega procesa Quickshell, ki riše tudi meni, obvestila, pojavna okna OSD in zaklenjeni zaslon. Zato se popolnoma ujema z vsem ostalim in zato se plošča odpre takoj, namesto da bi zagnala novo aplikacijo.

Je tudi edini del namizja, ki je vedno na zaslonu, zato se splača vedeti, kaj počnejo vsi tisti majhni znaki.

## Kaj je na njej privzeto

Vrstica ima tri dele. Na levi sta logotip Omarchy (zaganjalnik menija) in kazalniki delovnih prostorov. V sredini so kazalniki stanja, ura, Elsewhen (svetovna ura), vreme in značka za posodobitev Omarchy. Na desni: sistemski pladenj, razporeditev tipkovnice (kadar je konfigurirana več kot ena razporeditev ali način vnosa), agenti, bluetooth, omrežje, zvok, zaslon in napajanje.

Nekateri od teh se pokažejo samo, kadar imajo kaj povedati. Razporeditev tipkovnice se prikaže samo, če ste konfigurirali več kot eno razporeditev ali način vnosa. Značka za posodobitev se prikaže samo, kadar čaka posodobitev Omarchy.

## Klikanje naokrog

Skoraj vsak gradnik nekaj naredi ob levem, desnem in srednjem kliku, več pa se jih odzove tudi na pomikanje. To je del, ki ga ljudje spregledajo — desni in srednji gumb skrivata veliko dobrih stvari.

| Gradnik | Levi | Desni | Srednji / pomikanje |
| --- | --- | --- | --- |
| Meni | Meni Omarchy | Nov terminal | — |
| Delovni prostori | Preklopi na ta delovni prostor na tem monitorju | — | Pomikanje: naslednji/prejšnji delovni prostor |
| Ura | Pojavno okno koledarja | Preklopi med oblikama zapisa oznake | Srednji: izbira časovnega pasu |
| Svetovna ura | Plošča svetovne ure | Osveži | Srednji: osveži |
| Vreme | Pojavno okno napovedi | Celotna vremenska napoved kot obvestilo | Srednji: osveži |
| Zvok | Plošča zvoka | Utišaj | Srednji: plošča · pomikanje: glasnost |
| Mikrofon | Utišaj mikrofon | — | Srednji: plošča zvoka · pomikanje: vhodna glasnost |
| Omrežje | Plošča omrežja | — | — |
| Bluetooth | Plošča Bluetooth | Vklopi/izklopi radio | — |
| Zaslon | Plošča zaslona | — | Pomikanje: svetlost |
| Napajanje | Plošča napajanja | Preklopi prikaz odstotka baterije | — |
| Mediji | Predvajaj/premor | Pojavno okno s sliko naslovnice | Srednji: naslednja · pomikanje: prejšnja/naslednja |
| Agenti | Plošča agentov | Zaženi svojega agenta | Srednji: osveži porabo |
| Pladenj | Z miško pokaži nad njim, da razkriješ predal | Desni klik na puščico za upravljanje | — |
| Posodobitev Omarchy | Zaženi posodobitev | — | — |

Vsega v tej tabeli ni na vaši vrstici takoj po namestitvi. Gradnik za medije (MPRIS zdaj se predvaja, s pomikajočo se skladbo in izvajalcem) in gradnik za mikrofon sta vgrajena, a privzeto izklopljena — dodajte ju, če ju želite, kot je opisano spodaj.

## Plošče

Klik na ikono v vrstici odpre ploščo, ki je pravo pojavno okno z drsniki, seznami in navigacijo s tipkovnico, ne le namig. Vsaka ima tudi bližnjico, da vam nikoli ni treba meriti na znak velikosti 16 pikslov:

| Bližnjica | Plošča |
| --- | --- |
| `Super + Ctrl + A` | Zvok |
| `Super + Ctrl + N` | Omrežje |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Zaslon |
| `Super + Ctrl + P` | Napajanje |
| `Super + Ctrl + Alt + D` | Koledar |
| `Super + Ctrl + Alt + E` | Svetovna ura |
| `Super + Ctrl + X` | Agenti |
| `Super + Ctrl + 1-9` | Preklopi n-to ploščo v desnem delu |

Plošče niso izpisi. Na njih dejansko kaj naredite:

- **Zvok** ima glavni drsnik za glasnost, izbiro izhodne naprave in mešalnik za posamezne aplikacije, da lahko utišate tisti en zavihek brskalnika, ne da bi se dotaknili vsega ostalega.
- **Omrežje** išče Wi-Fi, pokaže moč signala, se poveže in vam omogoči izbiro ponudnika DNS.
- **Bluetooth** navede vaše naprave s povezovanjem/prekinjanjem povezave in ravnmi baterije.
- **Napajanje** pokaže statistiko baterije, preklaplja profile napajanja (zapomni si ločeno izbiro za baterijo in AC) in izpiše nekaj informacij o sistemu.
- **Zaslon** ima drsnik za svetlost, velikost besedila, prednastavitve skaliranja monitorja in — kadar imate več kot en zaslon — kontrolnike za posamezne monitorje. Glejte [monitorji](33-monitors.md) za podrobnejšo zgodbo.
- **Ura** odpre mesečno mrežo s številkami tednov ISO in pomikanjem po mesecih.
- **Svetovna ura** ima vrstico za vsako mesto, z njegovim vremenom in potekom njegovega dneva. Iskanje najde tudi manjša mesta in ne le časovne pasove, tako da je Fort Lauderdale Fort Lauderdale in ne New York. Če vrstica na vrhu imenuje napačno mesto, kliknite nanjo in povejte, kje ste; izberite kraj v drugem časovnem pasu in tudi sistemska ura se premakne tja, kar pride prav na potovanjih. Z miško pokažite na mesto in kliknite gumb z osebo, da poveste, kdo tam živi — z navadnimi imeni ali z uporabniškimi imeni GitHub `@`, da zraven prinese tudi njihove obraze.

Vsaka plošča sprejema tako tipkovnico kot miško: puščice premikajo, Return aktivira, Tab skoči na sosednjo ploščo in Escape zapre.

`Super + Ctrl + 1-9` šteje plošče od leve proti desni v desnem delu, pri čemer preskoči pladenj, saj ta nima svoje plošče. Številka se torej ujema z ikono, na katero bi pokazali.

### Tailscale in Dropbox

Še dva gradnika se na vrstici pojavita šele, ko iz **Namesti → Storitev** namestite ustrezno storitev, in oba je vredno poznati, ker naredita več kot le poročata o stanju.

Plošča **Tailscale** povezuje in prekinja povezavo s tailnetom, preklaplja med računi in izbere izhodno vozlišče (na tem seznamu se pojavijo tako vaše naprave kot regije Mullvad). Brska tudi po vaših napravah — in ko je ena izbrana, `s` pošlje datoteke nanjo prek Taildrop, kar je najhitrejši način, da datoteko premaknete na telefon ali drug prenosnik. `c` kopira IP naprave, `n` njeno ime in `d` njeno polno ime DNS. Na vsaki vrstici naprave je tudi gumb za pošiljanje, če raje klikate. Enako iz terminala je `omarchy tailscale send <machine> [file...]`.

Plošča **Dropbox** skrbi za prijavo, pokaže, koliko prostora za shranjevanje ste porabili, in navede nedavno sinhronizirane datoteke.

Če katero od storitev odstranite, gre z vrstice tudi njen gradnik.

## Kazalniki

Majhna gruča v sredini je gradnik kazalnikov. To so znaki stanja za načine, ki ste jih vklopili: ne moti, nočna svetloba, čakajoči [opomnik](09-reminders.md), aktivno snemanje zaslona in ostani buden, poleg tega pa še opozorila, kadar je vklopljen sudo brez gesla ali je nekdo povezan z oddaljeno sejo. Zasvetijo, kadar je način aktiven, sicer pa se umaknejo s poti — z miško pokažite tik poleg njih, tja, kjer bi sedeli neaktivni, da pokukate še k njim. Klik na kazalnik ta način preklopi. Še eden je samo za stanje: oddaljena seja sveti rdeče, kadar je nekdo prek gliff povezan s to napravo.

Če želite, da so vedno vidni, na gradniku nastavite `alwaysShow` na `true`. In če vas zanimajo le nekateri, v `items` navedite tiste, ki jih želite: `["Dnd", "Reminder", "NightLight"]`. Gradnikov kazalnikov imate lahko več kot enega, tako da lahko različni deli prikazujejo različne podnabore.

## Preurejanje vrstice

Vrstica se konfigurira sama. Da kaj premaknete, vam ni treba odpirati konfiguracijske datoteke.

Primite prazen del vrstice okoli sredine in ga povlecite proti drugemu robu zaslona in vrstica se premakne tja — levo, desno, zgoraj ali spodaj, vse deluje, vsak gradnik pa se prilagodi (navpične vrstice preidejo na kompaktne oblike samo z ikonami). Enak vlek začne tudi klik z držanjem. Dvakrat levo kliknite na isti prazen prostor, da ozadje vrstice preklopite od prozornega prek steklenega do neprozornega. In povlecite kateri koli gradnik, da ga preuredite ali vržete v drug del; ostali gradniki se razmaknejo, da naredijo prostor tam, kjer bo pristal.

Sredina vrstice je škatla: kar je v njej, ostane centrirano kot ena skupina, gradniki na obeh straneh pa visijo z njenih robov. Med vlečenjem gradnika se škatla pokaže kot oris ali kot črta čez vrstico, kadar je prazna, in spustite lahko vanjo ali poleg nje. Kadar bi spust pristal v škatli, škatla zraste, da gradnik sprejme.

Gradnik, ki ga želite imeti pri roki, a ne vedno na očeh, lahko gre v predal pladnja: povlecite ga na pladenj in predal se odpre, da ga sprejme. Tam sedi za ikonami aplikacij, pokaže se, kadar koli se pokaže predal, in drži svoj predal odprt, medtem ko je njegova plošča odprta. Povlecite ga nazaj na vrstico, da ga vrnete.

Če raje izbirate iz menija, ima **Videz → Vrstica menija** položaj, **Ozadje vrstice** pa izbere, kako je vrstica narisana: **Neprozorna vrstica**, **Steklena vrstica** (prosojna, s tem, kar je za njo, zamegljenim) ali **Prozorna vrstica**.

Enake stvari imajo ukaze, kar želite za namestitev z [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Da gradnik v celoti dodate ali odstranite, uporabite ukaze za vtičnike. `omarchy plugin list` izpiše vsak gradnik, ki ga lupina pozna, z njegovim id, nato pa:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Skrivanje vrstice

`Super + Shift + Space` vrstico izklopi in znova vklopi, ne da bi ubil lupino — plošče in bližnjice delujejo naprej, vi pa dobite piksle nazaj. Je tudi v meniju pod **Videz → Vrstica menija → Skrij vrstico**.

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

Vsak gradnik je en vnos v eni od petih tabel postavitve, njegove nastavitve pa sedijo neposredno na tem vnosu — ni ločene datoteke z nastavitvami in ni podobjekta `config`. Ure `format`, `formatAlt` (tisto, na kar preklopi desni klik) in `verticalFormat` živijo prav tam na `{ "id": "omarchy.clock" }`.

`center` je škatla v sredini vrstice: vse v njej je centrirano na zaslonu kot ena skupina. `centerBegin` in `centerEnd` visita z obeh strani škatle, tako pa ura ostane točno v sredini, tudi ko značka za vreme in posodobitev prihajata in odhajata. Dajte v `center` več kot en gradnik in centrirani so skupaj; pustite ga praznega in `centerBegin` ter `centerEnd` se srečata v sredini vrstice.

Eno pravilo, ki si ga je vredno zapomniti: **ko imate svoj `shell.json`, je ta kanoničen**. Dokler ničesar ne prilagodite, lupina bere privzeto datoteko Omarchy. V trenutku, ko povlečete gradnik, zaženete `omarchy bar` ali datoteko uredite sami, je vaša — globokega spajanja ni, zato se novi privzeti gradniki v prihodnjih izdajah Omarchy na vaši vrstici ne bodo pojavili samodejno. `omarchy bar defaults` vrne dobavljeno postavitev, kadar koli želite čist začetek.

Ista datoteka na najvišji ravni, zunaj ključa `bar`, hrani tudi vaše časovnike nedejavnosti: `idle.screensaver` in `idle.lock`, oba v sekundah od takrat, ko ste postali nedejavni. Privzeti ohranjevalnik zaslona se torej vklopi pri 150 sekundah, zaklepanje pa pri 300.
