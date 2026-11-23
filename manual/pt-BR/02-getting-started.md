# Primeiros passos

Omarchy é instalado usando uma ISO. Você pode escolher entre uma instalação em disco inteiro, que ocupa todo o disco, ou uma instalação em espaço livre, que coloca o Omarchy no espaço não alocado de um disco — é assim que você faz dual boot junto com o Windows ou outro sistema operacional (veja [instalação em dual-boot](50-dual-boot-install.md) — observe que primeiro você precisará desativar o BitLocker no Windows). De qualquer forma, a instalação usa criptografia completa por padrão, e a opção de disco inteiro apagará o disco selecionado, então não deixe de fazer um backup antes de usar um disco já existente!

Em um Mac com Apple Silicon, a instalação é feita a partir do macOS, sem ISO nem pendrive USB. Veja [Omarchy para Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Baixe a ISO do Omarchy](https://omarchy.org/) primeiro, coloque-a em um pendrive USB (use [Rufus](https://rufus.ie/) no Windows, [balenaEtcher](https://etcher.balena.io/) no Mac ou [caligula](https://github.com/ifd3f/caligula) no Linux) e inicialize a partir do pendrive.

_Você precisa desativar o Secure Boot e/ou o TPM na BIOS. Você precisa desativar isso para conseguir instalar o Omarchy. São esquemas de segurança da Microsoft feitos para o Windows e para distribuições Linux afiliadas à Microsoft._

Depois responda às perguntas de configuração e confirme-as assim:

 ![install-config](images/install-config.webp)

Depois selecione um disco para a instalação, sente-se e assista ao show da instalação. Dá para terminar em menos de um minuto nas máquinas modernas mais rápidas, mas não deve levar mais de 5 minutos nem em um computador mais antigo.

 ![install-done](images/install-done.webp)

Agora você está pronto para o Omarchy!

### Use um teclado com fio ou de 2.4ghz!

A criptografia de disco inteiro não permitirá que você digite a senha em um teclado Bluetooth na inicialização. Assim como você não pode usar um teclado Bluetooth para entrar na BIOS em um PC. Você precisará de um teclado que use um dongle de 2.4ghz ou um cabo (que é muito melhor para a latência, aliás!). Eu pessoalmente adoro o [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalando para outro dono

Se você está configurando uma máquina para outra pessoa — um familiar, um novo funcionário, um comprador — você não deveria responder às perguntas pessoais no lugar dela. Pressione `Ctrl + C` na primeiríssima tela do instalador (a seleção de teclado), e o Omarchy oferecerá preparar a máquina para outro dono. O sistema instala na hora, mas toda a configuração pessoal — layout do teclado, nome de usuário, senha — fica adiada até a máquina inicializar pela primeira vez. O disco continua criptografado por padrão, e a senha que o novo dono escolher nessa primeira inicialização também se torna a senha de criptografia. (Uma máquina que você já vem usando também pode ser entregue sem reinstalação — veja [redefinindo o computador](48-security.md).)

### Instalações não supervisionadas

A ISO também pode instalar completamente sozinha — sem teclado, sem assistente — quando recebe sua configuração em um segundo disco. É assim que você trata o Omarchy como uma imagem base para VMs e máquinas de uma frota. Veja [instalações não supervisionadas](51-unattended-installs.md).

### Instalações sem criptografia

O Omarchy é instalado com criptografia por padrão. É a escolha segura e responsável para qualquer computador que possa ser perdido ou roubado. Você não quer que qualquer pessoa com acesso ao seu hardware consiga obter seus dados!

Mas em circunstâncias especiais, como instalações remotas do Omarchy em computadores protegidos ou instalações descartáveis sem dados confidenciais, você pode querer instalar sem criptografia. Você pode pressionar `Ctrl + C` na confirmação de formatação do disco para mudar para uma instalação sem criptografia.

### Idioma

O Omarchy fala 50 idiomas — o mesmo conjunto do omarchy.org — e o inglês é o padrão. Para trocar, abra o menu do Omarchy e vá para _Configuração > Região > Idioma_, ou execute `omarchy language <code>` em um terminal (`omarchy language list` mostra os códigos). O menu, a área de trabalho e as notificações do próprio Omarchy mudam de idioma imediatamente, e todos os aplicativos que você abrir depois também seguem o idioma. Os aplicativos que já estavam abertos mudam assim que você os reiniciar.

Para manter o idioma, mas escrever datas, horas, números, dinheiro, unidades e tamanhos de papel do jeito que outra região faz (inglês com datas europeias e um relógio de 24 horas, por exemplo), escolha uma região em _Configuração > Região > Formatos_, onde cada escolha mostra um exemplo, ou execute `omarchy region formats <code>` (`omarchy region formats list` mostra os códigos). _Mesmo que o idioma_ volta aos formatos próprios do idioma. Como uma troca de idioma, isso alcança os aplicativos que você abrir depois.

### Ajuda se você travar

Se você travar, geralmente consegue encontrar alguém disposto a ajudar no canal _#omarchy-help_ no [Discord da comunidade](https://omarchy.org/discord).
