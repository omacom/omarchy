# Suporte ao Mac

## Omarchy para Apple Silicon

O Omarchy para Apple Silicon é uma solução oficial da Omacom, lançada pela primeira vez com o Omarchy 4.5. Ele é instalado ao lado do macOS, e você escolhe entre os dois quando o Mac inicia.

Recebeu um aviso sobre o Omarchy Mac? Vá para [Vindo do Omarchy Mac](#coming-from-omarchy-mac).

Ele roda nestes Macs:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Macs com M4 e mais novos ainda não são suportados. O suporte ao M4 está em testes no canal edge e vem a seguir. O instalador verifica seu Mac antes de alterar qualquer coisa.

Em qualquer Mac com Apple Silicon, incluindo M4 e mais novos, você pode rodar o Omarchy em uma máquina virtual com o [Try Omarchy](https://github.com/omacom/try-omarchy).

### O que você precisa

- macOS 15 Sequoia ou posterior, e uma conta de administrador
- Espaço livre em disco para o Omarchy. O instalador sugere um tamanho e permite que você o altere.
- Um backup do seu Mac, energia e uma conexão com a internet. A instalação baixa vários gigabytes.

### Instalando

Você instala a partir do macOS. Instale o Omarchy Installer com o [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Ou baixe o Omarchy Installer mais recente na sua [página de lançamentos](https://github.com/omacom/omarchy-mac-installer/releases) e abra-o.

O instalador verifica seu Mac, mostra o plano e abre espaço para o Omarchy encolhendo a partição do macOS. O macOS permanece no disco e nenhum pendrive USB é necessário. Quando a primeira etapa termina, ele orienta você para concluir a configuração no macOS Recovery: desligue, segure o botão de ligar até que "Loading startup options" apareça, escolha Omarchy e siga as etapas.

Na primeira inicialização, o Omarchy pede uma senha que criptografa seu disco. Não há chave de recuperação: se você esquecer a senha, seus arquivos do Omarchy não poderão ser recuperados.

Para alternar entre o Omarchy e o macOS depois, desligue, segure o botão de ligar até que as opções de inicialização apareçam e escolha uma.

### Vindo do Omarchy Mac

O Omarchy Mac agora faz parte do Omarchy para Apple Silicon, e todos os Macs que o rodavam são suportados. Sua instalação atual continua rodando, e seus pacotes de sistema ainda são atualizados, mas ela não recebe mais atualizações do Omarchy. Não há prazo e nem atualização no local: você faz backup, remove a instalação antiga, instala do zero e restaura. As etapas 2 a 5 acontecem no macOS, então abra esta página no seu celular antes de reiniciar.

1. **Faça backup a partir do Omarchy, para fora do Mac.** Remover a instalação antiga a apaga, e o macOS não consegue ler o disco do Omarchy. Copie sua pasta home para um drive externo ou outro computador, incluindo chaves SSH e GPG, perfis do navegador e trabalho não enviado. Salve sua lista de pacotes com `pacman -Qqe > ~/packages.txt`. Faça backup do macOS também, pois remover e instalar redimensionam o disco dele.
2. **Inicie seu Mac no macOS.** Desligue, segure o botão de ligar até que as opções de inicialização apareçam e escolha macOS.
3. **Instale o Omarchy Installer** como mostrado em [Instalando](#installing).
4. **Remova a instalação antiga.** Abra o Omarchy Installer e escolha Installation > Remove Omarchy. Ele mostra o que será excluído e devolve o espaço ao macOS. Se ele não reconhecer sua instalação, ele para sem alterar o disco. Peça ajuda no [Discord](https://discord.gg/tXFUdasqhY) em vez de excluir partições manualmente, o que pode apagar o macOS.
5. **Instale o Omarchy para Apple Silicon** com o instalador.
6. **Restaure seus arquivos.** Traga suas configurações de volta uma parte de cada vez, em vez de copiar todo o `~/.config` por cima dos novos padrões, pois configurações antigas podem substituí-los.

### Bom saber

- Em MacBooks M1 e M2, desperte do repouso abrindo a tampa ou pressionando o botão de ligar.
- Dúvidas ou problemas: pergunte no nosso [Discord](https://discord.gg/tXFUdasqhY).

O [README do instalador](https://github.com/omacom/omarchy-mac-installer#readme) cobre canais de lançamento, atualização do instalador e remoção do Omarchy.

## Macs Intel

Em um teste simples, conseguimos obter 36% de ganho de desempenho em um MacBook Pro de 2019 só instalando o Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalando o Omarchy no Mac

O Omarchy só suporta ser o **único** sistema operacional instalado no momento. Durante a instalação, o drive será apagado e o MacOS não poderá mais ser inicializado.

Você ainda pode restaurá-lo depois via Internet Recovery, se quiser.

Para esta parte, vamos presumir que você já revisou [Primeiros passos](02-getting-started.md) e já está com seu pendrive USB pronto. Se não estiver, vá em frente e faça isso agora.

#### Desative o Secure Boot

É necessário desativar o Secure Boot da Apple para inicializar pelo USB inicializável, assim como pelo sistema operacional. Para desativá-lo, faça o seguinte:

1. Desligue seu Mac
2. Ligue-o e _imediatamente_ pressione e segure Command-R até ver a tela de carregamento aparecer
3. Selecione seu usuário e digite sua senha, se solicitado
4. Na tela de recuperação, escolha **Utilities > Startup Security Utility** na barra de menus
5. Digite sua senha quando solicitado para autenticar
6. Escolha "No Security" nas opções do Secure Boot
7. Escolha "Allow booting from external or removable media" nas opções do External Boot

#### Inicie a instalação

1. Insira o pendrive USB
2. Reinicie seu Mac e _imediatamente_ pressione e segure Option até ver uma tela com os dispositivos de inicialização
3. Selecione o dispositivo EFI Boot laranja
4. Prossiga com a [instalação normalmente](02-getting-started.md)

O instalador detecta o hardware do Mac e aplica as correções necessárias automaticamente: drivers e firmware Wi-Fi da Broadcom, o driver de teclado SPI nos modelos de MacBook que precisam dele e uma correção de suspensão NVMe para esses mesmos modelos.

### Limitações conhecidas

Membros da comunidade trabalham constantemente em soluções para esses desafios, então, se eles forem um problema para você, entre em #omarchy-on-other no nosso [Discord](https://discord.gg/tXFUdasqhY) e veja se há métodos atualizados para resolvê-los.

#### Dispositivos com chip T1

O chip Apple T1 foi lançado no final de 2016 e usado exclusivamente nos modelos de MacBook Pro de primeira geração com Touch Bar.
- MacBook Pro de 13 polegadas (2016, duas portas Thunderbolt 3) – Modelo: A1706
- MacBook Pro de 13 polegadas (2016, quatro portas Thunderbolt 3) – Modelo: A1708
- MacBook Pro de 15 polegadas (2016) – Modelo: A1707

#### Problemas conhecidos

- A Touch Bar não funciona
- O som não funciona

#### Dispositivos com chip T2

O Apple T2 Security Chip foi lançado em 2017. O chip T2 foi descontinuado com a transição para o Apple silicon (chips da série M) a partir de 2020.

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

Nesses modelos, o instalador configura automaticamente o kernel `linux-t2` corrigido, a configuração de áudio do T2, o firmware Wi-Fi/Bluetooth Broadcom da Apple e o controle de ventoinha via `t2fanrd`. A Touch Bar roda com o suporte integrado ao kernel no estilo Boot Camp.

#### iMac Retina 5K (2017)

O iMac de 27 polegadas de 2017 não tem chip T2, então o instalador o configura como os outros Macs Intel.

- iMac (Retina 5K, 27 polegadas, 2017) – Modelo: A1419

#### Problemas conhecidos

- A tela não roda na resolução nativa de 5120×2880: o painel é composto de dois blocos, e o driver padrão acende apenas um
- O som não funciona
- O controle de brilho não tem efeito
- O repouso trava a máquina; só desligar e ligar novamente a recupera

Um patcher da comunidade para este modelo corrige a tela, o som e o brilho: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
