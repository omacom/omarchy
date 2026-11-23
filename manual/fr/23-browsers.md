# Navigateurs

Omarchy est livré avec [Google Chrome](https://www.google.com/chrome/) comme navigateur par défaut. Son thème est assorti au reste de votre système, et c'est lui que `Super + Shift + Return` (ou `Super + Shift + B`) ouvre, avec `Super + Shift + Alt + B` pour une fenêtre privée, et celui à l'intérieur duquel s'exécute chaque [application web](25-web-apps.md). Il s'ouvre directement sur une fenêtre de navigateur : il n'y a ni écran de bienvenue ni invite de connexion, les statistiques d'utilisation et les rapports de plantage ne sont pas envoyés à Google, et les invites de confidentialité publicitaire sont désactivées. Vous pouvez toujours vous connecter à votre compte Google à partir du bouton de profil chaque fois que vous voulez la synchronisation.

Si Chrome n'est pas à votre goût, vous n'êtes pas coincé avec. Dans _Installer > Navigateur_ du menu Omarchy, vous trouverez [Chromium](https://www.chromium.org/) (la version open source simple à partir de laquelle Chrome est fabriqué), Edge, Brave, Brave Origin, Firefox et [Zen](https://zen-browser.app/) (Edge uniquement sur les machines x86). Choisissez-en un et Omarchy l'installe, configure son répertoire de politiques et lui applique votre thème actuel.

## En définir un par défaut

Installer un navigateur ne le promeut pas. Pour changer, allez dans _Configuration > Valeurs par défaut > Navigateur_ et choisissez-en un. Le navigateur par défaut actuel est marqué d'une coche, et choisir un navigateur que vous n'avez pas encore l'installe d'abord.

Depuis le terminal, c'est :

```bash
omarchy default browser firefox
```

Exécutez-la sans argument et elle vous indique le navigateur par défaut actuel. Cela définit le gestionnaire XDG, donc ce ne sont pas seulement les raccourcis clavier d'Omarchy qui suivent — tout ce qui ouvre un lien, d'une application de discussion à une commande de terminal, va vers le navigateur que vous avez choisi.

## Copy URL et Download Video

Les navigateurs de la famille Chromium (Chromium lui-même, Chrome, Edge, Brave et Brave Origin) sont livrés avec trois extensions Omarchy : deux qui sortent du navigateur pour atteindre le reste de votre système, et une qui met de l'ordre dans WhatsApp.

**Copy URL** met l'adresse de l'onglet actuel dans votre presse-papiers avec `Alt + Shift + L`. C'est plus rapide que de cliquer dans la barre d'adresse et de copier, et comme cela passe par le presse-papiers du système plutôt que par celui du navigateur, vous recevez une notification Omarchy qui le confirme et l'URL est immédiatement disponible dans l'[historique unifié du presse-papiers](08-unified-clipboard-history.md) et dans toutes les autres applications. Il y a aussi un bouton dans la barre d'outils, si vous préférez cliquer.

**Download Video** récupère la vidéo en cours de lecture sur la page que vous regardez avec `Alt + Shift + D`. Elle transmet l'URL à [yt-dlp](https://github.com/yt-dlp/yt-dlp), donc cela fonctionne sur bien plus que YouTube, et le téléchargement arrive dans `~/Videos`. La progression s'affiche dans le même affichage à l'écran que celui utilisé pour le volume et la luminosité, avec une mise à jour sur place plutôt qu'un empilement de notifications. Définissez `OMARCHY_YTDLP_DIR` si vous préférez que les fichiers aillent ailleurs — consultez la [FAQ](46-faq.md) pour savoir où mettre les variables d'environnement.

Les deux extensions communiquent avec Omarchy via un petit hôte de messagerie natif, qui est installé pour vous en même temps que le navigateur. C'est la pièce qui permet à la vidéo d'une page web de finir dans votre répertoire personnel et à une URL de finir dans votre gestionnaire de presse-papiers, ce qu'une extension normale ne peut pas faire toute seule.

**WhatsApp Slim** fait suivre à WhatsApp Web votre thème système et réduit sa liste de discussions quand la fenêtre est étroite.

Elles sont réservées à la famille Chromium. Firefox et Zen ne les reçoivent pas.

## Firefox et Zen

Firefox et Zen appartiennent à une famille différente, ils reçoivent donc un traitement différent : Omarchy installe un fichier de politiques pour des valeurs par défaut sensées et les bascule en mode Wayland natif, ce que vous voulez pour la mise à l'échelle fractionnaire et un défilement fluide au pavé tactile.

Ils ne reçoivent pas les extensions Chromium ci-dessus, et ils ne sont pas habillés par Omarchy, donc ces parties de l'expérience vous appartiennent à configurer.

## En supprimer un

N'importe lequel de ces navigateurs, Chrome inclus, peut être retiré sous _Supprimer > Navigateur_. Les liens iront ensuite vers Chrome ou Chromium si l'autre est toujours installé.
