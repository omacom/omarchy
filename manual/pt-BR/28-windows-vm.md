# VM do Windows

O Omarchy oferece uma maneira fácil de executar o Windows por meio de uma VM Docker. Você pode instalá-la usando _Instalar > Windows_ no menu do Omarchy (`Super + Space`).

Sua máquina precisa de virtualização KVM para isso, o que a maioria tem — mas às vezes ela está desligada no BIOS, e o instalador informará se for o caso. Você também vai querer o espaço em disco: o que você der ao Windows, mais cerca de 10GB para a própria imagem.

O instalador pergunta quanta RAM, quantos núcleos de CPU e quanto disco entregar (64GB ou mais é o piso sensato), depois um nome de usuário e uma senha do Windows. Deixe-os em branco e você obtém `docker` / `admin`. O download leva um bom tempo — de 10 a 15 minutos é normal — e você pode acompanhar o progresso no navegador em `http://127.0.0.1:8006`. O navegador pede o mesmo nome de usuário e senha antes de abrir o console.

 ![windows-vm](images/windows-vm.webp)

## Usando-a

Depois de instalada, inicie _Windows_ pelo inicializador de aplicativos. Isso inicia a VM se ela ainda não estiver em execução e o conecta via RDP, em tela cheia. Dê de 15 a 30 segundos a ela em uma inicialização a frio.

A sessão RDP carrega som, seu microfone e uma área de transferência compartilhada, então copiar texto entre Linux e Windows simplesmente funciona. A resolução acompanha sua janela, e o Omarchy repassa seu dimensionamento de tela, então não é uma bagunça embaçada em uma tela HiDPI.

Quando você fecha a janela RDP, a VM desliga automaticamente. Se você preferir deixá-la em execução — digamos que você tem algo trabalhando lá dentro — inicie-a com `omarchy windows vm launch --keep-alive`.

O resto dos controles está no mesmo comando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Compartilhando arquivos

O diretório `~/Windows` no seu diretório inicial é compartilhado automaticamente com a VM. Coloque arquivos lá se quiser que eles fiquem acessíveis ao Windows. A VM não tem acesso a nenhuma outra parte do seu sistema de arquivos, então você está a salvo de qualquer coisa desagradável do lado do Windows. O próprio disco virtual dela está disponível em `~/.windows`.

Esses caminhos iniciais familiares permanecem em seus próprios sistemas de arquivos. Eles também podem ser links simbólicos para diretórios de sua propriedade, o que é útil quando o disco virtual está em uma unidade maior. O instalador mede o espaço livre no sistema de arquivos que realmente contém `~/.windows`, não necessariamente o sistema de arquivos que contém seu diretório inicial.

Mantenha os caminhos do disco e os compartilhados como diretórios separados e sem sobreposição. A remoção esvazia deliberadamente o diretório do disco, mas preserva o diretório compartilhado. Imediatamente antes da exclusão, o Omarchy realiza uma verificação limitada de contenção e se recusa a remover qualquer coisa se essa verificação expirar ou não conseguir provar que as duas árvores são separadas.

Antes de a VM iniciar, o Omarchy abre e fixa esses dois diretórios e depois monta com bind os inodes exatos dos diretórios em âncoras privadas por usuário abaixo de `/var/lib/omarchy/windows/mounts`. O Docker só enxerga essas âncoras protegidas pelo root. Isso preserva locais de disco personalizados, ao mesmo tempo impedindo que outro processo executado como você troque um caminho verificado antes que o contêiner privilegiado o consuma. Os diretórios de disco e compartilhados existentes são apertados para o modo `0700` durante a migração, para que outras contas locais não possam navegar pelo conteúdo deles.

As portas da VM são vinculadas só ao localhost, então nada na sua rede pode alcançar a máquina Windows. O console web também exige o nome de usuário e a senha do Windows configurados, impedindo que outra conta local controle a VM pela porta 8006.

## Limites e licenciamento

Não há passthrough de GPU com essa configuração, então ela não é adequada para jogos ou edição de vídeo. É uma ótima maneira de executar o Microsoft Office ou qualquer outra coisa que você absolutamente precise ter.

A versão instalada é o Windows 11 Pro, não ativado. Você precisará da sua própria chave de licença para usar os recursos restritos.

Se este computador veio com o Windows, a chave OEM ainda está no firmware, mesmo depois de instalar o Omarchy. Imprima-a com `omarchy windows key`. Essa chave está vinculada a esta máquina — ela ativará o Windows reinstalado neste hardware, mas geralmente não ativará a VM.

Você pode alterar a alocação de recursos mais tarde executando de novo `omarchy-windows-vm install`, o que reescreve a configuração da VM a partir das suas respostas. O próprio arquivo compose agora fica em `/var/lib/omarchy/windows/docker-compose.yml` e pertence ao root — isso é deliberado, para que um processo executado como você não possa reescrevê-lo e fazer com que a inicialização privilegiada monte todo o seu disco no contêiner. Se você precisar editá-lo manualmente (por exemplo, para montar um dispositivo USB), edite-o com `sudo` e veja todas as opções no [projeto Dockur Windows](https://github.com/dockur/windows).

Para se livrar de tudo, use _Remover > Windows_ no menu do Omarchy. Isso exclui o disco da VM e todos os dados dela, então certifique-se de que qualquer coisa com a qual você se importe já tenha saído de `~/Windows` primeiro.
