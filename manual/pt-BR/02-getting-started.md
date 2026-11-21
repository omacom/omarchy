# Primeiros passos

O Omarchy é instalado usando uma ISO. Você pode escolher entre uma instalação em disco inteiro, que toma conta de todo o drive, ou uma instalação em espaço livre, que coloca o Omarchy no espaço não alocado de um drive — é assim que você faz dual boot ao lado do Windows ou de outro sistema operacional (consulte [instalação em dual-boot](50-dual-boot-install.md) — observe que você precisará desativar primeiro o BitLocker no Windows). De qualquer forma, por padrão a instalação usa criptografia completa, e a opção de disco inteiro vai apagar o drive selecionado, então não deixe de fazer um backup antes de usar um drive existente!

Primeiro [baixe a ISO do Omarchy](https://omarchy.org/), coloque-a em um pendrive (use o [Rufus](https://rufus.ie/) no Windows, o [balenaEtcher](https://etcher.balena.io/) no Mac ou o [caligula](https://github.com/ifd3f/caligula) no Linux) e inicialize a partir do pendrive.

_Você precisa desativar o Secure Boot e/ou o TPM na BIOS. Você tem que desativar esses recursos para conseguir instalar o Omarchy. São esquemas de segurança da Microsoft feitos para o Windows e para distribuições Linux afiliadas à Microsoft._

Depois responda às perguntas de configuração e confirme-as assim:

 ![install-config](images/install-config.webp)

Depois selecione um drive para a sua instalação e relaxe enquanto assiste ao show da instalação. Ela pode terminar em menos de um minuto nas máquinas modernas mais rápidas, mas não deve levar mais de 5 minutos nem mesmo em um computador mais antigo.

 ![install-done](images/install-done.webp)

Agora você está pronto para o Omarchy!

### Use um teclado com fio ou de 2.4ghz!

A criptografia de disco inteiro não vai permitir que você digite a senha com um teclado Bluetooth na inicialização. Assim como você não consegue usar um teclado Bluetooth para entrar na BIOS de um PC. Você vai precisar de um teclado que use um dongle de 2.4ghz ou um cabo (que, de qualquer forma, é bem melhor para a latência!). Pessoalmente, eu adoro o [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalando para outro proprietário

Se você está configurando uma máquina para outra pessoa — um familiar, um novo funcionário, um comprador — você não deve responder às perguntas pessoais no lugar dela. Pressione `Ctrl + C` na primeiríssima tela do instalador (a de seleção de teclado), e o Omarchy vai oferecer preparar a máquina para outro proprietário. O sistema é instalado na hora, mas toda a configuração pessoal — layout do teclado, nome de usuário, senha — fica adiada até a máquina ser inicializada pela primeira vez. O drive continua criptografado por padrão, e a senha que o novo proprietário escolher nessa primeira inicialização também se torna a senha de criptografia. (Uma máquina que você já vinha usando também pode ser entregue sem reinstalação — consulte [redefinindo o computador](48-security.md).)

### Instalações não assistidas

A ISO também pode instalar tudo completamente sozinha — sem teclado, sem assistente — quando recebe a sua configuração em um segundo drive. É assim que você trata o Omarchy como uma imagem base para VMs e máquinas de frotas. Consulte [instalações não assistidas](51-unattended-installs.md).

### Instalações sem criptografia

Por padrão, o Omarchy é instalado com criptografia. É a escolha segura e responsável para qualquer computador que possa ser perdido ou roubado. Você não quer que qualquer pessoa com acesso ao seu hardware consiga obter os seus dados!

Mas em circunstâncias especiais, como instalações remotas do Omarchy em computadores protegidos ou instalações descartáveis sem dados confidenciais, você pode querer instalar sem criptografia. Você pode pressionar `Ctrl + C` na confirmação de formatação do disco para mudar para uma instalação sem criptografia.

### Idioma

O Omarchy fala 50 idiomas — o mesmo conjunto do omarchy.org — e o inglês é o padrão. Para trocar, abra o menu do Omarchy e vá para _Configuração > Região > Idioma_, ou execute `omarchy language <code>` em um terminal (`omarchy language list` mostra os códigos). O menu, a área de trabalho e as notificações do próprio Omarchy mudam de idioma imediatamente, e todos os aplicativos que você abrir depois também acompanham. Os aplicativos que já estavam abertos mudam quando você os reinicia.

Para manter o idioma, mas escrever datas, horas, números, dinheiro, unidades e tamanhos de papel do jeito que outra região faz (inglês com datas europeias e relógio de 24 horas, por exemplo), escolha uma região em _Configuração > Região > Formatos_, onde cada opção mostra um exemplo, ou execute `omarchy region <code>` (`omarchy region list` mostra os códigos). _Mesmo do idioma_ volta aos formatos do próprio idioma. Assim como a troca de idioma, ela alcança os aplicativos que você abrir depois.

### Ajuda se você travar

Se você travar, geralmente consegue encontrar alguém disposto a ajudar no canal _#omarchy-help_ no [Discord da comunidade](https://omarchy.org/discord).
