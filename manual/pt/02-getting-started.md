# Primeiros Passos

O Omarchy é instalado com um ISO. Pode escolher entre uma instalação de disco completo, que ocupa toda a unidade, ou uma instalação em espaço livre, que coloca o Omarchy no espaço não atribuído de uma unidade — é assim que faz dual boot ao lado do Windows ou de outro sistema operativo (consulte [instalação em dual-boot](50-dual-boot-install.md) — tenha em atenção que primeiro terá de desativar o BitLocker no Windows). De qualquer forma, a instalação tem encriptação total por predefinição, e a opção de disco completo vai limpar a unidade selecionada, por isso não se esqueça de fazer uma cópia de segurança antes de usar uma já existente!

Num Mac com Apple Silicon, a instalação é feita a partir do macOS, sem ISO nem pen USB. Consulte [Omarchy para Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Descarregue o ISO do Omarchy](https://omarchy.org/) primeiro, coloque-o numa pen USB (use o [Rufus](https://rufus.ie/) no Windows, o [balenaEtcher](https://etcher.balena.io/) no Mac ou o [caligula](https://github.com/ifd3f/caligula) no Linux) e arranque a partir da pen.

_Tem de desativar o Secure Boot e/ou o TPM na BIOS. Tem de os desativar para poder instalar o Omarchy. São esquemas de segurança da Microsoft destinados ao Windows e a distribuições Linux afiliadas à Microsoft._

Depois responda às perguntas de configuração e confirme-as assim:

 ![install-config](images/install-config.webp)

Depois selecione uma unidade para a instalação e recoste-se a assistir ao espetáculo da instalação. Pode ficar concluída em menos de um minuto nas máquinas modernas mais rápidas, mas não deverá demorar mais de 5 minutos mesmo num computador mais antigo.

 ![install-done](images/install-done.webp)

Agora está pronto para o Omarchy!

### Utilize um teclado com fios ou de 2.4ghz!

A encriptação de disco completo não lhe permitirá introduzir a palavra-passe a partir de um teclado Bluetooth no arranque. Tal como não pode usar um teclado Bluetooth para entrar na BIOS de um PC. Vai precisar de um teclado que use um dongle de 2.4ghz ou um cabo (que, de qualquer forma, é muito melhor para a latência!). Pessoalmente, adoro o [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalar para outro proprietário

Se está a configurar uma máquina para outra pessoa — um familiar, um novo funcionário, um comprador — não deve responder às perguntas pessoais em nome dela. Prima `Ctrl + C` no primeiríssimo ecrã do instalador (a seleção do teclado), e o Omarchy irá propor preparar a máquina para outro proprietário. O sistema é instalado de imediato, mas toda a configuração pessoal — disposição do teclado, nome de utilizador, palavra-passe — fica adiada até a máquina arrancar pela primeira vez. A unidade continua encriptada por predefinição, e a palavra-passe que o novo proprietário escolher nesse primeiro arranque torna-se também a palavra-passe de encriptação. (Uma máquina que já tenha estado a utilizar também pode ser entregue sem reinstalação — consulte [repor o computador](48-security.md).)

### Instalações não assistidas

O ISO também pode instalar-se completamente sozinho — sem teclado, sem assistente — quando a sua configuração lhe é entregue numa segunda unidade. É assim que deve tratar o Omarchy como imagem base para VMs e máquinas de frota. Consulte [instalações não assistidas](51-unattended-installs.md).

### Instalações sem encriptação

O Omarchy é instalado com encriptação por predefinição. É a escolha segura e responsável para qualquer computador que possa ser perdido ou roubado. Não quer que qualquer pessoa com acesso ao seu hardware consiga aceder aos seus dados!

Mas em circunstâncias especiais, como instalações remotas do Omarchy em computadores protegidos ou instalações descartáveis sem dados sensíveis, pode querer instalar sem encriptação. Pode premir `Ctrl + C` na confirmação da formatação do disco para mudar para uma instalação sem encriptação.

### Idioma

O Omarchy fala 50 idiomas — o mesmo conjunto do omarchy.org — e o inglês é a predefinição. Para mudar, abra o menu do Omarchy e vá a _Setup > Region > Language_, ou execute `omarchy language <code>` num terminal (`omarchy language list` mostra os códigos). O menu, o ambiente de trabalho e as notificações do próprio Omarchy mudam de idioma imediatamente, e todas as aplicações que abrir depois também seguem. As aplicações que já estavam abertas mudam assim que as reiniciar.

Para manter o idioma mas escrever datas, horas, números, dinheiro, unidades e tamanhos de papel como noutra região (inglês com datas europeias e relógio de 24 horas, por exemplo), escolha uma região em _Setup > Region > Formats_, onde cada opção mostra um exemplo, ou execute `omarchy region formats <code>` (`omarchy region formats list` mostra os códigos). _Same as language_ volta aos formatos próprios do idioma. Tal como numa mudança de idioma, aplica-se às aplicações que abrir depois.

### Ajuda se ficar bloqueado

Se ficar bloqueado, normalmente consegue encontrar alguém disposto a ajudar no canal _#omarchy-help_ no [Discord da comunidade](https://omarchy.org/discord).
