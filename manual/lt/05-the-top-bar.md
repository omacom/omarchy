# Viršutinė juosta

Juosta jūsų ekrano viršuje yra „Omarchy“ juosta. Tai ne primontuota būsenos juosta, o „Omarchy“ apvalkalo dalis — to paties vieno ilgai veikiančio „Quickshell“ proceso, kuris taip pat piešia meniu, pranešimus, OSD iškylančiuosius langus ir užrakinimo ekraną. Štai kodėl ji puikiai dera su visa kita ir kodėl skydelis atsidaro akimirksniu, užuot paleidęs naują programą.

Tai taip pat vienintelė darbalaukio dalis, kuri visada matoma ekrane, todėl verta žinoti, ką daro visi tie maži glifai.

## Kas joje yra pagal numatytuosius nustatymus

Juosta turi tris skyrius. Kairėje yra „Omarchy“ logotipas (meniu paleidimo priemonė) ir darbo sričių indikatoriai. Centre matote būsenos indikatorius, laikrodį, „Elsewhen“ (pasaulio laikrodį), orą ir „Omarchy“ naujinio ženklelį. Dešinėje: sistemos dėklas, klaviatūros išdėstymas (kai sukonfigūruotas daugiau nei vienas), agentai, „Bluetooth“, tinklas, garsas, ekranas ir maitinimas.

Keli iš jų pasirodo tik tada, kai turi ką pasakyti. Klaviatūros išdėstymas pasirodo tik tada, jei sukonfigūravote daugiau nei vieną išdėstymą. Naujinio ženklelis pasirodo tik tada, kai laukia „Omarchy“ naujinys. O agentų piktograma pasirodo pirmą kartą, kai „Omarchy“ aptinka DI programavimo naudojimą kompiuteryje (žr. [DI](17-ai.md)).

## Ką daro spustelėjimai

Beveik kiekvienas valdiklis ką nors daro spustelėjus kairiuoju, dešiniuoju ir viduriniuoju mygtuku, o keli reaguoja į slinkimą. Tai dalis, kurią žmonės praleidžia — dešiniajame ir viduriniajame mygtukuose slepiasi daug gerų dalykų.

| Valdiklis | Kairysis | Dešinysis | Vidurinis / slinktis |
| --- | --- | --- | --- |
| Meniu | „Omarchy“ meniu | Naujas terminalas | — |
| Darbo sritys | Fokusuoti tą darbo sritį šiame monitoriuje | — | Slinktis: kita / ankstesnė darbo sritis |
| Laikrodis | Kalendoriaus iškylantysis langas | Cikliškai perjungti žymos formatą | Vidurinis: laiko juostos pasirinkimas |
| Oras | Prognozės iškylantysis langas | Išsami orų prognozė kaip pranešimas | Vidurinis: atnaujinti |
| Garsas | Garso skydelis | Nutildyti | Vidurinis: skydelis · slinktis: garsumas |
| Mikrofonas | Nutildyti mikrofoną | — | Vidurinis: garso skydelis · slinktis: įvesties garsumas |
| Tinklas | Tinklo skydelis | — | — |
| „Bluetooth“ | „Bluetooth“ skydelis | Perjungti radiją | — |
| Ekranas | Ekrano skydelis | — | Slinktis: ryškumas |
| Maitinimas | Maitinimo skydelis | Perjungti baterijos procentinę dalį | — |
| Medija | Leisti / pristabdyti | Viršelio paveikslėlio iškylantysis langas | Vidurinis: kita · slinktis: ankstesnė / kita |
| Agentai | Agentų skydelis | Paleisti jūsų agentą | Vidurinis: kita prenumerata |
| Dėklas | Užvesti pelę, kad atsidarytų stalčius | Dešinysis ant ševrono, kad tvarkytumėte | — |
| „Omarchy“ naujinys | Vykdyti naujinį | — | — |

Ne viskas, kas yra toje lentelėje, iš karto yra jūsų juostoje. Medijos valdiklis (MPRIS dabar leidžiamas įrašas su slenkančiu kūriniu ir atlikėju) ir mikrofono valdiklis abu yra integruoti, bet pagal numatytuosius nustatymus išjungti — pridėkite juos, jei norite, kaip aprašyta toliau.

## Skydeliai

Spustelėjus juostos piktogramą atsidaro skydelis, kuris yra tikras iškylantysis langas su slankikliais, sąrašais ir naršymu klaviatūra, o ne patarimas. Kiekvienas jų taip pat turi spartųjį klavišą, todėl niekada nereikia taikytis į 16 pikselių glifą:

| Spartusis klavišas | Skydelis |
| --- | --- |
| `Super + Ctrl + A` | Garsas |
| `Super + Ctrl + N` | Tinklas |
| `Super + Ctrl + B` | „Bluetooth“ |
| `Super + Ctrl + D` | Ekranas |
| `Super + Ctrl + P` | Maitinimas |
| `Super + Ctrl + Alt + D` | Kalendorius |
| `Super + Ctrl + Alt + E` | Pasaulio laikrodis |
| `Super + Ctrl + 1-9` | Perjungti n-ąjį skydelį dešiniajame skyriuje |

