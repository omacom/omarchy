# Extraction de texte et dictée

### Extraction de texte

Appuyez sur `Super + Ctrl + PrtScr` pour sélectionner une région à l'écran en vue d'en extraire le texte. Le modèle OCR open source tesseract convertira ensuite rapidement cette sélection en texte et le placera dans le presse-papiers. Il vous suffit ensuite d'appuyer sur `Super + V` pour coller.

C'est très pratique pour récupérer des adresses dans les pieds de page d'images ou des numéros de téléphone intégrés dans les titres de sites web.

 ![text-extraction](images/text-extraction.webp)

### Dictée

Sur les installations neuves, [Superwhisper](https://superwhisper.com/) est le backend de dictée par défaut, avec un traitement cloud sans téléchargement de modèle hors ligne. Choisissez Superwhisper ou [Voxtype](https://voxtype.io/) via _Configuration > Valeurs par défaut > Dictée_ dans le menu Omarchy. Sélectionner un backend l'installe si nécessaire et en fait le backend par défaut pour la dictée. Voxtype charge un modèle anglais de base qui occupe 150MB ; changez de modèle avec `voxtype setup model` et les autres paramètres via `~/.config/voxtype/config.toml`. Superwhisper ouvre ses paramètres pour choisir entre traitement cloud ou local, et OPR maintient l'application à jour.

Vous dictez en maintenant `Right Alt` enfoncée, ou en basculant avec `Alt + Space`, et le texte dicté apparaîtra dans la zone de saisie active. Ces raccourcis utilisent le backend sélectionné. Right Alt démarre aussi la dictée lorsqu'elle est utilisée dans une combinaison de modificateurs ; utilisez Left Alt pour ces combinaisons. Sur les dispositions de clavier où Right Alt est AltGr, utilisez `Alt + Space` pour garder AltGr disponible pour la saisie. Les installations antérieures au moment où Alt + Space est devenu la valeur par défaut conservent `F9` pour la dictée en maintien et `Super + Ctrl + X` pour le basculement, ajoutés à `~/.config/hypr/bindings.lua` ; supprimez-les à cet endroit pour rendre ces touches aux applications.

Les mêmes raccourcis fonctionnent avec l'un ou l'autre backend. Sélectionnez votre backend via Configuration > Valeurs par défaut > Dictée. L'installateur du backend le configure et enregistre la sélection. Exécutez `omarchy default dictation` pour voir lequel est sélectionné. La sélection est enregistrée dans `~/.config/omarchy/defaults/dictation`. Les installations neuves sélectionnent Superwhisper automatiquement.

Omarchy charge automatiquement l'intégration au bureau du backend sélectionné. Aucune configuration de Superwhisper n'est nécessaire dans `~/.config/hypr/`.

Les liaisons et scripts personnalisés peuvent utiliser `omarchy dictation start`, `omarchy dictation stop` et `omarchy dictation toggle`. Le backend sélectionné gère l'enregistrement et la transcription. Sélectionner Superwhisper désactive son raccourci natif de maintien et définit son raccourci natif de basculement sur `Ctrl + Alt + Space`, en le gardant séparé des touches d'enregistrement d'Omarchy. Superwhisper nécessite au moins un raccourci d'enregistrement natif, et son raccourci d'annulation reste disponible.

Des backends supplémentaires peuvent s'intégrer sans modifier Omarchy. Fournissez un exécutable nommé `omarchy-dictation-<backend>` sur PATH qui accepte `start`, `stop` et `toggle` et répond rapidement, avec un statut non nul en cas d'échec. Son installateur configure le fournisseur et appelle `omarchy-dictation-use <backend>` après une installation réussie. Cela arrête le backend précédent et enregistre la sélection de manière atomique ; `stop` doit réussir lorsque le fournisseur est inactif ou indisponible. Les noms de backend utilisent des lettres minuscules, des chiffres et des traits d'union. Fournissez `omarchy-install-dictation-<backend>` pour l'installation ; `omarchy default dictation <backend>` le lance. Ajoutez une entrée au menu Valeurs par défaut via une extension du menu Omarchy pour appeler ce sélecteur. L'intégration facultative au bureau peut se trouver dans `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
