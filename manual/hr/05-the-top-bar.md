# Gornja traka

Traka uz vrh vašeg zaslona je traka Omarchyja. To nije naknadno pričvršćena statusna traka, nego dio ljuske Omarchyja, jedinog dugotrajnog procesa Quickshell koji crta i izbornik, obavijesti, skočne OSD prozore i zaključani zaslon. Zato se savršeno uklapa u temu sa svim ostalim i zato se panel otvara trenutačno umjesto da pokrene novu aplikaciju.

To je ujedno i jedini dio radne površine koji je uvijek na zaslonu, pa vrijedi znati što svi ti mali znakovi rade.

## Što je na njoj prema zadanim postavkama

Traka ima tri dijela. Na lijevoj strani nalaze se logotip Omarchyja (pokretač izbornika) i pokazatelji radnih prostora. U sredini dobivate pokazatelje statusa, sat, Elsewhen (svjetski sat), vrijeme i značku za ažuriranje Omarchyja. Na desnoj strani: ladicu sustava, raspored tipkovnice (kada je konfigurirano više od jednog rasporeda ili načina unosa), agente, bluetooth, mrežu, zvuk, zaslon i napajanje.

Neki od njih pojavljuju se samo kada imaju što reći. Raspored tipkovnice pojavljuje se samo ako ste konfigurirali više od jednog rasporeda ili načina unosa. Značka za ažuriranje pojavljuje se samo kada čeka ažuriranje Omarchyja.

## Klikanje posvuda

Gotovo svaki widget nešto radi na lijevi, desni i srednji klik, a nekoliko ih reagira i na pomicanje kotačićem. To je dio koji ljudi propuštaju — desna i srednja tipka ondje su gdje se skriva velik dio dobrih stvari.

| Widget | Lijevi klik | Desni klik | Srednji klik / kotačić |
| --- | --- | --- | --- |
| Izbornik | Izbornik Omarchyja | Novi terminal | — |
| Radni prostori | Fokusiraj taj radni prostor na ovom monitoru | — | Kotačić: sljedeći/prethodni radni prostor |
| Sat | Skočni kalendar | Mijenja format oznake | Srednji klik: birač vremenske zone |
| Svjetski sat | Panel svjetskog sata | Osvježi | Srednji klik: osvježi |
| Vrijeme | Skočna prognoza | Puna prognoza kao obavijest | Srednji klik: osvježi |
| Zvuk | Panel zvuka | Utišaj | Srednji klik: panel · kotačić: glasnoća |
| Mikrofon | Utišaj mikrofon | — | Srednji klik: panel zvuka · kotačić: ulazna glasnoća |
| Mreža | Panel mreže | — | — |
| Bluetooth | Panel za Bluetooth | Uključi/isključi radio | — |
| Zaslon | Panel zaslona | — | Kotačić: svjetlina |
| Napajanje | Panel napajanja | Uključi/isključi postotak baterije | — |
| Mediji | Reproduciraj/pauziraj | Skočni prozor slike omota | Srednji klik: sljedeće · kotačić: prethodno/sljedeće |
| Agenti | Panel agenata | Pokreni svog agenta | Srednji klik: osvježi potrošnju |
| Ladica | Zadrži pokazivač za otkrivanje ladice | Desni klik na strelicu za upravljanje | — |
| Ažuriranje Omarchyja | Pokreni ažuriranje | — | — |

Nije sve u toj tablici na vašoj traci iz kutije. Widget za medije (MPRIS trenutna reprodukcija, s pomičnim naslovom pjesme i izvođačem) i widget za mikrofon ugrađeni su, ali su prema zadanim postavkama isključeni — dodajte ih ako ih želite, kao što je opisano u nastavku.

## Paneli

Klikanje ikone trake otvara panel, koji je pravi skočni prozor s klizačima, popisima i navigacijom tipkovnicom, a ne opis alata. Svaki ima i tipkovni prečac, pa nikada ne morate ciljati znak od 16 piksela:

| Tipkovni prečac | Panel |
| --- | --- |
| `Super + Ctrl + A` | Zvuk |
| `Super + Ctrl + N` | Mreža |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Zaslon |
| `Super + Ctrl + P` | Napajanje |
| `Super + Ctrl + Alt + D` | Kalendar |
| `Super + Ctrl + Alt + E` | Svjetski sat |
| `Super + Ctrl + X` | Agenti |
| `Super + Ctrl + 1-9` | Uključi/isključi n-ti panel u desnom dijelu |

