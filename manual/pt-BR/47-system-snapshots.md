# Snapshots do sistema

Criamos snapshots automaticamente a cada atualização do Omarchy, mas, se você quiser criar o seu próprio, pode usar `omarchy-snapshot create`.

Para inicializar e restaurar um snapshot, você o seleciona no bootloader Limine. O menu de inicialização fica oculto por padrão, então pressione qualquer tecla assim que o Limine iniciar para exibi-lo.

Nessa tela, escolha o snapshot que você quer inicializar com base na data e na versão. A versão do Omarchy no momento do snapshot pode ser vista no canto inferior esquerdo.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quando você entrar, uma notificação será exibida avisando que você está em um snapshot inicializável e, se você clicar nela, o processo de restauração será iniciado. Como alternativa, você pode usar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Isso restaurará o seu sistema de arquivos raiz, mas não o seu `/home`. Portanto, funciona para reverter uma atualização do sistema com problemas, mas não para recuperar arquivos pessoais perdidos.

Isso também significa que o seu diretório `~/.config` é mantido como está. Então, se você estiver voltando para uma versão anterior de uma biblioteca ou aplicativo que armazena arquivos de configuração em um novo formato, terá que resolver isso manualmente.

O mesmo vale para o próprio registro do Omarchy de quais migrações já foram executadas: ele fica no seu diretório home, portanto sobrevive à restauração. As migrações executadas depois que o snapshot foi criado continuam marcadas como concluídas, mesmo que as alterações que elas fizeram no sistema de arquivos raiz tenham sido revertidas, e a próxima execução de `omarchy update` não as executará novamente. Portanto, se você atualizar novamente após uma restauração e algo que uma atualização anterior havia configurado ainda estiver faltando, esse é o motivo provável.

_Nota: Este recurso está disponível apenas em instalações que usam o bootloader Limine, que é o padrão desde o Omarchy 2.0. Ele não está disponível se você estiver usando GRUB ou systemd-boot._
