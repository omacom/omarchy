# Presse-papiers unifié et historique

Habituellement sous Linux, vous avez besoin de `Ctrl + Shift + C/V` pour copier-coller dans le terminal et de `Ctrl + C/V` pour le faire partout ailleurs. C'est difficile à adopter pour quiconque n'est pas né et n'a pas grandi sous Linux ! Le passage de super à ctrl aussi, si vous venez du Mac.

Omarchy s'attaque à ces deux problèmes avec des raccourcis de presse-papiers unifiés qui fonctionnent (presque) partout. Les voici :

| Raccourci | Commande |
| ------- | ----------- |
| Super + C | Copier |
| Super + X | Couper |
| Super + V | Coller |
| Super + Ctrl + V | Historique presse-papiers |

_Notez que la plupart des harnais d'agent utiliseront `Ctrl + V` pour coller des images, mais `Super + V` pour coller du texte._

### Historique presse-papiers

L'historique du presse-papiers est fourni par le shell Omarchy et fonctionne pour le texte comme pour les images. Vous le déclenchez par `Super + Ctrl + V`, sélectionnez votre entrée avec Entrée, et elle sera placée sur le presse-papiers, prête à coller avec `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Vous pouvez aussi rechercher dans l'historique simplement en commençant à taper :

 ![clipboard-history-search](images/clipboard-history-search.webp)
