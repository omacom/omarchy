# Thèmes

Omarchy est livré avec vingt-trois magnifiques thèmes. Vous pouvez choisir entre eux via _Apparence > Thème_ dans le menu Omarchy (`Super + Space`) ou accéder directement au sélecteur de thème avec `Super + Ctrl + T`.

Chaque thème stylise le bureau, le terminal, neovim, l'écran d'activité (btop), votre navigateur (Chrome, Chromium, Edge ou Brave), et l'ensemble de l'interface Omarchy : barre supérieure, menu, notifications, OSD et écran de verrouillage. (Pour Obsidian, vous devez sélectionner manuellement le thème Omarchy via _Apparence > Thèmes_ dans l'application).

Les thèmes disposent d'un ensemble d'images d'arrière-plan parmi lesquelles vous pouvez choisir avec `Super + Ctrl + W`.

Vous pouvez trouver encore plus de thèmes sur [la page des thèmes supplémentaires](https://omarchy.org/themes/) ou même [créer votre propre thème](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Icônes des applications

Les icônes du lanceur d'applications et du dock sont dessinées aux couleurs de votre thème, elles changent donc avec lui. Elles proviennent d'un jeu d'icônes, que vous choisissez séparément du thème sous _Apparence > Icônes_, à partir d'aperçus de chaque jeu, de la même façon que vous choisissez un thème :

- _Papercraft_ est le jeu par défaut : tout ce qui est installé, dessiné dans un seul style. Les applications connues par leur logo, comme Chrome, HEY ou YouTube, conservent leur forme et adoptent les couleurs du thème.
- _Arcade_ dessine les mêmes applications en pixel art 8-bit, comme le ferait une vieille console de jeu.
- _Original_ affiche chaque application avec l'icône que lui a donnée son créateur.

Vous pouvez installer un jeu d'icônes créé par quelqu'un d'autre avec _Installer > Style > Icônes_ (ou `omarchy icons install <git url>`), et le supprimer à nouveau sous _Supprimer > Icônes_. _Mise à jour > Icônes supplémentaires_ récupère la dernière version des jeux que vous avez installés.

Pour créer le vôtre, placez vos icônes dans `~/.config/omarchy/icons/<name>/`, un fichier par application, nommé d'après la ligne `Icon=` du fichier `.desktop` de l'application. Un fichier se terminant par `.svg` est affiché tel quel. Un fichier se terminant par `.svg.tpl` est dessiné aux couleurs du thème : écrivez `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ou `{{ icon_shadow }}` là où va une couleur. Le jeu par défaut dans `/usr/share/omarchy/icons/papercraft/` est un bon point de départ. Ajoutez un `preview.png` pour afficher votre jeu dans le sélecteur ; sans, Omarchy dessine un aperçu à partir de vos icônes. Pour modifier une seule icône du jeu par défaut, placez votre version dans `~/.config/omarchy/icons/papercraft/`.

### Démarrage et connexion

L'écran qui demande le mot de passe de votre disque au démarrage de l'ordinateur, et l'écran de connexion, suivent eux aussi le thème. Chaque fois que vous changez de thème, ils récupèrent son arrière-plan, son texte, sa couleur d'accentuation et ses couleurs rouges, il n'y a donc pas de design de déverrouillage séparé à choisir. Sur les Mac Apple Silicon, l'écran du mot de passe du disque conserve l'apparence par défaut d'Omarchy quel que soit le thème.
