# Navigateurs

Omarchy est livré avec [Chromium](https://www.chromium.org/) comme navigateur par défaut. C'est la version open source simple, thématisée pour correspondre au reste de votre système, et c'est ce que `Super + Shift + Return` ouvre et ce dans quoi chaque [appli web](25-web-apps.md) s'exécute.

Si Chromium n'est pas à votre goût, vous n'êtes pas coincé avec lui. Sous _Installer > Navigateur_ dans le menu Omarchy, vous trouverez Chrome, Edge, Brave, Brave Origin, Firefox et [Zen](https://zen-browser.app/). Choisissez-en un et Omarchy l'installe, configure son répertoire de politiques et lui applique votre thème actuel.

## En faire le navigateur par défaut

Installer un navigateur ne le promeut pas. Une fois qu'il est sur la machine, allez dans _Configuration > Par défaut > Navigateur_ et choisissez-le — le menu ne liste que les navigateurs que vous avez effectivement installés, et marque celui par défaut actuel d'une coche.

Depuis le terminal, c'est :

```bash
omarchy default browser firefox
```

Lancez-la sans argument et elle vous dit lequel est le navigateur par défaut actuel. Cela définit le gestionnaire XDG, donc ce ne sont pas seulement les raccourcis d'Omarchy qui suivent — tout ce qui ouvre un lien, d'une appli de discussion à une commande de terminal, va vers le navigateur que vous avez choisi.

## Copier l'URL et Télécharger la vidéo

Les navigateurs de la famille Chromium (Chromium lui-même, Chrome, Edge et Brave) sont livrés avec deux extensions Omarchy qui sortent du navigateur pour aller dans le reste de votre système.

**Copy URL** place l'adresse de l'onglet courant dans votre presse-papiers avec `Alt + Shift + L`. C'est plus rapide que de cliquer dans la barre d'adresse et de copier, et comme cela passe par le presse-papiers du système plutôt que par celui du navigateur, vous obtenez une notification Omarchy qui le confirme et l'URL est immédiatement disponible dans l'[historique du presse-papiers](08-unified-clipboard-history.md) et dans toutes les autres applis. Il y a aussi un bouton dans la barre d'outils, si vous préférez cliquer.

**Download Video** récupère la vidéo en cours de lecture sur la page que vous regardez avec `Alt + Shift + D`. Elle transmet l'URL à [yt-dlp](https://github.com/yt-dlp/yt-dlp), donc elle fonctionne sur bien plus que YouTube, et le téléchargement atterrit dans `~/Videos`. La progression s'affiche dans le même affichage à l'écran que le volume et la luminosité utilisent, en se mettant à jour sur place plutôt qu'en empilant les notifications. Définissez `OMARCHY_YTDLP_DIR` si vous préférez que les fichiers aillent ailleurs — voir la [FAQ](46-faq.md) pour savoir où placer les variables d'environnement.

Les deux extensions parlent à Omarchy via un petit hôte de messagerie native, qui est installé pour vous avec le navigateur. C'est la pièce qui permet à la vidéo d'une page web de finir dans votre répertoire personnel et à une URL de finir dans votre gestionnaire de presse-papiers, ce qu'une extension normale ne peut pas faire toute seule.

Elles sont réservées à la famille Chromium. Firefox et Zen ne les ont pas.

## Firefox et Zen

Firefox et Zen font partie d'une famille différente, donc ils reçoivent un traitement différent : Omarchy installe un fichier de politiques pour des valeurs par défaut sensées et les bascule en mode Wayland natif, ce que vous voulez pour la mise à l'échelle fractionnaire et un défilement fluide au pavé tactile.

Ils n'ont pas les extensions Chromium ci-dessus, et ils ne sont pas thématisés par Omarchy, donc ces parties de l'expérience sont à vous de configurer.

## En supprimer un à nouveau

Tout ce que vous avez installé ici peut être retiré sous _Supprimer > Navigateur_. Chromium n'est pas dans cette liste — il fait partie du système de base.
