# Viršutinė juosta

Juosta palei jūsų ekrano viršų yra Omarchy juosta. Tai ne primontuota būsenos juosta, o Omarchy apvalkalo dalis — vieno ilgai veikiančio Quickshell proceso, kuris taip pat piešia meniu, pranešimus, OSD iškylančius langus ir užrakinimo ekraną. Štai kodėl ji puikiai dera prie viso kito ir kodėl skydelis atsidaro akimirksniu, o ne sukuria naują programą.

Tai taip pat vienintelė darbalaukio dalis, kuri visada yra ekrane, todėl verta žinoti, ką daro visi tie maži glifai.

## Kas joje yra pagal numatytuosius nustatymus

Juosta turi tris dalis. Kairėje yra Omarchy logotipas (meniu leistuvas) ir darbo sričių indikatoriai. Centre gaunate būsenos indikatorius, laikrodį, Elsewhen (pasaulio laikrodį), orus ir Omarchy atnaujinimo ženklelį. Dešinėje: klaviatūros išdėstymas (kai sukonfigūruota daugiau nei viena), sistemos dėklas, agentai, bluetooth, tinklas, garsas, ekranas ir maitinimas.

Keletas iš jų pasirodo tik tada, kai turi ką pasakyti. Klaviatūros išdėstymas pasirodo tik jei sukonfigūravote daugiau nei vieną išdėstymą. Atnaujinimo ženklelis pasirodo tik kai laukia Omarchy atnaujinimas. O agentų piktograma pasirodo pirmą kartą, kai Omarchy randa AI programavimo naudojimą kompiuteryje (žr. [AI](17-ai.md)).

## Spaudinėjimas

Beveik kiekvienas valdiklis kažką daro paspaudus kairiuoju, dešiniuoju ir viduriniu mygtuku, o keli reaguoja į slinkimą. Tai dalis, kurios žmonės nepastebi — dešinysis ir vidurinis mygtukai yra ten, kur slepiasi daug gerų dalykų.

| Valdiklis | Kairysis | Dešinysis | Vidurinis / slinkimas |
| --- | --- | --- | --- |
| Meniu | Omarchy meniu | Naujas terminalas | — |
| Darbo sritys | Sufokusuoti tą darbo sritį | — | Slinkimas: kita / ankstesnė darbo sritis |
| Laikrodis | Kalendoriaus iškylantis langas | Keisti žymos formatą cikliškai | Vidurinis: laiko juostos parinkiklis |
| Oras | Prognozės iškylantis langas | Pilnas oras kaip pranešimas | Vidurinis: atnaujinti |
| Garsas | Garso skydelis | Nutildyti | Vidurinis: skydelis · slinkimas: garsumas |
| Mikrofonas | Nutildyti mikrofoną | — | Vidurinis: garso skydelis · slinkimas: įvesties garsumas |
| Tinklas | Tinklo skydelis | — | — |
| Bluetooth | Bluetooth skydelis | Perjungti radiją | — |
| Ekranas | Ekrano skydelis | — | Slinkimas: ryškumas |
| Maitinimas | Maitinimo skydelis | Perjungti akumuliatoriaus procentus | — |
| Medija | Leisti / pristabdyti | Viršelio iškylantis langas | Vidurinis: kitas · slinkimas: ankstesnis / kitas |
| Agentai | Agentų skydelis | Paleisti jūsų agentą | Vidurinis: kita prenumerata |
| Dėklas | Užveskite, kad atidengtumėte stalčių | Dešinysis ant ševrono, kad valdytumėte | — |
| Omarchy atnaujinimas | Paleisti atnaujinimą | — | — |

Ne viskas iš tos lentelės iš karto yra jūsų juostoje. Medijos valdiklis (MPRIS dabar leidžiama, su slenkančiu kūriniu ir atlikėju) ir mikrofono valdiklis abu yra įmontuoti, bet pagal numatytuosius nustatymus išjungti — pridėkite juos, jei jų norite, kaip aprašyta toliau.

## Skydeliai

Spustelėjus juostos piktogramą atsidaro skydelis, kuris yra tikras iškylantis langas su slankikliais, sąrašais ir naršymu klaviatūra, o ne patarimas. Kiekvienas taip pat turi spartųjį klavišą, todėl niekada nereikia taikyti į 16 pikselių glifą:

