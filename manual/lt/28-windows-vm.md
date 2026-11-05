# Windows VM

Omarchy siūlo lengvą būdą paleisti Windows per Docker VM. Gali ją įdiegti naudodamas _Įdiegti > Windows_ iš Omarchy meniu (`Super + Space`).

Tavo mašinai tam reikia KVM virtualizacijos, kurią turi dauguma — bet kartais ji išjungiama BIOS, ir diegimo programa praneš, jei taip yra. Taip pat reikės vietos diske: tiek, kiek duosi Windows, plius apie 10GB pačiam atvaizdui.

Diegimo programa klausia, kiek RAM, kiek CPU branduolių ir kiek disko perduoti (64GB ar daugiau yra protingos grindys), tada Windows naudotojo vardo ir slaptažodžio. Palik juos tuščius ir gausi `docker` / `admin`. Atsisiuntimas užtrunka — 10-15 minučių yra normalu — ir progresą gali stebėti naršyklėje adresu `http://127.0.0.1:8006`. Naršyklė prieš atverdama konsolę paprašo to paties naudotojo vardo ir slaptažodžio.

 ![windows-vm](images/windows-vm.webp)

## Naudojimas

Kai ji įdiegta, paleisk _Windows_ iš programų paleidimo priemonės. Tai paleidžia VM, jei ji dar neveikia, ir prijungia tave per RDP, per visą ekraną. Šaltam paleidimui duok 15-30 sekundžių.

RDP sesija neša garsą, tavo mikrofoną ir bendrą iškarpinę, tad teksto kopijavimas tarp Linux ir Windows tiesiog veikia. Raiška seka tavo langą, o Omarchy perduoda tavo ekrano mastelį, tad HiDPI ekrane tai nėra neryški košė.

Kai uždarai RDP langą, VM automatiškai išsijungia. Jei mieliau paliktum ją veikti — tarkim, ten kažkas veikia — vietoj to paleisk ją su `omarchy windows vm launch --keep-alive`.

Likę valdikliai yra toje pačioje komandoje:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Failų bendrinimas

Katalogas `~/Windows` tavo namų kataloge automatiškai bendrinamas su VM. Dėk failus ten, jei nori, kad jie būtų prieinami Windows. VM neturi prieigos prie jokios kitos tavo failų sistemos dalies, tad esi saugus nuo bet ko bjauraus Windows pusėje. Jos pačios virtualus diskas prieinamas `~/.windows`.

Tie pažįstami namų keliai lieka savo failų sistemose. Jie taip pat gali būti simbolinės nuorodos į tau priklausančius katalogus, o tai naudinga, kai virtualus diskas gyvena didesniame diske. Diegimo programa matuoja laisvą vietą failų sistemoje, kurioje iš tikrųjų yra `~/.windows`, nebūtinai failų sistemoje, kurioje yra tavo namų katalogas.

Disko ir bendrinamus kelius laikyk kaip atskirus, nepersidengiančius katalogus. Pašalinimas tyčia ištuština disko katalogą, bet išsaugo bendrinamą katalogą. Iškart prieš trinant Omarchy atlieka ribotą atskirties patikrinimą ir atsisako ką nors šalinti, jei tas patikrinimas viršija laiką arba negali įrodyti, kad abu medžiai yra atskiri.

Prieš VM startuojant Omarchy atveria ir prikabina tuos du katalogus, tada bind-montuoja tikslius katalogų inode ant privačių vienam naudotojui skirtų inkarų žemiau `/var/lib/omarchy/windows/mounts`. Docker mato tik tuos root apsaugotus inkarus. Tai išsaugo pasirinktines disko vietas, kartu užkertant kelią kitam procesui, veikiančiam tavo vardu, pakeisti patikrintą kelią prieš privilegijuotai paleidžiamam konteineriui jį sunaudojant. Esami disko ir bendrinami katalogai migruojant sugriežtinami iki režimo `0700`, kad kitos vietinės paskyros negalėtų naršyti jų turinio.

VM portai susieti tik su localhost, tad niekas tavo tinkle negali pasiekti Windows mašinos. Žiniatinklio konsolei taip pat reikalingas sukonfigūruotas Windows naudotojo vardas ir slaptažodis, užkertant kelią kitai vietinei paskyrai valdyti VM per portą 8006.

## Ribos ir licencijavimas

Su šia sąranka nėra GPU praleidimo (passthrough), tad ji netinka žaidimams ar vaizdo redagavimui. Tai puikus būdas paleisti Microsoft Office ar ką kitą, ką būtinai turi turėti.

Įdiegta versija yra Windows 11 Pro, neaktyvinta. Tau reikės savo licencijos rakto, kad galėtum naudoti užrakintas funkcijas.

Jei šis kompiuteris pristatytas su Windows, OEM raktas vis dar yra programinėje įrangoje (firmware) net įdiegus Omarchy. Atspausdink jį su `omarchy windows key`. Tas raktas susietas su šia mašina — jis aktyvuos Windows, iš naujo įdiegtą šioje aparatūroje, bet paprastai neaktyvuos VM.

Vėliau išteklių paskirstymą gali pakeisti iš naujo paleidęs `omarchy-windows-vm install`, kuris perrašo VM konfigūraciją pagal tavo atsakymus. Pats compose failas dabar gyvena `/var/lib/omarchy/windows/docker-compose.yml` ir priklauso root — tai sąmoninga, kad procesas, veikiantis tavo vardu, negalėtų jo perrašyti ir priversti privilegijuotą paleidimą primontuoti visą tavo diską į konteinerį. Jei reikia jį redaguoti ranka (pavyzdžiui, primontuoti USB įrenginį), redaguok jį su `sudo` ir peržiūrėk visas parinktis [Dockur Windows projekte](https://github.com/dockur/windows).

Kad atsikratytum viso to, naudok _Pašalinti > Windows_ iš Omarchy meniu. Tai ištrina VM diską ir visus jos duomenis, tad pirmiausia įsitikink, kad viskas, kas tau rūpi, yra iš `~/Windows`.
