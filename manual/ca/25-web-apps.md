# Aplicacions web

Pots afegir les teves pròpies aplicacions web amb _Instal·la > Aplicació web_ al menú d'Omarchy (`Super + Space`). Et demanarà el nom de l'aplicació, l'URL de l'aplicació i l'URL de la icona, si no la pot recuperar mitjançant el favicon. Pots obtenir icones PNG fantàstiques per a moltes aplicacions web populars a [Dashboard Icons](https://dashboardicons.com).

Després seran accessibles mitjançant el llançador d'aplicacions (`Super + Space`) i faran servir la bonica finestra d'aplicació web sense marc.

Si vols eliminar una aplicació web, ves simplement a _Elimina > Aplicació web_ al menú d'Omarchy.

És millor que iniciïs sessió a tots els teus comptes amb un navegador normal abans de fer servir les dreceres d'aplicació web. El marc embolcall prim no funciona bé amb 1password, de manera que és més fàcil haver iniciat sessió directament abans.

Totes les dreceres de teclat per a aquestes aplicacions web es poden canviar a `~/.config/hypr/bindings.lua`.

Quan ets en una aplicació web, pots copiar l'URL actual al porta-retalls amb `Shift + Alt + L`.

Per defecte, Omarchy ja ve amb un assortiment d'aplicacions per defecte:

## HEY

[HEY](https://www.hey.com/) és un servei de correu electrònic i calendari que serveix com a gran alternativa per a les persones cansades de Gmail, Outlook o Apple Mail. L'ha creat [37signals](https://37signals.com/), on va néixer Omarchy.

Pots iniciar HEY Email amb `Super + Shift + E`, saltar directament a redactar un correu nou amb `Super + Shift + Alt + E` i iniciar HEY Calendar amb `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) és un servei de gestió de projectes que ajuda els equips petits a moure's més de pressa i a avançar més. En lloc d'anar apedaçant una barreja de Trello, Slack, Asana, Notion o el que sigui, ho pots tenir tot en un sol lloc amb Basecamp. L'ha creat [37signals](https://37signals.com/), on va néixer Omarchy.

Pots iniciar Basecamp amb el llançador d'aplicacions (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) és el bot de xat d'IA més popular del món.

Pots iniciar ChatGPT amb `Super + Shift + A`.

## Grok

[Grok](https://grok.com) és el bot de xat de xAI.

Pots iniciar Grok amb `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) és un dels serveis de missatgeria més populars del món, i la versió web és una gran opció per a Linux.

Pots iniciar WhatsApp amb `Super + Shift + Alt + G`.

## Aplicacions de Google

Google Messages, Google Photos, Google Maps i Google Contacts també s'inclouen com a aplicacions web.

Pots iniciar Google Messages amb `Super + Shift + Ctrl + G`, Google Photos amb `Super + Shift + P` i Google Maps amb `Super + Shift + S`. Google Contacts està disponible mitjançant el llançador d'aplicacions (`Super + Space`).

## X

X és on esclaten les notícies.

Pots iniciar X amb `Super + Shift + X` i anar directament a escriure una publicació nova amb `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) és la plataforma de vídeo més popular del món.

Pots iniciar YouTube amb `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) és el sistema de videoxat més popular als Estats Units. Grans connexions arreu del món. I es poden fer reunions de 40 minuts sense un compte de pagament. Omarchy embolcalla el client web de Zoom, i els enllaços de reunió de zoom s'obriran directament a dins.

Inicies Zoom amb el llançador d'aplicacions (`Super + Space`).

## Discord

[Discord](https://discord.com/) és on passen l'estona la majoria de comunitats de jocs i de codi obert, incloent-hi [la pròpia d'Omarchy](https://discord.gg/tXFUdasqhY).

Inicies Discord amb el llançador d'aplicacions (`Super + Space`).

## Aplicacions de Microsoft

Selecciona _Instal·la > Servei > Microsoft_ per afegir Outlook, Word, Excel, PowerPoint, Teams i OneDrive com a aplicacions web. Cada aplicació té el seu propi llançador i s'obre directament, fent servir els URL comercials de Microsoft 365 i el teu perfil de navegador existent. S'obren a les mateixes finestres d'aplicació de navegador que les altres aplicacions web d'Omarchy; no instal·len pas el client separat de Teams per a Linux.

Elimina el paquet amb _Elimina > Servei > Microsoft_, o elimina aplicacions individuals amb _Elimina > Aplicació web_. També pots instal·lar només les aplicacions que vulguis mitjançant _Instal·la > Aplicació web_.

Per a un núvol governamental o sobirà, edita l'URL de la línia `Exec=` al llançador corresponent a `~/.local/share/applications/`, com ara `Microsoft Teams.desktop`, fent servir l'URL que t'hagi subministrat la teva organització. Escriu qualsevol `%` literal d'aquella línia com a `%%`. Els canvis s'apliquen a la propera obertura. Si tornes a executar l'instal·lador del paquet, els seus llançadors es reemplacen pels URL per defecte.

Per mantenir separats els inicis de sessió de la feina, afegeix un directori de dades de navegador a la línia `Exec=` de cada llançador:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Substitueix el directori d'exemple per una ruta absoluta que triïs i fes servir la mateixa ruta per als sis llançadors per compartir els inicis de sessió de la feina entre ells. Les aplicacions web fan servir el navegador compatible seleccionat d'Omarchy, i recauen a Chromium quan el navegador per defecte no és compatible.