Paneli nisu prikazi za čitanje. Na njima zapravo obavljate stvari:

- **Zvuk** ima glavni klizač glasnoće, birač izlaznog uređaja i mikser po aplikaciji, pa možete stišati onu jednu karticu preglednika bez diranja svega ostaloga.
- **Mreža** traži Wi-Fi, pokazuje jačinu signala, spaja se i omogućuje vam odabir pružatelja DNS-a.
- **Bluetooth** navodi vaše uređaje s povezivanjem/odspajanjem i razinama baterije.
- **Napajanje** pokazuje statistiku baterije, mijenja profile napajanja (pamti odvojeni odabir za bateriju i za AC) i ispisuje neke informacije o sustavu.
- **Zaslon** ima klizač svjetline, veličinu teksta, unaprijed postavljene postavke skaliranja monitora i — kada imate više od jednog zaslona — kontrole po monitoru. Pogledajte [monitore](33-monitors.md) za dublju priču.
- **Sat** otvara mjesečnu mrežu s ISO brojevima tjedana i pomicanjem po mjesecima.
- **Svjetski sat** drži redak po gradu, s njegovim vremenom i kako mu prolazi dan. Pretraživanje pronalazi i mjesta i vremenske zone, pa je Fort Lauderdale Fort Lauderdale, a ne New York. Ako redak na vrhu imenuje pogrešan grad, kliknite ga i recite gdje ste; odaberite mjesto u drugoj vremenskoj zoni i sistemski sat također će se premjestiti onamo, što je zgodno kada putujete. Zadržite pokazivač nad gradom i kliknite gumb s osobom da biste rekli tko ondje živi — obična imena ili `@` GitHub korisnička imena da biste povukli i njihova lica.

Svaki panel prihvaća tipkovnicu kao i miš: strelice pomiču, Return aktivira, Tab prelazi na susjedni panel, a Escape zatvara.

`Super + Ctrl + 1-9` broji panele slijeva nadesno u desnom dijelu, preskačući ladicu jer nema vlastiti panel. Pa broj odgovara ikoni na koju biste pokazali.

### Tailscale i Dropbox

Još dva widgeta pojavljuju se na traci tek kada instalirate odgovarajuću uslugu iz **Instaliraj → Usluga**, a za oba vrijedi znati što rade jer čine više od izvještavanja o statusu.

