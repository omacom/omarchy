# Suporte a Mac

O Omarchy tem suporte embutido para **Macs Intel**. Há algumas limitações conhecidas no momento, mas desde que você esteja ciente e de acordo com elas, pode dar uma vida nova aos seus Macs antigos instalando o Omarchy.

Observe que a instalação em um Mac da série M não é suportada diretamente neste momento. Você pode saber mais sobre o estado disso em #omarchy-on-other no nosso [Discord](https://discord.gg/tXFUdasqhY).

Em um teste simples, conseguimos ganhos de desempenho de 36% em um MacBook Pro de 2019 só de instalar o Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalando o Omarchy no Mac

Atualmente, o Omarchy só oferece suporte para ser o **único** sistema operacional instalado. Durante a instalação, o disco será apagado e o MacOS não poderá mais ser inicializado.

Você ainda pode restaurá-lo depois pela Recuperação pela Internet, se quiser.

Para esta parte, vamos supor que você já revisou [Primeiros passos](02-getting-started.md) e que seu pendrive USB está pronto. Se não estiver, faça isso agora.

#### Desativar o Secure Boot

É necessário desativar o Secure Boot da Apple para inicializar o USB inicializável, assim como o sistema operacional. Para desativá-lo, faça o seguinte:

1. Desligue seu Mac
2. Ligue-o e pressione e segure _imediatamente_ Command-R até ver a tela de carregamento aparecer
3. Selecione seu usuário e digite sua senha se for solicitado
4. Quando estiver na tela de recuperação, escolha **Utilities > Startup Security Utility** na barra de menus
5. Digite sua senha quando for solicitado a autenticar
6. Escolha "No Security" nas opções de Secure Boot
7. Escolha "Allow booting from external or removable media" nas opções de External Boot

#### Iniciar a instalação

1. Insira o pendrive USB
2. Reinicie seu Mac e pressione e segure _imediatamente_ Option até ver uma tela de dispositivos de inicialização
3. Selecione o dispositivo EFI Boot laranja
4. Prossiga com a [instalação normalmente](02-getting-started.md)

O instalador detecta o hardware Mac e aplica as correções necessárias automaticamente: drivers e firmware de Wi-Fi Broadcom, o driver de teclado SPI nos modelos de MacBook que precisam dele, e uma correção de suspensão do NVMe para esses mesmos modelos.

### Limitações conhecidas

Membros da comunidade estão trabalhando constantemente em soluções para esses desafios, então se eles forem problemáticos para você, entre em #omarchy-on-other no nosso [Discord](https://discord.gg/tXFUdasqhY) e veja se há algum método atualizado para resolvê-los.

#### Dispositivos com chip T1

O chip Apple T1 foi lançado no final de 2016 e usado exclusivamente nos modelos de MacBook Pro de primeira geração com Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Problemas conhecidos

- A Touch Bar não funciona
- O som não está funcionando

#### Dispositivos com chip T2

O Apple T2 Security Chip foi lançado em 2017. O chip T2 foi descontinuado com a transição para o Apple silicon (chips da série M) a partir de 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Nesses modelos, o instalador configura automaticamente o kernel `linux-t2` corrigido, a configuração de áudio do T2, o firmware de Wi-Fi/Bluetooth Broadcom da Apple e o controle de ventiladores via `t2fanrd`. A Touch Bar roda com o suporte embutido no kernel no estilo Boot Camp.
