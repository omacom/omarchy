# Instalações não assistidas

A ISO do Omarchy pode se instalar sem ninguém no teclado. Se o instalador encontrar um segundo drive com o rótulo `cidata` contendo seus arquivos de configuração, ele os copia, pula o assistente de configuração por completo e reinicia sozinho já no sistema pronto. Nenhum build especial da ISO, nenhuma entrada extra no menu de boot — sem um drive desses conectado, nada muda e você recebe o assistente normal.

Isso faz do Omarchy uma ótima imagem base para ambientes de desenvolvimento descartáveis: crie uma VM no Proxmox ou com o Packer, inicialize, saia de perto e acesse via SSH. `cidata` é o rótulo `NoCloud` do cloud-init, então todas as ferramentas de virtualização comuns já sabem como anexar um drive assim.

## Os arquivos de configuração

Os arquivos são exatamente aqueles que o próprio assistente do instalador grava, então a maneira mais fácil de conseguir um conjunto inicial é executar uma instalação interativa (em uma VM, por exemplo) e copiar o que ele gravou em `/root`:

| Arquivo | Obrigatório | Finalidade |
|------|----------|---------|
| `user_configuration.json` | Sim | Disco, nome do host, fuso horário, teclado |
| `user_credentials.json` | Sim | Nome de usuário e hash da senha, e a frase secreta do LUKS para uma instalação criptografada |
| `user_encrypt_installation.txt` | Não | `true` quando a configuração carrega um bloco `disk_encryption` |
| `authorized_keys` | Não | Chaves públicas SSH, uma por linha |
| `tailscale_authkey` | Não | Chave de autenticação do Tailscale para entrar na sua tailnet na primeira inicialização |

Gere o hash da senha para o `user_credentials.json` com `openssl passwd -6 "yourpassword"`.

O nome e o e-mail para os commits do git não fazem parte da instalação. Defina-os assim que a máquina estiver no ar, via SSH, por exemplo, com `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Você também pode colocar um arquivo vazio chamado `defer-provisioning` no lugar do `user_credentials.json`. Isso executa a mesma [instalação para preparar para outro proprietário](02-getting-started.md) que você pode acionar interativamente: a máquina é instalada sem nenhum dado pessoal, e quem inicializá-la primeiro escolhe o teclado e cria seu usuário. É o modo para estações de criação de imagens, em que o drive não deve carregar as credenciais de ninguém.

## Acesso SSH

Quando o `authorized_keys` está presente, a instalação configura as chaves como o `~/.ssh/authorized_keys` do usuário, habilita o `sshd` e abre o firewall para ele. (Uma instalação padrão do Omarchy vem com o openssh com o serviço desabilitado e a porta fechada, então uma máquina não assistida ficaria, de outro modo, inacessível.) A instalação só adiciona as suas chaves — ela não afrouxa nenhuma das outras configurações de autenticação do daemon SSH.

Quando o `tailscale_authkey` está presente, a máquina entra na sua tailnet na primeira inicialização: o Tailscale é instalado a partir dos pacotes incluídos na ISO, o firewall permite a interface da tailnet e um trabalho em segundo plano executa a entrada assim que a máquina realmente tiver rede, tentando de novo até conseguir. Use uma chave reutilizável e pré-autorizada para que uma única imagem de drive possa servir a muitas máquinas.

## Criando o drive cidata

Qualquer sistema de arquivos com o rótulo certo funciona. Uma ISO minúscula é o jeito fácil:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Depois anexe-o à VM junto com a ISO do Omarchy. Aqui está um exemplo completo no Proxmox:

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

A ordem de boot coloca o disco primeiro de propósito: o disco vazio cai para a ISO na primeira inicialização, e o sistema instalado inicializa a partir do disco para sempre depois disso.

## Duas ressalvas

Instalações criptografadas não assistidas não são totalmente não assistidas — alguém ainda precisa digitar a frase secreta do LUKS na primeira inicialização. E essa frase secreta fica no nível superior do `user_credentials.json` como `encryption_password` — o archinstall a lê ali, não do bloco `disk_encryption` no `user_configuration.json` — então trate um drive cidata criado a partir de uma instalação criptografada como o segredo que ele é.
