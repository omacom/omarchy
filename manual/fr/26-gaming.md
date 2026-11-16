# Jeux

Omarchy n'est pas seulement fait pour la _pRoDUcTiVItÉ_, il est aussi fait pour s'amuser, et quoi de plus amusant que de jouer ? Omarchy est livré avec toute une suite d'options de jeu — Steam et RetroArch pour le jeu natif et rétro, Battle.net, Lutris et Heroic pour les boutiques hors Steam, Moonlight pour le streaming PC, Xbox Cloud Gaming + NVIDIA GeForce NOW pour le cloud, plus l'indémodable Minecraft.

Grâce au travail incroyable de Valve sur [la couche de compatibilité Proton](https://en.wikipedia.org/wiki/Proton_(software)), il existe désormais des dizaines de milliers de jeux modernes jouables sur Linux. Oh, et saviez-vous que le [Steam Deck](https://store.steampowered.com/steamdeck/) fonctionne en fait sous Arch !

Tous les programmes d'installation de jeux se trouvent sous _Install > Gaming_ dans le menu Omarchy (`Super + Space`). Si vous voulez un jour annuler l'un d'eux, utilisez _Remove > Gaming_.

## Steam

Installez [Steam](https://store.steampowered.com/) en sélectionnant _Install > Gaming > Steam_ dans le menu Omarchy (`Super + Space`).

Une fois installé, vous pourrez lancer Steam avec `Super + Space`.

Notez que Steam peut mettre 10-20 secondes à démarrer, et qu'il ne fournira aucun retour visuel pendant son chargement.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installez [RetroArch](https://www.retroarch.com/) en sélectionnant _Install > Gaming > RetroArch_ dans le menu Omarchy (`Super + Space`). Il est livré avec l'ensemble complet des cœurs libretro, donc tous les systèmes classiques sont couverts.

RetroArch est entièrement préconfiguré avec le magnifique shader CRT Royale pour ce look rétro parfait.

Pour commencer :

1. Déposez vos fichiers BIOS dans `~/Games/bios` et vos ROMs dans `~/Games/roms`.
2. Lancez RetroArch avec `Super + Space` et en tapant `retro`.
3. Scannez le répertoire `~/Games/roms` et vous êtes prêt à jouer.

Vous pouvez aussi donner à un jeu favori sa propre entrée dans le lanceur d'applications avec _Install > Gaming > RetroArch Game Launcher_, qui vous permet de choisir un cœur et une ROM, et de sauter directement dans le jeu depuis `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installez l'application web Xbox Cloud Gaming en sélectionnant _Install > Gaming > Xbox Cloud Gaming_ dans le menu Omarchy (`Super + Space`). C'est « juste » une application web pour le service, mais elle démarre vite et fonctionne très bien en 1080p.

Si vous avez déjà le Xbox Game Pass, c'est un moyen solide de jouer à Fortnite et à d'autres titres que vous ne pouvez pas faire tourner nativement sur Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installez le service de cloud gaming [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) en sélectionnant _Install > Gaming > NVIDIA GeForce NOW_ dans le menu Omarchy (`Super + Space`). Un autre excellent moyen de jouer à des titres qui ne sont pas disponibles nativement sur Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installez Minecraft en sélectionnant _Install > Gaming > Minecraft_ dans le menu Omarchy (`Super + Space`).

Comme Steam, notez qu'il peut s'écouler un certain temps après la connexion ou le démarrage avant que l'écran suivant n'apparaisse, et que vous n'aurez aucun retour pendant l'attente.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Installez la prise en charge des manettes Xbox Bluetooth en sélectionnant _Install > Gaming > Xbox Controllers_ dans le menu Omarchy (`Super + Space`). Associez les manettes via Bluetooth (`Super + Ctrl + B`) et elles fonctionneront dans tous vos jeux. Vous n'en avez pas besoin si vous branchez simplement votre manette avec un câble USB-C.

## Moonlight (streaming de jeux depuis un PC)

Installez le [client Moonlight](https://github.com/moonlight-stream/moonlight-qt) en sélectionnant _Install > Gaming > Moonlight_ dans le menu Omarchy (`Super + Space`), et vous pourrez diffuser des jeux depuis un PC Windows exécutant [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Si votre machine Omarchy et le PC de jeu distant sont tous deux branchés en filaire, l'expérience est impossible à distinguer d'une partie en local. Poussez la résolution jusqu'au natif, réglez le taux de rafraîchissement sur 120Hz et mettez le débit binaire au maximum — c'est la meilleure façon de jouer à des jeux de tir compétitifs comme Fortnite sur Linux.

Vous pouvez aussi transformer une machine Omarchy en hôte en exécutant `omarchy install service sunshine`, qui installe Sunshine et ouvre les ports de streaming Moonlight pour votre LAN et Tailscale.

## Battle.net

Installez [Battle.net](https://eu.shop.battle.net/en-us) en sélectionnant _Install > Gaming > Battle.net_ dans le menu Omarchy (`Super + Space`). Cela vous donne des titres comme Diablo, Starcraft et World of Warcraft sous forme d'installation autonome fonctionnant sous GE-Proton — pas besoin de Steam, Lutris ou Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (jeux Windows)

Installez [Lutris](https://lutris.net/) en sélectionnant _Install > Gaming > Lutris_ dans le menu Omarchy (`Super + Space`). Lutris est le moyen de jouer aux jeux Windows de boutiques comme EA et Ubisoft Connect qui n'ont pas leur propre programme d'installation ci-dessus.

L'installation est un peu bancale et donne parfois l'impression qu'il ne se passe rien — soyez juste patient, elle travaille en arrière-plan.

## Heroic Launcher (Epic Games)

Installez le [Heroic Launcher](https://heroicgameslauncher.com/) en sélectionnant _Install > Gaming > Heroic (Epic Games)_ dans le menu Omarchy (`Super + Space`). Heroic vous permet de faire tourner des titres Epic Games, comme OddSparks, qui ne reposent pas sur un système anti-triche — plus des jeux de GOG et Amazon Prime Gaming. Malheureusement, cela signifie pas de Fortnite et pas de Rocket League — tant que Tim Sweeney ne viendra pas sur Linux, on ne pourra pas faire mieux.

Comme Lutris, il peut sembler lent et bancal pendant l'installation des jeux. Laissez-lui du temps.
