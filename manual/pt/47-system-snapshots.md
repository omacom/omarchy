# Instantâneos do sistema

Criamos instantâneos automaticamente em cada atualização do Omarchy, mas se quiser criar o seu, pode usar `omarchy-snapshot create`.

Para arrancar e restaurar um instantâneo, selecione-o a partir do carregador de arranque Limine. O menu de arranque permanece oculto por predefinição, por isso prima qualquer tecla assim que o Limine iniciar para o mostrar.

Nesse ecrã, escolha o instantâneo em que pretende arrancar com base na data e na versão. A versão do Omarchy à data do instantâneo pode ser vista no canto inferior esquerdo.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quando entrar, vai surgir uma notificação a avisá-lo de que está num instantâneo arrancável e, se clicar nela, dará início ao processo de restauro. Em alternativa, pode utilizar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Isto irá restaurar o seu sistema de ficheiros raiz, mas não o seu `/home`. Por isso, funciona para reverter uma atualização do sistema danificada, mas não para recuperar ficheiros pessoais perdidos.

Isto também significa que o seu diretório `~/.config` é mantido tal como está. Por isso, se estiver a reverter para uma versão anterior de uma biblioteca ou aplicação que guarda ficheiros de configuração num novo formato, terá de resolver isso manualmente.

O mesmo se aplica ao registo do próprio Omarchy das migrações que já foram executadas: vive no seu diretório pessoal, por isso sobrevive ao restauro. As migrações executadas depois de o instantâneo ter sido criado permanecem marcadas como concluídas, mesmo que as alterações que fizeram ao sistema de ficheiros raiz tenham sido revertidas, e a próxima `omarchy update` não as voltará a executar. Por isso, se atualizar novamente após um restauro e algo que uma atualização anterior tinha configurado continuar em falta, é provável que seja essa a razão.

_Nota: Esta funcionalidade só está disponível em instalações que utilizem o carregador de arranque Limine, que é a predefinição desde o Omarchy 2.0. Não está disponível se estiver a usar GRUB ou systemd-boot._
