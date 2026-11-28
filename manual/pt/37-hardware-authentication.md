# Autenticação por hardware

### Autenticação por impressão digital

Muitos computadores portáteis vêm com um sensor de impressão digital para fazer a autenticação. Pode utilizá-lo com o Omarchy executando _Setup > Security > Fingerprint_ no menu Omarchy (`Super + Space`).

Isso abre uma impressão digital em ecrã inteiro que se vai preenchendo à medida que toca no sensor. Nos bastidores, o Omarchy vai instalar o pacote de impressão digital, recolher a sua impressão, verificá-la, e ficará tudo pronto para utilizar a sua impressão digital para desbloquear a partir do ecrã de bloqueio (que pode ativar com `Super + Ctrl + L`), entrar no modo sudo e autorizar pedidos do sistema.

Depois de o ecrã de bloqueio desligar o ecrã, o sensor entra em repouso para poupar energia, por isso desperte o ecrã com qualquer tecla ou com o touchpad antes de tocar no sensor.

Quando a tampa do seu computador portátil está fechada, o pedido de impressão digital é ignorado automaticamente, por isso vai diretamente para o pedido de palavra-passe em vez de estar à espera de um sensor ao qual não consegue chegar. Se, por outro motivo, precisar de trabalhar com um teclado externo que não tem sensor, basta premir `CTRL + C` quando lhe for pedida a impressão digital durante o `sudo`.

Pode remover a autenticação por impressão digital em _Remove > Security > Fingerprint_ no menu Omarchy.

### Autenticação Fido2

Se estiver a utilizar um dispositivo Fido2, pode configurá-lo para autenticação `sudo` utilizando _Setup > Security > Fido2_ no menu Omarchy (`Super + Space`). Abrange o `sudo` e os pedidos de autorização do sistema, mas não o desbloqueio do seu computador.

Pode remover a autenticação fido2 em _Remove > Security > Fido2_ no menu Omarchy.
