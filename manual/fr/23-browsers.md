# Navigateurs

Omarchy est livré avec [Google Chrome](https://www.google.com/chrome/) comme navigateur par défaut. Il est assorti au reste de votre système, et c'est lui que `Super + Shift + Return` ouvre et dans lequel tourne chaque [application web](25-web-apps.md). Il s'ouvre directement sur une fenêtre de navigateur : il n'y a ni écran de bienvenue ni invite de connexion, les statistiques d'utilisation et les rapports de plantage ne sont pas envoyés à Google, et les invites relatives à la confidentialité publicitaire sont désactivées. Vous pouvez toujours vous connecter à votre compte Google depuis le bouton de profil quand vous voulez la synchronisation.

Si Chrome n'est pas à votre goût, vous n'êtes pas coincé avec. Sous _Installer > Navigateur_ dans le menu Omarchy, vous trouverez [Chromium](https://www.chromium.org/) (la version open source brute à partir de laquelle Chrome est fabriqué), Edge, Brave, Brave Origin, Firefox et [Zen](https://zen-browser.app/). Choisissez-en un et Omarchy l'installe, configure son répertoire de politiques et lui applique votre thème actuel.

## En définir un par défaut

Installer un navigateur ne le promeut pas. Une fois qu'il est sur la machine, allez dans _Configuration > Valeurs par défaut > Navigateur_ et choisissez-le — le menu ne liste que les navigateurs que vous avez réellement installés, et marque le navigateur par défaut actuel d'une coche.

Depuis le terminal, c'est :

```bash
omarchy default browser firefox
```

Exécutez-la sans argument et elle vous indique le navigateur par défaut actuel. Cela définit le gestionnaire XDG, donc ce ne sont pas seulement les raccourcis clavier d'Omarchy qui suivent — tout ce qui ouvre un lien, d'une application de discussion à une commande dans le terminal, passe par le navigateur que vous avez choisi.

## Copy URL et Download Video

Les navigateurs de la famille Chromium (Chromium lui-même, Chrome, Edge et Brave) sont livrés avec deux extensions Omarchy qui sortent du navigateur pour atteindre le reste de votre système.

**Copy URL** place l'adresse de l'onglet actuel dans votre presse-papiers avec `Alt + Shift + L`. C'est plus rapide que de cliquer dans la barre d'adresse et de copier, et comme cela passe par le presse-papiers du système plutôt que par celui du navigateur, vous recevez une notification Omarchy qui le confirme et l'URL est immédiatement disponible dans l'[historique du presse-papiers](08-unified-clipboard-history.md) et dans toutes les autres applications. Il y a aussi un bouton dans la barre d'outils, si vous préférez cliquer.

**Download Video** récupère la vidéo en cours de lecture sur la page que vous regardez avec `Alt + Shift + D`. Il transmet l'URL à [yt-dlp](https://github.com/yt-dlp/yt-dlp), donc cela fonctionne sur bien plus que YouTube, et le téléchargement arrive dans `~/Videos`. La progression s'affiche dans le même affichage à l'écran que celui utilisé pour le volume et la luminosité, avec une mise à jour sur place plutôt qu'un empilement de notifications. Définissez `OMARCHY_YTDLP_DIR` si vous préférez que les fichiers aillent ailleurs — voir la [FAQ](46-faq.md) pour savoir où placer les variables d'environnement.

Les deux extensions communiquent avec Omarchy via un petit hôte de messagerie natif, qui est installé pour vous en même temps que le navigateur. C'est la pièce qui permet à la vidéo d'une page web de finir dans votre répertoire personnel et à une URL de finir dans votre gestionnaire de presse-papiers, ce qu'une extension normale ne peut pas faire toute seule.

Elles sont réservées à la famille Chromium. Firefox et Zen ne les reçoivent pas.

## Firefox et Zen

Firefox et Zen appartiennent à une autre famille, ils reçoivent donc un traitement différent : Omarchy installe un fichier de politiques pour des valeurs par défaut sensées et les bascule en mode Wayland natif, ce que vous voulez pour la mise à l'échelle fractionnaire et un défilement fluide au pavé tactile.

Ils ne reçoivent pas les extensions Chromium ci-dessus, et ils ne sont pas assortis au thème par Omarchy, donc ces parties de l'expérience sont à vous de configurer.

## En supprimer un à nouveau

N'importe lequel de ces navigateurs, Chrome inclus, peut être retiré sous _Supprimer > Navigateur_. Les liens iront ensuite vers Chrome ou Chromium si l'autre est toujours installé.
