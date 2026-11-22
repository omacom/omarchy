# Applications web

Vous pouvez ajouter vos propres applications web via _Install > Web App_ dans le menu Omarchy (`Super + Space`). Il vous demandera le nom de l'application, l'URL de l'application et l'URL de l'icône, s'il ne peut pas la récupérer via le favicon. Vous trouverez de superbes icônes PNG pour de nombreuses applications web populaires sur [Dashboard Icons](https://dashboardicons.com).

Elles seront ensuite accessibles via le lanceur d'applications (`Super + Space`), et utiliseront la magnifique fenêtre d'application web sans cadre.

Si vous souhaitez supprimer une application web, allez simplement dans _Remove > Web App_ dans le menu Omarchy.

Le mieux est de vous connecter à tous vos comptes dans un navigateur classique avant d'utiliser les raccourcis des applications web. Le mince cadre d'encapsulation fonctionne mal avec 1password, donc c'est tout simplement plus facile d'être déjà connecté directement.

Tous les raccourcis clavier de ces applications web peuvent être modifiés dans `~/.config/hypr/bindings.lua`.

Quand vous êtes dans une application web, vous pouvez copier l'URL actuelle dans le presse-papiers avec `Shift + Alt + L`.

Par défaut, Omarchy est déjà livré avec un assortiment d'applications par défaut :

## HEY

[HEY](https://www.hey.com/) est un service d'e-mail et de calendrier qui constitue une excellente alternative pour les personnes lassées de Gmail, Outlook ou Apple Mail. Il est créé par [37signals](https://37signals.com/), là où Omarchy a vu le jour.

Vous pouvez lancer HEY Email avec `Super + Shift + E`, passer directement à la rédaction d'un nouvel e-mail avec `Super + Shift + Alt + E`, et lancer HEY Calendar avec `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) est un service de gestion de projet qui aide les petites équipes à avancer plus vite et à progresser davantage. Au lieu de rafistoler un bric-à-brac de Trello, Slack, Asana, Notion ou je ne sais quoi, vous pouvez tout avoir au même endroit avec Basecamp. Il est créé par [37signals](https://37signals.com/), là où Omarchy a vu le jour.

Vous pouvez lancer Basecamp via le lanceur d'applications (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) est le chatbot IA le plus populaire au monde.

Vous pouvez lancer ChatGPT avec `Super + Shift + A`.

## Grok

[Grok](https://grok.com) est le chatbot de xAI.

Vous pouvez lancer Grok avec `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) est l'un des services de messagerie les plus populaires au monde, et la version web est une excellente option pour Linux.

Vous pouvez lancer WhatsApp avec `Super + Shift + Alt + G`. Il s'ouvre avec l'extension WhatsApp Slim d'Omarchy, qui lui fait suivre votre thème et replie la liste des discussions quand la fenêtre est étroite.

## Applications Google

Google Messages, Google Photos, Google Maps et Google Contacts sont également inclus en tant qu'applications web.

Vous pouvez lancer Google Messages avec `Super + Shift + Ctrl + G`, Google Photos avec `Super + Shift + P`, et Google Maps avec `Super + Shift + S`. Google Contacts est disponible via le lanceur d'applications (`Super + Space`).

## X

C'est sur X que l'actualité tombe.

Vous pouvez lancer X avec `Super + Shift + X` et passer directement à la rédaction d'un nouveau message avec `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) est la plateforme vidéo la plus populaire au monde.

Vous pouvez lancer YouTube avec `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) est inclus en tant qu'application web sur les nouvelles installations.

Vous lancez Netflix via le lanceur d'applications (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) est le système de visioconférence le plus populaire aux États-Unis. D'excellentes connexions partout dans le monde. Et des réunions de 40 minutes peuvent être organisées sans compte payant. Omarchy encapsule le client web de Zoom, et les liens de réunion zoom s'ouvriront directement dedans.

Vous lancez Zoom via le lanceur d'applications (`Super + Space`).

## Discord

[Discord](https://discord.com/) est l'endroit où se retrouvent la plupart des communautés de jeux et d'open source, y compris [celle d'Omarchy](https://discord.gg/tXFUdasqhY).

Vous lancez Discord via le lanceur d'applications (`Super + Space`).

## Applications Microsoft

Sélectionnez _Install > Service > Microsoft_ pour ajouter Outlook, Word, Excel, PowerPoint, Teams et OneDrive en tant qu'applications web. Chaque application a son propre lanceur et s'ouvre directement, en utilisant les URL commerciales de Microsoft 365 et votre profil de navigateur existant. Elles s'ouvrent dans les mêmes fenêtres d'application de navigateur que les autres applications web d'Omarchy ; elles n'installent pas le client Teams for Linux séparé.

Supprimez l'ensemble avec _Remove > Services > Microsoft_, ou supprimez des applications individuelles avec _Remove > Web App_. Vous pouvez aussi installer uniquement les applications que vous voulez via _Install > Web App_.

Pour un cloud gouvernemental ou souverain, modifiez l'URL sur la ligne `Exec=` dans le lanceur concerné sous `~/.local/share/applications/`, par exemple `Microsoft Teams.desktop`, en utilisant l'URL fournie par votre organisation. Écrivez tout `%` littéral sur cette ligne sous la forme `%%`. Les modifications s'appliquent au prochain lancement. Relancer l'installateur de l'ensemble remplace ses lanceurs par les URL par défaut.

Pour garder les connexions professionnelles séparées, ajoutez un répertoire de données de navigateur à la ligne `Exec=` de chaque lanceur :

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Remplacez le répertoire d'exemple par un chemin absolu de votre choix et utilisez le même chemin pour les six lanceurs afin de partager les connexions professionnelles entre eux. Les applications web utilisent le navigateur pris en charge sélectionné par Omarchy, et se rabattent sur Chrome quand le navigateur par défaut n'est pas pris en charge.
