# Aplicații web

Îți poți adăuga propriile aplicații web folosind _Install > Web App_ din meniul Omarchy (`Super + Space`). Îți va cere numele aplicației, URL-ul aplicației și URL-ul pictogramei, dacă nu îl poate prelua prin favicon. Poți obține pictograme PNG excelente pentru multe aplicații web populare de pe [Dashboard Icons](https://dashboardicons.com).

Vor fi apoi accesibile prin lansatorul de aplicații (`Super + Space`) și vor folosi frumoasa fereastră de aplicație web fără ramă.

Dacă vrei să elimini o aplicație web, mergi pur și simplu la _Remove > Web App_ din meniul Omarchy.

Cel mai bine este să te autentifici în toate conturile folosind un browser obișnuit înainte să folosești scurtăturile aplicațiilor web. Rama subțire a wrapperului nu funcționează bine cu 1password, așa că e mai ușor să fii autentificat direct de la început.

Toate scurtăturile de tastatură pentru aceste aplicații web pot fi modificate în `~/.config/hypr/bindings.lua`.

Când ești într-o aplicație web, poți copia URL-ul curent în clipboard folosind `Shift + Alt + L`.

În mod implicit, Omarchy vine deja cu un sortiment de aplicații implicite:

## HEY

[HEY](https://www.hey.com/) este un serviciu de e-mail și calendar care servește drept alternativă excelentă pentru cei sătui de Gmail, Outlook sau Apple Mail. Este creat de [37signals](https://37signals.com/), de unde a pornit Omarchy.

Poți porni HEY Email folosind `Super + Shift + E`, poți sări direct la compunerea unui e-mail nou folosind `Super + Shift + Alt + E` și poți porni HEY Calendar folosind `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) este un serviciu de gestionare a proiectelor care ajută echipele mici să avanseze mai repede și să progreseze mai mult. În loc să încropești un amestec de Trello, Slack, Asana, Notion sau mai știu eu ce, le poți avea pe toate într-un singur loc cu Basecamp. Este creat de [37signals](https://37signals.com/), de unde a pornit Omarchy.

Poți porni Basecamp folosind lansatorul de aplicații (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) este cel mai popular bot de chat cu AI din lume.

Poți porni ChatGPT folosind `Super + Shift + A`.

## Grok

[Grok](https://grok.com) este botul de chat al xAI.

Poți porni Grok folosind `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) este unul dintre cele mai populare servicii de mesagerie din lume, iar versiunea web este o opțiune excelentă pentru Linux.

Poți porni WhatsApp folosind `Super + Shift + Alt + G`.

## Aplicații Google

Google Messages, Google Photos, Google Maps și Google Contacts sunt incluse și ele ca aplicații web.

Poți porni Google Messages folosind `Super + Shift + Ctrl + G`, Google Photos folosind `Super + Shift + P` și Google Maps folosind `Super + Shift + S`. Google Contacts este disponibil prin lansatorul de aplicații (`Super + Space`).

## X

X este locul unde știrile apar prima dată.

Poți porni X folosind `Super + Shift + X` și poți merge direct la scrierea unei postări noi cu `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) este cea mai populară platformă video din lume.

Poți porni YouTube folosind `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) este cel mai popular sistem de chat video folosit în SUA. Conexiuni excelente în întreaga lume. Iar întâlnirile de 40 de minute pot fi ținute fără un cont plătit. Omarchy înfășoară clientul web Zoom, iar linkurile de întâlnire Zoom se vor deschide direct în el.

Pornești Zoom folosind lansatorul de aplicații (`Super + Space`).

## Discord

[Discord](https://discord.com/) este locul unde se adună majoritatea comunităților de gaming și open source, inclusiv [cea a Omarchy](https://discord.gg/tXFUdasqhY).

Pornești Discord folosind lansatorul de aplicații (`Super + Space`).

## Aplicații Microsoft

Selectează _Install > Service > Microsoft_ pentru a adăuga Outlook, Word, Excel, PowerPoint, Teams și OneDrive ca aplicații web. Fiecare aplicație are propriul lansator și se deschide direct, folosind URL-urile comerciale Microsoft 365 și profilul tău de browser existent. Se deschid în aceleași ferestre de aplicație de browser ca celelalte aplicații web ale Omarchy; nu instalează clientul separat Teams for Linux.

Elimină pachetul cu _Remove > Service > Microsoft_ sau elimină aplicații individuale cu _Remove > Web App_. Poți, de asemenea, să instalezi doar aplicațiile pe care le vrei prin _Install > Web App_.

Pentru un cloud guvernamental sau suveran, editează URL-ul de pe linia `Exec=` din lansatorul relevant de sub `~/.local/share/applications/`, cum ar fi `Microsoft Teams.desktop`, folosind URL-ul furnizat de organizația ta. Scrie orice `%` literal din acea linie ca `%%`. Modificările se aplică la următoarea lansare. Rularea din nou a programului de instalare a pachetului îi înlocuiește lansatoarele cu URL-urile implicite.

Pentru a păstra autentificările de serviciu separate, adaugă un director de date al browserului la linia `Exec=` a fiecărui lansator:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Înlocuiește directorul din exemplu cu o cale absolută la alegerea ta și folosește aceeași cale pentru toate cele șase lansatoare, pentru a partaja autentificările de serviciu între ele. Aplicațiile web folosesc browserul acceptat selectat de Omarchy, revenind la Chrome atunci când browserul implicit nu este acceptat.
