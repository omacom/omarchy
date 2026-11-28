# Aplicacions web

Podeu afegir les vostres pròpies aplicacions web mitjançant _Instal·la > Aplicació web_ al menú d'Omarchy (`Super + Space`). Us demanarà el nom de l'aplicació, l'URL de l'aplicació i l'URL de la icona, si no la pot obtenir mitjançant el favicon. Podeu obtenir icones PNG fantàstiques per a moltes aplicacions web populars a [Dashboard Icons](https://dashboardicons.com).

Després hi podreu accedir mitjançant el llançador d'aplicacions (`Super + Space`), i utilitzen la bonica finestra d'aplicació web sense marc.

Si voleu eliminar una aplicació web, només cal que aneu a _Elimina > Aplicació web_ al menú d'Omarchy.

És millor que inicieu sessió en tots els vostres comptes amb un navegador normal abans d'utilitzar les dreceres de les aplicacions web. El marc prim de l'embolcall no funciona bé amb 1password, així que és més fàcil haver iniciat sessió directament abans.

Totes les tecles d'accés ràpid del teclat per a aquestes aplicacions web es poden canviar a `~/.config/hypr/bindings.lua`.

Quan sigueu en una aplicació web, podeu copiar l'URL actual al porta-retalls amb `Shift + Alt + L`.

Per defecte, Omarchy ja inclou un assortiment d'aplicacions predeterminades:

## HEY

[HEY](https://www.hey.com/) és un servei de correu electrònic i calendari que és una alternativa fantàstica per a la gent cansada de Gmail, Outlook o Apple Mail. L'ha creat [37signals](https://37signals.com/), on va néixer Omarchy.

Podeu iniciar HEY Email amb `Super + Shift + E`, anar directament a redactar un correu electrònic nou amb `Super + Shift + Alt + E`, i iniciar HEY Calendar amb `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) és un servei de gestió de projectes que ajuda els equips petits a avançar més de pressa i a fer més progressos. En lloc d'apedaçar una barreja de Trello, Slack, Asana, Notion o el que sigui, podeu tenir-ho tot en un sol lloc amb Basecamp. L'ha creat [37signals](https://37signals.com/), on va néixer Omarchy.

Podeu iniciar Basecamp mitjançant el llançador d'aplicacions (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) és el bot de xat d'IA més popular del món.

Podeu iniciar ChatGPT amb `Super + Shift + A`.

## Grok

[Grok](https://grok.com) és el bot de xat de xAI.

Podeu iniciar Grok amb `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) és un dels serveis de missatgeria més populars del món, i la versió web és una opció fantàstica per a Linux.

Podeu iniciar WhatsApp amb `Super + Shift + Alt + G`. S'obre amb l'extensió WhatsApp Slim d'Omarchy, que fa que segueixi el vostre tema i replega la llista de xats quan la finestra és estreta.

## Aplicacions de Google

Google Messages, Google Photos, Google Maps i Google Contacts també s'inclouen com a aplicacions web.

Podeu iniciar Google Messages amb `Super + Shift + Ctrl + G`, Google Photos amb `Super + Shift + P`, i Google Maps amb `Super + Shift + S`. Google Contacts està disponible mitjançant el llançador d'aplicacions (`Super + Space`).

## X

X és on esclaten les notícies.

Podeu iniciar X amb `Super + Shift + X` i anar directament a escriure una publicació nova amb `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) és la plataforma de vídeo més popular del món.

Podeu iniciar YouTube amb `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) s'inclou com a aplicació web en les instal·lacions noves.

Inicieu Netflix mitjançant el llançador d'aplicacions (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) és el sistema de videoxat més popular utilitzat als Estats Units. Connexions fantàstiques arreu del món. I es poden fer reunions de 40 minuts sense un compte de pagament. Omarchy embolcalla el client web de Zoom, i els enllaços de reunions de Zoom s'hi obriran directament.

Inicieu Zoom mitjançant el llançador d'aplicacions (`Super + Space`).

## Discord

[Discord](https://discord.com/) és on es reuneixen la majoria de comunitats de videojocs i de codi obert, inclosa [la d'Omarchy](https://discord.gg/tXFUdasqhY).

Inicieu Discord mitjançant el llançador d'aplicacions (`Super + Space`).

## Aplicacions de Microsoft

Seleccioneu _Instal·la > Servei > Microsoft_ per afegir Outlook, Word, Excel, PowerPoint, Teams i OneDrive com a aplicacions web. Cada aplicació té el seu propi llançador i s'obre directament, mitjançant els URL comercials de Microsoft 365 i el vostre perfil de navegador existent. S'obren a les mateixes finestres d'aplicació de navegador que les altres aplicacions web d'Omarchy; no instal·len el client separat de Teams for Linux.

Elimineu el paquet amb _Elimina > Serveis > Microsoft_, o elimineu aplicacions individuals amb _Elimina > Aplicació web_. També podeu instal·lar només les aplicacions que vulgueu mitjançant _Instal·la > Aplicació web_.

Per a un núvol governamental o sobirà, editeu l'URL a la línia `Exec=` del llançador corresponent a `~/.local/share/applications/`, com ara `Microsoft Teams.desktop`, amb l'URL que us hagi proporcionat la vostra organització. Escriviu qualsevol `%` literal en aquesta línia com a `%%`. Els canvis s'apliquen en el proper inici. Si torneu a executar l'instal·lador del paquet, substitueix els seus llançadors pels URL predeterminats.

Per mantenir separats els inicis de sessió de la feina, afegiu un directori de dades del navegador a la línia `Exec=` de cada llançador:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Substituïu el directori d'exemple per una ruta absoluta de la vostra elecció i utilitzeu la mateixa ruta per als sis llançadors per compartir els inicis de sessió de la feina entre ells. Les aplicacions web utilitzen el navegador compatible seleccionat d'Omarchy, i recorren a Chrome quan el navegador predeterminat no és compatible.
