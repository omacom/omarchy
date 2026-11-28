# Gaming

Omarchy non è solo per la _pRoDUtTiViTà_, è anche per divertirsi, e cosa c'è di più divertente del gaming? Omarchy include un'intera suite di opzioni per il gaming — Steam e RetroArch per giocare in nativo e in stile retrò, Battle.net, Lutris e Heroic per gli store non Steam, Moonlight per lo streaming da PC, Xbox Cloud Gaming + NVIDIA GeForce NOW per il cloud, più l'intramontabile Minecraft.

Grazie all'incredibile lavoro di Valve sul [layer di compatibilità Proton](https://en.wikipedia.org/wiki/Proton_(software)), ora ci sono decine di migliaia di giochi moderni giocabili su Linux. Ah, e lo sapevi che [Steam Deck](https://store.steampowered.com/steamdeck/) usa davvero Arch!

Tutti i programmi di installazione per il gaming si trovano sotto _Installa > Gaming_ nel menu di Omarchy (`Super + Space`). Se un giorno vuoi annullarne uno, usa _Rimuovi > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris e Heroic sono disponibili solo su macchine x86.

## Steam

Installa [Steam](https://store.steampowered.com/) selezionando _Installa > Gaming > Steam_ dal menu di Omarchy (`Super + Space`).

Dopo averlo installato, potrai avviare Steam con `Super + Space`.

Tieni presente che Steam può impiegare 10-20 secondi ad avviarsi e non ti darà nessun feedback visivo mentre si sta caricando.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installa [RetroArch](https://www.retroarch.com/) selezionando _Installa > Gaming > RetroArch_ dal menu di Omarchy (`Super + Space`). Include il set completo dei core libretro, quindi tutti i sistemi classici sono coperti.

RetroArch è completamente preconfigurato con il bellissimo shader CRT Royale per quel perfetto look retrò.

Per iniziare:

1. Copia i tuoi file BIOS in `~/Games/bios` e le tue ROM in `~/Games/roms`.
2. Avvia RetroArch con `Super + Space` e digitando `retro`.
3. Scansiona la directory `~/Games/roms` e sei pronto a giocare.

Puoi anche dare a un gioco preferito una sua voce nel launcher delle app con _Installa > Gaming > RetroArch Game Launcher_, che ti permette di scegliere un core e una ROM e di saltare dritto nel gioco da `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installa la web app di Xbox Cloud Gaming selezionando _Installa > Gaming > Xbox Cloud Gaming_ dal menu di Omarchy (`Super + Space`). È "solo" una web app per il servizio, ma si avvia in un attimo e funziona alla grande a 1080p.

Se hai già Xbox Game Pass, questo è un ottimo modo per giocare a Fortnite e ad altri titoli che non puoi eseguire in nativo su Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installa il servizio di cloud gaming [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) selezionando _Installa > Gaming > NVIDIA GeForce NOW_ dal menu di Omarchy (`Super + Space`). Un altro ottimo modo per giocare a titoli che non sono disponibili in nativo su Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installa Minecraft selezionando _Installa > Gaming > Minecraft_ dal menu di Omarchy (`Super + Space`).

Come Steam, tieni presente che può volerci un po' dopo l'accesso o l'avvio prima che compaia la schermata successiva, e non riceverai nessun feedback mentre aspetti.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Controller Xbox

Installa il supporto per i controller Xbox Bluetooth selezionando _Installa > Gaming > Xbox Controllers_ dal menu di Omarchy (`Super + Space`). Associa i controller via Bluetooth (`Super + Ctrl + B`) e funzioneranno in tutti i tuoi giochi. Non ti serve se colleghi semplicemente il controller in modo cablato con un cavo USB-C.

## Moonlight (Streaming di giochi da un PC)

Installa il [client Moonlight](https://github.com/moonlight-stream/moonlight-qt) selezionando _Installa > Gaming > Moonlight_ dal menu di Omarchy (`Super + Space`), e potrai trasmettere in streaming i giochi da un PC Windows che esegue [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Se sia la tua macchina Omarchy sia il PC da gaming remoto sono cablati, l'esperienza è indistinguibile dal giocare in locale. Spingi la risoluzione fino a quella nativa, imposta la frequenza di aggiornamento a 120Hz e alza il bitrate al massimo — questo è il modo migliore per giocare a sparatutto competitivi come Fortnite su Linux.

Puoi anche trasformare una macchina Omarchy nell'host eseguendo `omarchy install service sunshine`, che installa Sunshine e apre le porte per lo streaming Moonlight per la tua LAN e Tailscale.

## Battle.net

Installa [Battle.net](https://eu.shop.battle.net/en-us) selezionando _Installa > Gaming > Battle.net_ dal menu di Omarchy (`Super + Space`). Questo ti dà titoli come Diablo, Starcraft e World of Warcraft come installazione autonoma eseguita tramite GE-Proton — senza bisogno di Steam, Lutris o Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Giochi Windows)

Installa [Lutris](https://lutris.net/) selezionando _Installa > Gaming > Lutris_ dal menu di Omarchy (`Super + Space`). Lutris è il modo per giocare ai giochi Windows di store come EA e Ubisoft Connect che non hanno un proprio programma di installazione tra quelli qui sopra.

L'installazione è un po' traballante e a tratti sembra che non stia succedendo niente — sii solo paziente, sta lavorando in background.

## Heroic Launcher (Epic Games)

Installa [Heroic Launcher](https://heroicgameslauncher.com/) selezionando _Installa > Gaming > Heroic (Epic Games)_ dal menu di Omarchy (`Super + Space`). Heroic ti permette di eseguire titoli di Epic Games, come OddSparks, che non dipendono dall'anti-cheat — oltre a giochi di GOG e Amazon Prime Gaming. Purtroppo, questo significa niente Fortnite e niente Rocket League — finché Tim Sweeney non arriverà su Linux, questo è il massimo che si possa ottenere.

Come Lutris, può sembrare lento e traballante mentre installa i giochi. Dagli tempo.
