# Suporte a Mac

O Omarchy tem suporte integrado para **Macs Intel**. No momento, há algumas limitações conhecidas, mas, desde que você esteja ciente delas e de acordo com isso, você pode dar uma nova vida aos seus Macs antigos instalando o Omarchy.

Observe que a instalação em um Mac da série M não é suportada diretamente no momento. Você pode saber mais sobre o estado disso em #omarchy-on-other no nosso [Discord](https://discord.gg/tXFUdasqhY).

Em um teste simples, conseguimos ganhos de desempenho de 36% em um MacBook Pro de 2019 só instalando o Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalando o Omarchy no Mac

No momento, o Omarchy só suporta ser o **único** sistema operacional instalado. Durante a instalação, o disco será apagado e o MacOS não poderá mais ser inicializado.

Você ainda pode restaurá-lo depois via Internet Recovery, se quiser.

Para esta parte, vamos presumir que você já revisou [Primeiros passos](02-getting-started.md) e está com o seu pendrive USB pronto. Se não estiver, vá fazer isso agora.

#### Desative o Secure Boot

É necessário desativar o Secure Boot da Apple para inicializar tanto pelo USB inicializável quanto pelo sistema operacional. Para desativá-lo, faça o seguinte:

1. Desligue o seu Mac
2. Ligue-o e _imediatamente_ pressione e segure Command-R até ver a tela de carregamento aparecer
3. Selecione o seu usuário e digite a sua senha, se solicitado
4. Já na tela de recuperação, escolha **Utilitários > Utilitário de Segurança de Inicialização** na barra de menus
5. Digite a sua senha quando solicitado para autenticar
6. Escolha "Sem Segurança" nas opções do Secure Boot
7. Escolha "Permitir inicialização a partir de mídia externa ou removível" nas opções de Inicialização Externa

#### Inicie a instalação

1. Insira o pendrive USB
2. Reinicie o seu Mac e _imediatamente_ pressione e segure Option até ver uma tela com os dispositivos de inicialização
3. Selecione o dispositivo EFI Boot laranja
4. Prossiga com a [instalação normalmente](02-getting-started.md)

O instalador detecta o hardware do Mac e aplica as correções necessárias automaticamente: drivers e firmware Wi-Fi Broadcom, o driver de teclado SPI nos modelos de MacBook que precisam dele e uma correção de suspensão NVMe para esses mesmos modelos.

### Limitações conhecidas

Membros da comunidade estão trabalhando constantemente em soluções para esses desafios, então, se eles forem um problema para você, entre em #omarchy-on-other no nosso [Discord](https://discord.gg/tXFUdasqhY) e veja se há algum método atualizado para resolvê-los.

#### Dispositivos com chip T1

O chip Apple T1 foi lançado no final de 2016 e usado exclusivamente nos modelos de MacBook Pro de primeira geração com Touch Bar.
- MacBook Pro de 13 polegadas (2016, duas portas Thunderbolt 3) – Modelo: A1706
- MacBook Pro de 13 polegadas (2016, quatro portas Thunderbolt 3) – Modelo: A1708
- MacBook Pro de 15 polegadas (2016) – Modelo: A1707

#### Problemas conhecidos

- A Touch Bar não funciona
- O som não funciona

#### Dispositivos com chip T2

O chip de segurança Apple T2 foi lançado em 2017. O chip T2 foi descontinuado com a transição para o Apple silicon (chips da série M), a partir de 2020.

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

Nesses modelos, o instalador configura automaticamente o kernel `linux-t2` com correções, a configuração de áudio do T2, o firmware Wi-Fi/Bluetooth Broadcom da Apple e o controle de ventiladores via `t2fanrd`. A Touch Bar funciona com o suporte integrado do kernel, no estilo Boot Camp.

#### iMac Retina 5K (2017)

O iMac de 27 polegadas de 2017 não tem chip T2, então o instalador o configura como os outros Macs Intel.

- iMac (Retina 5K, 27 polegadas, 2017) – Modelo: A1419

#### Problemas conhecidos

- A tela não funciona na sua resolução nativa de 5120×2880: o painel é composto por dois blocos, e o driver padrão acende apenas um
- O som não funciona
- O controle de brilho não tem efeito
- A suspensão trava a máquina; só desligar e ligar novamente a recupera

Um patcher da comunidade para esse modelo corrige a tela, o som e o brilho: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
