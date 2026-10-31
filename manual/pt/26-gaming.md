# Jogos

O Omarchy não é só para _pRoDUtIvIdAdE_, também é para te divertires, e o que é mais divertido do que jogar? O Omarchy vem com um conjunto completo de opções de jogo — Steam e RetroArch para jogo nativo e retro, Battle.net, Lutris e Heroic para lojas fora do Steam, Moonlight para streaming a partir de um PC, Xbox Cloud Gaming + NVIDIA GeForce NOW para a nuvem, mais o intemporal Minecraft.

Graças ao trabalho incrível da Valve na [camada de compatibilidade Proton](https://en.wikipedia.org/wiki/Proton_(software)), existem agora dezenas de milhares de jogos modernos jogáveis no Linux. Ah, e sabias que a [Steam Deck](https://store.steampowered.com/steamdeck/) corre, na verdade, Arch!

Todos os instaladores de jogos vivem em _Instalar > Jogos_ no menu Omarchy (`Super + Space`). Se alguma vez quiseres desfazer um deles, usa _Remover > Jogos_.

## Steam

Instala o [Steam](https://store.steampowered.com/) selecionando _Instalar > Jogos > Steam_ no menu Omarchy (`Super + Space`).

Depois de o instalares, poderás iniciar o Steam com `Super + Space`.

Nota que o Steam pode demorar 10 a 20 segundos a arrancar, e não te vai dar qualquer indicação visual de que está a carregar.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instala o [RetroArch](https://www.retroarch.com/) selecionando _Instalar > Jogos > RetroArch_ no menu Omarchy (`Super + Space`). Vem com o conjunto completo de núcleos libretro, por isso todos os sistemas clássicos estão cobertos.

O RetroArch vem totalmente pré-configurado com o belo shader CRT Royale para aquele aspeto retro perfeito.

Para começares:

1. Coloca os teus ficheiros BIOS em `~/Games/bios` e as tuas ROM em `~/Games/roms`.
2. Inicia o RetroArch com `Super + Space` e escrevendo `retro`.
3. Analisa o diretório `~/Games/roms` e estás pronto para jogar.

Também podes dar a um jogo favorito a sua própria entrada no lançador de aplicações com _Instalar > Jogos > Lançador RetroArch_, o que te permite escolher um núcleo e uma ROM e saltar diretamente para o jogo a partir de `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instala a aplicação web Xbox Cloud Gaming selecionando _Instalar > Jogos > Xbox Cloud Gaming_ no menu Omarchy (`Super + Space`). É «apenas» uma aplicação web para o serviço, mas arranca depressa e corre muito bem a 1080p.

Se já tiveres o Xbox Game Pass, esta é uma forma sólida de jogar Fortnite e outros títulos que não consegues correr nativamente no Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instala o serviço de jogos na nuvem [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) selecionando _Instalar > Jogos > NVIDIA GeForce NOW_ no menu Omarchy (`Super + Space`). Outra ótima forma de jogar títulos que não estão disponíveis nativamente no Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instala o Minecraft selecionando _Instalar > Jogos > Minecraft_ no menu Omarchy (`Super + Space`).

Tal como o Steam, nota que pode demorar algum tempo, depois de iniciares sessão ou de arrancar, até o ecrã seguinte aparecer, e não vais receber qualquer indicação enquanto esperas.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Comandos Xbox

Instala o suporte para comandos Xbox por Bluetooth selecionando _Instalar > Jogos > Comandos Xbox_ no menu Omarchy (`Super + Space`). Emparelha os comandos via Bluetooth (`Super + Ctrl + B`) e eles funcionam em todos os teus jogos. Não precisas disto se estiveres apenas a ligar o teu comando com um cabo USB-C.

## Moonlight (streaming de jogos a partir de um PC)

O [cliente Moonlight](https://github.com/moonlight-stream/moonlight-qt) vem pré-instalado com o Omarchy, por isso podes transmitir jogos de um PC Windows a correr o [Sunshine](https://app.lizardbyte.dev/Sunshine/) de imediato. Inicia o Moonlight com `Super + Space`.

Se tanto a tua máquina Omarchy como o PC de jogos remoto estiverem ligados por cabo, a experiência é indistinguível de jogar localmente. Aumenta a resolução para a nativa, define a atualização para 120Hz e coloca a taxa de bits no máximo — esta é a melhor forma de jogar shooters competitivos como o Fortnite no Linux.

Também podes transformar uma máquina Omarchy no anfitrião executando `omarchy install service sunshine`, o que instala o Sunshine e abre as portas de streaming do Moonlight para a tua LAN e o Tailscale.

## Battle.net

Instala o [Battle.net](https://eu.shop.battle.net/en-us) selecionando _Instalar > Jogos > Battle.net_ no menu Omarchy (`Super + Space`). Isto dá-te títulos como Diablo, Starcraft e World of Warcraft como uma instalação autónoma a correr sob o GE-Proton — sem precisares de Steam, Lutris ou Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (jogos Windows)

Instala o [Lutris](https://lutris.net/) selecionando _Instalar > Jogos > Lutris_ no menu Omarchy (`Super + Space`). O Lutris é a forma de jogar jogos Windows de lojas como a EA e a Ubisoft Connect que não têm o seu próprio instalador acima.

A instalação é um bocado tosca e, por vezes, parece que não está a acontecer nada — tem paciência, ele está a trabalhar em segundo plano.

## Heroic Launcher (Epic Games)

Instala o [Heroic Launcher](https://heroicgameslauncher.com/) selecionando _Instalar > Jogos > Heroic (Epic Games)_ no menu Omarchy (`Super + Space`). O Heroic permite-te correr títulos da Epic Games, como o OddSparks, que não dependem de anti-cheat — mais jogos da GOG e do Amazon Prime Gaming. Infelizmente, isso significa nada de Fortnite e nada de Rocket League — até o Tim Sweeney vir para o Linux, é o mais perto que se consegue.

Tal como o Lutris, pode parecer lento e tosco enquanto instala jogos. Dá-lhe tempo.
