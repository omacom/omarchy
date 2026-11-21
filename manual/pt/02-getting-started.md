# Primeiros Passos

O Omarchy é instalado através de um ISO. Pode escolher entre uma instalação em disco completo, que ocupa a unidade inteira, ou uma instalação em espaço livre, que coloca o Omarchy no espaço não alocado de uma unidade — é assim que se faz o arranque duplo ao lado do Windows ou de outro sistema operativo (consulte [instalação com arranque duplo](50-dual-boot-install.md) — note que terá de desativar primeiro o BitLocker no Windows). De qualquer forma, a instalação utiliza por predefinição a encriptação total, e a opção de disco completo vai apagar a unidade selecionada, por isso certifique-se de que faz uma cópia de segurança antes de utilizar uma unidade existente!

Comece por [transferir o ISO do Omarchy](https://omarchy.org/), coloque-o numa pen USB (utilize o [Rufus](https://rufus.ie/) no Windows, o [balenaEtcher](https://etcher.balena.io/) no Mac ou o [caligula](https://github.com/ifd3f/caligula) no Linux) e arranque a partir da pen.

_Tem de desativar o Secure Boot e/ou o TPM na BIOS. Tem de desativar estas opções para poder instalar o Omarchy. São esquemas de segurança da Microsoft pensados para o Windows e para distribuições Linux afiliadas à Microsoft._

Depois responda às perguntas de configuração e confirme-as assim:

 ![install-config](images/install-config.webp)

Depois selecione uma unidade para a instalação e recoste-se a ver o espetáculo da instalação a decorrer. Pode ficar concluída em menos de um minuto nas máquinas modernas mais rápidas, mas não deverá demorar mais de 5 minutos nem mesmo num computador mais antigo.

 ![install-done](images/install-done.webp)

Agora está pronto para o Omarchy!

### Utilize um teclado com fios ou de 2.4ghz!

A encriptação total do disco não lhe permite introduzir a palavra-passe a partir de um teclado Bluetooth no arranque. Tal como não pode utilizar um teclado Bluetooth para aceder à BIOS num PC. Vai precisar de um teclado que utilize um recetor de 2.4ghz ou um cabo (o que, de qualquer forma, é muito melhor para a latência!). Pessoalmente, adoro o [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalar para outro proprietário

Se está a configurar uma máquina para outra pessoa — um familiar, um novo funcionário, um comprador — não deve responder às perguntas pessoais em nome dela. Prima `Ctrl + C` no primeiríssimo ecrã do instalador (a seleção do teclado) e o Omarchy propõe preparar a máquina para outro proprietário. O sistema é instalado de imediato, mas toda a configuração pessoal — disposição do teclado, nome de utilizador, palavra-passe — é adiada até a máquina arrancar pela primeira vez. A unidade continua encriptada por predefinição e a palavra-passe que o novo proprietário escolher nesse primeiro arranque passa também a ser a palavra-passe de encriptação. (Uma máquina que já esteja a utilizar também pode ser entregue sem reinstalação — consulte [repor o computador](48-security.md).)

### Instalações não assistidas

O ISO também pode instalar-se completamente sozinho — sem teclado, sem assistente — quando recebe a sua configuração numa segunda unidade. É assim que se trata o Omarchy como uma imagem base para VMs e para frotas de máquinas. Consulte [instalações não assistidas](51-unattended-installs.md).

### Instalações sem encriptação

O Omarchy é instalado com encriptação por predefinição. É a escolha segura e responsável para qualquer computador que possa ser perdido ou roubado. Não quer que qualquer pessoa com acesso ao seu hardware consiga aceder aos seus dados!

Mas em circunstâncias especiais, como instalações remotas do Omarchy em computadores protegidos ou instalações descartáveis sem dados sensíveis, pode querer instalar sem encriptação. Pode premir `Ctrl + C` na confirmação da formatação do disco para mudar para uma instalação sem encriptação.

### Idioma

O Omarchy fala 50 línguas — o mesmo conjunto que o omarchy.org — e o inglês é o idioma predefinido. Para mudar, abra o menu do Omarchy e aceda a _Setup > Region > Language_, ou execute `omarchy language <code>` num terminal (`omarchy language list` mostra os códigos). O menu, o ambiente de trabalho e as notificações do próprio Omarchy mudam de idioma imediatamente, e todas as aplicações que abrir a seguir acompanham a mudança. As aplicações que já estavam abertas mudam quando as reiniciar.

Para manter o idioma mas escrever datas, horas, números, moeda, unidades e tamanhos de papel como noutra região (inglês com datas europeias e um relógio de 24 horas, por exemplo), escolha uma região em _Setup > Region > Formats_, onde cada opção mostra um exemplo, ou execute `omarchy region formats <code>` (`omarchy region formats list` mostra os códigos). _Same as language_ regressa aos formatos próprios do idioma. Tal como numa mudança de idioma, esta alteração aplica-se às aplicações que abrir a seguir.

### Ajuda se ficar bloqueado

Se ficar bloqueado, normalmente consegue encontrar alguém disposto a ajudar no canal _#omarchy-help_ no [Discord da comunidade](https://omarchy.org/discord).
