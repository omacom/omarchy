# Presse-papiers unifié & historique

D'habitude sous Linux, il faut `Ctrl + Shift + C/V` pour copier-coller dans le terminal et `Ctrl + C/V` pour le faire partout ailleurs. C'est difficile à adopter pour quiconque n'est pas né et n'a pas grandi sous Linux ! Il en va de même pour le passage de super à ctrl, si vous venez du Mac.

Omarchy s'attaque à ces deux problèmes avec des raccourcis de presse-papiers unifiés qui fonctionnent (presque) partout. Les voici :

| Raccourci | Commande |
| ------- | ----------- |
| Super + A | Tout sélectionner |
| Super + C | Copier |
| Super + X | Couper |
| Super + V | Coller |
| Super + Ctrl + V | Historique du presse-papiers |

_Notez que la plupart des harnais d'agents utiliseront `Ctrl + V` pour coller des images, mais `Super + V` pour coller du texte._

Utilisez `Super + A`, puis `Super + C` pour tout copier dans un champ de texte actif ou une autre application qui prend en charge `Ctrl + A`. Dans un terminal, `Ctrl + A` déplace le curseur au début de la ligne de commande au lieu d'en sélectionner le texte.

### Historique du presse-papiers

L'historique du presse-papiers est fourni par le shell Omarchy et fonctionne pour le texte comme pour les images. Vous l'ouvrez avec `Super + Ctrl + V`, vous sélectionnez votre entrée avec Entrée, et elle sera alors placée dans le presse-papiers, prête à être collée avec `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Vous pouvez aussi rechercher dans l'historique en commençant simplement à taper :

 ![clipboard-history-search](images/clipboard-history-search.webp)
