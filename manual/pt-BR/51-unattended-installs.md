# Instalações autônomas

A ISO do Omarchy pode se instalar sem ninguém no teclado. Se o instalador encontrar um segundo disco com o rótulo `cidata` contendo seus arquivos de configuração, ele os copia, pula o assistente de configuração por completo e reinicia sozinho no sistema pronto. Nenhuma versão especial da ISO, nenhuma entrada extra no menu de inicialização — sem um disco assim conectado, nada muda e você tem o assistente normal.

Isso torna o Omarchy ótimo como imagem base para ambientes de desenvolvimento descartáveis: crie uma VM no Proxmox ou com o Packer, inicialize, saia de perto, acesse por SSH. `cidata` é o rótulo `NoCloud` do cloud-init, então todas as ferramentas comuns de virtualização já sabem como conectar um disco assim.

## Os arquivos de configuração

Os arquivos são exatamente os que o próprio assistente do instalador grava, então a maneira mais fácil de obter um conjunto inicial é executar uma instalação interativa (numa VM, por exemplo) e copiar o que ele gravou em `/root`:

| Arquivo | Obrigatório | Finalidade |
|------|----------|---------|
| `user_configuration.json` | Sim | Disco, nome do host, fuso horário, teclado |
| `user_credentials.json` | Sim | Nome de usuário e hash da senha |
| `user_encrypt_installation.txt` | Não | `true` quando a configuração contém um bloco `disk_encryption` |
| `authorized_keys` | Não | Chaves públicas SSH, uma por linha |
| `tailscale_authkey` | Não | Chave de autenticação do Tailscale para entrar no seu tailnet na primeira inicialização |

Gere o hash da senha para `user_credentials.json` com `openssl passwd -6 "yourpassword"`.

O nome e o e-mail para os commits do git não fazem parte da instalação. Configure-os quando a máquina estiver no ar, por SSH, por exemplo, com `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Você também pode colocar um arquivo vazio chamado `defer-provisioning` no lugar de `user_credentials.json`. Isso executa a mesma [instalação de preparação para outro proprietário](02-getting-started.md) que você pode acionar interativamente: a máquina é instalada sem nenhum dado pessoal, e quem a inicializar primeiro escolhe o teclado e cria seu usuário. Esse é o modo para equipamentos de imagem, em que o disco não deve carregar as credenciais de ninguém.

## Acesso por SSH

Quando `authorized_keys` está presente, a instalação configura as chaves como o `~/.ssh/authorized_keys` do usuário, ativa o `sshd` e abre o firewall para ele. (Uma instalação padrão do Omarchy vem com o openssh com o serviço desativado e a porta fechada, então uma máquina autônoma ficaria inacessível de outra forma.) A instalação só adiciona as suas chaves — ela não afrouxa nenhuma das outras configurações de autenticação do daemon SSH.

Quando `tailscale_authkey` está presente, a máquina entra no seu tailnet na primeira inicialização: o Tailscale é instalado a partir dos pacotes incluídos na ISO, o firewall permite a interface do tailnet e um trabalho em segundo plano executa a entrada assim que a máquina realmente tiver rede, tentando de novo até conseguir. Use uma chave reutilizável e pré-autorizada para que uma única imagem de disco possa atender muitas máquinas.

## Criando o disco cidata

Qualquer sistema de arquivos com o rótulo certo funciona. Uma ISO minúscula é a maneira fácil:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Depois conecte-o à VM junto com a ISO do Omarchy. Aqui está um exemplo completo no Proxmox:

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

A ordem de inicialização coloca o disco em primeiro de propósito: o disco vazio passa direto para a ISO na primeira inicialização, e o sistema instalado inicializa a partir do disco para sempre depois disso.

## Dois avisos

Instalações autônomas criptografadas não são totalmente autônomas — alguém ainda precisa digitar a senha LUKS na primeira inicialização. E o bloco `disk_encryption` em `user_configuration.json` carrega essa senha em texto simples, então trate um disco cidata criado a partir de uma instalação criptografada como o segredo que ele é.
