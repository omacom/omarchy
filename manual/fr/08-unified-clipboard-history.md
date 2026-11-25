# Presse-papiers unifié et historique

Sous Linux, il faut habituellement `Ctrl + Shift + C/V` pour copier-coller dans le terminal et `Ctrl + C/V` pour le faire partout ailleurs. C'est difficile à adopter pour quiconque n'est pas né et n'a pas grandi sous Linux ! Le passage de super à ctrl l'est tout autant, si vous venez du Mac.

Omarchy s'attaque aux deux problèmes avec des raccourcis de presse-papiers unifiés qui fonctionnent (presque) partout. Les voici :

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Tout sélectionner |
| Super + C | Copier |
| Super + X | Couper |
| Super + V | Coller |
| Super + Ctrl + V | Historique du presse-papiers |

_Notez que la plupart des harnais d'agents utiliseront `Ctrl + V` pour coller des images, mais `Super + V` pour coller du texte._

Utilisez `Super + A`, puis `Super + C` pour tout copier dans un champ de texte actif ou dans une autre appli qui prend en charge `Ctrl + A`. Dans un terminal, `Ctrl + A` déplace le curseur au début de la ligne de commande au lieu d'en sélectionner le texte.

### Historique du presse-papiers

L'historique du presse-papiers est fourni par le shell Omarchy et fonctionne à la fois pour le texte et pour les images. Vous le déclenchez avec `Super + Ctrl + V` et vous sélectionnez votre entrée avec Entrée, ce qui la colle directement dans l'appli où vous étiez. Utilisez `Shift + Return` pour la copier seulement dans le presse-papiers, `Alt + Return` pour l'ouvrir, `Delete` pour la retirer de l'historique, et `Shift + Delete` pour effacer tout l'historique.

 ![clipboard-history](images/clipboard-history.webp)

Vous pouvez aussi rechercher dans l'historique simplement en commençant à taper :

 ![clipboard-history-search](images/clipboard-history-search.webp)
