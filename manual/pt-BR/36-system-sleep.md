# Suspensão do sistema

O Omarchy habilita a suspensão e a hibernação por padrão, mas, se você estiver tendo problemas com qualquer uma das duas na sua máquina, pode desativá-las.

Em máquinas NVIDIA GB10, como o DGX Spark e o ASUS Ascent GX10, a suspensão e a hibernação vêm desativadas, assim como no DGX OS da NVIDIA, porque ainda não foi demonstrado que o modo de suspensão funciona nesse hardware. O mesmo vale para o ASUS Zenbook A16 (UX3607OA), em que a suspensão ainda não coloca o chip totalmente para dormir e pode travar durante a noite. A alternância de suspensão e a configuração de hibernação não se aplicam nesse caso. Para reativar o modo de suspensão, remova `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` com `sudo rm`; o Suspender volta então ao menu, e a hibernação pode ser configurada como nas outras máquinas. Executar `sudo omarchy apply hardware --install-user "$USER"` coloca o arquivo de volta.

### Perfis de energia

Em um laptop, o Omarchy lembra seu perfil de energia separadamente para quando ele está conectado na tomada e para quando está funcionando na bateria, e alterna entre os dois conforme você conecta e desconecta da tomada. De fábrica, isso significa desempenho na tomada e equilibrado na bateria.

Você pode ver o que sua máquina oferece com `omarchy powerprofiles list` e definir o perfil desejado para o estado em que você está no momento com `omarchy powerprofiles set autodetect power-saver`. Para definir o outro estado sem desconectar nada, nomeie-o diretamente: `omarchy powerprofiles set battery power-saver`. O que você escolher é o que voltará na próxima vez em que você estiver nesse estado.

### Alternar suspensão

Você alterna a suspensão executando `omarchy toggle suspend` a partir do terminal. Isso apenas mostra/oculta a opção em _Sistema_ (ou `Super + Esc`), e então você pode ver se ela funciona de forma consistente no seu sistema. Se não funcionar, você pode ocultá-la novamente com o mesmo comando.

### Alternar hibernação

Você configura a hibernação executando `omarchy hibernation setup` a partir do terminal. A hibernação cria um subvolume /swap na sua unidade de inicialização do tamanho da sua alocação de RAM física, então tenha bastante espaço sobrando. Em uma máquina de 32GB, você sempre precisará de mais de 32GB livres para esse volume. A hibernação também exige o bootloader Limine padrão.

Quando configurada, você verá a opção de hibernar em _Sistema_ (ou `Super + Esc`), e então poderá ver se ela funciona de forma consistente no seu sistema. Se não funcionar, você pode removê-la novamente executando `omarchy hibernation remove`.
