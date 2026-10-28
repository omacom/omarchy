# Jeux

Omarchy n'est pas seulement fait pour la _pRoDUcTiVItÉ_, il est aussi fait pour s'amuser, et quoi de plus amusant que les jeux ? Omarchy est livré avec toute une panoplie d'options de jeu — Steam et RetroArch pour le jeu natif et rétro, Battle.net, Lutris et Heroic pour les boutiques hors Steam, Moonlight pour le streaming PC, Xbox Cloud Gaming + NVIDIA GeForce NOW pour le cloud, plus l'indémodable Minecraft.

Grâce à l'incroyable travail de Valve sur [la couche de compatibilité Proton](https://en.wikipedia.org/wiki/Proton_(software)), il existe désormais des dizaines de milliers de jeux modernes jouables sous Linux. Oh, et saviez-vous que le [Steam Deck](https://store.steampowered.com/steamdeck/) tourne en fait sous Arch !

Tous les installateurs de jeux vivent sous _Installer > Jeux_ dans le menu Omarchy (`Super + Space`). Si vous souhaitez un jour annuler l'un d'eux, utilisez _Supprimer > Jeux_.

## Steam

Installez [Steam](https://store.steampowered.com/) en sélectionnant _Installer > Jeux > Steam_ depuis le menu Omarchy (`Super + Space`).

Une fois que vous l'avez installé, vous pourrez lancer Steam avec `Super + Space`.

Notez que Steam peut mettre 10 à 20 secondes à démarrer, et qu'il ne fournira aucun retour visuel indiquant qu'il est en train de se charger.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installez [RetroArch](https://www.retroarch.com/) en sélectionnant _Installer > Jeux > RetroArch_ depuis le menu Omarchy (`Super + Space`). Il est livré avec l'ensemble complet des cœurs libretro, donc tous les systèmes classiques sont couverts.

RetroArch est entièrement préconfiguré avec le magnifique shader CRT Royale pour ce look rétro parfait.

Pour vous lancer :

1. Déposez vos fichiers BIOS dans `~/Games/bios` et vos ROM dans `~/Games/roms`.
2. Lancez RetroArch avec `Super + Space` et en tapant `retro`.
3. Analysez le répertoire `~/Games/roms` et vous êtes prêt à jouer.

Vous pouvez aussi donner à un jeu favori sa propre entrée dans le lanceur d'applis avec _Installer > Jeux > Lanceur de jeux RetroArch_, ce qui vous permet de choisir un cœur et une ROM, et de sauter directement dans le jeu depuis `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installez l'appli web Xbox Cloud Gaming en sélectionnant _Installer > Jeux > Xbox Cloud Gaming_ depuis le menu Omarchy (`Super + Space`). C'est « juste » une appli web pour le service, mais elle démarre vite et fonctionne très bien en 1080p.

Si vous avez déjà Xbox Game Pass, c'est un moyen solide de jouer à Fortnite et à d'autres titres que vous ne pouvez pas faire tourner nativement sous Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installez le service de cloud gaming [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) en sélectionnant _Installer > Jeux > NVIDIA GeForce NOW_ depuis le menu Omarchy (`Super + Space`). Un autre excellent moyen de jouer à des titres qui ne sont pas disponibles nativement sous Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installez Minecraft en sélectionnant _Installer > Jeux > Minecraft_ depuis le menu Omarchy (`Super + Space`).

Comme pour Steam, notez qu'il peut falloir un moment après la connexion ou le démarrage pour que l'écran suivant apparaisse, et que vous n'obtiendrez aucun retour pendant que vous attendez.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Manettes Xbox

Installez la prise en charge des manettes Xbox Bluetooth en sélectionnant _Installer > Jeux > Manettes Xbox_ depuis le menu Omarchy (`Super + Space`). Appairez les manettes via Bluetooth (`Super + Ctrl + B`) et elles fonctionneront dans tous vos jeux. Vous n'en avez pas besoin si vous branchez simplement votre manette avec un câble USB-C.

## Moonlight (Streaming de jeu depuis un PC)

Le [client Moonlight](https://github.com/moonlight-stream/moonlight-qt) est préinstallé avec Omarchy, donc vous pouvez diffuser des jeux depuis un PC Windows exécutant [Sunshine](https://app.lizardbyte.dev/Sunshine/) tout de suite. Lancez Moonlight via `Super + Space`.

Si votre machine Omarchy et le PC de jeu distant sont tous deux branchés en filaire, l'expérience est indiscernable du jeu local. Poussez la résolution en natif, réglez le rafraîchissement à 120 Hz, et mettez le débit au maximum — c'est la meilleure façon de jouer à des shooters compétitifs comme Fortnite sous Linux.

Vous pouvez aussi transformer une machine Omarchy en hôte en lançant `omarchy install service sunshine`, ce qui installe Sunshine et ouvre les ports de streaming Moonlight pour votre LAN et Tailscale.

## Battle.net

Installez [Battle.net](https://eu.shop.battle.net/en-us) en sélectionnant _Installer > Jeux > Battle.net_ depuis le menu Omarchy (`Super + Space`). Cela vous donne des titres comme Diablo, Starcraft et World of Warcraft en installation autonome tournant sous GE-Proton — pas besoin de Steam, Lutris ou Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Jeux Windows)

Installez [Lutris](https://lutris.net/) en sélectionnant _Installer > Jeux > Lutris_ depuis le menu Omarchy (`Super + Space`). Lutris est le moyen de jouer à des jeux Windows provenant de boutiques comme EA et Ubisoft Connect qui n'ont pas leur propre installateur ci-dessus.

L'installation est un peu bancale et donne l'impression qu'il ne se passe rien par moments — soyez juste patient, ça travaille en arrière-plan.

## Heroic Launcher (Epic Games)

Installez le [Heroic Launcher](https://heroicgameslauncher.com/) en sélectionnant _Installer > Jeux > Heroic (Epic Games)_ depuis le menu Omarchy (`Super + Space`). Heroic vous permet de faire tourner des titres Epic Games, comme OddSparks, qui ne dépendent pas d'un anti-triche — plus des jeux de GOG et Amazon Prime Gaming. Malheureusement, cela signifie pas de Fortnite et pas de Rocket League — jusqu'à ce que Tim Sweeney vienne sous Linux, c'est ce qu'il y a de plus proche.

Comme Lutris, il peut sembler lent et bancal pendant l'installation des jeux. Laissez-lui du temps.
