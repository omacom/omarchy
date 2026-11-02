# Extraction de texte et dictée

### Extraction de texte

Appuyez sur `Super + Ctrl + PrtScr` pour sélectionner une zone de l'écran pour l'extraction de texte. Le modèle OCR open source tesseract convertira ensuite rapidement cette sélection en texte et la placera dans le presse-papiers. Ensuite, appuyez simplement sur `Super + V` pour coller.

C'est très utile pour récupérer des adresses dans les pieds de page d'images ou des numéros de téléphone intégrés aux titres de sites web.

 ![text-extraction](images/text-extraction.webp)

### Dictée

Sur les nouvelles installations, [Superwhisper](https://superwhisper.com/) est le backend de dictée par défaut, avec un traitement dans le cloud sans téléchargement de modèle hors ligne. Choisissez Superwhisper, [Voxtype](https://voxtype.io/) ou [Hex](https://anoma.ly/hex/) via _Setup > Defaults > Dictation_ dans le menu Omarchy. La sélection d'un backend l'installe si nécessaire et en fait le backend par défaut pour la dictée. Voxtype charge un modèle anglais de base qui occupe 150MB ; changez le modèle avec `voxtype setup model` et les autres paramètres via `~/.config/voxtype/config.toml`. Superwhisper ouvre ses paramètres pour choisir entre un traitement dans le cloud ou en local, et OPR maintient l'application à jour. Hex télécharge son modèle vocal sur l'appareil pendant l'installation et s'exécute en tant que service utilisateur `hex.service` ; ouvrez sa fenêtre depuis l'icône de la zone de notification de la barre ou en lançant `hex` pour changer de modèle et modifier les autres paramètres.

Vous dictez en maintenant `Right Alt` enfoncée, ou en basculant avec `Alt + Space`, et le texte dicté apparaîtra dans la zone de saisie active. Ces raccourcis utilisent le backend sélectionné. Right Alt lance également la dictée lorsqu'elle est utilisée dans un accord de modificateurs ; utilisez Left Alt pour ces accords. Sur les dispositions de clavier où Right Alt est AltGr, utilisez `Alt + Space` pour garder AltGr disponible pour la saisie. Les installations antérieures au moment où Alt + Space est devenu le comportement par défaut conservent `F9` pour le push-to-talk et `Super + Ctrl + X` pour basculer, ajoutés à `~/.config/hypr/bindings.lua` ; supprimez-les à cet endroit pour rendre ces touches aux applications.

Les mêmes raccourcis fonctionnent avec tous les backends. Sélectionnez votre backend via Setup > Defaults > Dictation. Le programme d'installation du backend le configure et enregistre la sélection. Lancez `omarchy default dictation` pour voir lequel est sélectionné. La sélection est enregistrée dans `~/.config/omarchy/defaults/dictation`. Les nouvelles installations sélectionnent Superwhisper automatiquement.

Omarchy charge automatiquement l'intégration bureau du backend sélectionné. Aucune configuration de Superwhisper n'est nécessaire dans `~/.config/hypr/`.

Les liaisons personnalisées et les scripts peuvent utiliser `omarchy dictation start`, `omarchy dictation stop` et `omarchy dictation toggle`. Le backend sélectionné se charge de l'enregistrement et de la transcription. La sélection de Superwhisper désactive son raccourci natif de maintien et définit sa bascule native sur `Ctrl + Alt + Space`, ce qui la maintient distincte des touches d'enregistrement d'Omarchy. Superwhisper exige au moins un raccourci d'enregistrement natif, et son raccourci d'annulation reste disponible.

Des backends supplémentaires peuvent s'intégrer sans modifier Omarchy. Fournissez un exécutable nommé `omarchy-dictation-<backend>` dans le PATH qui accepte `start`, `stop` et `toggle` et se termine rapidement, avec un statut non nul en cas d'échec. Son programme d'installation configure le fournisseur et appelle `omarchy-dictation-use <backend>` une fois l'installation réussie. Cela arrête le backend précédent et enregistre la sélection de manière atomique ; `stop` doit réussir lorsque le fournisseur est inactif ou indisponible. Les noms de backend utilisent des lettres minuscules, des chiffres et des tirets. Fournissez `omarchy-install-dictation-<backend>` pour l'installation ; `omarchy default dictation <backend>` le lance. Ajoutez une entrée au menu Defaults via une extension du menu Omarchy pour appeler ce sélecteur. L'intégration bureau facultative peut se trouver dans `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
