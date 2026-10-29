# Suporte para Mac

O Omarchy tem suporte integrado para **Mac com Intel**. Existem neste momento algumas limitações conhecidas, mas desde que esteja ciente delas e as aceite, pode dar uma nova vida aos seus Mac antigos instalando o Omarchy.

Note que a instalação num Mac da série M não é diretamente suportada neste momento. Pode saber mais sobre o estado disto em #omarchy-on-other no nosso [Discord](https://discord.gg/tXFUdasqhY).

Num teste simples, conseguimos obter ganhos de desempenho de 36% num MacBook Pro de 2019 apenas instalando o Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalar o Omarchy no Mac

O Omarchy só suporta, neste momento, ser o **único** sistema operativo instalado. Durante a instalação, a unidade será apagada e o MacOS deixará de ser arrancável.

Poderá ainda restaurá-lo mais tarde através da Recuperação pela Internet, se quiser.

Para efeitos desta parte, vamos assumir que já leu [Primeiros passos](02-getting-started.md) e que já tem a sua pen USB pronta. Se não tiver, avance e faça-o agora.

#### Desativar o Arranque Seguro

É necessário desativar o Arranque Seguro da Apple para arrancar a partir da pen USB arrancável, bem como do sistema operativo. Para o desativar, faça o seguinte:

1. Desligue o seu Mac
2. Ligue-o e prima e mantenha _imediatamente_ Command-R até ver aparecer o ecrã de carregamento
3. Selecione o seu utilizador e introduza a sua palavra-passe, se lhe for pedido
4. Já no ecrã de recuperação, escolha **Utilitários > Utilitário de Segurança de Arranque** na barra de menus
5. Introduza a sua palavra-passe quando lhe for pedido para se autenticar
6. Escolha «Sem segurança» nas opções de Arranque Seguro
7. Escolha «Permitir arranque a partir de suportes externos ou amovíveis» nas opções de Arranque Externo

#### Iniciar a instalação

1. Insira a pen USB
2. Reinicie o seu Mac e prima e mantenha _imediatamente_ Option até ver um ecrã de dispositivos de arranque
3. Selecione o dispositivo EFI Boot laranja
4. Prossiga com a [instalação como habitualmente](02-getting-started.md)

O instalador deteta o hardware Mac e aplica automaticamente as correções necessárias: drivers e firmware Wi-Fi Broadcom, o driver de teclado SPI nos modelos MacBook que dele precisam e uma correção de suspensão NVMe para esses mesmos modelos.

### Limitações conhecidas

Os membros da comunidade estão constantemente a trabalhar em soluções para estes desafios, por isso, se eles forem problemáticos para si, junte-se a #omarchy-on-other no nosso [Discord](https://discord.gg/tXFUdasqhY) e veja se há métodos atualizados para os resolver.

#### Dispositivos com chip T1

O chip Apple T1 foi introduzido no final de 2016 e usado exclusivamente nos modelos MacBook Pro de primeira geração com Touch Bar.
- MacBook Pro de 13 polegadas (2016, duas portas Thunderbolt 3) – Modelo: A1706
- MacBook Pro de 13 polegadas (2016, quatro portas Thunderbolt 3) – Modelo: A1708
- MacBook Pro de 15 polegadas (2016) – Modelo: A1707

#### Problemas conhecidos

- A Touch Bar não funciona
- O som não está a funcionar

#### Dispositivos com chip T2

O Chip de Segurança Apple T2 foi introduzido em 2017. O chip T2 foi descontinuado com a transição para o Apple silicon (chips da série M) a partir de 2020.

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

Nestes modelos, o instalador configura automaticamente o kernel corrigido `linux-t2`, a configuração de áudio T2, o firmware Wi-Fi/Bluetooth Broadcom da Apple e o controlo da ventoinha através de `t2fanrd`. A Touch Bar funciona com o suporte integrado ao estilo Boot Camp do kernel.
