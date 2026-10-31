# Primeiros passos

O Omarchy instala-se a partir de um ISO. Podes escolher entre uma instalação em disco inteiro, que fica com a unidade toda, ou uma instalação em espaço livre, que põe o Omarchy no espaço não atribuído de uma unidade — é assim que fazes dual boot ao lado do Windows ou de outro sistema operativo (vê [instalação em dual boot](50-dual-boot-install.md) — repara que primeiro vais ter de desligar o BitLocker no Windows). Seja como for, a instalação usa encriptação total por predefinição, e a opção de disco inteiro vai limpar a unidade escolhida, por isso faz uma cópia de segurança antes de usares uma unidade existente!

[Descarrega o ISO do Omarchy](https://omarchy.org/) primeiro, põe-no numa pen USB (usa o [balenaEtcher](https://etcher.balena.io/) no Mac/Windows ou o [caligula](https://github.com/ifd3f/caligula) no Linux) e arranca a partir da pen.

_Tens de desligar o Secure Boot e/ou o TPM na BIOS. Tens de os desligar para conseguires instalar o Omarchy. São esquemas de segurança da Microsoft feitos para o Windows e para distribuições Linux associadas à Microsoft._

Depois responde às perguntas de configuração e confirma-as assim:

 ![install-config](images/install-config.webp)

Depois escolhe uma unidade para a tua instalação, senta-te e vê o espetáculo da instalação a acontecer. Pode ficar pronto em menos de um minuto nas máquinas modernas mais rápidas, mas não deve demorar mais de 5 minutos nem num computador mais antigo.

 ![install-done](images/install-done.webp)

Agora estás pronto para o Omarchy!

### Usa um teclado com fios ou de 2.4ghz!

A encriptação total do disco não te vai deixar introduzir a palavra-passe a partir de um teclado Bluetooth no arranque. Tal como não consegues usar um teclado Bluetooth para entrar na BIOS num PC. Vais precisar de um teclado que use um dongle de 2.4ghz ou um cabo (o que, de qualquer forma, é muito melhor para a latência!). Pessoalmente, adoro o [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalar para outro proprietário

Se estás a preparar uma máquina para outra pessoa — um familiar, um novo funcionário, um comprador — não deves responder às perguntas pessoais em nome dela. Prime `Ctrl + C` no primeiríssimo ecrã do instalador (a seleção do teclado), e o Omarchy vai oferecer-se para preparar a máquina para outro proprietário. O sistema instala-se de imediato, mas toda a configuração pessoal — esquema do teclado, nome de utilizador, palavra-passe — fica adiada até a máquina arrancar pela primeira vez. A unidade continua encriptada por predefinição, e a palavra-passe que o novo proprietário escolher nesse primeiro arranque também passa a ser a palavra-passe de encriptação. (Uma máquina que já tenhas estado a usar também pode ser entregue sem uma reinstalação — vê [repor o computador](48-security.md).)

### Instalações não assistidas

O ISO também pode instalar-se completamente sozinho — sem teclado, sem assistente — quando recebe a sua configuração numa segunda unidade. É assim que deves tratar o Omarchy como imagem base para VMs e máquinas de uma frota. Vê [instalações não assistidas](51-unattended-installs.md).

### Instalações sem encriptação

O Omarchy instala-se com encriptação por predefinição. É a escolha segura e responsável para qualquer computador que possa ser perdido ou roubado. Não queres que qualquer pessoa com acesso ao teu hardware consiga chegar aos teus dados!

Mas em circunstâncias especiais, como instalações remotas do Omarchy em computadores protegidos ou instalações descartáveis sem dados sensíveis, podes querer instalar sem encriptação. Podes premir `Ctrl + C` na confirmação da formatação do disco para mudares para uma instalação sem encriptação.

### Idioma

O Omarchy fala 50 línguas — o mesmo conjunto do omarchy.org — e o inglês é a predefinição. Para mudar, abre o menu do Omarchy e vai a _Setup > Language_, ou executa `omarchy language <code>` num terminal (`omarchy language list` mostra os códigos). O menu, o ambiente de trabalho e as próprias notificações do Omarchy mudam de idioma imediatamente, e todas as aplicações que abrires a seguir também acompanham. As aplicações que já estavam abertas mudam assim que as reiniciares.

### Ajuda se ficares bloqueado

Se ficares bloqueado, normalmente consegues encontrar alguém disposto a ajudar no canal _#omarchy-help_ no [Discord da comunidade](https://omarchy.org/discord).
