# Navigateurs

Omarchy est livré avec [Google Chrome](https://www.google.com/chrome/) comme navigateur par défaut. Il est assorti au thème du reste de votre système, et c'est lui que `Super + Shift + Return` (ou `Super + Shift + B`) ouvre, avec `Super + Shift + Alt + B` pour une fenêtre privée, et celui dans lequel chaque [application web](25-web-apps.md) s'exécute. Il s'ouvre directement sur une fenêtre de navigateur : il n'y a ni écran de bienvenue ni invite de connexion, les statistiques d'utilisation et les rapports de plantage ne sont pas envoyés à Google, et les invites relatives à la confidentialité publicitaire sont désactivées. Vous pouvez toujours vous connecter à votre compte Google depuis le bouton de profil quand vous voulez la synchronisation.

Si Chrome n'est pas à votre goût, vous n'êtes pas coincé avec. Sous _Installer > Navigateur_ dans le menu Omarchy, vous trouverez [Chromium](https://www.chromium.org/) (la version open source simple à partir de laquelle Chrome est fabriqué), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/), et [Ladybird](https://ladybird.org/) (Edge uniquement sur les machines x86). Choisissez-en un et Omarchy l'installe, configure son répertoire de politiques et lui applique votre thème actuel.

## En définir un par défaut

Installer un navigateur ne le promeut pas. Pour changer, allez dans _Configuration > Par défaut > Navigateur_ et choisissez-en un. Le navigateur par défaut actuel est marqué d'une coche, et choisir un navigateur que vous n'avez pas encore l'installe d'abord.

Depuis le terminal, c'est :

```bash
omarchy default browser firefox
```

Exécutez-la sans argument et elle vous indique le navigateur par défaut actuel. Cela définit le gestionnaire XDG, donc ce ne sont pas seulement les raccourcis clavier d'Omarchy qui suivent — tout ce qui ouvre un lien, d'une application de discussion à une commande dans le terminal, va vers le navigateur que vous avez choisi.

## Copy URL et Download Video

Les navigateurs de la famille Chromium (Chromium lui-même, Chrome, Edge, Brave et Brave Origin) sont livrés avec trois extensions Omarchy : deux qui sortent du navigateur pour atteindre le reste de votre système, et une qui met de l'ordre dans WhatsApp.

**Copy URL** met l'adresse de l'onglet actuel dans votre presse-papiers avec `Alt + Shift + L`. C'est plus rapide que de cliquer dans la barre d'adresse et de copier, et comme cela passe par le presse-papiers du système plutôt que par celui du navigateur, vous recevez une notification Omarchy qui le confirme et l'URL est immédiatement disponible dans [l'historique unifié du presse-papiers](08-unified-clipboard-history.md) et dans toutes les autres applications. Il y a aussi un bouton dans la barre d'outils, si vous préférez cliquer.

**Download Video** récupère la vidéo en cours de lecture sur la page que vous regardez avec `Alt + Shift + D`. Elle transmet l'URL à [yt-dlp](https://github.com/yt-dlp/yt-dlp), donc cela fonctionne sur bien plus que YouTube, et le téléchargement arrive dans `~/Videos`. La progression s'affiche dans le même affichage à l'écran que celui utilisé pour le volume et la luminosité, en se mettant à jour sur place plutôt qu'en empilant les notifications. Définissez `OMARCHY_YTDLP_DIR` si vous préférez que les fichiers aillent ailleurs — voir la [FAQ](46-faq.md) pour savoir où mettre les variables d'environnement.

Les deux extensions communiquent avec Omarchy via un petit hôte de messagerie natif, qui est installé pour vous en même temps que le navigateur. C'est l'élément qui permet à la vidéo d'une page web de se retrouver dans votre répertoire personnel et à une URL de se retrouver dans votre gestionnaire de presse-papiers, ce qu'une extension normale ne peut pas faire toute seule.

**WhatsApp Slim** fait suivre à WhatsApp Web votre thème système et réduit sa liste de discussions quand la fenêtre est étroite.

Ces extensions sont réservées à la famille Chromium. Firefox et Zen n'y ont pas droit.

## Firefox et Zen

Firefox et Zen appartiennent à une autre famille, ils reçoivent donc un traitement différent : Omarchy installe un fichier de politiques avec des réglages par défaut sensés et les bascule en mode Wayland natif, ce que vous voulez pour la mise à l'échelle fractionnaire et un défilement fluide au pavé tactile.

Ils ne reçoivent pas les extensions Chromium ci-dessus, et ils ne sont pas assortis au thème par Omarchy, donc ces parties de l'expérience sont à configurer vous-même.

## Ladybird

Ladybird est un navigateur écrit à partir de zéro, avec son propre moteur plutôt que celui de Chromium ou de Firefox. Il est encore en alpha, attendez-vous donc à des sites qui ne fonctionnent pas encore, et Omarchy l'installe tel quel : pas d'extensions, pas de thème, pas de politiques. Il n'a pas non plus de fenêtre privée, donc `Super + Shift + Alt + B` l'ouvre avec un profil temporaire qui est supprimé quand vous le fermez. Les [applications web](25-web-apps.md) continuent de s'exécuter dans Chrome ou Chromium.

## En supprimer un

N'importe lequel de ces navigateurs, Chrome inclus, peut être retiré sous _Supprimer > Navigateur_. Les liens iront alors vers Chrome ou Chromium si l'autre est toujours installé.
