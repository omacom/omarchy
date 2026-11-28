# Windows VM

Omarchy siūlo paprastą būdą paleisti Windows per Docker VM x86_64 kompiuteriuose. Jį galite įdiegti naudodami _Install > Windows_ iš Omarchy meniu (`Super + Space`).

Jūsų kompiuteriui tam reikia KVM virtualizacijos, kurią turi dauguma — bet kartais ji būna išjungta BIOS, ir diegimo programa jums praneš, jei taip yra. Taip pat prireiks vietos diske: tiek, kiek skiriate Windows, plius apie 10GB pačiam atvaizdui.

Diegimo programa paklausia, kiek RAM, kiek CPU branduolių ir kiek vietos diske atiduoti (64GB ar daugiau yra protinga apatinė riba), tada — Windows vartotojo vardo ir slaptažodžio. Palikite juos tuščius ir gausite `docker` / `admin`. Atsisiuntimas užtrunka — 10-15 minučių yra normalu — o eigą galite sekti naršyklėje adresu `http://127.0.0.1:8006`. Prieš atidarydama konsolę, naršyklė paprašys to paties vartotojo vardo ir slaptažodžio.

 ![windows-vm](images/windows-vm.webp)

## Naudojimas

Įdiegę paleiskite _Windows_ iš programų paleidyklės. Tai paleidžia VM, jei ji dar neveikia, ir prijungia jus per RDP, per visą ekraną. Šaltam paleidimui skirkite 15-30 sekundžių.

RDP seansas perduoda garsą, jūsų mikrofoną ir bendrą iškarpinę, todėl teksto kopijavimas tarp Linux ir Windows tiesiog veikia. Raiška prisitaiko prie jūsų lango, o Omarchy perduoda jūsų ekrano mastelį, todėl HiDPI ekrane tai nėra išsiliejusi košė.

Kai uždarote RDP langą, VM automatiškai išsijungia. Jei verčiau paliktumėte ją veikti — tarkime, joje kažkas dirba — vietoj to paleiskite ją su `omarchy windows vm launch --keep-alive`.

Likę valdikliai yra toje pačioje komandoje:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Failų bendrinimas

Katalogas `~/Windows` jūsų namų kataloge yra automatiškai bendrinamas su VM. Dėkite failus ten, jei norite, kad jie būtų pasiekiami Windows. VM neturi prieigos prie jokios kitos jūsų failų sistemos dalies, todėl esate saugūs nuo bet kokių bjaurybių Windows pusėje. Jos pačios virtualus diskas yra pasiekiamas adresu `~/.windows`.

Tie pažįstami namų keliai lieka savo failų sistemose. Jie taip pat gali būti simbolinės nuorodos į jums priklausančius katalogus, o tai naudinga, kai virtualus diskas yra didesniame diske. Diegimo programa matuoja laisvą vietą failų sistemoje, kurioje iš tikrųjų yra `~/.windows`, nebūtinai failų sistemoje, kurioje yra jūsų namų katalogas.

Disko ir bendrinamus kelius laikykite kaip atskirus, nepersidengiančius katalogus. Šalinimas sąmoningai ištuština disko katalogą, bet išsaugo bendrinamą katalogą. Iškart prieš ištrynimą Omarchy atlieka ribotą atskyrimo patikrą ir atsisako šalinti bet ką, jei ta patikra viršija skirtą laiką arba negali įrodyti, kad abu medžiai yra atskiri.

Prieš paleisdama VM, Omarchy atidaro ir prisega tuos du katalogus, tada bind-mount būdu prijungia tikslius katalogų inodus prie privačių, konkrečiam vartotojui skirtų inkarų žemiau `/var/lib/omarchy/windows/mounts`. Docker mato tik tuos root apsaugotus inkarus. Taip išsaugomos pasirinktinės disko vietos, kartu neleidžiant kitam jūsų vardu veikiančiam procesui sukeisti patikrinto kelio, kol privilegijuotas konteineris jo nepanaudojo. Esami disko ir bendrinami katalogai perkėlimo metu sugriežtinami iki režimo `0700`, kad kitos vietinės paskyros negalėtų naršyti jų turinio.

VM prievadai susiejami tik su localhost, todėl niekas jūsų tinkle negali pasiekti Windows kompiuterio. Žiniatinklio konsolė taip pat reikalauja sukonfigūruoto Windows vartotojo vardo ir slaptažodžio, taip neleisdama kitai vietinei paskyrai valdyti VM per 8006 prievadą.

## Apribojimai ir licencijavimas

Su šia sąranka nėra GPU passthrough, todėl ji netinka žaidimams ar vaizdo įrašų redagavimui. Tai puikus būdas paleisti Microsoft Office ar bet ką kita, ko jums būtinai reikia.

Įdiegta versija yra Windows 11 Pro, neaktyvuota. Norėdami naudoti apribotas funkcijas, turėsite turėti savo licencijos raktą.

Jei šis kompiuteris buvo pristatytas su Windows, OEM raktas vis dar yra programinėje aparatinėje įrangoje net ir įdiegus Omarchy. Atsispausdinkite jį su `omarchy windows key`. Tas raktas yra susietas su šiuo kompiuteriu — jis aktyvuos Windows, iš naujo įdiegtą šioje aparatinėje įrangoje, bet paprastai neaktyvuos VM.

Vėliau išteklių paskirstymą galite pakeisti terminale paleidę `omarchy windows vm install` — tai perrašo VM konfigūraciją pagal jūsų atsakymus. Pats compose failas dabar yra `/var/lib/omarchy/windows/docker-compose.yml` ir priklauso root — tai sąmoninga, kad jūsų vardu veikiantis procesas negalėtų jo perrašyti ir priversti privilegijuoto paleidimo prijungti visą jūsų diską į konteinerį. Jei reikia jį redaguoti ranka (pavyzdžiui, norint prijungti USB įrenginį), redaguokite jį su `sudo` ir visas parinktis žiūrėkite [„Dockur Windows“ projekte](https://github.com/dockur/windows).

Norėdami atsikratyti visko, naudokite _Remove > Windows_ iš Omarchy meniu. Tai ištrina VM diską, esantį `~/.windows`, ir viską, kas įdiegta Windows viduje, todėl prieš tai nukopijuokite iš VM viską, ko jums reikia. Jūsų bendrinamas `~/Windows` aplankas paliekamas ramybėje.
