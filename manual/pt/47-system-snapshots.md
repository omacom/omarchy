# Instantâneos do sistema

Criamos instantâneos automaticamente em cada atualização do Omarchy, mas, se quiser criar o seu, pode utilizar `omarchy-snapshot create`.

Para arrancar e restaurar um instantâneo, selecione-o a partir do carregador de arranque Limine. (Se atualmente está a arrancar diretamente para o ecrã de desencriptação do Omarchy, terá primeiro de selecionar o Limine como opção de arranque através da BIOS).

Nesse ecrã, escolha o instantâneo para o qual pretende arrancar com base na data e na versão. A versão do Omarchy à data do instantâneo pode ser vista no canto inferior esquerdo.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quando chegar lá dentro, aparecerá uma notificação a avisar que está num instantâneo de arranque e, se clicar nela, iniciará o processo de restauro. Em alternativa, pode utilizar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Isto irá restaurar o seu sistema de ficheiros raiz, mas não o seu `/home`. Por isso, funciona para reverter uma atualização do sistema que correu mal, mas não para recuperar ficheiros pessoais perdidos.

Isto também significa que o seu diretório `~/.config` é mantido tal como está. Portanto, se estiver a reverter para uma versão anterior de uma biblioteca ou aplicação que guarda ficheiros de configuração num novo formato, terá de resolver isso manualmente.

O mesmo se aplica ao registo do próprio Omarchy sobre quais as migrações que já foram executadas: vive no seu diretório pessoal, por isso sobrevive ao restauro. As migrações executadas depois de o instantâneo ter sido criado permanecem marcadas como concluídas, mesmo que as alterações que fizeram ao sistema de ficheiros raiz tenham sido revertidas, e a próxima `omarchy update` não as voltará a executar. Por isso, se atualizar novamente após um restauro e algo que uma atualização anterior tinha configurado continuar em falta, essa é a razão provável.

_Nota: Esta funcionalidade só está disponível em instalações que utilizam o carregador de arranque Limine, que é a predefinição desde o Omarchy 2.0. Não está disponível se estiver no GRUB ou no systemd-boot._

### Ignorar o menu de arranque

Se nunca toca no menu de arranque e só quer que a máquina vá diretamente para o ecrã de desencriptação, execute _Setup > Direct Boot_ no menu do Omarchy. Isso adiciona uma entrada EFI a apontar diretamente para o Omarchy, para que o firmware o arranque sem parar no Limine.

A contrapartida é a mencionada no início: com o arranque direto ativado, chegar a um instantâneo significa escolher primeiro o Limine no menu de arranque da BIOS. Execute _Setup > Direct Boot_ novamente para remover a entrada e voltar a arrancar através do Limine. Alguns firmwares não lidam bem com entradas EFI personalizadas, por isso a configuração recusa-se a executar em firmware American Megatrends e Apple.
