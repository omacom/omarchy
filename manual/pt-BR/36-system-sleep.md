# Suspensão do sistema

O Omarchy ativa a suspensão por padrão, e a hibernação depois que ela é configurada, mas se você estiver tendo problemas com qualquer uma das duas na sua máquina, pode desativá-las.

Em máquinas NVIDIA GB10, como o DGX Spark e o ASUS Ascent GX10, a suspensão e a hibernação ficam desativadas, como ficam no DGX OS da NVIDIA, porque ainda não foi demonstrado que o modo de suspensão funciona nesse hardware. O alternador da suspensão e a configuração da hibernação não se aplicam a essas máquinas. Para reativar a suspensão, remova `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` com `sudo rm`; a suspensão volta então ao menu, e a hibernação pode ser configurada como nas outras máquinas. Executar `sudo omarchy apply hardware --install-user "$USER"` recoloca o arquivo.

### Perfis de energia

Em um laptop, o Omarchy lembra o seu perfil de energia separadamente para quando ele está conectado à tomada e para quando está funcionando na bateria, e alterna entre os dois conforme você conecta e desconecta o carregador. De fábrica, isso significa desempenho na tomada e equilibrado na bateria.

Você pode ver o que a sua máquina oferece com `omarchy powerprofiles list` e definir o perfil que você quer para o estado em que você está no momento com `omarchy powerprofiles set autodetect power-saver`. Para definir o outro estado sem desconectar nada, nomeie-o diretamente: `omarchy powerprofiles set battery power-saver`. O que você escolher é o que você terá de volta da próxima vez que estiver nesse estado.

### Alternar a suspensão

Você alterna a suspensão executando `omarchy toggle suspend` no terminal. Isso apenas mostra/oculta a opção em _Sistema_ (ou `Super + Esc`), e então você pode ver se ela funciona de forma consistente no seu sistema. Se não funcionar, você pode ocultá-la novamente com o mesmo comando.

### Alternar a hibernação

Você configura a hibernação executando `omarchy hibernation setup` no terminal (ela não está disponível em Macs com Apple Silicon). A hibernação cria um subvolume /swap na sua unidade de inicialização do tamanho da sua alocação de RAM física, então certifique-se de ter bastante espaço de sobra. Em uma máquina de 32GB, você sempre precisará de mais de 32GB livres para esse volume. A hibernação também exige o bootloader padrão Limine.

Quando estiver configurada, você verá a opção de hibernar em _Sistema_ (ou `Super + Esc`), e então poderá ver se ela funciona de forma consistente no seu sistema. Se não funcionar, você pode removê-la novamente executando `omarchy hibernation remove`.
