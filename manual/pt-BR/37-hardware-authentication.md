# Autenticação por hardware

### Autenticação por impressão digital

Muitos laptops vêm com um sensor de impressão digital para fazer a autenticação. Você pode usar isso com o Omarchy executando _Setup > Security > Fingerprint_ no menu do Omarchy (`Super + Space`).

Isso abre uma impressão digital em tela cheia que vai se preenchendo conforme você toca no sensor. Por trás disso, o Omarchy vai instalar o pacote de impressão digital, coletar sua impressão, verificá-la, e você estará pronto para usar sua impressão digital para desbloquear a partir da tela de bloqueio (que você pode acionar com `Super + Ctrl + L`), entrar no modo sudo e autorizar os prompts do sistema.

Depois que a tela de bloqueio desliga o display, o sensor entra em repouso para economizar energia, então acorde a tela com qualquer tecla ou com o touchpad antes de tocá-lo.

Quando a tampa do seu laptop está fechada, o prompt de impressão digital é pulado automaticamente, então você vai direto para o prompt de senha em vez de ficar esperando por um sensor que você não consegue alcançar. Se por acaso você precisar trabalhar em um teclado externo que não tem sensor, é só apertar `CTRL + C` quando for solicitado sua impressão digital durante o `sudo`.

Você pode remover a autenticação por impressão digital em _Remove > Security > Fingerprint_ no menu do Omarchy.

### Autenticação Fido2

Se você estiver usando um dispositivo Fido2, você pode configurá-lo para a autenticação do `sudo` usando _Setup > Security > Fido2_ no menu do Omarchy (`Super + Space`). Ele cobre o `sudo` e os prompts de autorização do sistema, mas não o desbloqueio do seu computador.

Você pode remover a autenticação fido2 em _Remove > Security > Fido2_ no menu do Omarchy.
