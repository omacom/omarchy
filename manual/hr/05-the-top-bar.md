# Gornja traka

Traka duž gornjeg dijela vašeg zaslona je Omarchy traka. Nije naknadno pričvršćena statusna traka, nego dio Omarchy shella, jednog dugovječnog Quickshell procesa koji također crta izbornik, obavijesti, OSD skočne prozore i zaslon za zaključavanje. Zato se savršeno tematski uklapa sa svime ostalim i zato se panel otvara trenutno umjesto da pokreće novu aplikaciju.

To je ujedno jedini dio desktopa koji je uvijek na zaslonu, pa vrijedi znati što svi ti mali znakovi rade.

## Što je na njoj prema zadanim postavkama

Traka ima tri dijela. S lijeve strane nalaze se Omarchy logotip (pokretač izbornika) i pokazatelji radnih prostora. U sredini dobivate pokazatelje statusa, sat, Elsewhen (svjetski sat), vremensku prognozu i značku za Omarchy ažuriranje. S desne strane: sistemska ladica, raspored tipkovnice (kada je konfigurirano više od jednog), agenti, bluetooth, mreža, zvuk, zaslon i napajanje.

Nekoliko njih pojavljuje se samo kada imaju što reći. Raspored tipkovnice pojavljuje se samo ako ste konfigurirali više od jednog rasporeda. Značka za ažuriranje pojavljuje se samo kada čeka Omarchy ažuriranje. A ikona agenata pojavljuje se prvi put kada Omarchy pronađe korištenje AI kodiranja na računalu (vidi [AI](17-ai.md)).

## Klikanje uokolo

Gotovo svaki widget nešto radi na lijevi, desni i srednji klik, a nekoliko ih reagira na pomicanje. Ovo je dio koji ljudima promakne — desni i srednji gumb skrivaju puno dobrih stvari.

| Widget | Lijevi | Desni | Srednji / pomicanje |
| --- | --- | --- | --- |
| Izbornik | Omarchy izbornik | Novi terminal | — |
| Radni prostori | Fokusiraj taj radni prostor na ovom monitoru | — | Pomicanje: sljedeći/prethodni radni prostor |
| Sat | Skočni kalendar | Kružite formatom oznake | Srednji: birač vremenske zone |
| Vrijeme | Skočna prognoza | Potpuna vremenska prognoza kao obavijest | Srednji: osvježi |
| Zvuk | Panel za zvuk | Utišaj | Srednji: panel · pomicanje: glasnoća |
| Mikrofon | Utišaj mikrofon | — | Srednji: panel za zvuk · pomicanje: glasnoća ulaza |
| Mreža | Panel za mrežu | — | — |
| Bluetooth | Panel za Bluetooth | Uključi/isključi radio | — |
| Zaslon | Panel za zaslon | — | Pomicanje: svjetlina |
| Napajanje | Panel za napajanje | Uključi/isključi postotak baterije | — |
| Mediji | Reproduciraj/pauziraj | Skočni prikaz naslovnice | Srednji: sljedeće · pomicanje: prethodno/sljedeće |
| Agenti | Panel za agente | Pokreni svog agenta | Srednji: sljedeća pretplata |
| Ladica | Lebdite za otkrivanje ladice | Desni klik na ševron za upravljanje | — |
| Omarchy ažuriranje | Pokreni ažuriranje | — | — |

Nije sve iz te tablice na vašoj traci odmah po instalaciji. Medijski widget (MPRIS trenutno se reproducira, s pjesmom i izvođačem koji se pomiču) i widget za mikrofon ugrađeni su, ali isključeni prema zadanim postavkama — dodajte ih ako ih želite, kao što je opisano u nastavku.

## Paneli

Klikanje ikone na traci otvara panel, što je pravi skočni prozor s klizačima, popisima i navigacijom tipkovnicom, a ne opis alata. Svaki ima i prečac, pa nikada ne morate ciljati znak od 16 piksela:

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

Paneli nisu samo prikazi. Na njima zapravo radite ono što trebate:

