# Suspensão do sistema

O Omarchy habilita a suspensão por padrão, e a hibernação depois que ela é configurada, mas se você estiver tendo problemas com qualquer uma delas na sua máquina, pode desativá-las.

Em máquinas NVIDIA GB10, como o DGX Spark e o ASUS Ascent GX10, a suspensão e a hibernação vêm desativadas, assim como no DGX OS da NVIDIA, porque ainda não foi demonstrado que a suspensão funciona nesse hardware. O mesmo vale para o ASUS Zenbook A16 (UX3607OA), em que a suspensão ainda não coloca o chip para dormir totalmente e pode travar durante a noite. A alternância de suspensão e a configuração de hibernação não se aplicam a ele. Para reativar a suspensão, remova `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` com `sudo rm`; a opção Suspender então volta ao menu, e a hibernação pode ser configurada como em outras máquinas. Executar `sudo omarchy apply hardware --install-user "$USER"` recoloca o arquivo.

### Perfis de energia

Em um laptop, o Omarchy lembra seu perfil de energia separadamente para quando ele está conectado à tomada e quando está funcionando na bateria, e alterna entre os dois conforme você conecta e desconecta. De fábrica, isso significa desempenho na tomada e equilibrado na bateria.

Você pode ver o que sua máquina oferece com `omarchy powerprofiles list` e definir o perfil desejado para o estado em que você está no momento com `omarchy powerprofiles set autodetect power-saver`. Para definir o outro estado sem desconectar nada, nomeie-o diretamente: `omarchy powerprofiles set battery power-saver`. O que você escolher é o que você terá de volta na próxima vez que estiver nesse estado.

### Alternar suspensão

Você alterna a suspensão executando `omarchy toggle suspend` no terminal. Isso apenas mostra/oculta a opção em _Sistema_ (ou `Super + Esc`), e então você pode ver se ela funciona de forma consistente no seu sistema. Se não funcionar, você pode ocultá-la novamente com o mesmo comando.

### Alternar hibernação

Você configura a hibernação executando `omarchy hibernation setup` no terminal (ela não está disponível em Macs com Apple Silicon). A hibernação cria um subvolume /swap na sua unidade de inicialização do tamanho da sua alocação de RAM física, então garanta que você tenha bastante espaço sobrando. Em uma máquina de 32GB, você sempre vai precisar de 32GB+ livres para esse volume. A hibernação também exige o bootloader padrão Limine.

Depois de configurada, você verá a opção de hibernar em _Sistema_ (ou `Super + Esc`), e então pode ver se ela funciona de forma consistente no seu sistema. Se não funcionar, você pode removê-la novamente executando `omarchy hibernation remove`.
