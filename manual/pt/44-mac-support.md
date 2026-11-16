# Suporte para Mac

O Omarchy tem suporte integrado para **Macs com Intel**. De momento, há algumas limitações conhecidas, mas, desde que esteja ciente delas e não se importe, pode dar uma nova vida aos seus Macs antigos ao instalar o Omarchy.

Tenha em atenção que a instalação num Mac da série M não é diretamente suportada neste momento. Pode saber mais sobre o estado disto no #omarchy-on-other no nosso [Discord](https://discord.gg/tXFUdasqhY).

Num teste simples, conseguimos obter ganhos de desempenho de 36% num MacBook Pro de 2019 só por instalar o Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalar o Omarchy no Mac

De momento, o Omarchy só suporta ser o **único** sistema operativo instalado. Durante a instalação, o disco será apagado e o MacOS deixará de poder arrancar.

Pode restaurá-lo mais tarde através do Internet Recovery, se quiser.

Para esta parte, vamos assumir que já leu [Primeiros Passos](02-getting-started.md) e que tem a sua pen USB pronta. Se não tiver, faça-o agora.

#### Desativar o Secure Boot

É necessário desativar o Secure Boot da Apple para poder arrancar a partir da pen USB de arranque, bem como do sistema operativo. Para o desativar, faça o seguinte:

1. Desligue o Mac
2. Ligue-o e prima _imediatamente_ sem soltar Command-R até ver aparecer o ecrã de carregamento
3. Selecione o seu utilizador e introduza a sua palavra-passe, se lhe for pedido
4. Quando estiver no ecrã de recuperação, escolha **Utilities > Startup Security Utility** na barra de menus
5. Introduza a sua palavra-passe quando lhe for pedido para se autenticar
6. Escolha "No Security" nas opções do Secure Boot
7. Escolha "Allow booting from external or removable media" nas opções do External Boot

#### Iniciar a Instalação

1. Insira a pen USB
2. Reinicie o Mac e prima _imediatamente_ sem soltar Option até ver um ecrã com os dispositivos de arranque
3. Selecione o dispositivo EFI Boot cor de laranja
4. Continue com a [instalação normal](02-getting-started.md)

O instalador deteta o hardware do Mac e aplica automaticamente as correções necessárias: controladores e firmware Wi-Fi da Broadcom, o controlador de teclado SPI nos modelos MacBook que dele precisam e uma correção de suspensão NVMe para esses mesmos modelos.

### Limitações Conhecidas

Os membros da comunidade estão constantemente a trabalhar em soluções para estes desafios, por isso, se isto for problemático para si, junte-se ao #omarchy-on-other no nosso [Discord](https://discord.gg/tXFUdasqhY) e veja se existem métodos atualizados para os resolver.

#### Dispositivos com chip T1

O chip Apple T1 foi apresentado no final de 2016 e utilizado exclusivamente nos modelos MacBook Pro de primeira geração com Touch Bar.
- MacBook Pro de 13 polegadas (2016, duas portas Thunderbolt 3) – Modelo: A1706
- MacBook Pro de 13 polegadas (2016, quatro portas Thunderbolt 3) – Modelo: A1708
- MacBook Pro de 15 polegadas (2016) – Modelo: A1707

#### Problemas Conhecidos

- A Touch Bar não funciona
- O som não funciona

#### Dispositivos com chip T2

O Apple T2 Security Chip foi apresentado em 2017. O chip T2 foi descontinuado com a transição para o Apple silicon (chips da série M) a partir de 2020.

- iMac Pro (2017) – Modelo: A1862
- MacBook Pro de 13 polegadas (2018, quatro portas Thunderbolt 3) – Modelo: A1989
- MacBook Pro de 15 polegadas (2018) – Modelo: A1990
- MacBook Air (Retina, 13 polegadas, 2018) – Modelo: A1932
- Mac mini (2018) – Modelo: A1998
- MacBook Pro de 13 polegadas (2019, duas portas Thunderbolt 3) – Modelo: A2159
- MacBook Pro de 13 polegadas (2019, quatro portas Thunderbolt 3) – Modelo: A2178
- MacBook Pro de 15 polegadas (2019) – Modelo: A1990
- iMac (Retina 5K, 27 polegadas, 2020) – Modelo: A2115 (iMac20,1 e iMac20,2)
- MacBook Pro de 13 polegadas (2020, duas portas Thunderbolt 3) – Modelo: A2265
- MacBook Pro de 15 polegadas (2020) – Modelo: A1990

Nestes modelos, o instalador configura automaticamente o kernel `linux-t2` corrigido, a configuração de áudio T2, o firmware Wi-Fi/Bluetooth Broadcom da Apple e o controlo das ventoinhas através de `t2fanrd`. A Touch Bar funciona com o suporte integrado do kernel ao estilo Boot Camp.

#### iMac Retina 5K (2017)

O iMac de 27 polegadas de 2017 não tem chip T2, por isso o instalador configura-o como os outros Macs com Intel.

- iMac (Retina 5K, 27 polegadas, 2017) – Modelo: A1419

#### Problemas Conhecidos

- O ecrã não funciona na sua resolução nativa de 5120×2880: o painel é composto por dois mosaicos e o controlador de origem só ativa um
- O som não funciona
- O controlo do brilho não tem qualquer efeito
- A suspensão bloqueia a máquina; só desligar e voltar a ligar permite recuperá-la

Um patcher da comunidade para este modelo corrige o ecrã, o som e o brilho: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
