# VM Windows

O Omarchy oferece uma forma fácil de correr o Windows através de uma VM Docker. Podes instalá-la usando _Instalar > Windows_ no menu Omarchy (`Super + Space`).

A tua máquina precisa de virtualização KVM para isto, o que a maioria tem — mas, por vezes, está desligada na BIOS, e o instalador diz-te se for esse o caso. Também vais querer o espaço em disco: aquilo que deres ao Windows, mais cerca de 10GB para a própria imagem.

O instalador pergunta quanta RAM, quantos núcleos de CPU e quanto disco deve entregar (64GB ou mais é o mínimo sensato), e depois um nome de utilizador e uma palavra-passe do Windows. Deixa-os em branco e obténs `docker` / `admin`. A transferência demora algum tempo — 10 a 15 minutos é normal — e podes acompanhar o progresso no navegador em `http://127.0.0.1:8006`. O navegador pede o mesmo nome de utilizador e palavra-passe antes de abrir a consola.

 ![windows-vm](images/windows-vm.webp)

## Utilizá-la

Depois de instalada, inicia _Windows_ a partir do lançador de aplicações. Isso inicia a VM, se ela ainda não estiver a correr, e liga-te por RDP, em ecrã inteiro. Dá-lhe 15 a 30 segundos num arranque a frio.

A sessão RDP transporta som, o teu microfone e uma área de transferência partilhada, por isso copiar texto entre o Linux e o Windows simplesmente funciona. A resolução segue a tua janela, e o Omarchy faz passar o escalonamento do teu ecrã, por isso não fica uma confusão desfocada num ecrã HiDPI.

Quando fechas a janela RDP, a VM encerra automaticamente. Se preferires deixá-la a correr — digamos que tens alguma coisa a trabalhar lá dentro —, inicia-a antes com `omarchy windows vm launch --keep-alive`.

Os restantes controlos estão no mesmo comando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Partilhar ficheiros

O diretório `~/Windows` no teu diretório pessoal é partilhado automaticamente com a VM. Coloca lá ficheiros se quiseres que fiquem acessíveis ao Windows. A VM não tem acesso a mais nenhuma parte do teu sistema de ficheiros, por isso estás a salvo de qualquer coisa desagradável do lado do Windows. O seu próprio disco virtual está disponível em `~/.windows`.

Esses caminhos familiares do diretório pessoal mantêm-se nos seus próprios sistemas de ficheiros. Também podem ser ligações simbólicas para diretórios teus, o que é útil quando o disco virtual vive numa unidade maior. O instalador mede o espaço livre no sistema de ficheiros que realmente contém `~/.windows`, não necessariamente no sistema de ficheiros que contém o teu diretório pessoal.

Mantém os caminhos do disco e da partilha como diretórios separados e sem sobreposição. A remoção esvazia deliberadamente o diretório do disco, mas preserva o diretório partilhado. Imediatamente antes da eliminação, o Omarchy faz uma verificação de contenção limitada e recusa-se a remover seja o que for se essa verificação exceder o tempo limite ou não conseguir provar que as duas árvores estão separadas.

Antes de a VM arrancar, o Omarchy abre e fixa esses dois diretórios e depois monta, por ligação, os inodes exatos dos diretórios em âncoras privadas por utilizador em `/var/lib/omarchy/windows/mounts`. O Docker só vê essas âncoras protegidas pelo root. Isto preserva localizações de disco personalizadas, ao mesmo tempo que impede que outro processo a correr como tu troque um caminho verificado antes de o contentor privilegiado o consumir. Os diretórios de disco e partilhados existentes são apertados para o modo `0700` durante a migração, para que outras contas locais não possam espreitar o seu conteúdo.

As portas da VM estão ligadas apenas ao localhost, por isso nada na tua rede consegue chegar à máquina Windows. A consola web também exige o nome de utilizador e a palavra-passe do Windows configurados, impedindo que outra conta local controle a VM através da porta 8006.

## Limites e licenciamento

Não há passagem de GPU com esta configuração, por isso não é adequada para jogos nem para edição de vídeo. É uma ótima forma de correr o Microsoft Office ou o que mais tenhas mesmo de ter.

A versão instalada é o Windows 11 Pro, não ativado. Vais precisar da tua própria chave de licença para usares as funcionalidades restritas.

Se este computador veio com Windows, a chave OEM continua no firmware mesmo depois de instalares o Omarchy. Imprime-a com `omarchy windows key`. Essa chave está ligada a esta máquina — ativa o Windows reinstalado neste hardware, mas, normalmente, não ativa a VM.

Podes alterar a atribuição de recursos mais tarde executando outra vez `omarchy-windows-vm install`, o que reescreve a configuração da VM a partir das tuas respostas. O próprio ficheiro compose vive agora em `/var/lib/omarchy/windows/docker-compose.yml` e pertence ao root — isto é deliberado, para que um processo a correr como tu não o possa reescrever e fazer com que o arranque privilegiado monte todo o teu disco dentro do contentor. Se precisares de o editar à mão (por exemplo, para montar um dispositivo USB), edita-o com `sudo` e vê todas as opções no [projeto Dockur Windows](https://github.com/dockur/windows).

Para te livrares daquilo tudo, usa _Remover > Windows_ no menu Omarchy. Isso apaga o disco da VM e todos os seus dados, por isso certifica-te de que tudo o que te interessa saiu primeiro de `~/Windows`.
