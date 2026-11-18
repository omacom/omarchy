# Viršutinė juosta

Juosta jūsų ekrano viršuje yra Omarchy juosta. Tai ne prisukta būsenos juosta, o Omarchy aplinkos dalis – vieno ilgai veikiančio Quickshell proceso, kuris taip pat piešia meniu, pranešimus, OSD iššokamuosius langus ir užrakinimo ekraną. Todėl ji puikiai dera su visa kita ir todėl skydelis atsidaro akimirksniu, užuot paleidus naują programą.

Tai taip pat vienintelė darbalaukio dalis, kuri visada matoma ekrane, todėl verta žinoti, ką daro visi tie maži ženklai.

## Kas joje yra pagal numatytuosius nustatymus

Juostą sudaro trys dalys. Kairėje yra Omarchy logotipas (meniu paleidimo priemonė) ir darbo sričių indikatoriai. Centre rasite būsenos indikatorius, laikrodį, Elsewhen (pasaulio laikrodį), orą ir Omarchy naujinimo ženklelį. Dešinėje: sistemos dėklas, klaviatūros išdėstymas (kai sukonfigūruota daugiau nei vienas), agentai, bluetooth, tinklas, garsas, ekranas ir maitinimas.

Kai kurie iš jų pasirodo tik tada, kai turi ką pasakyti. Klaviatūros išdėstymas pasirodo tik tada, jei sukonfigūravote daugiau nei vieną išdėstymą. Naujinimo ženklelis pasirodo tik tada, kai laukia Omarchy naujinimas. O agentų piktograma pasirodo pirmą kartą, kai Omarchy randa AI kodavimo naudojimą kompiuteryje (žr. [AI](17-ai.md)).

## Spustelėjimai

Beveik kiekvienas valdiklis ką nors daro spustelėjus kairįjį, dešinįjį ir vidurinį mygtuką, o keli reaguoja į slinkimą. Tai dalis, kurią žmonės praleidžia – dešinysis ir vidurinis mygtukai slepia daug gerų dalykų.

| Valdiklis | Kairysis | Dešinysis | Vidurinis / slinktis |
| --- | --- | --- | --- |
| Meniu | Omarchy meniu | Naujas terminalas | — |
| Darbo sritys | Sutelkti tą darbo sritį šiame monitoriuje | — | Slinktis: kita / ankstesnė darbo sritis |
| Laikrodis | Kalendoriaus iššokantis langas | Perjungti etiketės formatą | Vidurinis: laiko juostos parinkiklis |
| Oras | Prognozės iššokantis langas | Visas oras kaip pranešimas | Vidurinis: atnaujinti |
| Garsas | Garso skydelis | Nutildyti | Vidurinis: skydelis · slinktis: garsumas |
| Mikrofonas | Nutildyti mikrofoną | — | Vidurinis: garso skydelis · slinktis: įvesties garsumas |
| Tinklas | Tinklo skydelis | — | — |
| Bluetooth | Bluetooth skydelis | Perjungti radijo ryšį | — |
| Ekranas | Ekrano skydelis | — | Slinktis: ryškumas |
| Maitinimas | Maitinimo skydelis | Perjungti akumuliatoriaus procentus | — |
| Medija | Leisti / pristabdyti | Viršelio iššokantis langas | Vidurinis: kitas · slinktis: ankstesnis / kitas |
| Agentai | Agentų skydelis | Paleisti jūsų agentą | Vidurinis: kita prenumerata |
| Dėklas | Užveskite, kad atsirastų stalčius | Dešinysis ant ševrono, kad valdytumėte | — |
| Omarchy naujinimas | Vykdyti naujinimą | — | — |

Ne viskas iš šios lentelės jūsų juostoje yra iš karto. Medijos valdiklis (MPRIS dabar grojamas, su slenkančiu takeliu ir atlikėju) ir mikrofono valdiklis yra integruoti, bet pagal numatytuosius nustatymus išjungti – pridėkite juos, jei norite, kaip aprašyta toliau.

## Skydeliai

Spustelėjus juostos piktogramą atsidaro skydelis, kuris yra tikras iššokantis langas su slankikliais, sąrašais ir klaviatūros valdymu, o ne patarimas. Kiekvienas taip pat turi spartųjį klavišą, todėl niekada nereikia taikytis į 16 pikselių ženklą:

| Spartusis klavišas | Skydelis |
| --- | --- |
| `Super + Ctrl + A` | Garsas |
| `Super + Ctrl + N` | Tinklas |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ekranas |
| `Super + Ctrl + P` | Maitinimas |
| `Super + Ctrl + Alt + D` | Kalendorius |
| `Super + Ctrl + Alt + E` | Pasaulio laikrodis |
| `Super + Ctrl + 1-9` | Perjungti n-ąjį skydelį dešinėje dalyje |

