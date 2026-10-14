# Autenticação por hardware

### Autenticação por impressão digital

Muitos laptops vêm com um sensor de impressão digital para autenticação. Você pode usá-lo com o Omarchy executando _Setup > Security > Fingerprint_ no menu do Omarchy (`Super + Space`).

Isso instalará o pacote de impressão digital, coletará sua digital, a verificará, e você estará pronto para usar sua impressão digital para desbloquear a partir da tela de bloqueio (que você pode acionar com `Super + Ctrl + L`), entrar no modo sudo e autorizar solicitações do sistema.

Depois que a tela de bloqueio desliga o monitor, o sensor entra em repouso para economizar energia, então desperte a tela com qualquer tecla ou com o touchpad antes de tocá-lo.

Quando a tampa do seu laptop está fechada, a solicitação de impressão digital é ignorada automaticamente, então você vai direto para a solicitação de senha em vez de ficar esperando por um sensor que você não consegue alcançar. Se, por outro motivo, você precisar trabalhar em um teclado externo que não tem um sensor, basta pressionar `CTRL + C` quando sua impressão digital for solicitada durante o `sudo`.

Você pode remover a autenticação por impressão digital em _Remove > Security > Fingerprint_ no menu do Omarchy.

### Autenticação Fido2

Se você usa um dispositivo Fido2, pode configurá-lo para autenticação com `sudo` usando _Setup > Security > Fido2_ no menu do Omarchy (`Super + Space`). Isso cobre o `sudo` e as solicitações de autorização do sistema, mas não o desbloqueio do seu computador.

Você pode remover a autenticação fido2 em _Remove > Security > Fido2_ no menu do Omarchy.
