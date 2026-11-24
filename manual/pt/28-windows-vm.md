# VM Windows

O Omarchy oferece uma forma fácil de executar o Windows através de uma VM Docker em máquinas x86_64. Pode instalá-lo através de _Install > Windows_ no menu do Omarchy (`Super + Space`).

A sua máquina precisa de virtualização KVM para isto, o que a maioria tem — mas por vezes está desligada na BIOS, e o instalador avisa-o se for esse o caso. Também vai querer espaço em disco: o que der ao Windows, mais cerca de 10GB para a própria imagem.

O instalador pergunta quanta RAM, quantos núcleos de CPU e quanto disco quer atribuir (64GB ou mais é o mínimo sensato), e depois um nome de utilizador e uma palavra-passe do Windows. Deixe-os em branco e fica com `docker` / `admin`. A transferência demora algum tempo — 10-15 minutos é normal — e pode acompanhar o progresso no browser em `http://127.0.0.1:8006`. O browser pede o mesmo nome de utilizador e a mesma palavra-passe antes de abrir a consola.

 ![windows-vm](images/windows-vm.webp)

## Utilizar

Depois de instalado, abra _Windows_ a partir do lançador de aplicações. Isso arranca a VM, se ainda não estiver a funcionar, e liga-o por RDP, em ecrã inteiro. Dê-lhe 15-30 segundos num arranque a frio.

A sessão RDP transporta o som, o seu microfone e uma área de transferência partilhada, por isso copiar texto entre o Linux e o Windows simplesmente funciona. A resolução acompanha a sua janela, e o Omarchy faz passar a escala do seu ecrã, por isso não fica uma confusão desfocada num ecrã HiDPI.

Quando fecha a janela RDP, a VM desliga-se automaticamente. Se preferir deixá-la a funcionar — por exemplo, se tiver alguma coisa a trabalhar lá dentro — abra-a com `omarchy windows vm launch --keep-alive` em alternativa.

Os restantes controlos estão no mesmo comando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Partilhar ficheiros

O diretório `~/Windows`, no seu diretório pessoal, é partilhado automaticamente com a VM. Coloque lá ficheiros se quiser que fiquem acessíveis ao Windows. A VM não tem acesso a nenhuma outra parte do seu sistema de ficheiros, por isso está a salvo de qualquer coisa desagradável do lado do Windows. O seu próprio disco virtual está disponível em `~/.windows`.

Esses caminhos familiares da pasta pessoal mantêm-se nos seus próprios sistemas de ficheiros. Também podem ser symlinks para diretórios seus, o que é útil quando o disco virtual está numa unidade maior. O instalador mede o espaço livre no sistema de ficheiros que contém efetivamente `~/.windows`, não necessariamente no sistema de ficheiros que contém o seu diretório pessoal.

Mantenha os caminhos do disco e da partilha como diretórios separados e sem sobreposição. A remoção esvazia deliberadamente o diretório do disco, mas preserva o diretório partilhado. Imediatamente antes da eliminação, o Omarchy faz uma verificação de contenção limitada e recusa-se a remover seja o que for se essa verificação exceder o tempo limite ou não conseguir provar que as duas árvores estão separadas.

Antes de a VM arrancar, o Omarchy abre e fixa esses dois diretórios e, em seguida, faz bind-mount dos inodes exatos dos diretórios em âncoras privadas por utilizador abaixo de `/var/lib/omarchy/windows/mounts`. O Docker só vê essas âncoras protegidas por root. Isto preserva localizações de disco personalizadas e, ao mesmo tempo, impede que outro processo executado com o seu utilizador troque um caminho verificado antes de o contentor privilegiado o consumir. Os diretórios de disco e de partilha existentes são apertados para o modo `0700` durante a migração, para que outras contas locais não possam navegar pelo seu conteúdo.

As portas da VM estão ligadas apenas a localhost, por isso nada na sua rede consegue chegar à máquina Windows. A consola web também exige o nome de utilizador e a palavra-passe do Windows configurados, o que impede que outra conta local controle a VM através da porta 8006.

## Limites e licenciamento

Não há passthrough de GPU com esta configuração, por isso não é adequada para jogos nem para edição de vídeo. É uma excelente forma de executar o Microsoft Office ou qualquer outra coisa de que absolutamente precise.

A versão instalada é o Windows 11 Pro, não ativado. Vai precisar da sua própria chave de licença para utilizar as funcionalidades condicionadas.

Se este computador vinha com o Windows, a chave OEM continua no firmware mesmo depois de instalar o Omarchy. Imprima-a com `omarchy windows key`. Essa chave está associada a esta máquina — vai ativar o Windows reinstalado neste hardware, mas normalmente não vai ativar a VM.

Pode alterar a atribuição de recursos mais tarde, executando `omarchy windows vm install` num terminal, o que reescreve a configuração da VM a partir das suas respostas. O próprio ficheiro compose vive agora em `/var/lib/omarchy/windows/docker-compose.yml` e pertence a root — é deliberado, para que um processo executado com o seu utilizador não o possa reescrever e fazer com que o arranque privilegiado monte todo o seu disco no contentor. Se precisar de o editar manualmente (por exemplo, para montar um dispositivo USB), edite-o com `sudo` e consulte todas as opções em [o projeto Dockur Windows](https://github.com/dockur/windows).

Para se livrar de tudo isto, utilize _Remove > Windows_ no menu do Omarchy. Isso apaga o disco da VM em `~/.windows` e tudo o que estiver instalado dentro do Windows, por isso copie primeiro para fora da VM tudo o que precisar. A sua pasta partilhada `~/Windows` fica intacta.
