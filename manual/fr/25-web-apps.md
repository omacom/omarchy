# Applis web

Vous pouvez ajouter vos propres applis web en utilisant _Installer > Appli web_ dans le menu Omarchy (`Super + Space`). Il vous demandera le nom de l'appli, l'URL de l'appli et l'URL de l'icône, s'il ne peut pas la récupérer via le favicon. Vous pouvez obtenir de superbes icônes PNG pour de nombreuses applis web populaires sur [Dashboard Icons](https://dashboardicons.com).

Elles seront ensuite accessibles via le lanceur d'applis (`Super + Space`), et utiliseront la belle fenêtre d'appli web sans cadre.

Si vous souhaitez supprimer une appli web, allez simplement dans _Supprimer > Appli web_ dans le menu Omarchy.

Il vaut mieux vous connecter à tous vos comptes avec un navigateur classique avant d'utiliser les raccourcis d'applis web. Le cadre d'enveloppe mince ne fonctionne pas bien avec 1password, donc il est plus facile d'être déjà connecté directement au préalable.

Tous les raccourcis clavier pour ces applis web peuvent être changés dans `~/.config/hypr/bindings.lua`.

Quand vous êtes dans une appli web, vous pouvez copier l'URL actuelle dans le presse-papiers avec `Shift + Alt + L`.

Par défaut, Omarchy est déjà livré avec un assortiment d'applis par défaut :

## HEY

[HEY](https://www.hey.com/) est un service d'e-mail et de calendrier qui constitue une excellente alternative pour les personnes fatiguées de Gmail, Outlook ou Apple Mail. Il est fait par [37signals](https://37signals.com/) où Omarchy est né.

Vous pouvez démarrer HEY Email avec `Super + Shift + E`, passer directement à la rédaction d'un nouvel e-mail avec `Super + Shift + Alt + E`, et démarrer HEY Calendar avec `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) est un service de gestion de projet qui aide les petites équipes à avancer plus vite et à progresser davantage. Au lieu de bricoler un assemblage de Trello, Slack, Asana, Notion ou autres, vous pouvez tout avoir au même endroit avec Basecamp. Il est fait par [37signals](https://37signals.com/) où Omarchy est né.

Vous pouvez démarrer Basecamp en utilisant le lanceur d'applications (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) est le chatbot IA le plus populaire au monde.

Vous pouvez démarrer ChatGPT avec `Super + Shift + A`.

## Grok

[Grok](https://grok.com) est le chatbot de xAI.

Vous pouvez démarrer Grok avec `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) est l'un des services de messagerie les plus populaires au monde, et la version web est une excellente option pour Linux.

Vous pouvez démarrer WhatsApp avec `Super + Shift + Alt + G`.

## Applis Google

Google Messages, Google Photos, Google Maps et Google Contacts sont tous inclus aussi comme applis web.

Vous pouvez démarrer Google Messages avec `Super + Shift + Ctrl + G`, Google Photos avec `Super + Shift + P`, et Google Maps avec `Super + Shift + S`. Google Contacts est disponible via le lanceur d'applis (`Super + Space`).

## X

X est l'endroit où les nouvelles éclatent.

Vous pouvez démarrer X avec `Super + Shift + X` et aller directement écrire un nouveau message avec `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) est la plateforme vidéo la plus populaire au monde.

Vous pouvez démarrer YouTube avec `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) est le système de discussion vidéo le plus populaire aux États-Unis. D'excellentes connexions dans le monde entier. Et des réunions de 40 minutes peuvent se tenir sans compte payant. Omarchy enveloppe le client web de Zoom, et les liens de réunion zoom s'ouvriront directement dedans.

Vous démarrez Zoom en utilisant le lanceur d'applications (`Super + Space`).

## Discord

[Discord](https://discord.com/) est l'endroit où la plupart des communautés de jeux et d'open source se retrouvent, y compris [celle d'Omarchy](https://discord.gg/tXFUdasqhY).

Vous démarrez Discord en utilisant le lanceur d'applications (`Super + Space`).

## Applis Microsoft

Sélectionnez _Installer > Service > Microsoft_ pour ajouter Outlook, Word, Excel, PowerPoint, Teams et OneDrive comme applis web. Chaque appli a son propre lanceur et s'ouvre directement, en utilisant les URL commerciales de Microsoft 365 et votre profil de navigateur existant. Elles s'ouvrent dans les mêmes fenêtres d'appli de navigateur que les autres applis web d'Omarchy ; elles n'installent pas le client Teams for Linux séparé.

Supprimez le bundle avec _Supprimer > Service > Microsoft_, ou supprimez des applis individuelles avec _Supprimer > Appli web_. Vous pouvez aussi installer juste les applis que vous voulez via _Installer > Appli web_.

Pour un cloud gouvernemental ou souverain, modifiez l'URL sur la ligne `Exec=` du lanceur concerné sous `~/.local/share/applications/`, comme `Microsoft Teams.desktop`, en utilisant l'URL fournie par votre organisation. Écrivez tout `%` littéral dans cette ligne sous la forme `%%`. Les changements s'appliquent au prochain lancement. Relancer l'installateur du bundle remplace ses lanceurs par les URL par défaut.

Pour garder les connexions professionnelles séparées, ajoutez un répertoire de données de navigateur à la ligne `Exec=` de chaque lanceur :

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Remplacez le répertoire d'exemple par un chemin absolu de votre choix et utilisez le même chemin pour les six lanceurs afin de partager les connexions professionnelles entre eux. Les applis web utilisent le navigateur pris en charge sélectionné par Omarchy, avec Chromium en repli quand le navigateur par défaut n'est pas pris en charge.
