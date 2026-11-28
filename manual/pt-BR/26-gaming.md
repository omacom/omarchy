# Jogos

O Omarchy não é só para _pRoDUtIvIdAdE_, também é para se divertir, e o que é mais divertido do que jogar? O Omarchy vem com um conjunto completo de opções de jogos — Steam e RetroArch para jogos nativos e retrô, Battle.net, Lutris e Heroic para lojas fora da Steam, Moonlight para streaming de PC, Xbox Cloud Gaming + NVIDIA GeForce NOW para a nuvem, além do eterno Minecraft.

Graças ao trabalho incrível da Valve na [camada de compatibilidade proton](https://en.wikipedia.org/wiki/Proton_(software)), agora há dezenas de milhares de jogos modernos jogáveis no Linux. Ah, e você sabia que o [Steam Deck](https://store.steampowered.com/steamdeck/) na verdade roda Arch!

Todos os instaladores de jogos ficam em _Install > Gaming_ no menu do Omarchy (`Super + Space`). Se você quiser desfazer algum deles, use _Remove > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris e Heroic são oferecidos apenas em máquinas x86.

## Steam

Instale a [Steam](https://store.steampowered.com/) selecionando _Install > Gaming > Steam_ no menu do Omarchy (`Super + Space`).

Depois de instalar, você poderá iniciar a Steam com `Super + Space`.

Observe que a Steam pode levar de 10 a 20 segundos para iniciar, e ela não vai dar nenhum retorno visual de que está carregando.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instale o [RetroArch](https://www.retroarch.com/) selecionando _Install > Gaming > RetroArch_ no menu do Omarchy (`Super + Space`). Ele vem com o conjunto completo de cores libretro, então todos os sistemas clássicos estão cobertos.

O RetroArch vem totalmente pré-configurado com o belo shader CRT Royale para aquele visual retrô perfeito.

Para começar:

1. Coloque seus arquivos de BIOS em `~/Games/bios` e suas ROMs em `~/Games/roms`.
2. Inicie o RetroArch com `Super + Space` e digitando `retro`.
3. Escaneie o diretório `~/Games/roms` e você estará pronto para jogar.

Você também pode dar a um jogo favorito sua própria entrada no launcher de aplicativos com _Install > Gaming > RetroArch Game Launcher_, que permite escolher um core e uma ROM e pular direto para o jogo a partir de `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instale o web app do Xbox Cloud Gaming selecionando _Install > Gaming > Xbox Cloud Gaming_ no menu do Omarchy (`Super + Space`). É "só" um web app para o serviço, mas inicia rápido e roda muito bem em 1080p.

Se você já tem Xbox Game Pass, essa é uma forma sólida de jogar Fortnite e outros títulos que você não consegue rodar nativamente no Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instale o serviço de jogos na nuvem [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) selecionando _Install > Gaming > NVIDIA GeForce NOW_ no menu do Omarchy (`Super + Space`). Outra ótima forma de jogar títulos que não estão disponíveis nativamente no Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instale o Minecraft selecionando _Install > Gaming > Minecraft_ no menu do Omarchy (`Super + Space`).

Assim como a Steam, observe que pode demorar um pouco depois de fazer login ou iniciar para a próxima tela aparecer, e você não vai receber nenhum retorno enquanto espera.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Controles do Xbox

Instale o suporte a controles Xbox Bluetooth selecionando _Install > Gaming > Xbox Controllers_ no menu do Omarchy (`Super + Space`). Pareie os controles via Bluetooth (`Super + Ctrl + B`) e eles vão funcionar em todos os seus jogos. Você não precisa disso se estiver apenas conectando seu controle com um cabo USB-C.

## Moonlight (Streaming de jogos de um PC)

Instale o [cliente Moonlight](https://github.com/moonlight-stream/moonlight-qt) selecionando _Install > Gaming > Moonlight_ no menu do Omarchy (`Super + Space`), e você poderá transmitir jogos de um PC com Windows rodando o [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Se tanto sua máquina com Omarchy quanto o PC de jogos remoto estiverem conectados por cabo, a experiência é indistinguível de jogar localmente. Aumente a resolução para a nativa, defina a atualização para 120Hz e coloque a taxa de bits no máximo — essa é a melhor forma de jogar shooters competitivos como Fortnite no Linux.

Você também pode transformar uma máquina com Omarchy em host executando `omarchy install service sunshine`, que instala o Sunshine e abre as portas de streaming do Moonlight para sua LAN e para o Tailscale.

## Battle.net

Instale a [Battle.net](https://eu.shop.battle.net/en-us) selecionando _Install > Gaming > Battle.net_ no menu do Omarchy (`Super + Space`). Isso lhe dá títulos como Diablo, Starcraft e World of Warcraft como uma instalação independente rodando sob o GE-Proton — sem precisar de Steam, Lutris ou Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Jogos de Windows)

Instale o [Lutris](https://lutris.net/) selecionando _Install > Gaming > Lutris_ no menu do Omarchy (`Super + Space`). O Lutris é a forma de jogar jogos de Windows de lojas como EA e Ubisoft Connect que não têm seu próprio instalador acima.

A instalação é meio capenga e parece que nada está acontecendo em alguns momentos — só tenha paciência, ele está trabalhando em segundo plano.

## Heroic Launcher (Epic Games)

Instale o [Heroic Launcher](https://heroicgameslauncher.com/) selecionando _Install > Gaming > Heroic (Epic Games)_ no menu do Omarchy (`Super + Space`). O Heroic permite rodar títulos da Epic Games, como OddSparks, que não dependem de anti-cheat — além de jogos da GOG e do Amazon Prime Gaming. Infelizmente, isso significa nada de Fortnite e nada de Rocket League — até que Tim Sweeney venha para o Linux, é o mais perto que dá para chegar.

Assim como o Lutris, ele pode parecer lento e capenga ao instalar jogos. Dê tempo a ele.
