# Snapshots do sistema

Criamos snapshots automaticamente a cada atualização do Omarchy, mas se você quiser criar os seus, pode usar `omarchy-snapshot create`.

Para inicializar e restaurar um snapshot, você o seleciona no bootloader Limine. (Se você atualmente inicializa direto para a tela de descriptografia do Omarchy, precisará selecionar o Limine como uma opção de inicialização pela BIOS primeiro).

Nessa tela, escolha o snapshot que você quer inicializar com base na data e na versão. A versão do Omarchy no momento do snapshot pode ser vista no canto inferior esquerdo.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quando você entrar, uma notificação aparecerá avisando que você está em um snapshot inicializável e, se você clicar nela, o processo de restauração começará. Como alternativa, você pode usar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Isso vai restaurar seu sistema de arquivos raiz, mas não seu `/home`. Então funciona para reverter uma atualização de sistema quebrada, mas não para recuperar arquivos pessoais perdidos.

Isso também significa que seu diretório `~/.config` é mantido como está. Então, se você estiver voltando para uma versão anterior de uma biblioteca ou aplicativo que armazena arquivos de configuração em um novo formato, terá que resolver isso manualmente.

_Observação: este recurso só está disponível em instalações que usam o bootloader Limine, que é o padrão desde o Omarchy 2.0. Ele não está disponível se você estiver no GRUB ou no systemd-boot._

### Pulando o menu de inicialização

Se você nunca toca no menu de inicialização e só quer que a máquina vá direto para a tela de descriptografia, execute _Configuração > Inicialização direta_ no menu do Omarchy. Isso adiciona uma entrada EFI apontando diretamente para o Omarchy, então o firmware o inicializa sem parar no Limine.

A contrapartida é a mencionada no início: com a inicialização direta ativada, chegar a um snapshot significa escolher o Limine no menu de inicialização da sua BIOS primeiro. Execute _Configuração > Inicialização direta_ de novo para remover a entrada e voltar a inicializar pelo Limine. Alguns firmwares não lidam bem com entradas EFI personalizadas, então a configuração se recusa a executar em firmwares American Megatrends e Apple.
