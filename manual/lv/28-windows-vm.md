# Windows VM

Omarchy piedāvā vienkāršu veidu, kā x86_64 datoros darbināt Windows, izmantojot Docker VM. To var instalēt Omarchy izvēlnē, izvēloties _Install > Windows_ (`Super + Space`).

Šim nolūkam datoram ir nepieciešama KVM virtualizācija, kas lielākajai daļai datoru ir, taču dažkārt tā BIOS ir izslēgta, un instalētājs par to paziņos, ja tā būs. Būs vajadzīga arī vieta diskā: tik daudz, cik atvēlēsiet Windows, un vēl aptuveni 10GB pašam attēlam.

Instalētājs pajautās, cik daudz RAM, cik daudz CPU kodolu un cik daudz vietas diskā atvēlēt (64GB vai vairāk ir saprātīgā apakšējā robeža), un pēc tam pajautās Windows lietotājvārdu un paroli. Ja tos atstāsiet tukšus, iegūsiet `docker` / `admin`. Lejupielāde aizņem kādu laiku — 10-15 minūtes ir normāli —, un tās norisei var sekot pārlūkā adresē `http://127.0.0.1:8006`. Pirms konsoles atvēršanas pārlūks pieprasīs to pašu lietotājvārdu un paroli.

 ![windows-vm](images/windows-vm.webp)

## Lietošana

Kad tā ir instalēta, lietotņu palaidējā palaidiet _Windows_. Tas palaiž VM, ja tā vēl nedarbojas, un izveido pilnekrāna savienojumu ar to, izmantojot RDP. Aukstai palaišanai atvēliet 15-30 sekundes.

RDP sesija nodrošina skaņu, mikrofona izmantošanu un kopīgu starpliktuvi, tāpēc teksta kopēšana starp Linux un Windows vienkārši darbojas. Izšķirtspēja pielāgojas logam, un Omarchy nodod tālāk displeja mērogošanas iestatījumu, tāpēc HiDPI ekrānā attēls nav izplūdusi putra.

Kad aizverat RDP logu, VM automātiski izslēdzas. Ja vēlaties to atstāt darbojamies, piemēram, ja tajā kaut kas turpina strādāt, palaidiet to ar `omarchy windows vm launch --keep-alive`.

Pārējās vadīklas ir pieejamas ar to pašu komandu:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Failu kopīgošana

Jūsu mājas direktorijā esošā direktorija `~/Windows` tiek automātiski kopīgota ar VM. Ja vēlaties, lai faili būtu pieejami Windows, ievietojiet tos tur. VM nav piekļuves nevienai citai failu sistēmas daļai, tāpēc Windows pusē esošs kaitēklis jums nekā nevar nodarīt. VM virtuālais disks ir pieejams mapē `~/.windows`.

Šie pazīstamie mājas ceļi paliek katrs savā failu sistēmā. Tie var būt arī simboliskās saites uz jums piederošām direktorijām, kas ir noderīgi, ja virtuālais disks atrodas lielākā diskā. Instalētājs brīvo vietu mēra failu sistēmā, kurā faktiski atrodas `~/.windows`, nevis obligāti failu sistēmā, kurā atrodas jūsu mājas direktorija.

Diska un kopīgoto ceļu turiet kā atsevišķas direktorijas, kas nepārklājas. Noņemšanas laikā diska direktorija tiek apzināti iztukšota, bet kopīgotā direktorija tiek saglabāta. Tieši pirms dzēšanas Omarchy veic ierobežota laika ierobežošanas pārbaudi un atsakās kaut ko noņemt, ja šīs pārbaudes laiks beidzas vai tā nevar pierādīt, ka abi koki ir atsevišķi.

Pirms VM palaišanas Omarchy atver un piesprauž šīs abas direktorijas, pēc tam ar bind-mount piestiprina tieši šo direktoriju inodes pie privātiem katram lietotājam paredzētiem enkuriem mapē `/var/lib/omarchy/windows/mounts`. Docker redz tikai šos ar root aizsargātos enkurus. Tādējādi tiek saglabātas pielāgotas diska atrašanās vietas, vienlaikus neļaujot citam procesam, kas darbojas ar jūsu tiesībām, nomainīt pārbaudīto ceļu, pirms priviliģētais konteiners to izmanto. Migrācijas laikā esošajām diska un kopīgotajām direktorijām tiek noteikts stingrāks režīms `0700`, lai citi lokālie konti nevarētu pārlūkot to saturu.

VM porti ir piesaistīti tikai localhost, tāpēc nekas jūsu tīklā nevar sasniegt Windows datoru. Tīmekļa konsolei ir nepieciešams arī konfigurētais Windows lietotājvārds un parole, tāpēc cits lokālais konts nevar vadīt VM caur portu 8006.

## Ierobežojumi un licencēšana

Šajā konfigurācijā nav GPU passthrough, tāpēc tā nav piemērota spēlēm vai video montāžai. Tas ir lielisks veids, kā darbināt Microsoft Office vai jebko citu, kas jums ir absolūti nepieciešams.

Instalētā versija ir Windows 11 Pro bez aktivizācijas. Lai izmantotu funkcijas, kurām nepieciešama licence, būs vajadzīga pašam sava licences atslēga.

Ja šis dators tika piegādāts ar Windows, OEM atslēga arī pēc Omarchy instalēšanas joprojām atrodas programmaparatūrā. To var izdrukāt ar komandu `omarchy windows key`. Šī atslēga ir piesaistīta šim datoram: tā aktivizēs Windows, kas pārinstalēta uz šīs pašas aparatūras, bet parasti neaktivizēs VM.

Resursu piešķīrumu vēlāk var mainīt, terminālī palaižot `omarchy windows vm install`, kas pārraksta VM konfigurāciju atbilstoši jūsu atbildēm. Pats compose fails tagad atrodas mapē `/var/lib/omarchy/windows/docker-compose.yml` un pieder root. Tas ir darīts apzināti, lai process, kas darbojas ar jūsu tiesībām, nevarētu to pārrakstīt un panākt, ka priviliģētā palaišana konteinerā piemontē visu jūsu disku. Ja tas ir jārediģē manuāli, piemēram, lai piemontētu USB ierīci, rediģējiet to ar `sudo` un skatiet visas iespējas [Dockur Windows projektā](https://github.com/dockur/windows).

Lai no visa tā atbrīvotos, Omarchy izvēlnē izvēlieties _Remove > Windows_. Tādējādi tiks izdzēsts VM disks mapē `~/.windows` un viss, kas instalēts Windows, tāpēc vispirms izkopējiet no VM visu nepieciešamo. Kopīgotā mape `~/Windows` tiek atstāta neskarta.