Skydeliai nėra tik rodmenys. Juose iš tikrųjų atliekate veiksmą:

- **Garsas** turi pagrindinio garsumo slankiklį, išvesties įrenginio parinkiklį ir atskirą kiekvienos programos maišytuvą, todėl galite pritildyti tą vieną naršyklės skirtuką neliesdami viso kito.
- **Tinklas** ieško Wi-Fi, rodo signalo stiprumą, prisijungia ir leidžia pasirinkti DNS teikėją.
- **Bluetooth** pateikia jūsų įrenginius su prijungimu / atjungimu ir akumuliatoriaus lygiais.
- **Maitinimas** rodo akumuliatoriaus statistiką, perjungia maitinimo profilius (įsimena atskirą pasirinkimą akumuliatoriui ir AC) ir pateikia šiek tiek sistemos informacijos.
- **Ekranas** turi ryškumo slankiklį, teksto dydį, monitoriaus mastelio išankstinius nustatymus ir – kai turite daugiau nei vieną ekraną – atskirus kiekvieno monitoriaus valdiklius. Gilesnę istoriją žr. [monitoriai](33-monitors.md).
- **Laikrodis** atidaro mėnesio tinklelį su ISO savaičių numeriais ir mėnesių perjungimu.
- **Pasaulio laikrodis** kiekvienam miestui skiria po eilutę su jo oru ir tuo, kaip klostosi jo diena. Paieška randa ir miestus, ir laiko juostas, todėl Fort Lauderdale yra Fort Lauderdale, o ne New York. Jei viršuje esanti eilutė įvardija ne tą miestą, spustelėkite ją ir pasakykite, kur esate; pasirinkite vietą kitoje laiko juostoje ir sistemos laikrodis taip pat persikels ten, o tai patogu keliaujant. Užveskite ant miesto ir spustelėkite asmens mygtuką, kad pasakytumėte, kas ten gyvena – paprastais vardais arba `@` GitHub vardais, kad kartu atsirastų ir jų veidai.

Kiekvienas skydelis priima ir klaviatūrą, ir pelę: rodyklės juda, Return suaktyvina, Tab pereina prie gretimo skydelio, o Escape uždaro.

`Super + Ctrl + 1-9` skaičiuoja skydelius iš kairės į dešinę dešinėje dalyje, praleisdamas dėklą, nes jis neturi savo skydelio. Todėl skaičius atitinka piktogramą, į kurią rodytumėte.

### Tailscale ir Dropbox

Dar du valdikliai juostoje pasirodo tik tada, kai iš **Įdiegti → Paslauga** įdiegiate atitinkamą paslaugą, ir abu verta žinoti, nes jie daro daugiau nei tik praneša būseną.

**Tailscale** skydelis prijungia ir atjungia tailnet, perjungia paskyras ir parenka išėjimo mazgą (tame sąraše rodomi ir jūsų paties kompiuteriai, ir Mullvad regionai). Jis taip pat naršo jūsų kompiuterius – ir kai vienas pasirinktas, `s` siunčia jam failus per Taildrop, o tai yra greičiausias būdas perkelti failą į jūsų telefoną ar kitą nešiojamąjį kompiuterį. `c` kopijuoja kompiuterio IP, `n` – jo pavadinimą, o `d` – jo visą DNS pavadinimą. Kiekvienoje kompiuterio eilutėje taip pat yra siuntimo mygtukas, jei mieliau spustelėsite. Tas pats iš terminalo yra `omarchy tailscale send <machine> [file...]`.

**Dropbox** skydelis tvarko prisijungimą, rodo, kiek saugyklos išnaudojote, ir pateikia neseniai sinchronizuotus failus.

Pašalinus bet kurią paslaugą jos valdiklis vėl dings nuo juostos.

## Indikatoriai

Maža grupelė centre yra indikatorių valdiklis. Tai įjungtų režimų būsenos ženklai: netrukdyti, naktinė šviesa, eilėje laukiantis [priminimas](09-reminders.md), aktyvus ekrano įrašymas, nemiegoti ir [diktavimas](11-text-extraction-dictation.md). Jie užsižiebia, kai režimas aktyvus, ir kitaip lieka nuošalyje – užveskite visai šalia jų, kur sėdėtų neaktyvūs, kad žvilgtelėtumėte į juos. Spustelėjus indikatorių tas režimas perjungiamas. Dar vienas yra tik būsenos: nuotolinė sesija šviečia raudonai, kol kas nors prisijungęs prie šio kompiuterio per gliff.

Jei mieliau norėtumėte, kad jie visada būtų matomi, valdiklyje nustatykite `alwaysShow` į `true`. O jei jums rūpi tik kai kurie iš jų, išvardykite norimus `items`: `["Dnd", "Reminder", "NightLight"]`. Galite turėti daugiau nei vieną indikatorių valdiklį, todėl skirtingos dalys gali rodyti skirtingus poaibius.

