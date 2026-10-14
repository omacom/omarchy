# Windows VM

Omarchy piedāvā vienkāršu veidu, kā darbināt Windows caur Docker virtuālo mašīnu. To var instalēt no Omarchy izvēlnes (`Super + Space`) sadaļas _Instalēt > Windows_.

Šim nolūkam jūsu datoram nepieciešama KVM virtualizācija, kura lielākoties ir — taču dažkārt tā BIOS līmenī ir izslēgta, un instalētājs jums pateiks, ja tas tā ir. Jums būs vajadzīga arī diska vieta: viss, ko iedodat Windows, plus apmēram 10 GB pašam attēlam.

Instalētājs prasa, cik daudz RAM, cik daudz centrālā procesora kodolu un cik daudz diska atdot (64 GB vai vairāk ir saprātīgā apakšējā robeža), pēc tam prasa Windows lietotājvārdu un paroli. Atstājiet tos tukšus, un iegūsiet `docker` / `admin`. Lejupielāde aizņem kādu laiku — 10–15 minūtes ir normāli —, un tās norisei varat sekot pārlūkprogrammā adresē `http://127.0.0.1:8006`. Pirms konsoles atvēršanas pārlūkprogramma prasa to pašu lietotājvārdu un paroli.

 ![windows-vm](images/windows-vm.webp)

## Lietošana

Kad tā ir instalēta, no lietotņu palaidēja palaidiet _Windows_. Tas palaiž virtuālo mašīnu, ja tā jau nedarbojas, un pilnekrāna režīmā savieno jūs caur RDP. Aukstā palaišanā dodiet tam 15–30 sekundes.

RDP sesija pārraida skaņu, jūsu mikrofonu un koplietu starpliktuvi, tāpēc teksta kopēšana starp Linux un Windows vienkārši darbojas. Izšķirtspēja seko jūsu logam, un Omarchy cauri padod jūsu ekrāna mērogu, tāpēc augsta pikseļu blīvuma (HiDPI) ekrānā tas nav izplūdis haoss.

Kad aizverat RDP logu, virtuālā mašīna automātiski izslēdzas. Ja labprātāk to atstāt darboties — teiksim, jums tur kaut kas darbojas —, palaidiet to tā vietā ar komandu `omarchy windows vm launch --keep-alive`.

Pārējās vadības komandas ir tajā pašā komandā:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Failu koplietošana

Direktorija `~/Windows` jūsu mājas direktorijā tiek automātiski koplietota ar virtuālo mašīnu. Lieciet tur failus, ja vēlaties, lai tie būtu pieejami Windows. Virtuālajai mašīnai nav piekļuves nevienai citai jūsu failu sistēmas daļai, tāpēc jūs esat pasargāts no visa ļaunā Windows pusē. Tās pašas virtuālais disks ir pieejams ceļā `~/.windows`.

Šie pazīstamie mājas ceļi paliek savās failu sistēmās. Tie var būt arī simboliskās saites uz jums piederošām direktorijām, kas ir noderīgi, kad virtuālais disks dzīvo uz lielāka diska. Instalētājs brīvo vietu mēra tajā failu sistēmā, kurā patiesībā atrodas `~/.windows`, nevis obligāti tajā failu sistēmā, kurā ir jūsu mājas direktorija.

Uzturiet diska un koplietošanas ceļus kā atsevišķas direktorijas, kas nepārklājas. Noņemšana mērķtiecīgi iztukšo diska direktoriju, bet koplietošanas direktoriju saglabā. Tieši pirms dzēšanas Omarchy veic ierobežotu norobežojuma pārbaudi un atsaka jebkā noņemšanu, ja šī pārbaude pārsniedz laika ierobežojumu vai nevar pierādīt, ka abi koki ir atsevišķi.

Pirms virtuālās mašīnas palaišanas Omarchy atver un nofiksē šīs abas direktorijas un pēc tam ar stiprinājumu (bind-mount) precīzās direktoriju inode vērtības uzstāda uz privātām, katram lietotājam atsevišķām enkura vietām zem `/var/lib/omarchy/windows/mounts`. Docker redz tikai šīs root aizsargātās enkura vietas. Tas saglabā pielāgotās diska atrašanās vietas, vienlaikus neļaujot citam procesam, kas darbojas jūsu vārdā, apmainīt pārbaudītu ceļu, pirms to patērē privileģētais konteiners. Migrācijas laikā esošās diska un koplietošanas direktorijas tiek nostingrinātas līdz režīmam `0700`, lai citi lokālie konti nevarētu pārlūkot to saturu.

Virtuālās mašīnas porti ir piesaistīti tikai localhost, tāpēc nekas jūsu tīklā nevar sasniegt Windows datoru. Tīmekļa konsole arī prasa konfigurēto Windows lietotājvārdu un paroli, neļaujot citam lokālam kontam vadīt virtuālo mašīnu caur 8006. portu.

## Ierobežojumi un licencēšana

Grafikas procesoru (GPU) ar šo iestatījumu cauri padot nevar, tāpēc tas spēlēm vai video rediģēšanai piemērots nav. Tas ir lielisks veids, kā darbināt Microsoft Office vai jebko citu, kas jums noteikti ir nepieciešams.

Instalētā versija ir Windows 11 Pro, neaktivizēta. Lai izmantotu par autorizāciju noslēgtās funkcijas, jums būs nepieciešama sava licences atslēga.

Ja šis dators tika piegādāts ar Windows, OEM atslēga programmaparatūrā joprojām saglabājas pat pēc Omarchy instalēšanas. Izdrukājiet to ar `omarchy windows key`. Šī atslēga ir piesaistīta šim datoram — tā aktivizēs Windows, kas pārinstalēts uz šīs aparatūras, bet parasti virtuālo mašīnu neaktivizēs.

Resursu piešķīrumu vēlāk varat mainīt, atkārtoti palaižot `omarchy-windows-vm install`, kas no jūsu atbildēm pārraksta virtuālās mašīnas konfigurāciju. Pats compose fails tagad atrodas ceļā `/var/lib/omarchy/windows/docker-compose.yml` un pieder root — tas ir darīts apzināti, lai process, kas darbojas jūsu vārdā, nevarētu to pārrakstīt un likt privileģētajai ienākšanai uzmontēt veselu jūsu disku konteinerā. Ja tas jums ir jārediģē ar rokām (piemēram, lai pievienotu USB ierīci), rediģējiet to ar `sudo` un visas iespējas skatiet [Dockur Windows projektā](https://github.com/dockur/windows).

Lai no visa tā atbrīvotos, Omarchy izvēlnē izmantojiet _Noņemt > Windows_. Tas izdzēš virtuālās mašīnas disku un visus tā datus, tāpēc vispirms pārliecinieties, ka viss jums svarīgais ir ārā no mapes `~/Windows`.
