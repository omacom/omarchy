# Instalações Não Assistidas

A ISO do Omarchy consegue instalar-se sem ninguém ao teclado. Se o instalador encontrar uma segunda unidade com a etiqueta `cidata` contendo os seus ficheiros de configuração, copia-os, salta por completo o assistente de configuração e reinicia sozinho para o sistema já pronto. Não é preciso nenhuma compilação especial da ISO, nenhuma entrada extra no menu de arranque — sem essa unidade ligada, nada muda e obtém o assistente normal.

Isto faz do Omarchy uma excelente imagem base para ambientes de desenvolvimento descartáveis: crie uma VM no Proxmox ou com o Packer, arranque-a, afaste-se, entre por SSH. `cidata` é a etiqueta `NoCloud` do cloud-init, por isso todas as ferramentas de virtualização comuns já sabem como ligar uma unidade dessas.

## Os ficheiros de configuração

Os ficheiros são exatamente o que o próprio assistente do instalador escreve, por isso a forma mais fácil de obter um conjunto inicial é fazer uma instalação interativa (numa VM, por exemplo) e copiar o que ele escreveu para `/root`:

| Ficheiro | Obrigatório | Finalidade |
|------|----------|---------|
| `user_configuration.json` | Sim | Disco, nome da máquina, fuso horário, teclado |
| `user_credentials.json` | Sim | Nome de utilizador e hash da palavra-passe, e a frase-passe LUKS para uma instalação encriptada |
| `user_encrypt_installation.txt` | Não | `true` quando a configuração contém um bloco `disk_encryption` |
| `authorized_keys` | Não | Chaves públicas SSH, uma por linha |
| `tailscale_authkey` | Não | Chave de autenticação do Tailscale para aderir à sua tailnet no primeiro arranque |

Gere o hash da palavra-passe para `user_credentials.json` com `openssl passwd -6 "yourpassword"`.

O nome e o e-mail para os commits do git não fazem parte da instalação. Defina-os quando a máquina estiver a funcionar, por SSH por exemplo, com `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Também pode deixar um ficheiro vazio chamado `defer-provisioning` em vez de `user_credentials.json`. Isso executa a mesma [instalação de preparação para outro proprietário](02-getting-started.md) que pode ativar interativamente: a máquina instala-se sem quaisquer dados pessoais, e quem a arrancar primeiro escolhe o seu teclado e cria o seu utilizador. É o modo para estações de criação de imagens, onde a unidade não deve conter as credenciais de ninguém.

## Acesso SSH

Quando o `authorized_keys` está presente, a instalação configura as chaves como o `~/.ssh/authorized_keys` do utilizador, ativa o `sshd` e abre a firewall para ele. (Uma instalação normal do Omarchy vem com o openssh com o serviço desativado e a porta fechada, por isso uma máquina sem assistência ficaria de outra forma inalcançável.) A instalação apenas adiciona as suas chaves — não afrouxa nenhuma das outras definições de autenticação do daemon SSH.

Quando o `tailscale_authkey` está presente, a máquina adere à sua tailnet no primeiro arranque: o Tailscale é instalado a partir dos pacotes incluídos na ISO, a firewall permite a interface da tailnet e uma tarefa em segundo plano executa a adesão assim que a máquina tiver realmente rede, repetindo as tentativas até conseguir. Utilize uma chave reutilizável e pré-autorizada para que uma imagem de unidade possa servir muitas máquinas.

## Criar a unidade cidata

Qualquer sistema de ficheiros com a etiqueta certa funciona. Uma ISO minúscula é a forma fácil:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Depois ligue-a à VM juntamente com a ISO do Omarchy. Aqui está um exemplo completo para o Proxmox:

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

A ordem de arranque coloca o disco em primeiro de propósito: o disco vazio passa para a ISO no primeiro arranque, e o sistema instalado arranca a partir do disco daí em diante.

## Duas ressalvas

As instalações encriptadas sem assistência não são totalmente sem assistência — alguém ainda tem de escrever a frase-passe LUKS no primeiro arranque. E essa frase-passe vai no nível superior de `user_credentials.json` como `encryption_password` — o archinstall lê-a aí, e não a partir do bloco `disk_encryption` em `user_configuration.json` — por isso trate uma unidade cidata criada a partir de uma instalação encriptada como o segredo que ela é.