Skydeliai nėra vien rodmenys. Juose iš tikrųjų atliekate veiksmą:

- **Garsas** turi pagrindinio garsumo slankiklį, išvesties įrenginio pasirinkimą ir atskirą maišytuvą kiekvienai programai, todėl galite pritildyti tą vieną naršyklės skirtuką neliesdami viso kito.
- **Tinklas** ieško „Wi-Fi“, rodo signalo stiprumą, prisijungia ir leidžia pasirinkti DNS teikėją.
- **„Bluetooth“** išvardija jūsų įrenginius su prisijungimu / atsijungimu ir baterijos lygiais.
- **Maitinimas** rodo baterijos statistiką, perjungia maitinimo profilius (jis prisimena atskirą pasirinkimą baterijai ir AC) ir pateikia šiek tiek sistemos informacijos.
- **Ekranas** turi ryškumo slankiklį, teksto dydį, monitoriaus mastelio išankstinius nustatymus ir — kai turite daugiau nei vieną ekraną — atskirus valdiklius kiekvienam monitoriui. Išsamesnę istoriją žr. [monitoriai](33-monitors.md).
- **Laikrodis** atidaro mėnesio tinklelį su ISO savaičių numeriais ir mėnesių perjungimu.
- **Pasaulio laikrodis** laiko po eilutę kiekvienam miestui, su jo oru ir tuo, kaip jam einasi diena. Paieška randa ir miestelius, ir laiko juostas, todėl Fort Lauderdale yra Fort Lauderdale, o ne New York. Jei viršuje esančioje eilutėje nurodytas neteisingas miestas, spustelėkite ją ir pasakykite, kur esate; pasirinkite vietą kitoje laiko juostoje ir sistemos laikrodis taip pat persikels ten, o tai patogu keliaujant. Užveskite pelę ant miesto ir spustelėkite asmens mygtuką, kad pasakytumėte, kas ten gyvena — paprastus vardus arba `@` „GitHub“ pseudonimus, kad kartu atkeliautų ir jų veidai.

Kiekvienas skydelis valdomas ir klaviatūra, ir pele: rodyklės juda, Return aktyvina, Tab pereina į gretimą skydelį, o Escape uždaro.

`Super + Ctrl + 1-9` skaičiuoja skydelius iš kairės į dešinę dešiniajame skyriuje, praleisdamas dėklą, nes jis neturi savo skydelio. Taigi skaičius atitinka piktogramą, į kurią rody tumėte.

### „Tailscale“ ir „Dropbox“

Dar du valdikliai juostoje pasirodo tik tada, kai įdiegiate atitinkamą paslaugą iš **Install → Service**, ir abu verta žinoti, nes jie daro daugiau nei tik praneša būseną.

**„Tailscale“** skydelis prijungia ir atjungia tailnet, perjungia paskyras ir pasirenka išėjimo mazgą (tame sąraše rodomi ir jūsų pačių kompiuteriai, ir „Mullvad“ regionai). Jis taip pat naršo jūsų kompiuterius — ir kai vienas pasirinktas, `s` siunčia į jį failus per „Taildrop“, o tai greičiausias būdas perkelti failą į telefoną ar kitą nešiojamąjį kompiuterį. `c` kopijuoja kompiuterio IP, `n` — jo pavadinimą, o `d` — jo visą DNS pavadinimą. Kiekvienoje kompiuterio eilutėje taip pat yra siuntimo mygtukas, jei mieliau spustelėsite. Tas pats iš terminalo yra `omarchy tailscale send <machine> [file...]`.

**„Dropbox“** skydelis tvarko prisijungimą, rodo, kiek saugyklos išnaudojote, ir išvardija neseniai sinchronizuotus failus.

Pašalinus bet kurią paslaugą, jos valdiklis taip pat dings iš juostos.

## Indikatoriai

Maža grupelė centre yra indikatorių valdiklis. Tai būsenos glifai režimams, kuriuos įjungėte: netrukdyti, nakties šviesa, eilėje laukiantis [priminimas](09-reminders.md), aktyvus ekrano įrašymas, nemiegojimas ir [diktavimas](11-text-extraction-dictation.md). Jie užsižiebia, kai režimas aktyvus, o kitu atveju nesimaišo — užveskite pelę bet kur ant juostos, kad žvilgtelėtumėte į neaktyvius. Spustelėjus indikatorių, tas režimas perjungiamas. Dar vienas yra tik būsenos: nuotolinė sesija šviečia raudonai, kol kas nors yra prisijungęs prie šio kompiuterio per gliff.

Jei mieliau norėtumėte, kad jie visada būtų matomi, valdiklyje nustatykite `alwaysShow` į `true`. O jei jums rūpi tik kai kurie iš jų, išvardykite norimus `items`: `["Dnd", "Reminder", "NightLight"]`. Galite turėti daugiau nei vieną indikatorių valdiklį, todėl skirtingi skyriai gali rodyti skirtingus pogrupius.

