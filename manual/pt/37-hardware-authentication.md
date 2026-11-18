# Autenticação por hardware

### Autenticação por impressão digital

Muitos portáteis trazem um sensor de impressão digital para fazer a autenticação. Podes usá-lo com o Omarchy ao executar _Setup > Security > Fingerprint_ no menu do Omarchy (`Super + Space`).

Isso instala o pacote de impressão digital, recolhe a tua impressão, verifica-a, e ficas pronto para usar a tua impressão digital para desbloquear a partir do ecrã de bloqueio (que podes ativar com `Super + Ctrl + L`), entrar no modo sudo e autorizar pedidos do sistema.

Assim que o ecrã de bloqueio desligar o ecrã, o sensor fica em repouso para poupar energia, por isso acorda o ecrã com qualquer tecla ou com o touchpad antes de lhe tocares.

Quando a tampa do portátil está fechada, o pedido de impressão digital é ignorado automaticamente, por isso vais diretamente para o pedido de palavra-passe em vez de ficares à espera de um sensor ao qual não consegues chegar. Se, noutra situação, precisares de trabalhar com um teclado externo que não tem sensor, basta carregares em `CTRL + C` quando te for pedida a impressão digital durante o `sudo`.

Podes remover a autenticação por impressão digital em _Remove > Security > Fingerprint_ no menu do Omarchy.

### Autenticação Fido2

Se estás a usar um dispositivo Fido2, podes configurá-lo para autenticação `sudo` com _Setup > Security > Fido2_ no menu do Omarchy (`Super + Space`). No entanto, abrange os pedidos de `sudo` e de autorização do sistema, não o desbloqueio do computador.

Podes remover a autenticação fido2 em _Remove > Security > Fido2_ no menu do Omarchy.
