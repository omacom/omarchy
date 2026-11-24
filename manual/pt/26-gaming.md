# Jogos

O Omarchy não serve só para a _pRoDUcTiVItY_, também serve para nos divertirmos, e o que há de mais divertido do que jogar? O Omarchy vem com um conjunto completo de opções para jogar — Steam e RetroArch para jogos nativos e retro, Battle.net, Lutris e Heroic para lojas fora do Steam, Moonlight para streaming a partir do PC, Xbox Cloud Gaming + NVIDIA GeForce NOW para a nuvem, e ainda o intemporal Minecraft.

Graças ao trabalho incrível da Valve na [camada de compatibilidade Proton](https://en.wikipedia.org/wiki/Proton_(software)), existem agora dezenas de milhares de jogos modernos jogáveis no Linux. Ah, e sabias que a [Steam Deck](https://store.steampowered.com/steamdeck/) corre, na verdade, Arch!

Todos os instaladores de jogos estão em _Install > Gaming_ no menu do Omarchy (`Super + Space`). Se alguma vez quiseres desfazer uma instalação, usa _Remove > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris e Heroic são disponibilizados apenas em máquinas x86.

## Steam

Instala o [Steam](https://store.steampowered.com/) selecionando _Install > Gaming > Steam_ no menu do Omarchy (`Super + Space`).

Depois de o instalares, poderás iniciar o Steam com `Super + Space`.

Repara que o Steam pode demorar 10-20 segundos a arrancar e não vai mostrar qualquer indicação visual de que está a carregar.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instala o [RetroArch](https://www.retroarch.com/) selecionando _Install > Gaming > RetroArch_ no menu do Omarchy (`Super + Space`). Vem com o conjunto completo de núcleos libretro, por isso todos os sistemas clássicos estão cobertos.

O RetroArch vem totalmente pré-configurado com o belo shader CRT Royale para aquele visual retro perfeito.

Para começares:

1. Coloca os teus ficheiros BIOS em `~/Games/bios` e as tuas ROMs em `~/Games/roms`.
2. Inicia o RetroArch com `Super + Space` e escrevendo `retro`.
3. Faz a leitura do diretório `~/Games/roms` e estás pronto para jogar.

Também podes dar a um jogo favorito a sua própria entrada no lançador de aplicações com _Install > Gaming > RetroArch Game Launcher_, que te permite escolher um núcleo e uma ROM e saltar diretamente para o jogo a partir do `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instala a aplicação web Xbox Cloud Gaming selecionando _Install > Gaming > Xbox Cloud Gaming_ no menu do Omarchy (`Super + Space`). É "apenas" uma aplicação web para o serviço, mas arranca depressa e corre muito bem a 1080p.

Se já tens Xbox Game Pass, esta é uma forma sólida de jogar Fortnite e outros títulos que não consegues correr nativamente no Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instala o serviço de jogos na nuvem [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) selecionando _Install > Gaming > NVIDIA GeForce NOW_ no menu do Omarchy (`Super + Space`). Outra excelente forma de jogar títulos que não estão disponíveis nativamente no Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instala o Minecraft selecionando _Install > Gaming > Minecraft_ no menu do Omarchy (`Super + Space`).

Tal como o Steam, repara que pode demorar algum tempo, depois de iniciares sessão ou de arrancares, até aparecer o ecrã seguinte, e não vais receber qualquer indicação enquanto estás à espera.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Comandos Xbox

Instala o suporte para comandos Xbox por Bluetooth selecionando _Install > Gaming > Xbox Controllers_ no menu do Omarchy (`Super + Space`). Emparelha os comandos por Bluetooth (`Super + Ctrl + B`) e eles vão funcionar em todos os teus jogos. Não precisas disto se estiveres apenas a ligar o teu comando por cabo com um cabo USB-C.

## Moonlight (Streaming de jogos a partir de um PC)

Instala o [cliente Moonlight](https://github.com/moonlight-stream/moonlight-qt) selecionando _Install > Gaming > Moonlight_ no menu do Omarchy (`Super + Space`), e podes transmitir jogos a partir de um PC Windows a executar [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Se tanto a tua máquina Omarchy como o PC de jogos remoto estiverem ligados por cabo, a experiência é indistinguível de jogar localmente. Aumenta a resolução para a nativa, define a taxa de atualização para 120Hz e coloca o bitrate no máximo — esta é a melhor forma de jogar shooters competitivos como o Fortnite no Linux.

Também podes transformar uma máquina Omarchy na máquina anfitriã executando `omarchy install service sunshine`, que instala o Sunshine e abre as portas de streaming do Moonlight para a tua LAN e para o Tailscale.

## Battle.net

Instala o [Battle.net](https://eu.shop.battle.net/en-us) selecionando _Install > Gaming > Battle.net_ no menu do Omarchy (`Super + Space`). Isto dá-te títulos como Diablo, Starcraft e World of Warcraft como uma instalação autónoma a correr sob GE-Proton — sem precisares do Steam, do Lutris ou do Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Jogos Windows)

Instala o [Lutris](https://lutris.net/) selecionando _Install > Gaming > Lutris_ no menu do Omarchy (`Super + Space`). O Lutris é a forma de jogar jogos Windows de lojas como a EA e a Ubisoft Connect que não têm o seu próprio instalador acima.

A instalação é um bocado atabalhoada e, por vezes, parece que não está a acontecer nada — tem paciência, está a trabalhar em segundo plano.

## Heroic Launcher (Epic Games)

Instala o [Heroic Launcher](https://heroicgameslauncher.com/) selecionando _Install > Gaming > Heroic (Epic Games)_ no menu do Omarchy (`Super + Space`). O Heroic permite-te correr títulos da Epic Games, como o OddSparks, que não dependem de anti-cheat — além de jogos da GOG e da Amazon Prime Gaming. Infelizmente, isso significa nada de Fortnite e nada de Rocket League — até o Tim Sweeney vir para o Linux, é o mais perto que se consegue chegar.

Tal como o Lutris, pode parecer lento e atabalhoado enquanto está a instalar jogos. Dá-lhe tempo.
