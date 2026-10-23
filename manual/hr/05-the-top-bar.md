# Gornja traka

Traka duž vrha vašega zaslona je Omarchy traka. To nije naknadno pričvršćena statusna traka, već dio Omarchy ljuske, jedinoga dugotrajnoga Quickshell procesa koji također crta izbornik, obavijesti, OSD skočnice i zaključani zaslon. Zato se savršeno uklapa u temu sa svime ostalim i zato se ploča otvara trenutačno umjesto da pokreće novu aplikaciju.

To je i jedini dio radne površine koji je uvijek na zaslonu, pa vrijedi znati što rade svi ti maleni znakovi.

## Što je na njoj prema zadanim postavkama

Traka ima tri odjeljka. Na lijevoj strani nalaze se Omarchy logotip (pokretač izbornika) i pokazatelji radnih prostora. U sredini dobivate pokazatelje statusa, sat, Elsewhen (svjetski sat), vrijeme i značku za Omarchy ažuriranje. Na desnoj strani: raspored tipkovnice (kada je konfigurirano više od jednoga), paleta sustava, agenti, bluetooth, mreža, zvuk, zaslon i napajanje.

Nekoliko njih pojavljuje se samo kada imaju što reći. Raspored tipkovnice pojavljuje se samo ako ste konfigurirali više od jednoga rasporeda. Značka za ažuriranje pojavljuje se samo kada čeka Omarchy ažuriranje. A ikona agenata pojavljuje se prvi put kada Omarchy pronađe upotrebu AI kodiranja na stroju (pogledajte [AI](17-ai.md)).

## Klikanje okolo

Gotovo svaki widget radi nešto na lijevi, desni i srednji klik, a nekoliko ih reagira na pomicanje. Ovo je dio koji ljudi propuštaju — desna i srednja tipka mjesto su gdje se skriva mnogo dobrih stvari.

| Widget | Lijevi | Desni | Srednji / pomicanje |
| --- | --- | --- | --- |
| Izbornik | Omarchy izbornik | Novi terminal | — |
| Radni prostori | Fokusiraj taj radni prostor | — | Pomicanje: sljedeći/prethodni radni prostor |
| Sat | Skočni kalendar | Kruži kroz format naljepnice | Srednji: birač vremenske zone |
| Vrijeme | Skočna prognoza | Potpuno vrijeme kao obavijest | Srednji: osvježi |
| Zvuk | Audio ploča | Utišaj | Srednji: ploča · pomicanje: glasnoća |
| Mikrofon | Utišaj mikrofon | — | Srednji: audio ploča · pomicanje: ulazna glasnoća |
| Mreža | Mrežna ploča | — | — |
| Bluetooth | Bluetooth ploča | Prebaci radio | — |
| Zaslon | Zaslon ploča | — | Pomicanje: svjetlina |
| Napajanje | Ploča napajanje | Prebaci postotak baterije | — |
| Mediji | Reproduciraj/pauziraj | Skočni omot | Srednji: sljedeće · pomicanje: prethodno/sljedeće |
| Agenti | Ploča agenata | Pokreni svoga agenta | Srednji: sljedeća pretplata |
| Paleta | Lebdjenje otkriva ladicu | Desni klik na ševron za upravljanje | — |
| Omarchy ažuriranje | Pokreni ažuriranje | — | — |

Nije sve u toj tablici na vašoj traci odmah iz kutije. Medijski widget (MPRIS koji se trenutačno reproducira, s pomičnom pjesmom i izvođačem) i widget mikrofona oboje su ugrađeni, ali prema zadanim postavkama isključeni — dodajte ih ako ih želite, kako je opisano u nastavku.

## Ploče

Klikom na ikonu trake otvara se ploča, što je pravi skočni prozor s klizačima, popisima i navigacijom tipkovnicom, a ne opis alata. Svaka ima i prečac, pa nikada ne morate ciljati na znak od 16 piksela:

