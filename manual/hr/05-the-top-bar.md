# Gornja traka

Traka duž vrha vašeg zaslona je Omarchy traka. To nije naknadno pričvršćena statusna traka, nego dio Omarchy ljuske, jedinog dugotrajnog Quickshell procesa koji također crta izbornik, obavijesti, OSD skočne prozore i zaključani zaslon. Zato se savršeno uklapa u temu sa svime ostalim i zato se panel otvara trenutačno umjesto da pokreće novu aplikaciju.

To je ujedno jedini dio radne površine koji je uvijek na zaslonu, pa vrijedi znati što svi ti mali glifovi rade.

## Što je na njoj prema zadanim postavkama

Traka ima tri dijela. S lijeve strane nalaze se Omarchy logotip (pokretač izbornika) i indikatori radnih prostora. U sredini dobivate indikatore statusa, sat, Elsewhen (svjetski sat), vremensku prognozu i značku za Omarchy ažuriranje. S desne strane: ladica sustava, raspored tipkovnice (kada je konfigurirano više od jednog), agenti, bluetooth, mreža, zvuk, zaslon i napajanje.

Nekoliko njih pojavljuje se samo kada imaju što reći. Raspored tipkovnice pojavljuje se samo ako ste konfigurirali više od jednog rasporeda. Značka za ažuriranje pojavljuje se samo kada čeka Omarchy ažuriranje. A ikona agenata pojavljuje se prvi put kada Omarchy pronađe korištenje AI kodiranja na računalu (pogledajte [AI](17-ai.md)).

## Klikanje uokolo

Gotovo svaki widget nešto radi na lijevi, desni i srednji klik, a nekoliko ih reagira na pomicanje kotačićem. To je dio koji ljudima promakne — iza desne i srednje tipke skriva se mnogo dobrih stvari.

| Widget | Lijevi | Desni | Srednji / kotačić |
| --- | --- | --- | --- |
| Izbornik | Omarchy izbornik | Novi terminal | — |
| Radni prostori | Fokusiraj taj radni prostor na ovom monitoru | — | Kotačić: sljedeći/prethodni radni prostor |
| Sat | Skočni prozor kalendara | Kruži kroz formate oznake | Srednji: birač vremenske zone |
| Vremenska prognoza | Skočni prozor prognoze | Puna prognoza kao obavijest | Srednji: osvježi |
| Zvuk | Panel zvuka | Isključi zvuk | Srednji: panel · kotačić: glasnoća |
| Mikrofon | Isključi mikrofon | — | Srednji: panel zvuka · kotačić: ulazna glasnoća |
| Mreža | Panel mreže | — | — |
| Bluetooth | Panel za Bluetooth | Uključi/isključi radio | — |
| Zaslon | Panel zaslona | — | Kotačić: svjetlina |
| Napajanje | Panel napajanja | Uključi/isključi postotak baterije | — |
| Mediji | Reproduciraj/pauziraj | Skočni prozor naslovnice | Srednji: sljedeće · kotačić: prethodno/sljedeće |
| Agenti | Panel agenata | Pokreni svog agenta | Srednji: sljedeća pretplata |
| Ladica | Zadrži pokazivač za otkrivanje ladice | Desni klik na chevron za upravljanje | — |
| Omarchy ažuriranje | Pokreni ažuriranje | — | — |

Nije sve u toj tablici na vašoj traci odmah po instalaciji. Widget za medije (MPRIS trenutna reprodukcija, s pomičnom pjesmom i izvođačem) i widget za mikrofon ugrađeni su, ali prema zadanim postavkama isključeni — dodajte ih ako ih želite, kako je opisano u nastavku.

## Paneli

Klikanje ikone na traci otvara panel, što je pravi skočni prozor s klizačima, popisima i navigacijom tipkovnicom, a ne opis alata. Svaki ima i tipkovnički prečac, pa nikada ne morate ciljati glif od 16 piksela:

| Prečac | Panel |
| --- | --- |
| `Super + Ctrl + A` | Zvuk |
| `Super + Ctrl + N` | Mreža |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Zaslon |
| `Super + Ctrl + P` | Napajanje |
| `Super + Ctrl + Alt + D` | Kalendar |
| `Super + Ctrl + Alt + E` | Svjetski sat |
| `Super + Ctrl + 1-9` | Uključi/isključi n-ti panel u desnom dijelu |

