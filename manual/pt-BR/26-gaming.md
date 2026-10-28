# Jogos

O Omarchy não é só para _pRoDUcTiViDaDe_, é também para se divertir, e o que é mais divertido do que jogar? O Omarchy vem com um conjunto completo de opções de jogos — Steam e RetroArch para jogos nativos e retrô, Battle.net, Lutris e Heroic para lojas que não são a Steam, Moonlight para streaming de PC, Xbox Cloud Gaming + NVIDIA GeForce NOW para a nuvem, além do sempre presente Minecraft.

Graças ao incrível trabalho da Valve na [camada de compatibilidade Proton](https://en.wikipedia.org/wiki/Proton_(software)), agora há dezenas de milhares de jogos modernos jogáveis no Linux. Ah, e você sabia que o [Steam Deck](https://store.steampowered.com/steamdeck/) na verdade executa Arch!

Todos os instaladores de jogos ficam em _Instalar > Jogos_ no menu do Omarchy (`Super + Space`). Se algum dia você quiser desfazer um deles, use _Remover > Jogos_.

## Steam

Instale a [Steam](https://store.steampowered.com/) selecionando _Instalar > Jogos > Steam_ no menu do Omarchy (`Super + Space`).

Depois de instalá-la, você poderá iniciar a Steam com `Super + Space`.

Observe que a Steam pode levar de 10 a 20 segundos para iniciar, e ela não dará nenhum retorno visual de que está carregando.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instale o [RetroArch](https://www.retroarch.com/) selecionando _Instalar > Jogos > RetroArch_ no menu do Omarchy (`Super + Space`). Ele vem com o conjunto completo de núcleos libretro, então todos os sistemas clássicos estão cobertos.

O RetroArch vem totalmente pré-configurado com o belo shader CRT Royale para aquele visual retrô perfeito.

Para começar:

1. Coloque seus arquivos BIOS em `~/Games/bios` e suas ROMs em `~/Games/roms`.
2. Inicie o RetroArch com `Super + Space` e digitando `retro`.
3. Escaneie o diretório `~/Games/roms` e você estará pronto para jogar.

Você também pode dar a um jogo favorito sua própria entrada no inicializador de aplicativos com _Instalar > Jogos > RetroArch Game Launcher_, o que permite escolher um núcleo e uma ROM e pular direto para o jogo a partir de `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instale o aplicativo web do Xbox Cloud Gaming selecionando _Instalar > Jogos > Xbox Cloud Gaming_ no menu do Omarchy (`Super + Space`). É "apenas" um aplicativo web para o serviço, mas é rápido de iniciar e funciona muito bem em 1080p.

Se você já tem o Xbox Game Pass, essa é uma maneira sólida de jogar Fortnite e outros títulos que você não consegue executar nativamente no Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instale o serviço de jogos em nuvem [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) selecionando _Instalar > Jogos > NVIDIA GeForce NOW_ no menu do Omarchy (`Super + Space`). Outra ótima maneira de jogar títulos que não estão disponíveis nativamente no Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instale o Minecraft selecionando _Instalar > Jogos > Minecraft_ no menu do Omarchy (`Super + Space`).

Como a Steam, observe que pode levar um bom tempo depois de fazer login ou de iniciar para que a próxima tela apareça, e você não receberá nenhum retorno enquanto espera.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Controles do Xbox

Instale o suporte para controles Bluetooth do Xbox selecionando _Instalar > Jogos > Controles do Xbox_ no menu do Omarchy (`Super + Space`). Pareie os controles via Bluetooth (`Super + Ctrl + B`) e eles funcionarão em todos os seus jogos. Você não precisa disso se estiver apenas conectando seu controle com um cabo USB-C.

## Moonlight (Streaming de jogos de um PC)

O [cliente Moonlight](https://github.com/moonlight-stream/moonlight-qt) vem pré-instalado no Omarchy, então você pode transmitir jogos de um PC com Windows executando o [Sunshine](https://app.lizardbyte.dev/Sunshine/) imediatamente. Inicie o Moonlight com `Super + Space`.

Se tanto sua máquina Omarchy quanto o PC de jogos remoto estiverem conectados por cabo, a experiência é indistinguível de jogar localmente. Aumente a resolução para a nativa, defina a taxa de atualização para 120Hz e leve a taxa de bits ao máximo — essa é a melhor maneira de jogar atiradores competitivos como o Fortnite no Linux.

Você também pode transformar uma máquina Omarchy no host executando `omarchy install service sunshine`, o que instala o Sunshine e abre as portas de streaming do Moonlight para a sua LAN e para o Tailscale.

## Battle.net

Instale o [Battle.net](https://eu.shop.battle.net/en-us) selecionando _Instalar > Jogos > Battle.net_ no menu do Omarchy (`Super + Space`). Isso oferece títulos como Diablo, Starcraft e World of Warcraft como uma instalação independente executada sob o GE-Proton — sem necessidade de Steam, Lutris ou Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (jogos do Windows)

Instale o [Lutris](https://lutris.net/) selecionando _Instalar > Jogos > Lutris_ no menu do Omarchy (`Super + Space`). O Lutris é a maneira de jogar jogos do Windows de lojas como EA e Ubisoft Connect que não têm seu próprio instalador acima.

A instalação é um pouco truncada e parece que nada está acontecendo em alguns momentos — apenas seja paciente, ele está trabalhando em segundo plano.

## Heroic Launcher (Epic Games)

Instale o [Heroic Launcher](https://heroicgameslauncher.com/) selecionando _Instalar > Jogos > Heroic (Epic Games)_ no menu do Omarchy (`Super + Space`). O Heroic permite executar títulos da Epic Games, como OddSparks, que não dependem de anti-cheat — além de jogos do GOG e do Amazon Prime Gaming. Infelizmente, isso significa nada de Fortnite e nada de Rocket League — até que o Tim Sweeney venha para o Linux, esse é o mais próximo que chegamos.

Como o Lutris, ele pode parecer lento e truncado ao instalar jogos. Dê um tempo a ele.
