# Giochi

Omarchy non è solo per la _pRoDUTTiViTÀ_, è anche per divertirsi, e cosa c'è di più divertente che giocare? Omarchy include un'intera suite di opzioni per il gaming — Steam e RetroArch per il gioco nativo e retrò, Battle.net, Lutris e Heroic per gli store non Steam, Moonlight per lo streaming da PC, Xbox Cloud Gaming + NVIDIA GeForce NOW per il cloud, oltre all'intramontabile Minecraft.

Grazie all'incredibile lavoro di Valve su [il livello di compatibilità proton](https://en.wikipedia.org/wiki/Proton_(software)), ora ci sono decine di migliaia di giochi moderni giocabili su Linux. Ah, e sapevi che [Steam Deck](https://store.steampowered.com/steamdeck/) esegue effettivamente Arch!

Tutti gli installatori per il gaming vivono in _Installa > Giochi_ nel menu Omarchy (`Super + Space`). Se mai volessi annullarne uno, usa _Rimuovi > Giochi_.

## Steam

Installa [Steam](https://store.steampowered.com/) selezionando _Installa > Giochi > Steam_ dal menu Omarchy (`Super + Space`).

Dopo averlo installato, potrai avviare Steam con `Super + Space`.

Nota che Steam può impiegare 10-20 secondi per avviarsi e non fornirà alcun feedback visivo del caricamento.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installa [RetroArch](https://www.retroarch.com/) selezionando _Installa > Giochi > RetroArch_ dal menu Omarchy (`Super + Space`). Include l'intero set di core libretro, quindi tutti i sistemi classici sono coperti.

RetroArch è completamente preconfigurato con il bellissimo shader CRT Royale per quel perfetto look retrò.

Per iniziare:

1. Metti i tuoi file BIOS in `~/Games/bios` e le tue ROM in `~/Games/roms`.
2. Avvia RetroArch con `Super + Space` e digitando `retro`.
3. Scansiona la directory `~/Games/roms` e sei pronto a giocare.

Puoi anche dare a un gioco preferito la sua voce nel launcher delle app con _Installa > Giochi > Avvio giochi RetroArch_, che ti permette di scegliere un core e una ROM e saltare direttamente nel gioco da `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installa l'app web Xbox Cloud Gaming selezionando _Installa > Giochi > Xbox Cloud Gaming_ dal menu Omarchy (`Super + Space`). È "solo" un'app web per il servizio, ma si avvia rapidamente e gira ottimamente a 1080p.

Se hai già Xbox Game Pass, questo è un modo solido per giocare a Fortnite e ad altri titoli che non puoi eseguire nativamente su Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installa il servizio di cloud gaming [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) selezionando _Installa > Giochi > NVIDIA GeForce NOW_ dal menu Omarchy (`Super + Space`). Un altro ottimo modo per giocare a titoli che non sono disponibili nativamente su Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installa Minecraft selezionando _Installa > Giochi > Minecraft_ dal menu Omarchy (`Super + Space`).

Come Steam, nota che dopo l'accesso o l'avvio può volerci un po' prima che appaia la schermata successiva, e non riceverai alcun feedback mentre aspetti.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Controller Xbox

Installa il supporto per i controller Xbox Bluetooth selezionando _Installa > Giochi > Controller Xbox_ dal menu Omarchy (`Super + Space`). Associa i controller via Bluetooth (`Super + Ctrl + B`) e funzioneranno in tutti i tuoi giochi. Non ti serve se colleghi semplicemente il controller con un cavo USB-C.

## Moonlight (Streaming di gioco da un PC)

Il [client Moonlight](https://github.com/moonlight-stream/moonlight-qt) è preinstallato con Omarchy, quindi puoi trasmettere subito giochi da un PC Windows che esegue [Sunshine](https://app.lizardbyte.dev/Sunshine/). Avvia Moonlight tramite `Super + Space`.

Se sia la tua macchina Omarchy sia il PC da gaming remoto sono cablati, l'esperienza è indistinguibile dal giocare in locale. Alza la risoluzione a quella nativa, imposta l'aggiornamento a 120Hz e porta il bitrate al massimo — questo è il modo migliore per giocare a sparatutto competitivi come Fortnite su Linux.

Puoi anche trasformare una macchina Omarchy nell'host eseguendo `omarchy install service sunshine`, che installa Sunshine e apre le porte di streaming Moonlight per la tua LAN e Tailscale.

## Battle.net

Installa [Battle.net](https://eu.shop.battle.net/en-us) selezionando _Installa > Giochi > Battle.net_ dal menu Omarchy (`Super + Space`). Questo ti dà titoli come Diablo, Starcraft e World of Warcraft come installazione autonoma in esecuzione sotto GE-Proton — non servono Steam, Lutris o Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (giochi Windows)

Installa [Lutris](https://lutris.net/) selezionando _Installa > Giochi > Lutris_ dal menu Omarchy (`Super + Space`). Lutris è il modo per giocare a giochi Windows da store come EA e Ubisoft Connect che non hanno un proprio installatore qui sopra.

L'installazione è un po' macchinosa e a volte sembra che non stia succedendo nulla — sii paziente, sta lavorando in background.

## Heroic Launcher (Epic Games)

Installa [Heroic Launcher](https://heroicgameslauncher.com/) selezionando _Installa > Giochi > Heroic (Epic Games)_ dal menu Omarchy (`Super + Space`). Heroic ti permette di eseguire titoli Epic Games, come OddSparks, che non si affidano all'anti-cheat — oltre a giochi da GOG e Amazon Prime Gaming. Purtroppo, questo significa niente Fortnite e niente Rocket League — finché Tim Sweeney non arriverà su Linux, questo è il massimo che si può ottenere.

Come Lutris, può sembrare lento e macchinoso durante l'installazione dei giochi. Dagli tempo.