Paneli nisu prikazi očitanja. U njima zapravo radite stvari:

- **Zvuk** ima glavni klizač glasnoće, birač izlaznog uređaja i mikser po aplikaciji, pa možete stišati onu jednu karticu preglednika bez diranja svega ostalog.
- **Mreža** skenira Wi-Fi, prikazuje jačinu signala, povezuje se i omogućuje vam odabir DNS pružatelja.
- **Bluetooth** navodi vaše uređaje s povezivanjem/odspajanjem i razinama baterije.
- **Napajanje** prikazuje statistiku baterije, mijenja profile napajanja (pamti zaseban odabir za bateriju i AC) i ispisuje neke informacije o sustavu.
- **Zaslon** sadrži klizač svjetline, veličinu teksta, unaprijed postavljene vrijednosti skaliranja monitora i — kada imate više od jednog zaslona — kontrole po monitoru. Pogledajte [monitore](33-monitors.md) za dublju priču.
- **Sat** otvara mjesečnu mrežu s ISO brojevima tjedana i koračanjem po mjesecima.
- **Svjetski sat** drži redak po gradu, s njegovom vremenskom prognozom i kako mu prolazi dan. Pretraživanje pronalazi gradove kao i vremenske zone, pa je Fort Lauderdale Fort Lauderdale, a ne New York. Ako redak na vrhu navodi pogrešan grad, kliknite ga i recite gdje ste; odaberite negdje u drugoj vremenskoj zoni i sistemski sat također se pomiče tamo, što je zgodno kada putujete. Zadržite pokazivač iznad grada i kliknite gumb osobe da biste rekli tko tamo živi — obična imena ili `@` GitHub korisnička imena da ponesete i njihova lica.

Svaki panel prihvaća tipkovnicu kao i miš: strelice pomiču, Return aktivira, Tab prelazi na susjedni panel, a Escape zatvara.

`Super + Ctrl + 1-9` broji panele slijeva nadesno u desnom dijelu, preskačući ladicu jer nema vlastiti panel. Pa broj odgovara ikoni na koju biste pokazali.

### Tailscale i Dropbox

Još dva widgeta pojavljuju se na traci tek kada instalirate odgovarajuću uslugu iz **Instalacija → Usluga**, i oba vrijedi poznavati jer rade više od izvještavanja o statusu.

