# Web-aplikacije

Svoje web-aplikacije možete dodati pomoću _Install > Web App_ u izborniku Omarchy (`Super + Space`). Pitat će vas za naziv aplikacije, URL aplikacije i URL ikone, ako je ne može dohvatiti putem favicona. Odlične PNG ikone za mnoge popularne web-aplikacije možete pronaći na [Dashboard Icons](https://dashboardicons.com).

Zatim će biti dostupne putem pokretača aplikacija (`Super + Space`) i koristit će prekrasan prozor web-aplikacije bez okvira.

Ako želite ukloniti web-aplikaciju, jednostavno idite na _Remove > Web App_ u izborniku Omarchy.

Najbolje je da se u sve svoje račune prijavite pomoću običnog preglednika prije korištenja prečaca za web-aplikacije. Tanki okvir omotača ne radi dobro s 1password, pa je jednostavno lakše prvo se izravno prijaviti.

Sve tipkovničke prečace za ove web-aplikacije možete promijeniti u `~/.config/hypr/bindings.lua`.

Kad ste u web-aplikaciji, trenutni URL možete kopirati u međuspremnik pomoću `Shift + Alt + L`.

Omarchy prema zadanim postavkama već dolazi s izborom zadanih aplikacija:

## HEY

[HEY](https://www.hey.com/) je usluga za e-poštu i kalendar koja služi kao odlična alternativa ljudima kojima je dosta Gmail, Outlook ili Apple Mail. Izradio ju je [37signals](https://37signals.com/), odakle Omarchy potječe.

HEY Email možete pokrenuti pomoću `Super + Shift + E`, izravno prijeći na sastavljanje nove e-pošte pomoću `Super + Shift + Alt + E`, a HEY Calendar pokrenuti pomoću `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) je usluga za upravljanje projektima koja malim timovima pomaže da rade brže i postižu veći napredak. Umjesto da krpate zbrku od Trello, Slack, Asana, Notion ili čega već, sve to možete imati na jednom mjestu uz Basecamp. Izradio ga je [37signals](https://37signals.com/), odakle Omarchy potječe.

Basecamp možete pokrenuti pomoću pokretača aplikacija (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) je najpopularniji AI chatbot na svijetu.

ChatGPT možete pokrenuti pomoću `Super + Shift + A`.

## Grok

[Grok](https://grok.com) je chatbot tvrtke xAI.

Grok možete pokrenuti pomoću `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) je jedna od najpopularnijih usluga za razmjenu poruka na svijetu, a web-verzija odlična je opcija za Linux.

WhatsApp možete pokrenuti pomoću `Super + Shift + Alt + G`. Otvara se s proširenjem WhatsApp Slim sustava Omarchy, zahvaljujući kojem prati vašu temu i sažima popis razgovora kad je prozor uzak.

## Googleove aplikacije

Google Messages, Google Photos, Google Maps i Google Contacts također su uključeni kao web-aplikacije.

Google Messages možete pokrenuti pomoću `Super + Shift + Ctrl + G`, Google Photos pomoću `Super + Shift + P`, a Google Maps pomoću `Super + Shift + S`. Google Contacts dostupan je putem pokretača aplikacija (`Super + Space`).

## X

X je mjesto gdje vijesti prve izlaze.

X možete pokrenuti pomoću `Super + Shift + X` i izravno prijeći na pisanje nove objave pomoću `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) je najpopularnija videoplatforma na svijetu.

YouTube možete pokrenuti pomoću `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) uključen je kao web-aplikacija na novim instalacijama.

Netflix pokrećete pomoću pokretača aplikacija (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) najpopularniji je sustav za videorazgovore koji se koristi u SAD-u. Odlične veze diljem svijeta. A sastanci od 40 minuta mogu se održavati bez plaćenog računa. Omarchy obavija Zoom web-klijent, a poveznice na Zoom sastanke otvarat će se izravno u njemu.

Zoom pokrećete pomoću pokretača aplikacija (`Super + Space`).

## Discord

[Discord](https://discord.com/) mjesto je gdje se okuplja većina zajednica za igre i otvoreni kod, uključujući i [onu od Omarchyja](https://discord.gg/tXFUdasqhY).

Discord pokrećete pomoću pokretača aplikacija (`Super + Space`).

## Microsoftove aplikacije

Odaberite _Install > Service > Microsoft_ kako biste dodali Outlook, Word, Excel, PowerPoint, Teams i OneDrive kao web-aplikacije. Svaka aplikacija ima vlastiti pokretač i otvara se izravno, koristeći komercijalne Microsoft 365 URL-ove i vaš postojeći profil preglednika. Otvaraju se u istim prozorima aplikacija preglednika kao i ostale web-aplikacije sustava Omarchy; ne instaliraju zaseban klijent Teams for Linux.

Uklonite paket pomoću _Remove > Services > Microsoft_ ili uklonite pojedinačne aplikacije pomoću _Remove > Web App_. Putem _Install > Web App_ možete instalirati i samo aplikacije koje želite.

Za državni ili suvereni oblak uredite URL na retku `Exec=` u odgovarajućem pokretaču pod `~/.local/share/applications/`, kao što je `Microsoft Teams.desktop`, koristeći URL koji vam je dala vaša organizacija. Svaki doslovni `%` u tom retku napišite kao `%%`. Promjene se primjenjuju pri sljedećem pokretanju. Ponovno pokretanje instalacijskog programa paketa zamjenjuje njegove pokretače zadanim URL-ovima.

Kako bi poslovne prijave ostale odvojene, dodajte direktorij podataka preglednika na redak `Exec=` svakog pokretača:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Zamijenite ogledni direktorij apsolutnom putanjom po vlastitom izboru i koristite istu putanju za svih šest pokretača kako bi međusobno dijelili poslovne prijave. Web-aplikacije koriste odabrani podržani preglednik sustava Omarchy, a ako zadani preglednik nije podržan, vraćaju se na Chrome.
