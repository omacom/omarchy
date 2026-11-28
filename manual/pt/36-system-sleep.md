# Suspensão do sistema

O Omarchy ativa a suspensão por predefinição, e a hibernação assim que estiver configurada, mas se estiver a ter problemas com qualquer uma delas na sua máquina, pode desativá-las.

Nas máquinas NVIDIA GB10, como a DGX Spark e a ASUS Ascent GX10, a suspensão e a hibernação estão desativadas, tal como no DGX OS da NVIDIA, porque ainda não foi demonstrado que a suspensão funciona nesse hardware. A ativação/desativação da suspensão e a configuração da hibernação não se aplicam nesse caso. Para voltar a ativar a suspensão, remova `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` com `sudo rm`; a opção de suspensão volta então ao menu, e a hibernação pode ser configurada como nas outras máquinas. Executar `sudo omarchy apply hardware --install-user "$USER"` repõe o ficheiro.

### Perfis de energia

Num computador portátil, o Omarchy memoriza o seu perfil de energia separadamente para quando está ligado à corrente e para quando está a funcionar com bateria, e alterna entre os dois à medida que liga e desliga da corrente. De fábrica, isso significa desempenho com AC e equilibrado com bateria.

Pode ver o que a sua máquina oferece com `omarchy powerprofiles list`, e definir o perfil que pretende para o estado em que se encontra atualmente com `omarchy powerprofiles set autodetect power-saver`. Para definir o outro estado sem desligar nada da corrente, indique-o diretamente: `omarchy powerprofiles set battery power-saver`. O que escolher é o que vai voltar a ter da próxima vez que estiver nesse estado.

### Ativar/desativar a suspensão

Ativa ou desativa a suspensão ao executar `omarchy toggle suspend` a partir do terminal. Isso apenas mostra/oculta a opção em _System_ (ou `Super + Esc`), e depois pode verificar se funciona de forma consistente no seu sistema. Se não funcionar, pode voltar a ocultá-la com o mesmo comando.

### Ativar/desativar a hibernação

Configura a hibernação ao executar `omarchy hibernation setup` a partir do terminal (não está disponível em Macs com Apple Silicon). A hibernação cria um subvolume /swap na sua unidade de arranque com o tamanho da alocação da sua RAM física, por isso certifique-se de que tem bastante espaço livre. Numa máquina com 32GB, vai precisar sempre de mais de 32GB livres para este volume. A hibernação também requer o bootloader Limine predefinido.

Quando estiver configurada, verá a opção de hibernação em _System_ (ou `Super + Esc`), e depois pode verificar se funciona de forma consistente no seu sistema. Se não funcionar, pode voltar a removê-la ao executar `omarchy hibernation remove`.
