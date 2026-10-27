# Instalações não assistidas

O ISO do Omarchy pode instalar-se sem ninguém ao teclado. Se o instalador encontrar uma segunda unidade com o rótulo `cidata` que contenha os seus ficheiros de configuração, copia-os, ignora por completo o assistente de configuração e reinicia sozinho para o sistema acabado. Sem compilação especial do ISO, sem entrada extra no menu de arranque — sem essa unidade ligada, nada muda e obtém o assistente normal.

Isto torna o Omarchy excelente como imagem base para ambientes de desenvolvimento descartáveis: crie uma VM no Proxmox ou com o Packer, arranque-a, vá-se embora, aceda por SSH. `cidata` é o rótulo `NoCloud` do cloud-init, por isso todas as ferramentas comuns de virtualização já sabem como ligar uma unidade dessas.

## Os ficheiros de configuração

Os ficheiros são exatamente o que o próprio assistente do instalador escreve, por isso a forma mais fácil de obter um conjunto inicial é executar uma instalação interativa (numa VM, por exemplo) e copiar o que ele escreveu para `/root`:

| Ficheiro | Obrigatório | Finalidade |
|------|----------|---------|
| `user_configuration.json` | Sim | Disco, nome do anfitrião, fuso horário, teclado |
| `user_credentials.json` | Sim | Nome de utilizador e hash da palavra-passe |
| `user_encrypt_installation.txt` | Não | `true` quando a configuração contém um bloco `disk_encryption` |
| `authorized_keys` | Não | Chaves públicas SSH, uma por linha |
| `tailscale_authkey` | Não | Chave de autenticação do Tailscale para aderir à sua tailnet no primeiro arranque |

Gere o hash da palavra-passe para `user_credentials.json` com `openssl passwd -6 "yourpassword"`.

O nome e o e-mail para os commits do git não fazem parte da instalação. Defina-os quando a máquina estiver a funcionar, por SSH, por exemplo, com `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Também pode deixar um ficheiro vazio chamado `defer-provisioning` em vez de `user_credentials.json`. Isto executa a mesma [instalação de preparação para outro proprietário](02-getting-started.md) que pode acionar interativamente: a máquina instala-se sem detalhes pessoais, e quem a arrancar primeiro escolhe o seu teclado e cria o seu utilizador. É o modo para equipamentos de criação de imagens, onde a unidade não deve conter credenciais de ninguém.

## Acesso SSH

Quando `authorized_keys` está presente, a instalação configura as chaves como o `~/.ssh/authorized_keys` do utilizador, ativa o `sshd` e abre a firewall para ele. (Uma instalação Omarchy de origem inclui o openssh com o serviço desativado e a porta fechada, por isso uma máquina não assistida ficaria, de outra forma, inacessível.) A instalação apenas adiciona as suas chaves — não afrouxa nenhuma das outras definições de autenticação do daemon SSH.

Quando `tailscale_authkey` está presente, a máquina adere à sua tailnet no primeiro arranque: o Tailscale é instalado a partir dos pacotes incluídos no ISO, a firewall permite a interface da tailnet, e uma tarefa em segundo plano executa a adesão assim que a máquina tiver realmente rede, tentando novamente até conseguir. Utilize uma chave reutilizável e pré-autorizada para que uma imagem de unidade possa servir muitas máquinas.

## Criar a unidade cidata

Qualquer sistema de ficheiros com o rótulo certo funciona. Um ISO pequeno é a forma fácil:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Depois ligue-a à VM juntamente com o ISO do Omarchy. Eis um exemplo completo para Proxmox:

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

A ordem de arranque coloca o disco primeiro de propósito: o disco vazio passa para o ISO no primeiro arranque, e o sistema instalado arranca do disco a partir daí.

## Duas ressalvas

As instalações não assistidas encriptadas não são totalmente não assistidas — alguém ainda tem de introduzir a frase-passe LUKS no primeiro arranque. E o bloco `disk_encryption` em `user_configuration.json` contém essa frase-passe em texto simples, por isso trate uma unidade cidata criada a partir de uma instalação encriptada como o segredo que é.
