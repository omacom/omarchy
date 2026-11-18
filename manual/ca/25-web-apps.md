# Aplicacions web

Pots afegir les teves pròpies aplicacions web amb _Install > Web App_ al menú d'Omarchy (`Super + Space`). Et demanarà el nom de l'aplicació, l'URL de l'aplicació i l'URL de la icona, si no la pot obtenir mitjançant el favicon. Pots aconseguir icones PNG fantàstiques per a moltes aplicacions web populars a [Dashboard Icons](https://dashboardicons.com).

Aleshores hi podràs accedir mitjançant el llançador d'aplicacions (`Super + Space`), i utilitzen la bonica finestra d'aplicació web sense marc.

Si vols eliminar una aplicació web, vés simplement a _Remove > Web App_ al menú d'Omarchy.

El millor és que iniciïs sessió en tots els teus comptes amb un navegador normal abans d'utilitzar les dreceres de les aplicacions web. El marc prim de l'embolcall no funciona bé amb 1password, així que simplement és més fàcil haver iniciat sessió directament abans.

Totes les dreceres de teclat d'aquestes aplicacions web es poden canviar a `~/.config/hypr/bindings.lua`.

Quan siguis en una aplicació web, pots copiar l'URL actual al porta-retalls amb `Shift + Alt + L`.

Per defecte, Omarchy ja inclou una selecció d'aplicacions predeterminades:

## HEY

[HEY](https://www.hey.com/) és un servei de correu electrònic i calendari que és una alternativa fantàstica per a la gent cansada de Gmail, Outlook o Apple Mail. L'ha creat [37signals](https://37signals.com/), on va néixer Omarchy.

Pots obrir HEY Email amb `Super + Shift + E`, anar directament a redactar un correu electrònic nou amb `Super + Shift + Alt + E` i obrir HEY Calendar amb `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) és un servei de gestió de projectes que ajuda els equips petits a anar més de pressa i a avançar més. En lloc d'apedaçar una barreja de Trello, Slack, Asana, Notion o el que sigui, ho pots tenir tot en un sol lloc amb Basecamp. L'ha creat [37signals](https://37signals.com/), on va néixer Omarchy.

Pots obrir Basecamp amb el llançador d'aplicacions (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) és el bot de xat d'IA més popular del món.

Pots obrir ChatGPT amb `Super + Shift + A`.

## Grok

[Grok](https://grok.com) és el bot de xat de xAI.

Pots obrir Grok amb `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) és un dels serveis de missatgeria més populars del món, i la versió web és una opció fantàstica per a Linux.

Pots obrir WhatsApp amb `Super + Shift + Alt + G`.

## Aplicacions de Google

Google Messages, Google Photos, Google Maps i Google Contacts també s'inclouen com a aplicacions web.

Pots obrir Google Messages amb `Super + Shift + Ctrl + G`, Google Photos amb `Super + Shift + P` i Google Maps amb `Super + Shift + S`. Google Contacts està disponible mitjançant el llançador d'aplicacions (`Super + Space`).

## X

X és on esclaten les notícies.

Pots obrir X amb `Super + Shift + X` i anar directament a escriure una publicació nova amb `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) és la plataforma de vídeo més popular del món.

Pots obrir YouTube amb `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) és el sistema de videoxat més popular dels EUA. Connexions fantàstiques arreu del món. I es poden fer reunions de 40 minuts sense un compte de pagament. Omarchy embolcalla el client web de Zoom, i els enllaços de reunions de Zoom s'hi obriran directament.

Obres Zoom amb el llançador d'aplicacions (`Super + Space`).

## Discord

[Discord](https://discord.com/) és on es reuneixen la majoria de comunitats de videojocs i de codi obert, inclosa [la pròpia d'Omarchy](https://discord.gg/tXFUdasqhY).

Obres Discord amb el llançador d'aplicacions (`Super + Space`).

## Aplicacions de Microsoft

Selecciona _Install > Service > Microsoft_ per afegir Outlook, Word, Excel, PowerPoint, Teams i OneDrive com a aplicacions web. Cada aplicació té el seu propi llançador i s'obre directament, amb els URL comercials de Microsoft 365 i el teu perfil de navegador existent. S'obren en les mateixes finestres d'aplicació de navegador que les altres aplicacions web d'Omarchy; no instal·len el client separat Teams for Linux.

Elimina el paquet amb _Remove > Service > Microsoft_, o elimina aplicacions individuals amb _Remove > Web App_. També pots instal·lar només les aplicacions que vulguis mitjançant _Install > Web App_.

Per a un núvol governamental o sobirà, edita l'URL a la línia `Exec=` del llançador corresponent a `~/.local/share/applications/`, com ara `Microsoft Teams.desktop`, amb l'URL que t'hagi proporcionat la teva organització. Escriu qualsevol `%` literal d'aquesta línia com a `%%`. Els canvis s'apliquen en el proper inici. Si tornes a executar l'instal·lador del paquet, substituirà els seus llançadors pels URL predeterminats.

Per mantenir separats els inicis de sessió de la feina, afegeix un directori de dades del navegador a la línia `Exec=` de cada llançador:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Substitueix el directori d'exemple per una ruta absoluta que triïs tu i utilitza la mateixa ruta per als sis llançadors per compartir entre ells els inicis de sessió de la feina. Les aplicacions web utilitzen el navegador compatible seleccionat d'Omarchy, i recorren a Chrome quan el navegador predeterminat no és compatible.
