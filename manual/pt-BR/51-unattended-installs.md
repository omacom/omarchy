# Instalações autônomas

A ISO do Omarchy pode se instalar sozinha, sem ninguém no teclado. Se o instalador encontrar um segundo disco rotulado `cidata` carregando seus arquivos de configuração, ele os copia, pula completamente o assistente de configuração e reinicia no sistema pronto por conta própria. Sem uma compilação especial da ISO, sem uma entrada extra no menu de boot — sem esse disco conectado, nada muda e você tem o assistente normal.

Isso torna o Omarchy ótimo como imagem base para ambientes de desenvolvimento descartáveis: crie uma VM no Proxmox ou com o Packer, inicialize-a, vá embora, entre por SSH. `cidata` é o rótulo `NoCloud` do cloud-init, então todas as ferramentas comuns de virtualização já sabem como conectar um disco assim.

## Os arquivos de configuração

Os arquivos são exatamente o que o próprio assistente do instalador escreve, então a maneira mais fácil de obter um conjunto inicial é executar uma instalação interativa (em uma VM, digamos) e copiar o que ele escreveu em `/root`:

| Arquivo | Obrigatório | Finalidade |
|------|----------|---------|
| `user_configuration.json` | Sim | Disco, hostname, fuso horário, teclado |
| `user_credentials.json` | Sim | Nome de usuário e hash da senha |
| `user_full_name.txt` | Não | Nome completo no Git |
| `user_email_address.txt` | Não | E-mail do Git |
| `user_encrypt_installation.txt` | Não | `true` quando a configuração carrega um bloco `disk_encryption` |
| `authorized_keys` | Não | Chaves públicas SSH, uma por linha |
| `tailscale_authkey` | Não | Chave de autenticação do Tailscale para entrar na sua tailnet na primeira inicialização |

Gere o hash da senha para `user_credentials.json` com `openssl passwd -6 "yourpassword"`.

Você também pode colocar um arquivo vazio chamado `defer-provisioning` no lugar de `user_credentials.json`. Isso executa a mesma [instalação preparada para outro dono](02-getting-started.md) que você pode acionar interativamente: a máquina é instalada sem nenhum dado pessoal, e quem a inicializar primeiro escolhe seu teclado e cria seu usuário. Esse é o modo para plataformas de geração de imagem, onde o disco não deve carregar as credenciais de ninguém.

## Acesso SSH

Quando `authorized_keys` está presente, a instalação configura as chaves como o `~/.ssh/authorized_keys` do usuário, ativa o `sshd` e abre o firewall para ele. (Uma instalação padrão do Omarchy traz o openssh com o serviço desativado e a porta fechada, então uma máquina autônoma ficaria inacessível de outra forma.) A instalação só adiciona suas chaves — ela não afrouxa nenhuma das outras configurações de autenticação do daemon SSH.

Quando `tailscale_authkey` está presente, a máquina entra na sua tailnet na primeira inicialização em vez disso: o Tailscale é instalado a partir dos pacotes incluídos na ISO, o firewall permite a interface da tailnet, e um trabalho em segundo plano executa a entrada assim que a máquina realmente tem rede, tentando de novo até conseguir. Use uma chave reutilizável e pré-autorizada para que uma imagem de disco possa servir a muitas máquinas.

## Construindo o disco cidata

Qualquer sistema de arquivos com o rótulo certo funciona. Uma ISO minúscula é o caminho fácil:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Depois conecte-a à VM ao lado da ISO do Omarchy. Aqui está um exemplo completo no Proxmox:

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

A ordem de boot lista o disco primeiro de propósito: o disco vazio cai para a ISO na primeira inicialização, e o sistema instalado inicializa do disco para sempre depois disso.

## Dois avisos

Instalações autônomas criptografadas não são totalmente autônomas — alguém ainda precisa digitar a senha do LUKS na primeira inicialização. E o bloco `disk_encryption` em `user_configuration.json` carrega essa senha em texto simples, então trate um disco cidata construído a partir de uma instalação criptografada como o segredo que ele é.