| Spartusis klavišas | Skydelis |
| --- | --- |
| `Super + Ctrl + A` | Garsas |
| `Super + Ctrl + W` | Tinklas |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ekranas |
| `Super + Ctrl + P` | Maitinimas |
| `Super + Ctrl + Alt + D` | Kalendorius |
| `Super + Ctrl + Alt + E` | Pasaulio laikrodis |
| `Super + Ctrl + 1-9` | Perjungti n-tąjį skydelį dešinėje dalyje |

Skydeliai nėra rodmenys. Juose iš tikrųjų atliekate veiksmą:

- **Garsas** turi pagrindinio garsumo slankiklį, išvesties įrenginio parinkiklį ir maišytuvą atskiroms programoms, tad galite pritildyti tą vieną naršyklės skirtuką neliesdami viso kito.
- **Tinklas** ieško Wi-Fi, rodo signalo stiprumą, jungiasi ir leidžia pasirinkti DNS tiekėją.
- **Bluetooth** išvardija jūsų įrenginius su prijungimu / atjungimu ir akumuliatoriaus lygiais.
- **Maitinimas** rodo akumuliatoriaus statistiką, perjungia maitinimo profilius (jis prisimena atskirą pasirinkimą akumuliatoriui ir AC) ir atspausdina šiek tiek sistemos informacijos.
- **Ekranas** turi ryškumo slankiklį, teksto dydį, monitoriaus mastelio išankstinius nustatymus ir — kai turite daugiau nei vieną ekraną — atskirų monitorių valdiklius. Žr. [monitorius](33-monitors.md) gilesnei istorijai.
- **Laikrodis** atidaro mėnesio tinklelį su ISO savaičių numeriais ir mėnesių perjungimu.

Kiekvienas skydelis priima ir klaviatūrą, ir pelę: rodyklės juda, Return aktyvuoja, Tab pereina į kaimyninį skydelį, o Escape uždaro.

`Super + Ctrl + 1-9` skaičiuoja skydelius iš kairės į dešinę dešinėje dalyje, praleidžiant dėklą, nes jis neturi savo skydelio. Taigi skaičius atitinka piktogramą, į kurią taikytumėte.

### Tailscale ir Dropbox

Dar du valdikliai juostoje pasirodo tik įdiegus atitinkamą paslaugą iš **Įdiegti → Paslauga**, ir abu verta žinoti, nes jie daro daugiau nei praneša būseną.

**Tailscale** skydelis prijungia ir atjungia tailnet, perjungia paskyras ir pasirenka išėjimo mazgą (tame sąraše rodomi ir jūsų paties kompiuteriai, ir Mullvad regionai). Jis taip pat naršo jūsų kompiuterius — ir kai vienas pasirinktas, `s` siunčia jam failus per Taildrop, o tai yra greičiausias būdas perkelti failą į jūsų telefoną ar kitą nešiojamąjį kompiuterį. `c` nukopijuoja kompiuterio IP, `n` jo pavadinimą, o `d` jo pilną DNS pavadinimą. Kiekvienoje kompiuterio eilutėje taip pat yra siuntimo mygtukas, jei mieliau spustelėtumėte. Tas pats iš terminalo yra `omarchy tailscale send <machine> [file...]`.

**Dropbox** skydelis tvarko prisijungimą, rodo, kiek saugyklos naudojate, ir išvardija neseniai sinchronizuotus failus.

Pašalinus bet kurią paslaugą, jos valdiklis nuo juostos pašalinamas.

## Indikatoriai

Maža grupė centre yra indikatorių valdiklis. Tai būsenos glifai režimams, kuriuos įjungėte: netrukdyti, naktinė šviesa, eilėje laukiantis [priminimas](09-reminders.md), aktyvus ekrano įrašas, nemiegoti ir [diktavimas](11-text-extraction-dictation.md). Jie užsidega, kai režimas aktyvus, o kitu atveju nesimaišo — užveskite į kairę nuo laikrodžio (virš jo vertikalioje juostoje), kad pažvelgtumėte į neaktyvius. Spustelėjus indikatorių, tas režimas perjungiamas. Dar vienas yra tik būsena: nuotolinė sesija šviečia raudonai, kol kas nors per gliff yra prisijungęs prie šio kompiuterio.

Jei mieliau norėtumėte, kad jie visada būtų matomi, valdiklyje nustatykite `alwaysShow` į `true`. O jei jums rūpi tik kai kurie iš jų, išvardykite norimus `items`: `["Dnd", "Reminder", "NightLight"]`. Galite turėti daugiau nei vieną indikatorių valdiklį, todėl skirtingos dalys gali rodyti skirtingus poaibius.