Panel **Tailscale** povezuje i odspaja tailnet, mijenja račune i bira izlazni čvor (vaša vlastita računala i Mullvad regije pojavljuju se na tom popisu). Također pregledava vaša računala — a kada je jedno odabrano, `s` mu šalje datoteke preko Taildropa, što je najbrži način da premjestite datoteku na telefon ili drugo prijenosno računalo. `c` kopira IP računala, `n` njegovo ime, a `d` njegovo puno DNS ime. Na svakom retku računala postoji i gumb za slanje, ako radije klikate. Isto iz terminala je `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** upravlja prijavom, prikazuje koliko ste prostora za pohranu iskoristili i navodi nedavno sinkronizirane datoteke.

Uklanjanje bilo koje usluge uklanja i njezin widget s trake.

## Indikatori

Mali skup u sredini je widget indikatora. To su glifovi statusa za načine koje ste uključili: ne ometaj, noćno svjetlo, [podsjetnik](09-reminders.md) u redu čekanja, aktivno snimanje zaslona, ostani budan i [diktiranje](11-text-extraction-dictation.md). Svijetle kada je način aktivan i inače se ne nameću — zadržite pokazivač bilo gdje na traci da zavirite u neaktivne. Klikanje indikatora uključuje/isključuje taj način. Još jedan je samo status: udaljena sesija svijetli crveno dok je netko povezan s ovim računalom preko gliffa.

Ako biste radije da uvijek budu vidljivi, postavite `alwaysShow` na `true` na widgetu. A ako vas zanimaju samo neki od njih, navedite one koje želite u `items`: `["Dnd", "Reminder", "NightLight"]`. Možete imati više od jednog widgeta indikatora, pa različiti dijelovi mogu prikazivati različite podskupove.

## Preuređivanje trake

Traka se sama konfigurira. Ne morate otvarati konfiguracijsku datoteku da biste pomicali stvari.

Uhvatite prazan dio trake oko sredine i povucite ga prema drugom rubu zaslona i traka se pomiče tamo — lijevo, desno, gore ili dolje, sve radi, a svaki se widget prilagođava (okomite trake vraćaju se na kompaktne oblike samo s ikonama). Klik-i-držanje započinje isto povlačenje. Dvostruki lijevi klik na isti prazan prostor kruži pozadinom trake od prozirne do staklaste do neprozirne. I povucite bilo koji widget da ga premjestite ili bacite u drugi dio; ostali widgeti razmiču se da naprave mjesta gdje će sletjeti.

Sredina trake je okvir: što god je u njemu ostaje centrirano kao jedna skupina, a widgeti s obje njegove strane vise s njegovih rubova. Dok povlačite widget, okvir se prikazuje kao obris, ili kao crta preko trake kada je prazan, i možete ga ispustiti u njega ili pokraj njega. Kada bi ispuštanje završilo u okviru, okvir raste da primi widget.

Widget koji želite imati pri ruci, ali ne uvijek u vidokrugu, može ići u ladicu ladice sustava: povucite ga na ladicu sustava i ladica se otvara da ga primi. Sjedi tamo nakon ikona aplikacija, pojavljuje se kad god se pojavi ladica i drži svoju ladicu otvorenom dok je njegov panel otvoren. Povucite ga natrag na traku da ga vratite.

Ako radije birate iz izbornika, **Izgled → Traka izbornika** ima položaj, a **Pozadina trake** bira kako se traka crta: **Neprozirna traka**, **Staklasta traka** (prozirna, s onim iza nje zamućenim) ili **Prozirna traka**.

Iste stvari imaju naredbe, što želite za postavke s [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Za dodavanje ili uklanjanje widgeta u cijelosti upotrijebite naredbe za dodatke. `omarchy plugin list` ispisuje svaki widget koji ljuska poznaje s njegovim id-om, a zatim:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Sakrivanje trake

`Super + Shift + Space` uključuje/isključuje traku bez ubijanja ljuske — paneli i prečaci i dalje rade, samo dobivate piksele natrag. Također je u izborniku pod **Izgled → Traka izbornika → Sakrij traku**.

## Konfiguracijska datoteka

Sve je pohranjeno u `~/.config/omarchy/shell.json`, pod ključem `bar`. Evo skraćene verzije:

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

Svaki widget je jedan unos u jednom od pet nizova rasporeda, a njegove postavke nalaze se izravno na tom unosu — nema zasebne datoteke postavki i nema podobjekta `config`. Satov `format`, `formatAlt` (na što desni klik kruži) i `verticalFormat` svi žive upravo tamo na `{ "id": "omarchy.clock" }`.

`center` je okvir u sredini trake: sve u njemu centrirano je na zaslonu kao jedna skupina. `centerBegin` i `centerEnd` vise s obje strane okvira, što je način kako sat ostaje točno u sredini čak i dok vremenska prognoza i značka za ažuriranje dolaze i odlaze. Stavite više od jednog widgeta u `center` i oni se centriraju zajedno; ostavite ga praznim i `centerBegin` i `centerEnd` susreću se u sredini trake.

Jedno pravilo koje vrijedi usvojiti: **kada imate vlastiti `shell.json`, on je kanonski**. Dok ne prilagodite ništa, ljuska čita zadanu Omarchy datoteku. U trenutku kada povučete widget, pokrenete `omarchy bar` ili sami uredite datoteku, ona je vaša — nema dubokog spajanja, pa se novi zadani widgeti u budućim Omarchy izdanjima neće automatski pojaviti na vašoj traci. `omarchy bar defaults` vraća isporučeni raspored kad god želite čist početak.

Ista datoteka također sadrži vaša vremena mirovanja na najvišoj razini, izvan ključa `bar`: `idle.screensaver` i `idle.lock`, oboje u sekundama od kada ste postali neaktivni. Pa zadani čuvar zaslona uključuje se nakon 150 sekundi, a zaključavanje nakon 300.
