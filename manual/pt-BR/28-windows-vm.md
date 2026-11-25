# VM do Windows

O Omarchy oferece uma maneira fácil de executar o Windows por meio de uma VM do Docker em máquinas x86_64. Você pode instalá-la usando _Install > Windows_ no menu do Omarchy (`Super + Space`).

Sua máquina precisa de virtualização KVM para isso, que a maioria tem — mas às vezes ela vem desativada na BIOS, e o instalador vai avisar se for esse o caso. Você também vai precisar de espaço em disco: o que você der ao Windows, mais cerca de 10GB para a própria imagem.

O instalador pergunta quanta RAM, quantos núcleos de CPU e quanto disco entregar (64GB ou mais é o mínimo sensato), e depois um nome de usuário e uma senha do Windows. Deixe-os em branco e você fica com `docker` / `admin`. O download demora um pouco — 10-15 minutos é normal — e você pode acompanhar o progresso no navegador em `http://127.0.0.1:8006`. O navegador pede o mesmo nome de usuário e a mesma senha antes de abrir o console.

 ![windows-vm](images/windows-vm.webp)

## Como usar

Depois de instalada, inicie _Windows_ pelo lançador de aplicativos. Isso inicia a VM, se ela ainda não estiver em execução, e conecta você via RDP, em tela cheia. Dê a ela 15-30 segundos em uma inicialização a frio.

A sessão RDP leva o som, seu microfone e uma área de transferência compartilhada, então copiar texto entre Linux e Windows simplesmente funciona. A resolução acompanha sua janela, e o Omarchy repassa a escala da sua tela, então não fica aquela bagunça borrada em uma tela HiDPI.

Quando você fecha a janela do RDP, a VM desliga automaticamente. Se você preferir deixá-la em execução — digamos que tenha algo trabalhando lá dentro — inicie-a com `omarchy windows vm launch --keep-alive`.

Os demais controles estão no mesmo comando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Compartilhando arquivos

O diretório `~/Windows` no seu diretório pessoal é compartilhado automaticamente com a VM. Coloque arquivos lá se quiser que eles fiquem acessíveis ao Windows. A VM não tem acesso a nenhuma outra parte do seu sistema de arquivos, então você está seguro contra qualquer coisa desagradável do lado do Windows. O disco virtual dela fica disponível em `~/.windows`.

Esses caminhos familiares do diretório pessoal ficam em seus próprios sistemas de arquivos. Eles também podem ser symlinks para diretórios seus, o que é útil quando o disco virtual fica em uma unidade maior. O instalador mede o espaço livre no sistema de arquivos que realmente contém `~/.windows`, não necessariamente no sistema de arquivos que contém seu diretório pessoal.

Mantenha os caminhos do disco e do compartilhamento como diretórios separados e sem sobreposição. A remoção esvazia deliberadamente o diretório do disco, mas preserva o diretório compartilhado. Imediatamente antes da exclusão, o Omarchy faz uma verificação de contenção limitada e se recusa a remover qualquer coisa se essa verificação expirar ou não conseguir provar que as duas árvores são separadas.

Antes de a VM iniciar, o Omarchy abre e fixa esses dois diretórios, e depois monta por bind-mount os inodes exatos dos diretórios em âncoras privadas por usuário abaixo de `/var/lib/omarchy/windows/mounts`. O Docker enxerga apenas essas âncoras protegidas pelo root. Isso preserva locais de disco personalizados e ao mesmo tempo impede que outro processo em execução como você troque um caminho já verificado antes que o contêiner privilegiado o consuma. Os diretórios de disco e compartilhado existentes são reforçados para o modo `0700` durante a migração, para que outras contas locais não possam navegar pelo conteúdo deles.

As portas da VM ficam vinculadas somente ao localhost, então nada na sua rede consegue alcançar a máquina Windows. O console web também exige o nome de usuário e a senha do Windows configurados, impedindo que outra conta local controle a VM pela porta 8006.

## Limites e licenciamento

Não há passthrough de GPU nessa configuração, então ela não serve para jogos nem para edição de vídeo. É uma ótima maneira de executar o Microsoft Office ou qualquer outra coisa que você absolutamente precise ter.

A versão instalada é o Windows 11 Pro, não ativado. Você vai precisar da sua própria chave de licença para usar os recursos restritos.

Se este computador veio com Windows, a chave OEM ainda está no firmware, mesmo depois de instalar o Omarchy. Exiba-a com `omarchy windows key`. Essa chave está vinculada a esta máquina — ela vai ativar o Windows reinstalado neste hardware, mas normalmente não vai ativar a VM.

Você pode alterar a alocação de recursos depois executando `omarchy windows vm install` em um terminal, o que reescreve a configuração da VM a partir das suas respostas. O próprio arquivo compose agora fica em `/var/lib/omarchy/windows/docker-compose.yml` e pertence ao root — isso é deliberado, para que um processo em execução como você não possa reescrevê-lo e fazer a inicialização privilegiada montar todo o seu disco dentro do contêiner. Se você precisar editá-lo manualmente (por exemplo, para montar um dispositivo USB), edite-o com `sudo` e veja todas as opções no [projeto Dockur Windows](https://github.com/dockur/windows).

Para se livrar de tudo, use _Remove > Windows_ no menu do Omarchy. Isso apaga o disco da VM em `~/.windows` e tudo o que foi instalado dentro do Windows, então copie antes para fora da VM qualquer coisa de que você precise. Sua pasta compartilhada `~/Windows` é deixada em paz.
