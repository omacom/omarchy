# Instantâneos do sistema

Criamos instantâneos automaticamente em cada atualização do Omarchy, mas se quiser criar os seus próprios, pode usar `omarchy-snapshot create`.

Para arrancar e restaurar um instantâneo, seleciona-o a partir do carregador de arranque Limine. (Se estiver atualmente a arrancar diretamente para o ecrã de desencriptação do Omarchy, primeiro terá de selecionar o Limine como opção de arranque através da BIOS).

A partir desse ecrã, escolha o instantâneo a partir do qual quer arrancar com base na data e na versão. A versão do Omarchy no momento do instantâneo pode ser vista no canto inferior esquerdo.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quando chegar lá dentro, aparecerá uma notificação a avisá-lo de que está num instantâneo arrancável e, se clicar nela, dará início ao processo de restauração. Em alternativa, pode utilizar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Isto restaurará o seu sistema de ficheiros raiz, mas não o seu `/home`. Por isso funciona para reverter uma atualização de sistema defeituosa, mas não para recuperar ficheiros pessoais perdidos.

Isto também significa que o seu diretório `~/.config` é mantido como está. Por isso, se estiver a voltar a uma versão anterior de uma biblioteca ou aplicação que guarda ficheiros de configuração num novo formato, terá de resolver isso manualmente.

_Nota: esta funcionalidade só está disponível em instalações que usam o carregador de arranque Limine, que é a predefinição desde o Omarchy 2.0. Não está disponível se estiver no GRUB ou no systemd-boot._

### Saltar o menu de arranque

Se nunca tocar no menu de arranque e só quiser que a máquina vá diretamente ao ecrã de desencriptação, execute _Configurar > Arranque direto_ no menu Omarchy. Isso adiciona uma entrada EFI a apontar diretamente para o Omarchy, para o firmware o arrancar sem parar no Limine.

A contrapartida é a mencionada no topo: com o arranque direto ligado, chegar a um instantâneo significa primeiro escolher o Limine no menu de arranque da sua BIOS. Execute _Configurar > Arranque direto_ de novo para remover a entrada e voltar a arrancar através do Limine. Algum firmware não reage bem a entradas EFI personalizadas, por isso a configuração recusa-se a executar em firmware American Megatrends e Apple.
