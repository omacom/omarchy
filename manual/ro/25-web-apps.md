# Aplicații web

Îți poți adăuga propriile aplicații web folosind _Install > Web App_ în meniul Omarchy (`Super + Space`). Îți va cere numele aplicației, URL-ul aplicației și URL-ul pictogramei, dacă nu o poate prelua prin favicon. Poți obține pictograme PNG grozave pentru multe aplicații web populare de pe [Dashboard Icons](https://dashboardicons.com).

Vor fi apoi accesibile prin lansatorul de aplicații (`Super + Space`) și vor folosi frumoasa fereastră de aplicație web fără ramă.

Dacă vrei să elimini o aplicație web, mergi pur și simplu la _Remove > Web App_ în meniul Omarchy.

Cel mai bine este să te autentifici în toate conturile folosind un browser obișnuit înainte de a folosi scurtăturile aplicațiilor web. Cadrul subțire de încadrare nu funcționează bine cu 1password, așa că este pur și simplu mai ușor să fii autentificat direct de la început.

Toate tastele rapide de la tastatură pentru aceste aplicații web pot fi schimbate în `~/.config/hypr/bindings.lua`.

Când ești într-o aplicație web, poți copia URL-ul curent în clipboard folosind `Shift + Alt + L`.

În mod implicit, Omarchy vine deja cu o selecție de aplicații implicite:

## HEY

[HEY](https://www.hey.com/) este un serviciu de e-mail și calendar care servește drept o alternativă grozavă pentru oamenii sătui de Gmail, Outlook sau Apple Mail. Este realizat de [37signals](https://37signals.com/), unde a luat naștere Omarchy.

Poți porni HEY Email folosind `Super + Shift + E`, poți trece direct la compunerea unui e-mail nou folosind `Super + Shift + Alt + E` și poți porni HEY Calendar folosind `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) este un serviciu de management de proiect care ajută echipele mici să se miște mai repede și să facă mai multe progrese. În loc să încropești un amestec de Trello, Slack, Asana, Notion sau orice altceva, le poți avea pe toate într-un singur loc cu Basecamp. Este realizat de [37signals](https://37signals.com/), unde a luat naștere Omarchy.

Poți porni Basecamp folosind lansatorul de aplicații (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) este cel mai popular chatbot AI din lume.

Poți porni ChatGPT folosind `Super + Shift + A`.

## Grok

[Grok](https://grok.com) este chatbotul xAI.

Poți porni Grok folosind `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) este unul dintre cele mai populare servicii de mesagerie din lume, iar versiunea web este o opțiune grozavă pentru Linux.

Poți porni WhatsApp folosind `Super + Shift + Alt + G`. Se deschide cu extensia WhatsApp Slim a Omarchy, care îl face să urmeze tema ta și restrânge lista de conversații când fereastra este îngustă.

## Aplicații Google

Google Messages, Google Photos, Google Maps și Google Contacts sunt incluse și ele ca aplicații web.

Poți porni Google Messages folosind `Super + Shift + Ctrl + G`, Google Photos folosind `Super + Shift + P` și Google Maps folosind `Super + Shift + S`. Google Contacts este disponibil prin lansatorul de aplicații (`Super + Space`).

## X

X este locul unde izbucnesc știrile.

Poți porni X folosind `Super + Shift + X` și poți trece direct la scrierea unei postări noi cu `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) este cea mai populară platformă video din lume.

Poți porni YouTube folosind `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) este inclus ca aplicație web la instalările noi.

Pornești Netflix folosind lansatorul de aplicații (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) este cel mai popular sistem de chat video folosit în SUA. Conexiuni grozave în întreaga lume. Și întâlnirile de 40 de minute pot fi ținute fără un cont plătit. Omarchy încadrează clientul web al Zoom, iar linkurile de întâlnire Zoom se vor deschide direct în el.

Pornești Zoom folosind lansatorul de aplicații (`Super + Space`).

## Discord

[Discord](https://discord.com/) este locul unde își petrec timpul majoritatea comunităților de gaming și open source, inclusiv [propria comunitate a Omarchy](https://discord.gg/tXFUdasqhY).

Pornești Discord folosind lansatorul de aplicații (`Super + Space`).

## Aplicații Microsoft

Selectează _Install > Service > Microsoft_ pentru a adăuga Outlook, Word, Excel, PowerPoint, Teams și OneDrive ca aplicații web. Fiecare aplicație are propriul lansator și se deschide direct, folosind URL-urile comerciale Microsoft 365 și profilul tău de browser existent. Se deschid în aceleași ferestre de aplicație de browser ca celelalte aplicații web ale Omarchy; nu instalează clientul separat Teams for Linux.

Elimină pachetul cu _Remove > Services > Microsoft_ sau elimină aplicațiile individuale cu _Remove > Web App_. Poți, de asemenea, să instalezi doar aplicațiile pe care le vrei prin _Install > Web App_.

Pentru un cloud guvernamental sau suveran, editează URL-ul de pe linia `Exec=` din lansatorul relevant din `~/.local/share/applications/`, cum ar fi `Microsoft Teams.desktop`, folosind URL-ul furnizat de organizația ta. Scrie orice `%` literal din acea linie ca `%%`. Modificările se aplică la următoarea lansare. Rularea din nou a programului de instalare a pachetului îi înlocuiește lansatoarele cu URL-urile implicite.

Pentru a păstra autentificările de serviciu separate, adaugă un director de date al browserului la linia `Exec=` a fiecărui lansator:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Înlocuiește directorul din exemplu cu o cale absolută la alegerea ta și folosește aceeași cale pentru toate cele șase lansatoare, pentru a partaja autentificările de serviciu între ele. Aplicațiile web folosesc browserul acceptat selectat de Omarchy, revenind la Chrome atunci când browserul implicit nu este acceptat.