## Juostos pertvarkymas

Juosta susikonfigūruoja pati. Jums nereikia atidaryti konfigūracijos failo, kad perkeltumėte dalykus.

Suimkite tuščią juostos lopinėlį aplink centrą ir vilkite jį link kito ekrano krašto, ir juosta persikels ten — kairė, dešinė, viršus ar apačia visi veikia, o kiekvienas valdiklis prisitaiko (vertikalios juostos pereina prie kompaktiškų, tik piktograminių formų). Spustelėjimas ir laikymas pradeda tą patį vilkimą. Dukart spustelėkite kairiuoju mygtuku tą pačią tuščią vietą, kad cikliškai pakeistumėte juostos foną iš skaidraus į stiklinį ir į nepermatomą. Ir vilkite bet kurį valdiklį, kad jį pertvarkytumėte arba įmestumėte į kitą dalį.

Valdiklis, kurį norite turėti šalia, bet ne visada matyti, gali keliauti į dėklo stalčių: nutempkite jį ant dėklo, ir stalčius atsivers jį priimdamas. Ten jis būna už programų piktogramų, pasirodo kaskart, kai pasirodo stalčius, ir laiko stalčių atidarytą, kol rodomas jo skydelis. Norėdami grąžinti, nutempkite jį atgal į juostą.

Jei mieliau rinktumėtės iš meniu, **Veiksmai → Išvaizda → Meniu juosta** turi padėtį, o **Juostos fonas** pasirenka, kaip juosta piešiama: **Nepermatoma juosta**, **Stiklinė juosta** (permatoma, su sulietu tuo, kas yra už jos) arba **Skaidri juosta**.

Tie patys dalykai turi komandas, o tai yra tai, ko norite [dotfiles](31-dotfiles.md) sąrankai:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Norėdami visiškai pridėti arba pašalinti valdiklį, naudokite papildinių komandas. `omarchy plugin list` atspausdina kiekvieną valdiklį, kurį žino apvalkalas, su jo id, o tada:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Juostos slėpimas

`Super + Shift + Space` perjungia juostą išjungtą ir atgal neužmušant apvalkalo — skydeliai ir spartieji klavišai toliau veikia, tiesiog susigrąžinate pikselius. Tai taip pat yra meniu po **Veiksmai → Išvaizda → Meniu juosta → Slėpti juostą**.

## Konfigūracijos failas

Visa tai saugoma `~/.config/omarchy/shell.json`, po `bar` raktu. Štai apkarpyta versija:

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

Kiekvienas valdiklis yra vienas įrašas viename iš trijų išdėstymo masyvų, o jo nuostatos yra tame įraše — nėra atskiro nuostatų failo ir nėra `config` poobjekto. Laikrodžio `format`, `formatAlt` (į ką cikliškai pereina dešinysis spustelėjimas) ir `verticalFormat` visi gyvena ten pat ant `{ "id": "omarchy.clock" }`.

`centerAnchor` įvardija vieną centrinį valdiklį, kuris prisegamas prie tikslaus ekrano centro, o kiti jį supa iš šonų. Taip laikrodis lieka pačiame centre, net kai ateina ir išeina oras ir atnaujinimo ženklelis. Nustatykite jį į tuščią eilutę ir centro sąrašas tiesiog centruojamas kaip grupė.

Viena taisyklė, kurią verta įsisavinti: **kai turite savo `shell.json`, jis yra kanoninis**. Kol nieko nepritaikote, apvalkalas skaito Omarchy numatytąjį failą. Kai tik nutempiate valdiklį, paleidžiate `omarchy bar` arba patys redaguojate failą, jis priklauso jums — nėra gilaus sujungimo, todėl nauji numatytieji valdikliai būsimuose Omarchy leidimuose jūsų juostoje automatiškai nepasirodys. `omarchy bar defaults` grąžina pristatytą išdėstymą, kai tik norite švaraus lapo.

Tame pačiame faile taip pat yra jūsų tuščiosios eigos laikai aukščiausiame lygyje, už `bar` rakto: `idle.screensaver` ir `idle.lock`, abu sekundėmis nuo to, kai nuėjote į tuščiąją eigą. Taigi numatytoji ekrano užsklanda įsijungia po 150 sekundžių, o užraktas po 300.
