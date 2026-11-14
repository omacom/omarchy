# Applications web

Vous pouvez ajouter vos propres applications web via _Installer > Application web_ dans le menu Omarchy (`Super + Space`). Il vous demandera le nom de l'application, l'URL de l'application et l'URL de l'icône, s'il ne peut pas la récupérer via le favicon. Vous pouvez obtenir de superbes icônes PNG pour de nombreuses applications web populaires sur [Dashboard Icons](https://dashboardicons.com).

Elles seront ensuite accessibles via le lanceur d'applications (`Super + Space`), et utiliseront la magnifique fenêtre d'application web sans cadre.

Si vous souhaitez supprimer une application web, allez simplement dans _Retirer > Application web_ dans le menu Omarchy.

Il est préférable de vous connecter à tous vos comptes à l'aide d'un navigateur classique avant d'utiliser les raccourcis des applications web. Le mince cadre d'encapsulation fonctionne mal avec 1password, il est donc simplement plus facile de vous connecter directement au préalable.

Tous les raccourcis clavier de ces applications web peuvent être modifiés dans `~/.config/hypr/bindings.lua`.

Lorsque vous êtes dans une application web, vous pouvez copier l'URL actuelle dans le presse-papiers à l'aide de `Shift + Alt + L`.

Par défaut, Omarchy fournit déjà un assortiment d'applications par défaut :

## HEY

[HEY](https://www.hey.com/) est un service de messagerie électronique et de calendrier qui constitue une excellente alternative pour les personnes fatiguées de Gmail, Outlook ou Apple Mail. Il est créé par [37signals](https://37signals.com/), là où Omarchy est né.

Vous pouvez lancer HEY Email à l'aide de `Super + Shift + E`, passer directement à la rédaction d'un nouvel e-mail à l'aide de `Super + Shift + Alt + E`, et lancer HEY Calendar à l'aide de `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) est un service de gestion de projet qui aide les petites équipes à avancer plus vite et à progresser davantage. Au lieu de rafistoler un méli-mélo de Trello, Slack, Asana, Notion ou je ne sais quoi, vous pouvez tout avoir au même endroit avec Basecamp. Il est créé par [37signals](https://37signals.com/), là où Omarchy est né.

Vous pouvez lancer Basecamp à l'aide du lanceur d'applications (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) est le chatbot IA le plus populaire au monde.

Vous pouvez lancer ChatGPT à l'aide de `Super + Shift + A`.

## Grok

[Grok](https://grok.com) est le chatbot de xAI.

Vous pouvez lancer Grok à l'aide de `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) est l'un des services de messagerie les plus populaires au monde, et la version web est une excellente option pour Linux.

Vous pouvez lancer WhatsApp à l'aide de `Super + Shift + Alt + G`.

## Applications Google

Google Messages, Google Photos, Google Maps et Google Contacts sont également inclus en tant qu'applications web.

Vous pouvez lancer Google Messages à l'aide de `Super + Shift + Ctrl + G`, Google Photos à l'aide de `Super + Shift + P`, et Google Maps à l'aide de `Super + Shift + S`. Google Contacts est disponible via le lanceur d'applications (`Super + Space`).

## X

X, c'est là où l'actualité éclate.

Vous pouvez lancer X à l'aide de `Super + Shift + X` et passer directement à la rédaction d'une nouvelle publication avec `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) est la plateforme vidéo la plus populaire au monde.

Vous pouvez lancer YouTube à l'aide de `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) est le système de visioconférence le plus populaire utilisé aux États-Unis. D'excellentes connexions à travers le monde. Et des réunions de 40 minutes peuvent être organisées sans compte payant. Omarchy encapsule le client web de Zoom, et les liens de réunion Zoom s'ouvriront directement dedans.

Vous lancez Zoom à l'aide du lanceur d'applications (`Super + Space`).

## Discord

[Discord](https://discord.com/) est l'endroit où se retrouvent la plupart des communautés de jeux vidéo et open source, y compris [celle d'Omarchy](https://discord.gg/tXFUdasqhY).

Vous lancez Discord à l'aide du lanceur d'applications (`Super + Space`).

## Applications Microsoft

Sélectionnez _Installer > Service > Microsoft_ pour ajouter Outlook, Word, Excel, PowerPoint, Teams et OneDrive en tant qu'applications web. Chaque application possède son propre lanceur et s'ouvre directement, en utilisant les URL commerciales de Microsoft 365 et votre profil de navigateur existant. Elles s'ouvrent dans les mêmes fenêtres d'application navigateur que les autres applications web d'Omarchy ; elles n'installent pas le client Teams for Linux séparé.

Retirez l'ensemble avec _Retirer > Service > Microsoft_, ou retirez des applications individuelles avec _Retirer > Application web_. Vous pouvez aussi installer uniquement les applications que vous voulez via _Installer > Application web_.

Pour un cloud gouvernemental ou souverain, modifiez l'URL sur la ligne `Exec=` dans le lanceur concerné sous `~/.local/share/applications/`, comme `Microsoft Teams.desktop`, en utilisant l'URL fournie par votre organisation. Écrivez tout `%` littéral sur cette ligne sous la forme `%%`. Les modifications s'appliquent au prochain lancement. Relancer l'installateur de l'ensemble remplace ses lanceurs par les URL par défaut.

Pour séparer les connexions professionnelles, ajoutez un répertoire de données de navigateur à la ligne `Exec=` de chaque lanceur :

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Remplacez le répertoire d'exemple par un chemin absolu de votre choix et utilisez le même chemin pour les six lanceurs afin de partager les connexions professionnelles entre eux. Les applications web utilisent le navigateur pris en charge sélectionné par Omarchy, et se rabattent sur Chrome lorsque le navigateur par défaut n'est pas pris en charge.