- **Zvuk** ima glavni klizač za glasnoću, birač izlaznog uređaja i mikser po aplikaciji, pa možete stišati onu jednu karticu preglednika bez diranja svega ostaloga.
- **Mreža** traži Wi-Fi, pokazuje jačinu signala, povezuje i omogućuje vam odabir DNS pružatelja.
- **Bluetooth** navodi vaše uređaje s povezivanjem/odspajanjem i razinama baterije.
- **Napajanje** pokazuje statistiku baterije, mijenja profile napajanja (pamti odvojeni odabir za bateriju i AC) i ispisuje neke informacije o sustavu.
- **Zaslon** ima klizač za svjetlinu, veličinu teksta, unaprijed postavljene vrijednosti za skaliranje monitora i — kada imate više od jednog zaslona — kontrole po monitoru. Vidi [monitorima](33-monitors.md) za dublju priču.
- **Sat** otvara mjesečnu mrežu s ISO brojevima tjedana i kretanjem po mjesecima.
- **Svjetski sat** ima redak po gradu, s njegovom vremenskom prognozom i time kako mu prolazi dan. Pretraživanje pronalazi mjesta kao i vremenske zone, pa je Fort Lauderdale Fort Lauderdale, a ne New York. Ako redak na vrhu navodi pogrešan grad, kliknite ga i recite gdje ste; odaberite negdje u drugoj vremenskoj zoni i sistemski sat također se seli tamo, što je zgodno kada putujete. Lebdite iznad grada i kliknite gumb s osobom da kažete tko tamo živi — obična imena ili `@` GitHub korisnička imena da povedete i njihova lica.

Svaki panel prima i tipkovnicu i miša: strelice pomiču, Return aktivira, Tab prelazi na susjedni panel, a Escape zatvara.

`Super + Ctrl + 1-9` broji panele slijeva nadesno u desnom dijelu, preskačući ladicu jer nema vlastiti panel. Tako broj odgovara ikoni na koju biste pokazali.

### Tailscale i Dropbox

Još dva widgeta pojavljuju se na traci tek kada instalirate odgovarajuću uslugu iz **Install → Service**, a oba vrijedi poznavati jer rade više od izvještavanja o statusu.