## Juostos pertvarkymas

Juosta konfigūruojasi pati. Jums nereikia atidaryti konfigūracijos failo, kad ką nors perkeltumėte.

Suimkite tuščią juostos lopinėlį aplink centrą ir vilkite jį link kito ekrano krašto, ir juosta persikels ten — veikia kairė, dešinė, viršus ir apačia, o kiekvienas valdiklis prisitaiko (vertikalios juostos grįžta prie kompaktiškų, tik piktogramas rodančių formų). Tas pats vilkimas prasideda spustelėjus ir palaikius. Dukart spustelėkite kairiuoju mygtuku tą pačią tuščią vietą, kad cikliškai perjungtumėte juostos foną iš skaidraus į stiklinį į neskaidrų. Ir vilkite bet kurį valdiklį, kad pakeistumėte jo tvarką arba įmestumėte jį į kitą skyrių; kiti valdikliai prasiskirs, kad padarytų vietos ten, kur jis nusileis.

Juostos vidurys yra dėžutė: kas joje yra, lieka centre kaip viena grupė, o valdikliai abiejose jos pusėse kabo ant jos kraštų. Kol velkate valdiklį, dėžutė rodoma kaip kontūras arba, kai ji tuščia, kaip linija per juostą, ir galite numesti į ją arba šalia jos. Kai numetimas atsidurtų dėžutėje, dėžutė padidėja, kad priimtų valdiklį.

Valdiklis, kurį norite turėti po ranka, bet ne visada matomą, gali keliauti į dėklo stalčių: vilkite jį ant dėklo ir stalčius atsidarys, kad jį priimtų. Jis ten yra po programų piktogramų, pasirodo visada, kai pasirodo stalčius, ir laiko savo stalčių atidarytą, kol jo skydelis atidarytas. Vilkite jį atgal ant juostos, kad grąžintumėte.

Jei mieliau renkatės iš meniu, **Appearance → Menu Bar** turi padėtį, o **Bar Background** pasirenka, kaip juosta piešiama: **Opaque Bar**, **Glassy Bar** (permatoma, o tai, kas už jos, sulieta) arba **Clear Bar**.

Tie patys dalykai turi komandas, o būtent to norite [dotfiles](31-dotfiles.md) sąrankai:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Norėdami visiškai pridėti arba pašalinti valdiklį, naudokite papildinių komandas. `omarchy plugin list` išspausdina kiekvieną valdiklį, kurį žino apvalkalas, su jo id, o tada:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Juostos slėpimas

`Super + Shift + Space` išjungia ir vėl įjungia juostą nenužudydamas apvalkalo — skydeliai ir spartieji klavišai toliau veikia, jūs tiesiog atgaunate pikselius. Tai taip pat yra meniu, skiltyje **Appearance → Menu Bar → Hide Bar**.

## Konfigūracijos failas

Visa tai saugoma `~/.config/omarchy/shell.json`, po `bar` raktu. Štai sutrumpinta versija:

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

Kiekvienas valdiklis yra vienas įrašas viename iš penkių išdėstymo masyvų, o jo nustatymai yra tame pačiame įraše — nėra atskiro nustatymų failo ir nėra `config` poobjekčio. Laikrodžio `format`, `formatAlt` (į ką perjungia dešinysis spustelėjimas) ir `verticalFormat` visi yra ten pat, ant `{ "id": "omarchy.clock" }`.

`center` yra dėžutė juostos viduryje: viskas joje yra centruojama ekrane kaip viena grupė. `centerBegin` ir `centerEnd` kabo abiejose dėžutės pusėse, todėl laikrodis lieka pačiame centre net tada, kai orai ir naujinio ženklelis ateina ir išeina. Įdėkite daugiau nei vieną valdiklį į `center` ir jie bus centruojami kartu; palikite jį tuščią ir `centerBegin` bei `centerEnd` susitiks juostos viduryje.

Viena taisyklė, kurią verta įsisavinti: **kai turite savo `shell.json`, jis yra kanoninis**. Kol nieko nepritaikote, apvalkalas skaito numatytąjį „Omarchy“ failą. Vos tik nuvelkate valdiklį, paleidžiate `omarchy bar` arba patys redaguojate failą, jis tampa jūsų — nėra gilaus sujungimo, todėl nauji numatytieji valdikliai būsimose „Omarchy“ laidose automatiškai jūsų juostoje nepasirodys. `omarchy bar defaults` grąžina pristatytą išdėstymą, kai tik norite švaraus lapo.

Tame pačiame faile taip pat yra jūsų neveiklumo laikai aukščiausiame lygyje, už `bar` rakto ribų: `idle.screensaver` ir `idle.lock`, abu sekundėmis nuo tada, kai tapote neaktyvūs. Taigi numatytoji ekrano užsklanda įsijungia po 150 sekundžių, o užraktas — po 300.
