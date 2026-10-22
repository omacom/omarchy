# Suspensão do sistema

O Omarchy ativa a suspensão e a hibernação por predefinição, mas se tiver problemas com qualquer uma delas na sua máquina, pode desativá-las.

### Perfis de energia

Num portátil, o Omarchy recorda o seu perfil de energia separadamente para quando está ligado à corrente e para quando está a funcionar com bateria, e alterna entre os dois ao ligar e desligar o cabo. De origem, isso significa desempenho com corrente alternada e equilibrado com bateria.

Pode ver o que a sua máquina oferece com `omarchy powerprofiles list`, e definir o que quer para o estado em que se encontra atualmente com `omarchy powerprofiles set autodetect power-saver`. Para definir o outro estado sem desligar nada, nomeie-o diretamente: `omarchy powerprofiles set battery power-saver`. O que escolher é o que voltará a ter da próxima vez que estiver nesse estado.

### Alternar suspensão

Alterna a suspensão executando `omarchy toggle suspend` a partir do terminal. Isso apenas mostra/oculta a opção em _Sistema_ (ou `Super + Esc`), e depois pode ver se funciona de forma consistente no seu sistema. Se não funcionar, pode voltar a ocultá-la com o mesmo comando.

### Alternar hibernação

Configura a hibernação executando `omarchy hibernation setup` a partir do terminal. A hibernação cria um subvolume /swap na sua unidade de arranque com o tamanho da sua alocação de memória RAM física, por isso certifique-se de que tem bastante espaço de sobra. Numa máquina de 32GB, vai precisar sempre de 32GB+ livres para este volume. A hibernação também exige o carregador de arranque Limine predefinido.

Quando estiver configurada, verá a opção de hibernar em _Sistema_ (ou `Super + Esc`), e depois pode ver se funciona de forma consistente no seu sistema. Se não funcionar, pode voltar a removê-la executando `omarchy hibernation remove`.