| Prečac | Ploča |
| --- | --- |
| `Super + Ctrl + A` | Zvuk |
| `Super + Ctrl + W` | Mreža |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Zaslon |
| `Super + Ctrl + P` | Napajanje |
| `Super + Ctrl + Alt + D` | Kalendar |
| `Super + Ctrl + Alt + E` | Svjetski sat |
| `Super + Ctrl + 1-9` | Prebaci n-tu ploču u desnome odjeljku |

Ploče nisu očitanja. To je mjesto gdje doista radite stvar:

- **Zvuk** ima glavni klizač glasnoće, birač izlaznoga uređaja i mikser po aplikaciji, pa možete smanjiti tu jednu karticu preglednika bez diranja svega ostaloga.
- **Mreža** skenira Wi-Fi, prikazuje jačinu signala, povezuje se i omogućuje vam odabir DNS pružatelja.
- **Bluetooth** navodi vaše uređaje s povezivanjem/odspajanjem i razinama baterije.
- **Napajanje** prikazuje statistiku baterije, prebacuje profile napajanja (pamti zaseban odabir za bateriju i AC) i ispisuje neke podatke o sustavu.
- **Zaslon** nosi klizač svjetline, veličinu teksta, unaprijed postavljene vrijednosti skaliranja monitora i — kada imate više od jednoga zaslona — kontrole po monitoru. Pogledajte [monitore](33-monitors.md) za dublju priču.
- **Sat** otvara mjesečnu mrežu s ISO brojevima tjedana i korakanjem po mjesecima.

Svaka ploča prima tipkovnicu jednako kao i miš: strelice se pomiču, Return aktivira, Tab korača na susjednu ploču, a Escape zatvara.

`Super + Ctrl + 1-9` broji ploče slijeva nadesno u desnome odjeljku, preskačući paletu jer nema vlastitu ploču. Dakle broj odgovara ikoni na koju biste uperili.

### Tailscale i Dropbox

Još dva widgeta pojavljuju se na traci tek kada instalirate odgovarajuću uslugu iz **Instaliraj → Usluga**, i oboje vrijedi znati jer rade više od izvješćivanja o statusu.

Ploča **Tailscale** povezuje i odspaja tailnet, prebacuje između računa i odabire izlazni čvor (vaši vlastiti strojevi i Mullvad regije oboje se pojavljuju na tome popisu). Također pregledava vaše strojeve — a kada je jedan odabran, `s` mu šalje datoteke preko Taildropa, što je najbrži način za premještanje datoteke na vaš telefon ili drugo prijenosno računalo. `c` kopira IP stroja, `n` njegovo ime, a `d` njegovo puno DNS ime. Na svakom retku stroja nalazi se i tipka za slanje, ako radije klikate. Isto iz terminala je `omarchy tailscale send <machine> [file...]`.

Ploča **Dropbox** upravlja prijavom, prikazuje koliko ste prostora za pohranu iskoristili i navodi nedavno sinkronizirane datoteke.

Uklanjanjem bilo koje usluge njezin widget nestaje s trake.

## Pokazatelji

Maleni skup u sredini widget je pokazatelja. To su statusni znakovi za načine koje ste uključili: ne ometaj, noćno svjetlo, [podsjetnik](09-reminders.md) na čekanju, aktivno snimanje zaslona, ostani budan i [diktiranje](11-text-extraction-dictation.md). Svijetle kada je način aktivan i inače ostaju izvan puta — lebdite lijevo od sata (iznad njega na okomitoj traci) da zavirite u neaktivne. Klikom na pokazatelj prebacuje se taj način. Još jedan je samo statusni: udaljena sesija svijetli crveno dok je netko povezan s ovim strojem putem gliffa.