Panel **Tailscale** povezuje i odspaja tailnet, mijenja račune i bira izlazni čvor (vaši vlastiti strojevi i regije Mullvada pojavljuju se na tom popisu). Također pregledava vaše strojeve — a kada je jedan odabran, `s` šalje datoteke na njega putem Taildropa, što je najbrži način da premjestite datoteku na telefon ili drugo prijenosno računalo. `c` kopira IP stroja, `n` njegovo ime, a `d` njegovo puno DNS ime. Na svakom retku stroja postoji i gumb za slanje, ako radije klikate. Isto iz terminala je `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** upravlja prijavom, pokazuje koliko ste prostora za pohranu iskoristili i navodi nedavno sinkronizirane datoteke.

Uklanjanje bilo koje usluge uklanja i njezin widget s trake.

## Pokazatelji

Mala skupina u sredini je widget pokazatelja. To su znakovi statusa za načine koje ste uključili: ne ometaj, noćno svjetlo, [podsjetnik](09-reminders.md) na čekanju, aktivno snimanje zaslona i ostani budan, uz upozorenja dok je sudo bez lozinke uključen ili je netko povezan na udaljenu sesiju. Svijetle kada je način aktivan, a inače se drže po strani — zadržite pokazivač tik uz njih, gdje bi sjedili neaktivni, da biste zavirili u njih. Klikanje pokazatelja uključuje ili isključuje taj način. Još jedan je samo za status: udaljena sesija svijetli crveno dok je netko povezan na ovaj stroj putem gliff.

Ako želite da uvijek budu vidljivi, postavite `alwaysShow` na `true` na widgetu. A ako vas zanimaju samo neki od njih, navedite one koje želite u `items`: `["Dnd", "Reminder", "NightLight"]`. Možete imati više od jednog widgeta pokazatelja, pa različiti dijelovi mogu prikazivati različite podskupove.

## Preslagivanje trake

Traka se konfigurira sama. Ne morate otvarati konfiguracijsku datoteku da biste premjestili stvari.

Uhvatite prazan dio trake oko sredine i povucite ga prema drugom rubu zaslona i traka će se premjestiti onamo — lijevo, desno, gore ili dolje, sve radi, a svaki se widget prilagođava (okomite trake vraćaju se na kompaktne oblike samo s ikonama). Klik i držanje započinje isto povlačenje. Dvokliknite lijevom tipkom na isti prazan prostor da biste mijenjali pozadinu trake od prozirne do staklaste do neprozirne. I povucite bilo koji widget da biste mu promijenili redoslijed ili ga bacili u drugi dio; ostali widgeti razmiču se da bi napravili mjesta ondje gdje će sletjeti.

Sredina trake je okvir: što god je u njemu, ostaje centrirano kao jedna skupina, a widgeti s obje strane vise s njegovih rubova. Dok povlačite widget, okvir se prikazuje kao obris ili kao crta preko trake kada je prazan, a možete ispustiti u njega ili pokraj njega. Kada bi ispuštanje završilo u okviru, okvir raste da bi primio widget.

Widget koji želite imati pri ruci, ali ne uvijek na vidiku, može otići u ladicu ladice sustava: povucite ga na ladicu i ladica će se otvoriti da ga primi. Sjedi ondje iza ikona aplikacija, pojavljuje se kad god se pojavi ladica i drži svoju ladicu otvorenom dok je njegov panel otvoren. Povucite ga natrag na traku da biste ga vratili.

Ako radije birate iz izbornika, **Izgled → Traka izbornika** ima položaj, a **Pozadina trake** bira kako se traka crta: **Neprozirna traka**, **Staklasta traka** (prozirna, s onim iza nje zamućenim) ili **Prozirna traka**.

Iste stvari imaju naredbe, što je ono što želite za postavku [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Za dodavanje ili uklanjanje widgeta u cijelosti koristite naredbe za dodatke. `omarchy plugin list` ispisuje svaki widget koji ljuska poznaje, zajedno s njegovim id-om, a zatim:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Skrivanje trake

`Super + Shift + Space` isključuje i ponovno uključuje traku bez ubijanja ljuske — paneli i tipkovni prečaci i dalje rade, samo dobivate piksele natrag. Nalazi se i u izborniku pod **Izgled → Traka izbornika → Sakrij traku**.

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

Svaki widget je jedan unos u jednom od pet polja rasporeda, a njegove postavke sjede izravno na tom unosu — nema odvojene datoteke postavki i nema podobjekta `config`. `format`, `formatAlt` (na što desni klik prelazi) i `verticalFormat` sata žive upravo ondje na `{ "id": "omarchy.clock" }`.

`center` je okvir u sredini trake: sve u njemu centrirano je na zaslonu kao jedna skupina. `centerBegin` i `centerEnd` vise s obje strane okvira, što je način na koji sat ostaje točno u sredini čak i dok vrijeme i značka za ažuriranje dolaze i odlaze. Stavite više od jednog widgeta u `center` i oni će biti centrirani zajedno; ostavite ga praznim i `centerBegin` i `centerEnd` sastaju se u sredini trake.

Jedno pravilo koje vrijedi usvojiti: **kada jednom imate vlastiti `shell.json`, on je mjerodavan**. Dok ne prilagodite ništa, ljuska čita zadanu datoteku Omarchyja. Onog trenutka kada povučete widget, pokrenete `omarchy bar` ili sami uredite datoteku, ona je vaša — nema dubokog spajanja, pa se novi zadani widgeti u budućim izdanjima Omarchyja neće automatski pojaviti na vašoj traci. `omarchy bar defaults` vraća isporučeni raspored kad god želite krenuti od čistog lista.

Ista datoteka također drži vaša vremena mirovanja na najvišoj razini, izvan ključa `bar`: `idle.screensaver` i `idle.lock`, oba u sekundama od kada ste postali neaktivni. Pa se zadani čuvar zaslona uključuje nakon 150 sekundi, a zaključavanje nakon 300.
