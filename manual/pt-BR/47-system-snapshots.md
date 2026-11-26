# Snapshots do sistema

Criamos snapshots automaticamente a cada atualização do Omarchy, mas, se você quiser criar os seus próprios, pode usar `omarchy-snapshot create`.

Como você inicializa e restaura um snapshot depende do carregador de inicialização com o qual sua máquina inicia. Instalações UEFI novas usam systemd-boot; instalações mais antigas e máquinas com BIOS usam Limine. `omarchy-boot-backend` informa qual é o seu.

## Com o systemd-boot

Escolha _Sistema > Snapshots_ no menu do Omarchy e selecione o snapshot que você quer inicializar. A máquina reinicia nele uma única vez. Ou segure Space enquanto a máquina inicia para ver o menu de inicialização, onde cada snapshot aparece listado do mais novo para o mais antigo, com a versão do Omarchy e a data.

Um snapshot inicializa com uma camada temporária por cima, então você pode usá-lo normalmente, mas tudo o que você alterar desaparece na próxima reinicialização. Para mantê-lo, faça dele o seu sistema: clique na notificação que aparece quando você faz login, escolha _Sistema > Snapshots > Restaurar este snapshot_ ou execute `omarchy-snapshot restore`. A restauração acontece enquanto a máquina reinicia. O sistema como estava antes permanece no menu de inicialização como _Antes da restauração_, e `omarchy-snapshot restore backup` o traz de volta.

No terminal:

- `omarchy-snapshot list` lista os snapshots que você pode inicializar;
- `omarchy-snapshot boot 12` reinicia no snapshot 12 uma única vez;
- `omarchy-snapshot restore 12` torna o snapshot 12 o sistema na próxima reinicialização, e `omarchy-snapshot restore --cancel` desfaz sua decisão antes dessa reinicialização.

## Com o Limine

Para inicializar e restaurar um snapshot, você o seleciona no carregador de inicialização Limine. O menu de inicialização fica oculto por padrão, então pressione qualquer tecla assim que o Limine iniciar para exibi-lo.

Nessa tela, escolha o snapshot que você quer inicializar com base na data e na versão. A versão do Omarchy na época do snapshot pode ser vista no canto inferior esquerdo.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quando você entrar, uma notificação vai aparecer avisando que você está em um snapshot inicializável e, se você clicar nela, o processo de restauração começará. Como alternativa, você pode usar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## O que uma restauração cobre

Uma restauração traz de volta o sistema de arquivos raiz, mas não o seu `/home`. Então ela serve para reverter uma atualização do sistema que deu errado, mas não para recuperar arquivos pessoais perdidos.

Isso também significa que o seu diretório `~/.config` é mantido como está. Então, se você estiver voltando para uma versão anterior de uma biblioteca ou aplicativo que armazena arquivos de configuração em um novo formato, vai ter que resolver isso manualmente.

O mesmo vale para o registro do próprio Omarchy de quais migrações já foram executadas: ele fica no seu diretório pessoal, então sobrevive à restauração. Migrações executadas depois que o snapshot foi criado continuam marcadas como concluídas, mesmo que as alterações que elas fizeram no sistema de arquivos raiz tenham sido revertidas, e a próxima execução de `omarchy update` não as executará de novo. Então, se você atualizar de novo depois de uma restauração e algo que uma atualização anterior tinha configurado continuar faltando, esse é o motivo provável.
