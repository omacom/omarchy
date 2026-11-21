# Primeiros Passos

O Omarchy instala-se com uma ISO. Pode escolher entre uma instalação de disco inteiro, que ocupa toda a unidade, ou uma instalação em espaço livre, que coloca o Omarchy no espaço não atribuído de uma unidade — é assim que faz arranque duplo ao lado do Windows ou de outro sistema operativo (consulte [instalação com arranque duplo](50-dual-boot-install.md) — tenha em atenção que terá primeiro de desativar o BitLocker no Windows). De qualquer forma, a instalação utiliza encriptação integral por predefinição e a opção de disco inteiro apagará a unidade selecionada, por isso não se esqueça de fazer uma cópia de segurança antes de utilizar uma unidade existente!

Primeiro, [transfira a ISO do Omarchy](https://omarchy.org/), coloque-a numa pen USB (utilize o [Rufus](https://rufus.ie/) no Windows, o [balenaEtcher](https://etcher.balena.io/) no Mac ou o [caligula](https://github.com/ifd3f/caligula) no Linux) e arranque a partir da pen.

_Tem de desativar o Secure Boot e/ou o TPM na BIOS. Tem de os desativar para poder instalar o Omarchy. São esquemas de segurança da Microsoft destinados ao Windows e a distribuições Linux afiliadas à Microsoft._

Depois, responda às perguntas de configuração e confirme-as assim:

 ![install-config](images/install-config.webp)

Depois, selecione uma unidade para a instalação e recoste-se a ver o espetáculo da instalação a acontecer. Pode ficar concluída em menos de um minuto nas máquinas modernas mais rápidas, mas não deverá demorar mais de 5 minutos, mesmo num computador mais antigo.

 ![install-done](images/install-done.webp)

Agora está pronto para o Omarchy!

### Utilize um teclado com fios ou de 2,4 GHz!

A encriptação integral do disco não lhe permitirá introduzir a palavra-passe a partir de um teclado Bluetooth no arranque. Tal como não pode utilizar um teclado Bluetooth para entrar na BIOS num PC. Precisará de um teclado que utilize um dongle de 2,4 GHz ou um cabo (o que até é muito melhor para a latência!). Pessoalmente, adoro o [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalar para outro proprietário

Se estiver a configurar uma máquina para outra pessoa — um familiar, um novo funcionário, um comprador — não deve responder às perguntas pessoais em nome dela. Prima `Ctrl + C` no primeiríssimo ecrã do instalador (a seleção do teclado) e o Omarchy proporá preparar a máquina para outro proprietário. O sistema instala-se de imediato, mas toda a configuração pessoal — disposição do teclado, nome de utilizador, palavra-passe — fica adiada até a máquina arrancar pela primeira vez. A unidade continua encriptada por predefinição e a palavra-passe que o novo proprietário escolher nesse primeiro arranque torna-se também a palavra-passe de encriptação. (Uma máquina que já tenha estado a utilizar também pode ser entregue sem reinstalação — consulte [repor o computador](48-security.md).)

### Instalações não assistidas

A ISO também pode instalar-se completamente sozinha — sem teclado, sem assistente — quando lhe é entregue a configuração numa segunda unidade. É assim que se trata o Omarchy como uma imagem de base para VMs e máquinas de uma frota. Consulte [instalações não assistidas](51-unattended-installs.md).

### Instalações sem encriptação

O Omarchy instala-se com encriptação por predefinição. É a escolha segura e responsável para qualquer computador que possa ser perdido ou roubado. Não quer que ninguém com acesso ao seu hardware consiga obter os seus dados!

Mas, em circunstâncias especiais, como instalações remotas do Omarchy em computadores protegidos ou instalações descartáveis sem dados sensíveis, poderá querer instalar sem encriptação. Pode premir `Ctrl + C` na confirmação da formatação do disco para mudar para uma instalação sem encriptação.

### Idioma

O Omarchy fala 50 idiomas — o mesmo conjunto do omarchy.org — e o inglês é a predefinição. Para mudar, abra o menu do Omarchy e vá a _Configuração > Região > Idioma_, ou execute `omarchy language <code>` num terminal (`omarchy language list` mostra os códigos). O menu, o ambiente de trabalho e as próprias notificações do Omarchy mudam de idioma imediatamente, e todas as aplicações que abrir depois também acompanham a mudança. As aplicações que já estavam abertas mudam depois de as reiniciar.

Para manter o idioma mas escrever datas, horas, números, dinheiro, unidades e tamanhos de papel como outra região faz (inglês com datas europeias e um relógio de 24 horas, por exemplo), escolha uma região em _Configuração > Região > Formatos_, onde cada opção mostra um exemplo, ou execute `omarchy region <code>` (`omarchy region list` mostra os códigos). _Igual ao idioma_ volta aos formatos próprios do idioma. Tal como uma mudança de idioma, aplica-se às aplicações que abrir depois.

### Ajuda se ficar bloqueado

Se ficar bloqueado, normalmente encontra alguém disposto a ajudar no canal _#omarchy-help_ do [Discord da comunidade](https://omarchy.org/discord).