Ako biste radije da su uvijek vidljivi, postavite `alwaysShow` na `true` na widgetu. A ako vam je stalo samo do nekih od njih, navedite one koje želite u `items`: `["Dnd", "Reminder", "NightLight"]`. Možete imati više od jednoga widgeta pokazatelja, pa različiti odjeljci mogu prikazivati različite podskupove.

## Preuređivanje trake

Traka se sama konfigurira. Ne morate otvarati konfiguracijsku datoteku da biste premještali stvari.

Uhvatite prazan komad trake oko sredine i povucite ga prema drugome rubu zaslona i traka se tamo pomiče — lijevo, desno, gore ili dolje sve radi, a svaki widget se prilagođava (okomite trake vraćaju se na kompaktne oblike samo s ikonama). Klik-i-držanje započinje isto povlačenje. Dvaput lijevom tipkom kliknite taj isti prazan prostor da kružite pozadinom trake od prozirne do staklene do neprozirne. I povucite bilo koji widget da ga preuredite ili bacite u drugi odjeljak.

Widget koji želite imati pri ruci, ali ne uvijek na vidiku, može ići u ladicu palete: povucite ga na paletu i ladica će se otvoriti da ga primi. Sjedi ondje iza ikona aplikacija, pojavljuje se kad god se ladica pojavi i drži ladicu otvorenom dok mu je ploča otvorena. Povucite ga natrag na traku da ga vratite.

Ako radije birate iz izbornika, **Pokreni → Izgled → Traka izbornika** ima položaj, a **Pozadina trake** bira kako se traka crta: **Neprozirna traka**, **Staklena traka** (prozirna, s onim što je iza nje zamućenim) ili **Prozirna traka**.

Iste stvari imaju naredbe, što je ono što želite za postavku [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Za potpuno dodavanje ili uklanjanje widgeta koristite naredbe dodataka. `omarchy plugin list` ispisuje svaki widget koji ljuska poznaje s njegovim id-om, a zatim:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Skrivanje trake

`Super + Shift + Space` prebacuje traku isključeno i ponovno uključeno bez ubijanja ljuske — ploče i prečaci nastavljaju raditi, samo dobivate piksele natrag. Nalazi se i u izborniku pod **Pokreni → Izgled → Traka izbornika → Sakrij traku**.

## Konfiguracijska datoteka

Sve je to pohranjeno u `~/.config/omarchy/shell.json`, pod ključem `bar`. Evo skraćene verzije:

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

Svaki widget jedan je unos u jednom od tri polja rasporeda, a njegove postavke sjede u retku na tome unosu — nema zasebne datoteke postavki i nema podobjekta `config`. `format` sata, `formatAlt` (na što desni klik kruži) i `verticalFormat` svi žive točno ondje na `{ "id": "omarchy.clock" }`.

`centerAnchor` imenuje jedan središnji widget koji se prikvačuje na točno središte zaslona, s ostalima bočno uz njega. Tako sat ostaje točno u sredini čak i dok vrijeme i značka za ažuriranje dolaze i odlaze. Postavite ga na prazan niz i središnji popis samo se centrira kao grupa.

Jedno pravilo koje vrijedi usvojiti: **jednom kada imate vlastiti `shell.json`, on je kanonski**. Dok ništa ne prilagodite, ljuska čita Omarchyjevu zadanu datoteku. Trenutak kada povučete widget, pokrenete `omarchy bar` ili sami uredite datoteku, vi ste vlasnik — nema dubokoga spajanja, pa se novi zadani widgeti u budućim Omarchy izdanjima neće automatski pojaviti na vašoj traci. `omarchy bar defaults` vraća isporučeni raspored kad god želite čistu ploču.

Ista datoteka također drži vaše vremenske odmake neaktivnosti na najvišoj razini, izvan ključa `bar`: `idle.screensaver` i `idle.lock`, oba u sekundama otkako ste postali neaktivni. Dakle zadani čuvar zaslona uključuje se u 150 sekundi, a zaključavanje u 300.
