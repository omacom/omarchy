# Primeiros Passos

O Omarchy é instalado usando uma ISO. Você pode escolher entre uma instalação em disco inteiro, que ocupa o disco todo, ou uma instalação em espaço livre, que coloca o Omarchy no espaço não alocado de um disco — é assim que você faz dual boot ao lado do Windows ou de outro sistema operacional (veja [instalação em dual boot](50-dual-boot-install.md) — observe que primeiro você vai precisar desativar o BitLocker no Windows). De qualquer forma, a instalação usa criptografia completa por padrão, e a opção de disco inteiro apagará o disco selecionado, então não deixe de fazer um backup antes de usar um disco existente!

Primeiro [baixe a ISO do Omarchy](https://omarchy.org/), coloque-a em um pen drive (use o [Rufus](https://rufus.ie/) no Windows, o [balenaEtcher](https://etcher.balena.io/) no Mac ou o [caligula](https://github.com/ifd3f/caligula) no Linux) e inicialize a partir do pen drive.

_Você deve desativar o Secure Boot e/ou o TPM na BIOS. Você tem que desativar esses recursos para conseguir instalar o Omarchy. Eles são esquemas de segurança da Microsoft feitos para o Windows e para distribuições Linux afiliadas à Microsoft._

Depois responda às perguntas de configuração e confirme-as assim:

 ![install-config](images/install-config.webp)

Depois selecione um disco para a sua instalação, sente-se e assista ao espetáculo da instalação. Dá para concluir em menos de um minuto nas máquinas modernas mais rápidas, mas não deve levar mais de 5 minutos nem mesmo em um computador mais antigo.

 ![install-done](images/install-done.webp)

Agora você está pronto para o Omarchy!

### Use um teclado com fio ou 2.4ghz!

A criptografia de disco inteiro não permitirá que você digite a senha a partir de um teclado Bluetooth na inicialização. Assim como você não consegue usar um teclado Bluetooth para entrar na BIOS em um PC. Você vai precisar de um teclado que use um dongle 2.4ghz ou um cabo (o que é bem melhor para a latência, aliás!). Pessoalmente, eu adoro o [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalando para outro proprietário

Se você está configurando uma máquina para outra pessoa — um familiar, um novo funcionário, um comprador — você não deveria responder às perguntas pessoais no lugar dela. Pressione `Ctrl + C` na primeiríssima tela do instalador (a seleção de teclado), e o Omarchy oferecerá preparar a máquina para outro proprietário. O sistema é instalado na hora, mas toda a configuração pessoal — layout do teclado, nome de usuário, senha — fica adiada até a máquina ser inicializada pela primeira vez. O disco continua criptografado por padrão, e a senha que o novo proprietário escolher na primeira inicialização torna-se também a senha da criptografia. (Uma máquina que você já vinha usando também pode ser entregue sem reinstalação — veja [redefinir o computador](48-security.md).)

### Instalações não assistidas

A ISO também pode instalar tudo completamente sozinha — sem teclado, sem assistente — quando recebe sua configuração em um segundo disco. Essa é a maneira de tratar o Omarchy como uma imagem base para VMs e máquinas de frota. Veja [instalações não assistidas](51-unattended-installs.md).

### Instalações sem criptografia

O Omarchy é instalado com criptografia por padrão. É a escolha segura e responsável para qualquer computador que possa ser perdido ou roubado. Você não quer que qualquer pessoa com acesso ao seu hardware consiga obter os seus dados!

Mas em circunstâncias especiais, como instalações remotas do Omarchy em computadores protegidos ou instalações descartáveis sem dados sensíveis, você pode querer instalar sem criptografia. Você pode pressionar `Ctrl + C` na confirmação de formatação do disco para mudar para uma instalação sem criptografia.

### Idioma

O Omarchy fala 50 idiomas — o mesmo conjunto do omarchy.org — e o inglês é o padrão. Para mudar, abra o menu do Omarchy e vá para _Setup > Region > Language_, ou execute `omarchy language <code>` em um terminal (`omarchy language list` mostra os códigos). O menu, a área de trabalho e as próprias notificações do Omarchy mudam de idioma imediatamente, e todos os aplicativos que você abrir depois também acompanham. Os aplicativos que já estavam abertos mudam depois que você reiniciá-los.

Para manter o idioma, mas escrever datas, horas, números, dinheiro, unidades e tamanhos de papel do jeito que outra região faz (inglês com datas europeias e relógio de 24 horas, por exemplo), escolha uma região em _Setup > Region > Formats_, onde cada opção mostra um exemplo, ou execute `omarchy region formats <code>` (`omarchy region formats list` mostra os códigos). _Same as language_ volta aos formatos do próprio idioma. Como uma mudança de idioma, isso se aplica aos aplicativos que você abrir depois.

### Ajuda se você travar

Se você travar, geralmente consegue encontrar alguém disposto a ajudar no canal _#omarchy-help_ no [Discord da comunidade](https://omarchy.org/discord).
