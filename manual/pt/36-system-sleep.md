# Suspensão do sistema

O Omarchy ativa a suspensão e a hibernação por predefinição, mas se estiver a ter problemas com alguma delas na sua máquina, pode desativá-las.

Nas máquinas NVIDIA GB10, como o DGX Spark e o ASUS Ascent GX10, a suspensão e a hibernação estão desativadas, tal como no DGX OS da NVIDIA, porque ainda não se demonstrou que a suspensão funciona nesse hardware. O mesmo se aplica ao ASUS Zenbook A16 (UX3607OA), em que a suspensão ainda não coloca o chip totalmente em suspensão e pode encravar durante a noite. A ativação/desativação da suspensão e a configuração da hibernação não se aplicam nesse caso. Para voltar a ativar a suspensão, remova `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` com `sudo rm`; a opção Suspender volta então ao menu e a hibernação pode ser configurada como nas outras máquinas. Executar `sudo omarchy apply hardware --install-user "$USER"` repõe o ficheiro.

### Perfis de energia

Num portátil, o Omarchy memoriza o seu perfil de energia separadamente para quando está ligado à corrente e para quando está a funcionar com bateria, e alterna entre os dois à medida que liga e desliga da corrente. De origem, isso significa desempenho com corrente AC e equilibrado com bateria.

Pode ver o que a sua máquina oferece com `omarchy powerprofiles list` e definir o perfil que pretende para o estado em que se encontra atualmente com `omarchy powerprofiles set autodetect power-saver`. Para definir o outro estado sem desligar nada da corrente, indique-o diretamente: `omarchy powerprofiles set battery power-saver`. Aquilo que escolher é o que vai voltar a ter da próxima vez que estiver nesse estado.

### Ativar/desativar a suspensão

Ativa ou desativa a suspensão executando `omarchy toggle suspend` a partir do terminal. Isso limita-se a mostrar/ocultar a opção em _Sistema_ (ou `Super + Esc`), e depois pode verificar se funciona de forma consistente no seu sistema. Se não funcionar, pode ocultá-la novamente com o mesmo comando.

### Ativar/desativar a hibernação

Configura a hibernação executando `omarchy hibernation setup` a partir do terminal. A hibernação cria um subvolume /swap na sua unidade de arranque com o tamanho da sua alocação de RAM física, por isso certifique-se de que tem bastante espaço de sobra. Numa máquina com 32GB, vai precisar sempre de 32GB+ livres para este volume. A hibernação também requer o gestor de arranque predefinido Limine.

Depois de configurada, vai ver a opção de hibernação em _Sistema_ (ou `Super + Esc`), e depois pode verificar se funciona de forma consistente no seu sistema. Se não funcionar, pode removê-la novamente executando `omarchy hibernation remove`.
