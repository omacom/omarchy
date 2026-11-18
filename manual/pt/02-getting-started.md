# Primeiros Passos

O Omarchy é instalado através de um ISO. Pode escolher entre uma instalação em disco completo, que ocupa a unidade inteira, ou uma instalação em espaço livre, que coloca o Omarchy no espaço não alocado de uma unidade — é assim que faz arranque duplo ao lado do Windows ou de outro sistema operativo (consulte [instalação em arranque duplo](50-dual-boot-install.md) — tenha em atenção que primeiro vai precisar de desligar o BitLocker no Windows). Em qualquer dos casos, a instalação utiliza encriptação completa por predefinição, e a opção de disco completo vai apagar a unidade selecionada, por isso certifique-se de que faz uma cópia de segurança antes de utilizar uma unidade existente!

Primeiro, [descarregue o ISO do Omarchy](https://omarchy.org/), coloque-o numa pen USB (utilize o [Rufus](https://rufus.ie/) no Windows, o [balenaEtcher](https://etcher.balena.io/) no Mac ou o [caligula](https://github.com/ifd3f/caligula) no Linux) e arranque a partir da pen.

_Tem de desligar o Secure Boot e/ou o TPM na BIOS. Tem mesmo de os desligar para conseguir instalar o Omarchy. São esquemas de segurança da Microsoft pensados para o Windows e para distribuições Linux afiliadas à Microsoft._

Depois, responda às perguntas de configuração e confirme-as assim:

 ![install-config](images/install-config.webp)

Em seguida, selecione uma unidade para a instalação, sente-se e veja o espetáculo da instalação a decorrer. Pode ficar concluída em menos de um minuto nas máquinas modernas mais rápidas, mas não deverá demorar mais de 5 minutos, mesmo num computador mais antigo.

 ![install-done](images/install-done.webp)

Agora está pronto para o Omarchy!

### Utilize um teclado com fios ou de 2,4 GHz!

A encriptação de disco completo não lhe vai permitir introduzir a palavra-passe a partir de um teclado Bluetooth no arranque. É tal e qual como não conseguir utilizar um teclado Bluetooth para entrar na BIOS num PC. Vai precisar de um teclado que utilize um dongle de 2,4 GHz ou um cabo (o que até é muito melhor para a latência!). Eu pessoalmente adoro o [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalar para outro proprietário

Se está a preparar uma máquina para outra pessoa — um familiar, um novo colaborador, um comprador — não deve responder às perguntas pessoais em nome dela. Prima `Ctrl + C` no primeiríssimo ecrã do instalador (a seleção do teclado), e o Omarchy vai propor preparar a máquina para outro proprietário. O sistema instala-se de imediato, mas toda a configuração pessoal — disposição do teclado, nome de utilizador, palavra-passe — é adiada até a máquina arrancar pela primeira vez. A unidade continua encriptada por predefinição, e a palavra-passe que o novo proprietário escolher nesse primeiro arranque passa a ser também a palavra-passe de encriptação. (Uma máquina que já esteja a ser utilizada também pode ser entregue sem reinstalação — consulte [repor o computador](48-security.md).)

### Instalações sem intervenção

O ISO também se pode instalar completamente sozinho — sem teclado, sem assistente — quando lhe é fornecida a sua configuração num segundo disco. É assim que deve tratar o Omarchy como uma imagem de base para VMs e máquinas de uma frota. Consulte [instalações sem intervenção](51-unattended-installs.md).

### Instalações sem encriptação

O Omarchy é instalado com encriptação por predefinição. É a escolha segura e responsável para qualquer computador que possa ser perdido ou roubado. Não quer que qualquer pessoa com acesso ao seu hardware consiga aceder aos seus dados!

Mas em circunstâncias especiais, como instalações remotas do Omarchy em computadores protegidos ou instalações descartáveis sem dados sensíveis, pode querer instalar sem encriptação. Pode premir `Ctrl + C` na confirmação de formatação do disco para mudar para uma instalação sem encriptação.

### Idioma

O Omarchy fala 50 línguas — o mesmo conjunto do omarchy.org — e o inglês é a predefinição. Para mudar, abra o menu do Omarchy e vá a _Configuração > Idioma_, ou execute `omarchy language <code>` num terminal (`omarchy language list` mostra os códigos). O menu, o ambiente de trabalho e as próprias notificações do Omarchy mudam de idioma imediatamente, e todas as aplicações que abrir a seguir também acompanham a mudança. As aplicações que já estavam abertas mudam assim que as reiniciar.

### Ajuda se ficar bloqueado

Se ficar bloqueado, normalmente consegue encontrar alguém disposto a ajudar no canal _#omarchy-help_ no [Discord da comunidade](https://omarchy.org/discord).
