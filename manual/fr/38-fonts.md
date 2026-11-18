# Polices

Par défaut, Omarchy utilise JetBrainsMono Nerd Font à la fois comme police du terminal et comme police du système.

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

Vous pouvez changer cela via le menu _Apparence > Police_ dans le menu Omarchy (`Super + Space`). Cela définit la police à chasse fixe partout : le terminal, la barre, et tout le reste qui la demande.

Vous pouvez installer d'autres polices de programmation populaires via _Installation > Style > Police_ dans le menu Omarchy : Cascadia Mono, Meslo LG Mono, Fira Code, Victor Code, Bitstream Vera Mono et Iosevka sont toutes à un clic, dans leurs versions Nerd Font pour que les glyphes de la barre et du terminal continuent de fonctionner. Après en avoir installé une, sélectionnez-la sous _Apparence > Police_.

## Chinois, japonais et coréen

Le chinois, le japonais et le coréen partagent de nombreux caractères, mais en dessinent certains différemment, si bien que le même caractère semble correct à un lecteur et étranger à un autre. Choisir l'une de ces langues sous _Configuration > Langue_, ou sa méthode de saisie, définit les formes correspondantes. Pour les choisir vous-même, exécutez `omarchy font cjk jp`, `kr`, `sc`, `tc` (Taïwan) ou `hk` (Hong Kong) dans un terminal ; `omarchy font cjk default` revient au choix du système, qui correspond aux formes japonaises. Le texte qu'une page web ou un document marque avec sa propre langue, et l'ensemble du bureau lorsqu'il est dans l'une de ces langues, conservent les formes de cette langue.