Panel **Tailscale** povezuje i odspaja tailnet, mijenja račune i bira izlazni čvor (vaša vlastita računala i Mullvad regije pojavljuju se na tom popisu). Također pregledava vaša računala — i kada je jedno odabrano, `s` šalje datoteke na njega putem Taildropa, što je najbrži način da premjestite datoteku na svoj telefon ili drugo prijenosno računalo. `c` kopira IP računala, `n` njegovo ime, a `d` njegovo puno DNS ime. Na svakom retku računala postoji i gumb za slanje, ako radije klikate. Isto iz terminala je `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** upravlja prijavom, pokazuje koliko ste pohrane iskoristili i navodi nedavno sinkronizirane datoteke.

Uklanjanje bilo koje usluge uklanja i njezin widget s trake.

## Pokazatelji

Mala skupina u sredini je widget pokazatelja. To su znakovi statusa za načine koje ste uključili: ne ometaj, noćno svjetlo, [podsjetnik](09-reminders.md) u redu čekanja, aktivno snimanje zaslona, ostani budan i [diktiranje](11-text-extraction-dictation.md). Svijetle kada je način aktivan i inače se ne nameću — lebdite tik uz njih, gdje bi sjedili neaktivni, da zavirite u njih. Klikanje pokazatelja uključuje/isključuje taj način. Još jedan je samo status: udaljena sesija svijetli crveno dok je netko povezan s ovim računalom putem gliffa.

Ako biste radije da uvijek budu vidljivi, postavite `alwaysShow` na `true` na widgetu. A ako vas zanimaju samo neki od njih, navedite one koje želite u `items`: `["Dnd", "Reminder", "NightLight"]`. Možete imati više od jednog widgeta pokazatelja, pa različiti dijelovi mogu pokazivati različite podskupove.

## Preuređivanje trake

Traka se sama konfigurira. Ne morate otvarati konfiguracijsku datoteku da biste stvari premjestili.

Uhvatite prazan dio trake oko sredine i povucite ga prema drugom rubu zaslona i traka se seli tamo — lijevo, desno, gore ili dolje, sve radi, a svaki se widget prilagođava (okomite trake vraćaju se na kompaktne oblike samo s ikonama). Klik-i-držanje započinje isto povlačenje. Dvaput kliknite lijevom tipkom na isti prazan prostor da kružite pozadinom trake od prozirne do staklaste do neprozirne. I povucite bilo koji widget da ga premjestite ili bacite u drugi dio; ostali widgeti razmiču se da naprave mjesto gdje će sletjeti.

Sredina trake je kutija: što god je u njoj ostaje centrirano kao jedna skupina, a widgeti s obje strane vise s njezinih rubova. Dok povlačite widget, kutija se prikazuje kao obris ili kao crta preko trake kada je prazna, a možete ispustiti u nju ili pored nje. Kada bi ispuštanje završilo u kutiji, kutija raste da primi widget.

Widget koji želite imati pri ruci, ali ne uvijek na vidiku, može ići u ladicu sistemske ladice: povucite ga na ladicu i ladica se otvara da ga primi. Sjedi tamo nakon ikona aplikacija, pojavljuje se kad god se i ladica pojavljuje i drži svoju ladicu otvorenom dok je njegov panel otvoren. Povucite ga natrag na traku da ga vratite.

Ako biste radije birali iz izbornika, **Appearance → Menu Bar** ima položaj, a **Bar Background** bira kako se traka crta: **Opaque Bar**, **Glassy Bar** (prozirna, sa zamućenim onim što je iza nje) ili **Clear Bar**.

Iste stvari imaju naredbe, što je ono što želite za postavke s [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Da biste widget u potpunosti dodali ili uklonili, upotrijebite naredbe za dodatke. `omarchy plugin list` ispisuje svaki widget koji shell poznaje s njegovim id-om, a zatim:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Skrivanje trake

`Super + Shift + Space` uključuje/isključuje traku bez gašenja shella — paneli i prečaci i dalje rade, samo dobivate piksele natrag. Također je u izborniku pod **Appearance → Menu Bar → Hide Bar**.

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

Svaki widget je jedan unos u jednom od pet polja rasporeda, a njegove postavke nalaze se unutar tog unosa — nema zasebne datoteke s postavkama i nema podobjekta `config`. `format`, `formatAlt` (na što desni klik kruži) i `verticalFormat` sata žive upravo tamo na `{ "id": "omarchy.clock" }`.

`center` je kutija u sredini trake: sve u njoj centrirano je na zaslonu kao jedna skupina. `centerBegin` i `centerEnd` vise s obje strane kutije, što je način na koji sat ostaje točno u sredini čak i dok vremenska prognoza i značka za ažuriranje dolaze i odlaze. Stavite više od jednog widgeta u `center` i centrirani su zajedno; ostavite ga praznim i `centerBegin` i `centerEnd` sastaju se u sredini trake.

Jedno pravilo koje vrijedi usvojiti: **kada imate vlastiti `shell.json`, on je kanonski**. Dok ništa ne prilagodite, shell čita zadanu Omarchy datoteku. U trenutku kada povučete widget, pokrenete `omarchy bar` ili sami uredite datoteku, ona je vaša — nema dubokog spajanja, pa se novi zadani widgeti u budućim Omarchy izdanjima neće automatski pojaviti na vašoj traci. `omarchy bar defaults` vraća isporučeni raspored kad god želite čistu ploču.

Ista datoteka također sadrži vaša vremena mirovanja na najvišoj razini, izvan ključa `bar`: `idle.screensaver` i `idle.lock`, oba u sekundama od kada ste postali neaktivni. Tako se zadani čuvar zaslona uključuje nakon 150 sekundi, a zaključavanje nakon 300.