## Juostos pertvarkymas

Juosta konfigūruojasi pati. Norint ką nors perkelti nereikia atidaryti konfigūracijos failo.

Suimkite tuščią juostos lopinėlį apie centrą ir vilkite jį link kito ekrano krašto, ir juosta persikels ten – veikia kairė, dešinė, viršus ar apačia, o kiekvienas valdiklis prisitaiko (vertikalios juostos grįžta prie kompaktinių, tik piktogramų formų). Spustelėjimas ir laikymas pradeda tą patį vilkimą. Dukart spustelėkite kairiuoju mygtuku tą pačią tuščią vietą, kad perjungtumėte juostos foną iš skaidraus į stiklinį į nepermatomą. Ir vilkite bet kurį valdiklį, kad pakeistumėte jo tvarką arba mestumėte jį į kitą dalį; kiti valdikliai prasiskirs, kad padarytų vietos ten, kur jis nusileis.

Juostos vidurys yra dėžė: kas joje yra, lieka centre kaip viena grupė, o valdikliai iš abiejų jos pusių kabo nuo jos kraštų. Kol velkate valdiklį, dėžė rodoma kaip kontūras arba, kai ji tuščia, kaip linija per juostą, ir galite mesti į ją arba šalia jos. Kai metimas nusileistų dėžėje, dėžė padidėja, kad priimtų valdiklį.

Valdiklis, kurį norite turėti po ranka, bet ne visada matomą, gali keliauti į dėklo stalčių: vilkite jį ant dėklo, ir stalčius atsidarys, kad jį priimtų. Jis sėdi ten po programų piktogramų, pasirodo, kai tik pasirodo stalčius, ir laiko savo stalčių atidarytą, kol jo skydelis atidarytas. Vilkite jį atgal ant juostos, kad grąžintumėte.

Jei mieliau rinktumėtės iš meniu, **Išvaizda → Meniu juosta** turi padėtį, o **Juostos fonas** parenka, kaip juosta piešiama: **Nepermatoma juosta**, **Stiklinė juosta** (permatoma, už jos esantis vaizdas sulietas) arba **Skaidri juosta**.

Tie patys dalykai turi komandas, o būtent to norite [dotfiles](31-dotfiles.md) sąrankai:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Norėdami valdiklį pridėti arba visai pašalinti, naudokite papildinių komandas. `omarchy plugin list` atspausdina kiekvieną valdiklį, kurį aplinka žino, su jo id, o tada:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Juostos slėpimas

`Super + Shift + Space` perjungia juostą išjungtą ir vėl įjungtą neužmušdamas aplinkos – skydeliai ir spartieji klavišai veikia toliau, tiesiog atgaunate pikselius. Tai taip pat yra meniu dalyje **Išvaizda → Meniu juosta → Slėpti juostą**.

## Konfigūracijos failas

Visa tai saugoma `~/.config/omarchy/shell.json`, rakte `bar`. Štai sutrumpinta versija:

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

Kiekvienas valdiklis yra vienas įrašas viename iš penkių išdėstymo masyvų, o jo nustatymai yra tame pačiame įraše – nėra atskiro nustatymų failo ir nėra `config` poobjekto. Laikrodžio `format`, `formatAlt` (tai, į ką perjungia dešinysis spustelėjimas) ir `verticalFormat` visi gyvena ten pat, ant `{ "id": "omarchy.clock" }`.

`center` yra dėžė juostos viduryje: viskas joje centruojama ekrane kaip viena grupė. `centerBegin` ir `centerEnd` kabo iš abiejų dėžės pusių, todėl laikrodis lieka tiksliai centre, net kai oras ir naujinimo ženklelis atsiranda ir dingsta. Įdėkite daugiau nei vieną valdiklį į `center` ir jie bus centruojami kartu; palikite jį tuščią ir `centerBegin` bei `centerEnd` susitiks juostos viduryje.

Viena taisyklė, kurią verta įsisavinti: **kai turite savo `shell.json`, jis yra kanoninis**. Kol nieko nepakeitėte, aplinka skaito Omarchy numatytąjį failą. Vos tik nuvelkate valdiklį, paleidžiate `omarchy bar` arba pats redaguojate failą, jis jūsų – nėra gilaus sujungimo, todėl nauji numatytieji valdikliai būsimuose Omarchy leidimuose jūsų juostoje automatiškai nepasirodys. `omarchy bar defaults` grąžina pateiktą išdėstymą, kai tik norite švaraus lapo.

Tame pačiame faile aukščiausiu lygiu, už `bar` rakto ribų, taip pat yra jūsų neveiklumo laikai: `idle.screensaver` ir `idle.lock`, abu sekundėmis nuo tada, kai tapote neaktyvūs. Todėl numatytoji ekrano užsklanda įsijungia po 150 sekundžių, o užraktas – po 300.
