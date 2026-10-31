# Aplicații web

Îți poți adăuga propriile aplicații web folosind _Instalează > Aplicație web_ în meniul Omarchy (`Super + Space`). Te va întreba numele aplicației, URL-ul aplicației și URL-ul pictogramei, dacă nu îl poate obține prin favicon. Poți obține pictograme PNG excelente pentru multe aplicații web populare pe [Dashboard Icons](https://dashboardicons.com).

Ele vor fi apoi accesibile prin lansatorul de aplicații (`Super + Space`) și vor folosi frumoasa fereastră de aplicație web fără ramă.

Dacă dorești să elimini o aplicație web, mergi pur și simplu la _Elimină > Aplicație web_ în meniul Omarchy.

Cel mai bine este să te conectezi la toate conturile tale folosind un browser obișnuit înainte să folosești scurtăturile pentru aplicațiile web. Rama subțire de înfășurare nu funcționează bine cu 1password, așa că este mai ușor să fii conectat direct mai întâi.

Toate scurtăturile de tastatură pentru aceste aplicații web pot fi schimbate în `~/.config/hypr/bindings.lua`.

Când ești într-o aplicație web, poți copia URL-ul curent în clipboard folosind `Shift + Alt + L`.

Implicit, Omarchy vine deja cu un assortiment de aplicații implicite:

## HEY

[HEY](https://www.hey.com/) este un serviciu de e-mail și calendar care servește ca o alternativă excelentă pentru oamenii sătui de Gmail, Outlook sau Apple Mail. Este făcut de [37signals](https://37signals.com/), unde Omarchy și-a avut originea.

Poți porni HEY Email folosind `Super + Shift + E`, poți sări direct la compunerea unui e-mail nou folosind `Super + Shift + Alt + E` și poți porni HEY Calendar folosind `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) este un serviciu de management de proiecte care ajută echipele mici să se miște mai repede și să facă mai multe progrese. În loc să peticești laolaltă un amestec de Trello, Slack, Asana, Notion sau orice altceva, poți avea totul într-un singur loc cu Basecamp. Este făcut de [37signals](https://37signals.com/), unde Omarchy și-a avut originea.

Poți porni Basecamp folosind lansatorul de aplicații (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) este cel mai popular chatbot AI din lume.

Poți porni ChatGPT folosind `Super + Shift + A`.

## Grok

[Grok](https://grok.com) este chatbotul xAI.

Poți porni Grok folosind `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) este unul dintre cele mai populare servicii de mesagerie din lume, iar versiunea web este o opțiune excelentă pentru Linux.

Poți porni WhatsApp folosind `Super + Shift + Alt + G`.

## Aplicații Google

Google Messages, Google Photos, Google Maps și Google Contacts sunt toate incluse și ele ca aplicații web.

Poți porni Google Messages folosind `Super + Shift + Ctrl + G`, Google Photos folosind `Super + Shift + P` și Google Maps folosind `Super + Shift + S`. Google Contacts este disponibil prin lansatorul de aplicații (`Super + Space`).

## X

X este locul unde se întâmplă știrile.

Poți porni X folosind `Super + Shift + X` și poți merge direct la scrierea unei postări noi cu `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) este cea mai populară platformă video din lume.

Poți porni YouTube folosind `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) este cel mai popular sistem de videochat folosit în SUA. Conexiuni excelente în toată lumea. Iar întâlnirile de 40 de minute pot fi ținute fără un cont plătit. Omarchy înfășoară clientul web Zoom, iar linkurile de întâlnire Zoom se vor deschide direct în el.

Pornești Zoom folosind lansatorul de aplicații (`Super + Space`).

## Discord

[Discord](https://discord.com/) este locul unde se întâlnesc majoritatea comunităților de gaming și open source, inclusiv [cea a Omarchy](https://discord.gg/tXFUdasqhY).

Pornești Discord folosind lansatorul de aplicații (`Super + Space`).

## Aplicații Microsoft

Selectează _Instalează > Serviciu > Microsoft_ ca să adaugi Outlook, Word, Excel, PowerPoint, Teams și OneDrive ca aplicații web. Fiecare aplicație are propriul lansator și se deschide direct, folosind URL-urile comerciale Microsoft 365 și profilul tău de browser existent. Ele se deschid în aceleași ferestre de aplicații din browser ca celelalte aplicații web ale Omarchy; nu instalează clientul separat Teams for Linux.

Elimină pachetul cu _Elimină > Servicii > Microsoft_ sau elimină aplicații individuale cu _Elimină > Aplicație web_. Poți instala și doar aplicațiile pe care le dorești prin _Instalează > Aplicație web_.

Pentru un cloud guvernamental sau suveran, editează URL-ul de pe linia `Exec=` din lansatorul relevant sub `~/.local/share/applications/`, cum ar fi `Microsoft Teams.desktop`, folosind URL-ul furnizat de organizația ta. Scrie orice `%` literal pe acea linie ca `%%`. Schimbările se aplică la următoarea lansare. Rularea din nou a programului de instalare a pachetului îi înlocuiește lansatoarele cu URL-urile implicite.

Ca să ții conectările de serviciu separate, adaugă un director de date de browser la linia `Exec=` a fiecărui lansator:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Înlocuiește directorul din exemplu cu o cale absolută la alegerea ta și folosește aceeași cale pentru toate cele șase lansatoare ca să partajezi conectările de serviciu între ele. Aplicațiile web folosesc browserul acceptat selectat de Omarchy, revenind la Chromium atunci când browserul implicit nu este acceptat.
