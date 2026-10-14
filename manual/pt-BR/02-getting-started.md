# Primeiros passos

O Omarchy é instalado usando uma ISO. Você pode escolher entre uma instalação em disco inteiro, que ocupa toda a unidade, ou uma instalação no espaço livre, que coloca o Omarchy no espaço não alocado de uma unidade — é assim que você faz dual boot ao lado do Windows ou de outro sistema operacional (consulte [instalação em dual boot](50-dual-boot-install.md) — observe que você precisará desativar o BitLocker no Windows primeiro). De qualquer forma, a instalação usa criptografia completa por padrão, e a opção de disco inteiro apagará a unidade selecionada, então faça um backup antes de usar uma unidade existente!

[Baixe a ISO do Omarchy](https://omarchy.org/) primeiro, coloque-a em um pendrive USB (use o [balenaEtcher](https://etcher.balena.io/) no Mac/Windows ou o [caligula](https://github.com/ifd3f/caligula) no Linux) e inicialize a partir do pendrive.

_Você deve desativar o Secure Boot e/ou o TPM na BIOS. Você precisa desativar isso para conseguir instalar o Omarchy. São esquemas de segurança da Microsoft feitos para o Windows e para distribuições Linux afiliadas à Microsoft._

Depois responda às perguntas de configuração e confirme-as assim:

 ![install-config](images/install-config.webp)

Depois selecione uma unidade para a instalação e relaxe e assista ao show da instalação. Ela pode terminar em menos de um minuto nas máquinas modernas mais rápidas, mas não deve levar mais de 5 minutos nem mesmo em um computador mais antigo.

 ![install-done](images/install-done.webp)

Agora você está pronto para o Omarchy!

### Use um teclado com fio ou de 2.4ghz!

A criptografia de disco inteiro não permitirá que você digite a senha a partir de um teclado Bluetooth na inicialização. Assim como você não consegue usar um teclado Bluetooth para entrar na BIOS em um PC. Você precisará de um teclado que use um dongle de 2.4ghz ou um cabo (que é muito melhor para a latência, de qualquer forma!). Eu pessoalmente adoro o [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalando para outro proprietário

Se você está configurando uma máquina para outra pessoa — um familiar, um novo funcionário, um comprador — você não deveria responder às perguntas pessoais em nome dela. Pressione `Ctrl + C` na primeiríssima tela do instalador (a seleção de teclado), e o Omarchy oferecerá preparar a máquina para outro proprietário. O sistema é instalado na hora, mas toda a configuração pessoal — layout do teclado, nome de usuário, senha — é adiada até a máquina inicializar pela primeira vez. A unidade continua criptografada por padrão, e a senha que o novo proprietário escolher nessa primeira inicialização também se torna a senha de criptografia. (Uma máquina que você já vem usando também pode ser entregue sem reinstalação — consulte [redefinindo o computador](48-security.md).)

### Instalações não assistidas

A ISO também pode instalar completamente sozinha — sem teclado, sem assistente — quando recebe sua configuração em uma segunda unidade. É assim que você trata o Omarchy como uma imagem base para VMs e máquinas de uma frota. Consulte [instalações não assistidas](51-unattended-installs.md).

### Instalações sem criptografia

O Omarchy é instalado com criptografia por padrão. É a escolha segura e responsável para qualquer computador que possa ser perdido ou roubado. Você não quer que ninguém com acesso ao seu hardware consiga obter seus dados!

Mas em circunstâncias especiais, como instalações remotas do Omarchy em computadores protegidos ou instalações descartáveis sem dados sensíveis, você pode querer instalar sem criptografia. Você pode pressionar `Ctrl + C` na confirmação de formatação do disco para mudar para uma instalação sem criptografia.

### Idioma

O Omarchy fala 50 idiomas — o mesmo conjunto do omarchy.org — e o inglês é o padrão. Para trocar, abra o menu do Omarchy e vá para _Configuração > Idioma_, ou execute `omarchy language <code>` em um terminal (`omarchy language list` mostra os códigos). O menu, a área de trabalho e as próprias notificações do Omarchy mudam de idioma imediatamente, e todos os aplicativos que você abrir depois também acompanham. Os aplicativos que já estavam abertos mudam assim que você os reiniciar.

### Ajuda se você travar

Se você travar, geralmente consegue encontrar alguém disposto a ajudar no canal _#omarchy-help_ no [Discord da comunidade](https://omarchy.org/discord).
