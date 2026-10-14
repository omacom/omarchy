# Instalações não assistidas

A ISO do Omarchy pode instalar-se sozinha sem ninguém ao teclado. Se o instalador encontrar uma segunda unidade com a etiqueta `cidata` a conter os seus ficheiros de configuração, copia-os, salta por completo o assistente de configuração e reinicia por si só para o sistema acabado. Sem construção especial da ISO, sem entrada extra no menu de arranque — sem essa unidade ligada, nada muda e obtém o assistente normal.

Isto torna o Omarchy fantástico como imagem de base para ambientes de desenvolvimento descartáveis: crie uma VM no Proxmox ou com o Packer, arranque-a, afaste-se e entre por SSH. `cidata` é a etiqueta `NoCloud` do cloud-init, por isso todas as ferramentas de virtualização comuns já sabem ligar uma unidade dessas.

## Os ficheiros de configuração

Os ficheiros são exatamente o que o próprio assistente do instalador escreve, por isso a forma mais fácil de obter um conjunto inicial é fazer uma instalação interativa (numa VM, por exemplo) e copiar o que ele escreveu para `/root`:

| Ficheiro | Obrigatório | Finalidade |
|------|----------|---------|
| `user_configuration.json` | Sim | Disco, nome do anfitrião, fuso horário, teclado |
| `user_credentials.json` | Sim | Nome de utilizador e hash da palavra-passe |
| `user_full_name.txt` | Não | Nome completo do Git |
| `user_email_address.txt` | Não | E-mail do Git |
| `user_encrypt_installation.txt` | Não | `true` quando a configuração contém um bloco `disk_encryption` |
| `authorized_keys` | Não | Chaves públicas SSH, uma por linha |
| `tailscale_authkey` | Não | Chave de autenticação Tailscale para aderir à sua tailnet no primeiro arranque |

Gere o hash da palavra-passe para `user_credentials.json` com `openssl passwd -6 "yourpassword"`.

Também pode deixar um ficheiro vazio chamado `defer-provisioning` em vez de `user_credentials.json`. Isso executa a mesma [instalação preparar para outro dono](02-getting-started.md) que pode acionar interativamente: a máquina instala-se sem detalhes pessoais, e quem a arrancar primeiro escolhe o seu teclado e cria o seu utilizador. Esse é o modo para plataformas de criação de imagens, onde a unidade não deve conter credenciais de ninguém.

## Acesso SSH

Quando `authorized_keys` está presente, a instalação configura as chaves como o `~/.ssh/authorized_keys` do utilizador, ativa o `sshd` e abre a firewall para ele. (Uma instalação Omarchy de origem vem com openssh com o serviço desativado e a porta fechada, por isso uma máquina não assistida ficaria de outra forma inatingível.) A instalação só adiciona as suas chaves — não afrouxa nenhuma das outras definições de autenticação do daemon SSH.

Quando `tailscale_authkey` está presente, a máquina junta-se em vez disso à sua tailnet no primeiro arranque: o Tailscale é instalado a partir dos pacotes incluídos na ISO, a firewall permite a interface da tailnet, e um trabalho em segundo plano executa a adesão assim que a máquina tiver realmente rede, tentando de novo até conseguir. Use uma chave reutilizável e pré-autorizada para uma imagem de unidade poder servir muitas máquinas.

## Construir a unidade cidata

Qualquer sistema de ficheiros com a etiqueta certa funciona. Uma pequena ISO é a forma fácil:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Depois ligue-a à VM ao lado da ISO do Omarchy. Aqui está um exemplo completo para Proxmox:

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

A ordem de arranque lista o disco primeiro de propósito: o disco vazio passa para a ISO no primeiro arranque, e o sistema instalado arranca a partir do disco para sempre.

## Duas ressalvas

As instalações não assistidas encriptadas não são totalmente não assistidas — alguém continua a ter de escrever a frase-passe LUKS no primeiro arranque. E o bloco `disk_encryption` em `user_configuration.json` contém essa frase-passe em texto simples, por isso trate uma unidade cidata construída a partir de uma instalação encriptada como o segredo que ela é.
