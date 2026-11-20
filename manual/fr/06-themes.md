# Thèmes

Omarchy est livré avec vingt-trois magnifiques thèmes. Vous pouvez choisir entre eux via _Apparence > Thème_ dans le menu Omarchy (`Super + Space`) ou accéder directement au sélecteur de thème avec `Super + Ctrl + T`.

Chaque thème stylise le bureau, le terminal, neovim, l'écran d'activité (btop), votre navigateur (Chrome, Chromium, Edge ou Brave), et l'ensemble de l'interface Omarchy : barre supérieure, menu, notifications, OSD et écran de verrouillage. (Pour Obsidian, vous devez sélectionner manuellement le thème Omarchy via _Apparence > Thèmes_ dans l'application).

Les thèmes disposent d'un ensemble d'images d'arrière-plan parmi lesquelles vous pouvez choisir avec `Super + Ctrl + W`.

Vous trouverez encore plus de thèmes sur [la page des thèmes supplémentaires](https://omarchy.org/themes/) ou vous pouvez même [créer votre propre thème](43-making-your-own-theme.md).

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

- _Papercraft_ est le jeu par défaut : tout ce qui est installé, dessiné dans un seul style. Les applications connues par leur logo, comme Chrome, HEY ou YouTube, conservent sa forme et adoptent les couleurs du thème.
- _Arcade_ dessine les mêmes applications en pixel art 8 bits, comme le ferait une vieille console de jeu.
- _Original_ affiche chaque application avec l'icône que son créateur lui a donnée.

Vous pouvez installer un jeu d'icônes créé par quelqu'un d'autre avec _Installer > Style > Icônes_ (ou `omarchy icons install <git url>`), et le supprimer à nouveau sous _Supprimer > Icônes_. _Mettre à jour > Icônes supplémentaires_ récupère la dernière version des jeux que vous avez installés.

Pour créer le vôtre, placez vos icônes dans `~/.config/omarchy/icons/<name>/`, un fichier par application, nommé d'après la ligne `Icon=` du fichier `.desktop` de l'application. Un fichier se terminant par `.svg` est affiché tel quel. Un fichier se terminant par `.svg.tpl` est dessiné aux couleurs du thème : écrivez `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ou `{{ icon_shadow }}` là où va une couleur. Le jeu par défaut dans `/usr/share/omarchy/icons/papercraft/` est un bon point de départ. Ajoutez un `preview.png` pour afficher votre jeu dans le sélecteur ; sans cela, Omarchy dessine un aperçu à partir de vos icônes. Pour changer une seule icône du jeu par défaut, placez votre version dans `~/.config/omarchy/icons/papercraft/`.

### Déverrouillages

Les thèmes peuvent aussi avoir un design de déverrouillage personnalisé, utilisé pour le processus de déchiffrement au démarrage. Vous pouvez en sélectionner un sous _Apparence > Déverrouillage_. Ils ressemblent à ceci :

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![last-horizon](../themes/last-horizon/preview-unlock.png)
_Last Horizon_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![lupine](../themes/lupine/preview-unlock.png)
_Lupine_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![solitude](../themes/solitude/preview-unlock.png)
_Solitude_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
