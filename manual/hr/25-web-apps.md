# Web aplikacije

Vlastite web aplikacije možete dodati pomoću _Install > Web App_ u izborniku Omarchy (`Super + Space`). Pitat će vas za naziv aplikacije, URL aplikacije i URL ikone, ako je ne može dohvatiti putem favicona. Odlične PNG ikone za mnoge popularne web aplikacije možete pronaći na [Dashboard Icons](https://dashboardicons.com).

Ondje će zatim biti dostupne putem pokretača aplikacija (`Super + Space`) i koristit će prekrasan prozor web aplikacije bez okvira.

Ako želite ukloniti web aplikaciju, jednostavno idite na _Remove > Web App_ u izborniku Omarchy.

Najbolje je da se u sve svoje račune prijavite pomoću običnog preglednika prije korištenja prečaca za web aplikacije. Tanki okvir omotača ne radi dobro s 1passwordom, pa je jednostavno lakše prvo se izravno prijaviti.

Sve tipkovničke prečace za ove web aplikacije možete promijeniti u `~/.config/hypr/bindings.lua`.

Kada ste u web aplikaciji, trenutni URL možete kopirati u međuspremnik pomoću `Shift + Alt + L`.

Omarchy prema zadanim postavkama već dolazi s izborom zadanih aplikacija:

## HEY

[HEY](https://www.hey.com/) je usluga e-pošte i kalendara koja služi kao odlična alternativa ljudima kojima je dosta Gmaila, Outlooka ili Apple Maila. Izradio ju je [37signals](https://37signals.com/), odakle Omarchy i potječe.

HEY Email možete pokrenuti pomoću `Super + Shift + E`, izravno prijeći na sastavljanje nove e-pošte pomoću `Super + Shift + Alt + E`, a HEY Calendar pokrenuti pomoću `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) je usluga za upravljanje projektima koja malim timovima pomaže da se brže kreću i više napreduju. Umjesto da krpate zbrku od Trella, Slacka, Asane, Notiona ili čega već, s Basecampom sve možete imati na jednom mjestu. Izradio ga je [37signals](https://37signals.com/), odakle Omarchy i potječe.

Basecamp možete pokrenuti pomoću pokretača aplikacija (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) je najpopularniji AI chatbot na svijetu.

ChatGPT možete pokrenuti pomoću `Super + Shift + A`.

## Grok

[Grok](https://grok.com) je chatbot tvrtke xAI.

Grok možete pokrenuti pomoću `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) je jedna od najpopularnijih usluga za razmjenu poruka na svijetu, a web verzija odlična je opcija za Linux.

WhatsApp možete pokrenuti pomoću `Super + Shift + Alt + G`.

## Google aplikacije

Google Messages, Google Photos, Google Maps i Google Contacts također su uključeni kao web aplikacije.

Google Messages možete pokrenuti pomoću `Super + Shift + Ctrl + G`, Google Photos pomoću `Super + Shift + P`, a Google Maps pomoću `Super + Shift + S`. Google Contacts dostupan je putem pokretača aplikacija (`Super + Space`).

## X

X je mjesto gdje vijesti izlaze u javnost.

X možete pokrenuti pomoću `Super + Shift + X` i izravno prijeći na pisanje nove objave pomoću `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) je najpopularnija videoplatforma na svijetu.

YouTube možete pokrenuti pomoću `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) je najpopularniji sustav za videorazgovore koji se koristi u SAD-u. Odlične veze diljem svijeta. A sastanci od 40 minuta mogu se održavati i bez plaćenog računa. Omarchy omata Zoomov web klijent, a poveznice na Zoom sastanke otvarat će se izravno u njemu.

Zoom pokrećete pomoću pokretača aplikacija (`Super + Space`).

## Discord

[Discord](https://discord.com/) je mjesto gdje se druži većina gaming zajednica i zajednica otvorenog koda, uključujući i [vlastitu zajednicu Omarchyja](https://discord.gg/tXFUdasqhY).

Discord pokrećete pomoću pokretača aplikacija (`Super + Space`).

## Microsoft aplikacije

Odaberite _Install > Service > Microsoft_ kako biste Outlook, Word, Excel, PowerPoint, Teams i OneDrive dodali kao web aplikacije. Svaka aplikacija ima vlastiti pokretač i otvara se izravno, koristeći komercijalne URL-ove za Microsoft 365 i vaš postojeći profil preglednika. Otvaraju se u istim prozorima aplikacija preglednika kao i ostale web aplikacije Omarchyja; ne instaliraju zaseban klijent Teams for Linux.

Paket uklonite pomoću _Remove > Service > Microsoft_, a pojedinačne aplikacije uklonite pomoću _Remove > Web App_. Putem _Install > Web App_ možete instalirati i samo aplikacije koje želite.

Za državni ili suvereni oblak uredite URL u retku `Exec=` u odgovarajućem pokretaču pod `~/.local/share/applications/`, kao što je `Microsoft Teams.desktop`, koristeći URL koji vam je dala vaša organizacija. Svaki doslovni `%` u tom retku napišite kao `%%`. Promjene se primjenjuju pri sljedećem pokretanju. Ponovno pokretanje instalacijskog programa paketa zamjenjuje njegove pokretače zadanim URL-ovima.

Kako biste poslovne prijave držali odvojenima, dodajte direktorij s podacima preglednika u redak `Exec=` svakog pokretača:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Direktorij iz primjera zamijenite apsolutnom putanjom po vlastitom izboru i koristite istu putanju za svih šest pokretača kako bi međusobno dijelili poslovne prijave. Web aplikacije koriste podržani preglednik odabran u Omarchyju, a ako zadani preglednik nije podržan, pribjegavaju Chromeu.
