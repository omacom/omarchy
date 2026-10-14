# Web-aplikacije

Vlastite web-aplikacije možeš dodati koristeći _Instaliraj > Web App_ u izborniku Omarchy (`Super + Space`). Pitat će te za ime aplikacije, URL aplikacije i URL ikone, ako ga ne može dohvatiti putem favicona. Odlične PNG ikone za mnoge popularne web-aplikacije možeš dobiti na [Dashboard Icons](https://dashboardicons.com).

Zatim će biti dostupne putem pokretača aplikacija (`Super + Space`) i koristit će lijepi prozor web-aplikacije bez okvira.

Ako želiš ukloniti web-aplikaciju, samo idi na _Ukloni > Web App_ u izborniku Omarchy.

Najbolje je ako se u sve svoje račune prijaviš koristeći običan preglednik prije korištenja prečaca web-aplikacija. Tanki okvir omotača ne radi dobro s 1passwordom, pa je jednostavnije biti prijavljen izravno unaprijed.

Svi tipkovnički prečaci za ove web-aplikacije mogu se promijeniti u `~/.config/hypr/bindings.lua`.

Kad si u web-aplikaciji, možeš kopirati trenutni URL u međuspremnik koristeći `Shift + Alt + L`.

Prema zadanim postavkama, Omarchy već dolazi s asortimanom zadanih aplikacija:

## HEY

[HEY](https://www.hey.com/) usluga je e-pošte i kalendara koja služi kao sjajna alternativa ljudima umornima od Gmaila, Outlooka ili Apple Maila. Izrađuje je [37signals](https://37signals.com/) gdje je Omarchy nastao.

HEY Email možeš pokrenuti koristeći `Super + Shift + E`, skočiti izravno na sastavljanje nove e-pošte koristeći `Super + Shift + Alt + E` i pokrenuti HEY Calendar koristeći `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) usluga je za upravljanje projektima koja pomaže malim timovima da se kreću brže i postižu veći napredak. Umjesto krpanja zbrke Trello, Slack, Asana, Notion ili što god, sve to možeš imati na jednom mjestu s Basecampom. Izrađuje ga [37signals](https://37signals.com/) gdje je Omarchy nastao.

Basecamp možeš pokrenuti koristeći pokretač aplikacija (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) najpopularniji je AI chat bot na svijetu.

ChatGPT možeš pokrenuti koristeći `Super + Shift + A`.

## Grok

[Grok](https://grok.com) xAI-jev je chat bot.

Grok možeš pokrenuti koristeći `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) jedna je od najpopularnijih usluga za razmjenu poruka na svijetu, a web-verzija sjajna je opcija za Linux.

WhatsApp možeš pokrenuti koristeći `Super + Shift + Alt + G`.

## Google aplikacije

Google Messages, Google Photos, Google Maps i Google Contacts također su uključeni kao web-aplikacije.

Google Messages možeš pokrenuti koristeći `Super + Shift + Ctrl + G`, Google Photos koristeći `Super + Shift + P`, a Google Maps koristeći `Super + Shift + S`. Google Contacts dostupan je putem pokretača aplikacija (`Super + Space`).

## X

X je mjesto gdje vijesti izbijaju.

X možeš pokrenuti koristeći `Super + Shift + X` i ići izravno na pisanje nove objave sa `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) najpopularnija je video platforma na svijetu.

YouTube možeš pokrenuti koristeći `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) najpopularniji je sustav za video chat koji se koristi u SAD-u. Sjajne veze diljem svijeta. A 40-minutni sastanci mogu se održati bez plaćajućeg računa. Omarchy omata Zoomov web-klijent, a poveznice za Zoom sastanke otvarat će se izravno u njega.

Zoom pokrećeš koristeći pokretač aplikacija (`Super + Space`).

## Discord

[Discord](https://discord.com/) mjesto je gdje se većina gaming i zajednica otvorenog koda druži, uključujući [Omarchyjev vlastiti](https://discord.gg/tXFUdasqhY).

Discord pokrećeš koristeći pokretač aplikacija (`Super + Space`).

## Microsoft aplikacije

Odaberi _Instaliraj > Service > Microsoft_ za dodavanje Outlooka, Worda, Excela, PowerPointa, Teamsa i OneDrivea kao web-aplikacija. Svaka aplikacija ima vlastiti pokretač i otvara se izravno, koristeći komercijalne URL-ove Microsoft 365 i tvoj postojeći profil preglednika. Otvaraju se u istim prozorima aplikacija preglednika kao i Omarchyjeve druge web-aplikacije; ne instaliraju zaseban Teams for Linux klijent.

Ukloni paket s _Ukloni > Service > Microsoft_ ili ukloni pojedinačne aplikacije s _Ukloni > Web App_. Možeš instalirati i samo aplikacije koje želiš putem _Instaliraj > Web App_.

Za državni ili suvereni oblak uredi URL na retku `Exec=` u relevantnom pokretaču pod `~/.local/share/applications/`, poput `Microsoft Teams.desktop`, koristeći URL koji ti je dostavila tvoja organizacija. Svaki doslovni `%` u tom retku napiši kao `%%`. Promjene se primjenjuju pri sljedećem pokretanju. Ponovno pokretanje instalatera paketa zamjenjuje njegove pokretače zadanim URL-ovima.

Za odvajanje radnih prijava dodaj direktorij podataka preglednika na redak `Exec=` svakog pokretača:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Zamijeni primjer direktorija apsolutnom putanjom po vlastitom izboru i koristi istu putanju za svih šest pokretača za dijeljenje radnih prijava među njima. Web-aplikacije koriste Omarchyjev odabrani podržani preglednik, vraćajući se na Chromium kad zadani preglednik nije podržan.
