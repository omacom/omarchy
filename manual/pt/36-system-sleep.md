# Suspensão do sistema

O Omarchy ativa a suspensão por predefinição, e a hibernação depois de a configurar, mas se tiver problemas com qualquer uma delas na sua máquina, pode desativá-las.

Nas máquinas NVIDIA GB10, como a DGX Spark e a ASUS Ascent GX10, a suspensão e a hibernação estão desativadas, tal como no DGX OS da NVIDIA, porque ainda não foi demonstrado que a suspensão funcione nesse hardware. O mesmo acontece com o ASUS Zenbook A16 (UX3607OA), onde a suspensão ainda não coloca o chip totalmente a dormir e pode encravar durante a noite. A ativação/desativação da suspensão e a configuração da hibernação não se aplicam aí. Para voltar a ativar a suspensão, remova `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` com `sudo rm`; a opção Suspend volta então ao menu, e a hibernação pode ser configurada como noutras máquinas. Executar `sudo omarchy apply hardware --install-user "$USER"` repõe o ficheiro.

### Perfis de energia

Num portátil, o Omarchy memoriza o seu perfil de energia separadamente para quando está ligado à corrente e para quando está a funcionar com bateria, e alterna entre os dois à medida que liga e desliga da corrente. De origem, isto significa desempenho com corrente AC e equilibrado com bateria.

Pode ver o que a sua máquina oferece com `omarchy powerprofiles list`, e definir o que pretende para o estado em que está atualmente com `omarchy powerprofiles set autodetect power-saver`. Para definir o outro estado sem desligar nada da corrente, nomeie-o diretamente: `omarchy powerprofiles set battery power-saver`. O que escolher é o que terá de volta da próxima vez que estiver nesse estado.

### Ativar/desativar a suspensão

Ativa ou desativa a suspensão ao executar `omarchy toggle suspend` a partir do terminal. Isto apenas mostra/esconde a opção em _System_ (ou `Super + Esc`), e pode então ver se funciona de forma consistente no seu sistema. Se não funcionar, pode escondê-la novamente com o mesmo comando.

### Ativar/desativar a hibernação

Configura a hibernação ao executar `omarchy hibernation setup` a partir do terminal (não está disponível em Macs com Apple Silicon). A hibernação cria um subvolume /swap na sua unidade de arranque com o tamanho da sua alocação de RAM física, por isso certifique-se de que tem bastante espaço de sobra. Numa máquina com 32GB, precisará sempre de mais de 32GB livres para este volume. A hibernação também requer o bootloader Limine predefinido.

Depois de configurada, verá a opção de hibernar em _System_ (ou `Super + Esc`), e pode então ver se funciona de forma consistente no seu sistema. Se não funcionar, pode removê-la novamente ao executar `omarchy hibernation remove`.
