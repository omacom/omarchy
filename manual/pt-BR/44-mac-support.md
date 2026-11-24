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

Macs com M4 e mais recentes ainda não são suportados. O suporte ao M4 está em teste no canal edge e vem a seguir. O instalador verifica seu Mac antes de alterar qualquer coisa.

Em qualquer Mac com Apple Silicon, incluindo M4 e mais recentes, você pode rodar o Omarchy em uma máquina virtual com o [Try Omarchy](https://github.com/omacom/try-omarchy).

### O que você precisa

- macOS 15 Sequoia ou posterior, e uma conta de administrador
- Espaço livre em disco para o Omarchy. O instalador sugere um tamanho e permite que você o altere.
- Um backup do seu Mac, energia e uma conexão com a internet. A instalação baixa vários gigabytes.

### Instalando

Você instala a partir do macOS. Instale o Omarchy Installer com o [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Ou baixe o Omarchy Installer mais recente da sua [página de releases](https://github.com/omacom/omarchy-mac-installer/releases) e abra-o.

O instalador verifica seu Mac, mostra o plano e abre espaço para o Omarchy encolhendo a partição do macOS. O macOS permanece no disco e nenhum pendrive USB é necessário. Quando a primeira etapa termina, ele orienta você a concluir a configuração no macOS Recovery: desligue, segure o botão liga/desliga até aparecer "Loading startup options", escolha Omarchy e siga as etapas.

Na primeira inicialização, o Omarchy pede uma senha que criptografa seu disco. Não há chave de recuperação: se você esquecer a senha, seus arquivos do Omarchy não poderão ser recuperados.

Para alternar entre Omarchy e macOS depois, desligue, depois segure o botão liga/desliga até as opções de inicialização aparecerem e escolha um deles.

### Vindo do Omarchy Mac

O Omarchy Mac agora faz parte do Omarchy para Apple Silicon, e todos os Macs que o rodavam são suportados. Sua instalação atual continua rodando, e os pacotes de sistema dela ainda atualizam, mas ela não recebe mais atualizações do Omarchy. Não há prazo e não há atualização no local: você faz backup, remove a instalação antiga, instala do zero e restaura. As etapas 2 a 5 acontecem no macOS, então abra esta página no seu celular antes de reiniciar.

1. **Faça backup a partir do Omarchy, para fora do Mac.** Remover a instalação antiga a apaga, e o macOS não consegue ler o disco do Omarchy. Copie sua pasta pessoal para um disco externo ou outro computador, incluindo chaves SSH e GPG, perfis do navegador e trabalho não enviado. Salve sua lista de pacotes com `pacman -Qqe > ~/packages.txt`. Faça backup do macOS também, pois tanto a remoção quanto a instalação redimensionam o disco dele.
2. **Inicie seu Mac no macOS.** Desligue, segure o botão liga/desliga até as opções de inicialização aparecerem e escolha macOS.
3. **Instale o Omarchy Installer** como mostrado em [Instalando](#installing).
4. **Remova a instalação antiga.** Abra o Omarchy Installer e escolha Installation > Remove Omarchy. Ele mostra o que será excluído e devolve o espaço ao macOS. Se ele não reconhecer sua instalação, ele para sem alterar o disco. Peça ajuda no [Discord](https://discord.gg/tXFUdasqhY) em vez de excluir partições manualmente, o que pode apagar o macOS.
5. **Instale o Omarchy para Apple Silicon** com o instalador.
6. **Restaure seus arquivos.** Traga suas configurações de volta uma parte por vez em vez de copiar todo o `~/.config` por cima dos novos padrões, pois configurações antigas podem sobrescrevê-los.

### Bom saber

- Em MacBooks com M1 e M2, desperte do repouso abrindo a tampa ou pressionando o botão liga/desliga.
- Dúvidas ou problemas: pergunte no nosso [Discord](https://discord.gg/tXFUdasqhY).

O [README do instalador](https://github.com/omacom/omarchy-mac-installer#readme) cobre canais de release, atualização do instalador e remoção do Omarchy.

## Macs Intel

Em um teste simples, conseguimos ganhos de desempenho de 36% em um MacBook Pro de 2019 só instalando o Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalando o Omarchy no Mac

No momento, o Omarchy suporta apenas ser o **único** sistema operacional instalado. Durante a instalação, o disco será apagado e o macOS não será mais inicializável.

Você ainda pode restaurá-lo depois via Internet Recovery, se quiser.

Para esta parte, vamos supor que você já revisou [Primeiros passos](02-getting-started.md) e já deixou seu pendrive USB pronto. Se não, vá em frente e faça isso agora.

#### Desative o Secure Boot

É necessário desativar o Secure Boot da Apple para inicializar pelo USB inicializável, assim como pelo sistema operacional. Para desativá-lo, faça o seguinte:

1. Desligue seu Mac
2. Ligue-o e _imediatamente_ pressione e segure Command-R até ver a tela de carregamento aparecer
3. Selecione seu usuário e digite sua senha, se solicitado
4. Já na tela de recuperação, escolha **Utilities > Startup Security Utility** na barra de menus
5. Digite sua senha quando solicitado para autenticar
6. Escolha "No Security" nas opções de Secure Boot
7. Escolha "Allow booting from external or removable media" nas opções de External Boot

#### Inicie a instalação

1. Insira o pendrive USB
2. Reinicie seu Mac e _imediatamente_ pressione e segure Option até ver uma tela com dispositivos de inicialização
3. Selecione o dispositivo EFI Boot laranja
4. Prossiga com a [instalação normalmente](02-getting-started.md)

O instalador detecta o hardware do Mac e aplica as correções necessárias automaticamente: drivers e firmware Wi-Fi da Broadcom, o driver da câmera FaceTime HD em máquinas com Broadcom 1570 (o firmware dela é baixado da Apple assim que o Mac fica online, já que o instalador funciona offline), o driver de teclado SPI nos modelos de MacBook que precisam dele e uma correção de suspensão NVMe para esses mesmos modelos.

### Limitações conhecidas

Membros da comunidade estão trabalhando constantemente em soluções para esses desafios, então, se eles forem problemáticos para você, entre em #omarchy-on-other no nosso [Discord](https://discord.gg/tXFUdasqhY) e veja se há algum método atualizado para resolvê-los.

#### Câmera FaceTime HD

O driver da câmera trava a máquina se estiver carregado quando o Mac hiberna, então ele é descarregado antes. Ele não pode ser descarregado enquanto um aplicativo estiver com a câmera aberta, então a hibernação é cancelada com uma notificação nomeando o aplicativo: feche-o e hiberne novamente. Isso inclui hibernar automaticamente com bateria crítica e suspender-depois-hibernar, que é recusado antes de suspender. A suspensão comum é recusada pelo próprio driver enquanto a câmera estiver aberta, sem notificação.

O firmware da câmera é baixado da Apple, então a câmera só funciona depois que o Mac já esteve online. O download começa na inicialização e é tentado novamente a cada 15 minutos enquanto o problema for a rede; se o arquivo da Apple tiver mudado, ele para e espera uma atualização do Omarchy. Se a câmera não aparecer, `journalctl -u facetimehd-firmware-fetcher` diz o porquê, `sudo systemctl restart facetimehd-firmware-fetcher` tenta novamente, e uma reinicialização carrega o driver se o download tiver terminado, mas a câmera ainda não estiver lá.

#### Dispositivos com chip T1

O chip Apple T1 foi lançado no final de 2016 e usado exclusivamente nos modelos de MacBook Pro de primeira geração com Touch Bar.
- MacBook Pro 13 polegadas (2016, duas portas Thunderbolt 3) – Modelo: A1706
- MacBook Pro 13 polegadas (2016, quatro portas Thunderbolt 3) – Modelo: A1708
- MacBook Pro 15 polegadas (2016) – Modelo: A1707

#### Problemas conhecidos

- A Touch Bar não funciona
- O som não está funcionando

#### Dispositivos com chip T2

O Apple T2 Security Chip foi lançado em 2017. O chip T2 foi descontinuado com a transição para o Apple silicon (chips da série M) a partir de 2020.

- iMac Pro (2017) – Modelo: A1862
- MacBook Pro 13 polegadas (2018, quatro portas Thunderbolt 3) – Modelo: A1989
- MacBook Pro 15 polegadas (2018) – Modelo: A1990
- MacBook Air (Retina, 13 polegadas, 2018) – Modelo: A1932
- Mac mini (2018) – Modelo: A1998
- MacBook Pro 13 polegadas (2019, duas portas Thunderbolt 3) – Modelo: A2159
- MacBook Pro 13 polegadas (2019, quatro portas Thunderbolt 3) – Modelo: A2178
- MacBook Pro 15 polegadas (2019) – Modelo: A1990
- iMac (Retina 5K, 27 polegadas, 2020) – Modelo: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13 polegadas (2020, duas portas Thunderbolt 3) – Modelo: A2265
- MacBook Pro 15 polegadas (2020) – Modelo: A1990

Nesses modelos, o instalador configura automaticamente o kernel `linux-t2` com patch, a configuração de áudio do T2, o firmware Wi-Fi/Bluetooth Broadcom da Apple e o controle de ventoinha via `t2fanrd`. A Touch Bar roda com o suporte estilo Boot Camp integrado ao kernel.

#### iMac Retina 5K (2017)

O iMac de 27 polegadas de 2017 não tem chip T2, então o instalador o configura como os outros Macs Intel.

- iMac (Retina 5K, 27 polegadas, 2017) – Modelo: A1419

#### Problemas conhecidos

- A tela não roda na sua resolução nativa de 5120×2880: o painel é dividido em duas partes, e o driver padrão acende apenas uma
- O som não está funcionando
- O controle de brilho não tem efeito
- O repouso trava a máquina; só desligar e ligar novamente a recupera

Um patcher da comunidade para este modelo corrige a tela, o som e o brilho: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
