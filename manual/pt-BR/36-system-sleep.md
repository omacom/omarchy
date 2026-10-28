# Suspensão do sistema

O Omarchy ativa a suspensão e a hibernação por padrão, mas, se você estiver tendo problemas com qualquer uma das duas na sua máquina, pode desativá-las.

Em máquinas NVIDIA GB10, como o DGX Spark e o ASUS Ascent GX10, a suspensão e a hibernação ficam desligadas, como ficam no DGX OS da NVIDIA, porque ainda não foi demonstrado que a suspensão funciona nesse hardware. O botão de suspensão e a configuração da hibernação não se aplicam nesse caso. Para reativar a suspensão, remova `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` com `sudo rm`; a suspensão então volta ao menu, e a hibernação pode ser configurada como em outras máquinas. Executar `sudo omarchy apply hardware --install-user "$USER"` coloca o arquivo de volta.

### Perfis de energia

Em um laptop, o Omarchy lembra seu perfil de energia separadamente para quando ele está conectado à tomada e quando está funcionando na bateria, e alterna entre os dois conforme você conecta e desconecta. De fábrica, isso significa desempenho na tomada e equilibrado na bateria.

Você pode ver o que sua máquina oferece com `omarchy powerprofiles list` e definir o que você quer para o estado em que está no momento com `omarchy powerprofiles set autodetect power-saver`. Para definir o outro estado sem desconectar nada, nomeie-o diretamente: `omarchy powerprofiles set battery power-saver`. O que você escolher é o que você terá de volta na próxima vez em que estiver nesse estado.

### Ativar/desativar suspensão

Você ativa/desativa a suspensão executando `omarchy toggle suspend` no terminal. Isso apenas revela/oculta a opção em _Sistema_ (ou `Super + Esc`), e então você pode ver se ela funciona de forma consistente no seu sistema. Se não funcionar, você pode ocultá-la novamente com o mesmo comando.

### Ativar/desativar hibernação

Você configura a hibernação executando `omarchy hibernation setup` no terminal. A hibernação cria um subvolume /swap na sua unidade de inicialização do tamanho da sua alocação de RAM física, então garanta que você tenha bastante espaço sobrando. Em uma máquina de 32GB, você sempre precisará de 32GB+ livres para esse volume. A hibernação também exige o bootloader Limine padrão.

Quando configurada, você verá a opção de hibernar em _Sistema_ (ou `Super + Esc`), e então você pode ver se ela funciona de forma consistente no seu sistema. Se não funcionar, você pode removê-la novamente executando `omarchy hibernation remove`.
