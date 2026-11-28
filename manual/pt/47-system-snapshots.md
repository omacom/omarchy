# Snapshots do sistema

Criamos snapshots automaticamente em cada atualização do Omarchy, mas, se quiser criar um seu, pode usar `omarchy-snapshot create`.

A forma de arrancar e restaurar um snapshot depende do carregador de arranque com que a sua máquina inicia. As instalações UEFI novas usam o systemd-boot; as instalações mais antigas e as máquinas BIOS usam o Limine. `omarchy-boot-backend` indica-lhe qual tem.

## Com o systemd-boot

Escolha _System > Snapshots_ no menu do Omarchy e selecione o snapshot em que pretende arrancar. A máquina reinicia nele uma única vez. Ou mantenha premida a tecla Space enquanto a máquina arranca para ver o menu de arranque, onde todos os snapshots estão listados, do mais recente para o mais antigo, com a respetiva versão do Omarchy e data.

Um snapshot arranca com uma camada temporária por cima, por isso pode usá-lo normalmente, mas tudo o que alterar desaparece no próximo reinício. Para o manter, torne-o o seu sistema: clique na notificação que aparece quando inicia sessão, escolha _System > Snapshots > Restore This Snapshot_ ou execute `omarchy-snapshot restore`. O restauro acontece durante o reinício da máquina. O sistema tal como estava antes permanece no menu de arranque como _Before restore_, e `omarchy-snapshot restore backup` volta a repô-lo.

Do terminal:

- `omarchy-snapshot list` lista os snapshots em que pode arrancar;
- `omarchy-snapshot boot 12` reinicia no snapshot 12 uma única vez;
- `omarchy-snapshot restore 12` torna o snapshot 12 o sistema no próximo reinício, e `omarchy-snapshot restore --cancel` permite-lhe mudar de ideias antes desse reinício.

## Com o Limine

Para arrancar e restaurar um snapshot, selecione-o no carregador de arranque Limine. O menu de arranque permanece oculto por predefinição, por isso prima qualquer tecla assim que o Limine arrancar para o mostrar.

Nesse ecrã, escolha o snapshot em que pretende arrancar com base na data e na versão. A versão do Omarchy à data do snapshot pode ser vista no canto inferior esquerdo.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quando lá chegar, vai aparecer uma notificação a avisá-lo de que está num snapshot de arranque e, se clicar nela, o processo de restauro é iniciado. Em alternativa, pode utilizar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## O que abrange um restauro

Um restauro repõe o seu sistema de ficheiros raiz, mas não o seu `/home`. Por isso, funciona para reverter uma atualização do sistema que correu mal, mas não para recuperar ficheiros pessoais perdidos.

Isto também significa que o seu diretório `~/.config` é mantido tal como está. Por isso, se voltar a uma versão anterior de uma biblioteca ou aplicação que guarda ficheiros de configuração num novo formato, terá de resolver isso manualmente.

O mesmo se aplica ao próprio registo do Omarchy das migrações que já foram executadas: vive no seu diretório pessoal, por isso sobrevive ao restauro. As migrações executadas depois de o snapshot ter sido criado continuam marcadas como concluídas, mesmo que as alterações que fizeram no sistema de ficheiros raiz tenham sido revertidas, e a próxima execução de `omarchy update` não as voltará a executar. Por isso, se atualizar novamente após um restauro e continuar a faltar algo que uma atualização anterior tinha configurado, é provável que seja essa a razão.
