# Extraction de texte et dictée

### Extraction de texte

Faites `Super + Ctrl + PrtScr` pour sélectionner une région de l'écran pour l'extraction de texte. Le modèle OCR open source tesseract convertira ensuite rapidement cette sélection en texte et la placera dans le presse-papiers. Il ne vous reste plus qu'à faire `Super + V` pour coller.

C'est très pratique pour récupérer des adresses dans les pieds de page d'images ou des numéros de téléphone intégrés dans les titres de sites web.

 ![text-extraction](images/text-extraction.webp)

### Dictée

Sur les nouvelles installations, [Superwhisper](https://superwhisper.com/) est le moteur de dictée par défaut, utilisant le traitement cloud sans téléchargement de modèles hors ligne. Choisissez Superwhisper ou [Voxtype](https://voxtype.io/) via _Configuration > Par défaut > Dictée_ dans le menu Omarchy. Sélectionner un moteur l'installe si nécessaire et en fait le moteur par défaut pour la dictée. Voxtype charge un modèle anglais de base qui occupe 150 Mo ; changez le modèle avec `voxtype setup model` et les autres réglages via `~/.config/voxtype/config.toml`. Superwhisper ouvre ses réglages pour choisir le traitement cloud ou local, et OPR maintient l'application à jour.

Vous dictez en maintenant `Right Alt` ou `F9`, ou en basculant avec `Super + Ctrl + X`, et le texte dicté apparaîtra dans la zone de saisie active. Ces raccourcis utilisent le moteur sélectionné. Right Alt démarre aussi la dictée lorsqu'il est utilisé dans un accord de modificateurs ; utilisez Left Alt pour ces accords. Sur les dispositions de clavier où Right Alt est AltGr, utilisez `F9` pour garder AltGr disponible pour la saisie.

Les mêmes raccourcis fonctionnent avec l'un ou l'autre moteur. Sélectionnez votre moteur via Configuration > Par défaut > Dictée. L'installateur du moteur le configure et enregistre la sélection. Exécutez `omarchy default dictation` pour voir lequel est sélectionné. La sélection est enregistrée dans `~/.config/omarchy/defaults/dictation`. Les nouvelles installations sélectionnent Superwhisper automatiquement.

Omarchy charge automatiquement l'intégration bureau du moteur sélectionné. Aucune configuration Superwhisper n'est nécessaire dans `~/.config/hypr/`.

Les raccourcis et scripts personnalisés peuvent utiliser `omarchy dictation start`, `omarchy dictation stop` et `omarchy dictation toggle`. Le moteur sélectionné gère l'enregistrement et la transcription. Sélectionner Superwhisper désactive son raccourci natif en mode maintien et définit sa bascule native sur `Alt + Space`, en la gardant séparée des touches d'enregistrement d'Omarchy. Superwhisper exige au moins un raccourci d'enregistrement natif, et son raccourci d'annulation reste disponible.

Des moteurs supplémentaires peuvent s'intégrer sans modifier Omarchy. Fournissez un exécutable nommé `omarchy-dictation-<backend>` sur le PATH, qui accepte `start`, `stop` et `toggle` et revient promptement, avec un statut non nul en cas d'échec. Son installateur configure le fournisseur et appelle `omarchy-dictation-use <backend>` après une configuration réussie. Cela arrête le moteur précédent et enregistre la sélection de façon atomique ; `stop` doit réussir lorsque le fournisseur est inactif ou indisponible. Les noms de moteurs utilisent des lettres minuscules, des chiffres et des tirets. Fournissez `omarchy-install-dictation-<backend>` pour la configuration ; `omarchy default dictation <backend>` le lance. Ajoutez une entrée au menu Par défaut via une extension de menu Omarchy pour appeler ce sélecteur. L'intégration bureau optionnelle peut vivre dans `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
