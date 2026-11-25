# Segurança

O Omarchy leva a segurança extremamente a sério. Isto foi feito para ser um sistema operativo que pode utilizar para fazer _Trabalho a Sério_ no _Mundo Real_. Onde perder um portátil não pode dar origem a uma emergência de segurança. Por isso, eis o que fazemos:

1. *A encriptação total do disco está ativada por omissão*: Este é o passo mais importante para garantir a proteção física dos seus dados. Se o seu computador se perder ou for roubado, os dados estão totalmente encriptados com o LUKS (Linux Unified Key Setup) normal. O instalador permite-lhe optar por não a utilizar em máquinas descartáveis (ver [Começar](02-getting-started.md)); uma instalação sem encriptação não tem nenhuma desta proteção, e qualquer pessoa com a unidade na mão pode lê-la.
2. *A firewall está ativada por omissão*: Todo o tráfego de entrada está bloqueado por omissão, com algumas exceções: a porta 53317 para o [LocalSend](https://localsend.org/); consultas DNS para o próprio resolvedor do computador no endereço da bridge do Docker (172.17.0.1), aceites a partir dos intervalos de endereços privados que o Docker atribui aos seus contentores; e DNS multicast (porta 5353), que permite que impressoras e outros dispositivos na sua rede se encontrem uns aos outros e também anuncia aí o nome do seu computador. Além dessas, a firewall mantém as permissões normais do UFW para ping, para obter um endereço do seu router (DHCP) e para a descoberta UPnP. Até o ssh está desligado até o ativar em _Configuração > Segurança > SSHD_, que autoriza a sua chave SSH, desliga os inícios de sessão com palavra-passe e só então abre a porta 22 (com limite de taxa contra ataques de força bruta). Até restringimos o acesso ao Docker com a configuração [ufw-docker](https://github.com/chaifeng/ufw-docker) para impedir que os seus contentores fiquem acidentalmente expostos ao mundo.
3. *O Arch tem sempre as atualizações mais recentes*: O Arch, a distribuição subjacente em que o Omarchy assenta, é uma distribuição rolling. Isto significa que qualquer vulnerabilidade de segurança que seja descoberta e corrigida em qualquer pacote fica rapidamente disponível para instalação com `omarchy-update`. Dessa forma, está sempre a executar as versões mais recentes e mais seguras de tudo.
4. *O Omarchy mantém os seus próprios pacotes e mirror*: O Omarchy, por omissão, só depende de pacotes dos repositórios core/extra/multilib do próprio Arch (os do Arch Linux ARM em máquinas ARM, mais o Asahi ALARM em Apple Silicon) e do seu próprio Omarchy Package Repository. Pode instalar software diretamente a partir do AUR, mas a instalação de base não o faz — só algumas instalações opcionais, como os browsers de terceiros, vão buscar pacotes ao AUR.
5. *A Cloudflare protege-nos de DDoS*: A infraestrutura de distribuição do Omarchy — as ISO, os pacotes do Omarchy, o mirror do Arch — está protegida atrás do formidável escudo anti-DDoS da Cloudflare e alojada na CDN dela. Isto proporciona uma disponibilidade excelente.

## Alterar as suas palavras-passe

Tem duas palavras-passe numa instalação encriptada: a que desbloqueia a unidade no arranque e a que usa para iniciar sessão e para o `sudo`. A configuração inicial faz com que sejam iguais. _Atualizar > Palavra-passe_ no menu do Omarchy altera ambas ao mesmo tempo, para continuarem iguais: pede a palavra-passe atual da unidade, depois a nova, altera a da unidade e depois define a sua palavra-passe de início de sessão para corresponder. Sem encriptação da unidade, altera apenas a sua palavra-passe de início de sessão. Se uma alteração for interrompida, execute outra vez _Atualizar > Palavra-passe_: pede a palavra-passe que desbloqueia agora a unidade, conclui a alteração e define a sua palavra-passe de início de sessão com essa palavra-passe. Para alterar a palavra-passe de outra unidade encriptada, execute `omarchy-drive-password` num terminal.

## Entregar uma máquina que já utilizou

Se vai entregar a sua máquina a outra pessoa, não tem de a reinstalar. Execute _Remover > Reposição de Fábrica_ no menu do Omarchy, escreva `reset` para confirmar, introduza a palavra-passe de encriptação da unidade se lhe for pedida e reinicie. Isto apaga todas as contas de utilizador e tudo o que está em `/home`, deita fora todos os pacotes e alterações ao sistema que fez desde a instalação e limpa a identidade da máquina — ligações de rede, chaves de host e tudo. O que volta a arrancar é o assistente de configuração do primeiro arranque, pronto para o novo proprietário introduzir o seu próprio nome, palavra-passe e palavra-passe de encriptação.

Funciona restaurando o snapshot de base que o instalador cria, por isso só está disponível em máquinas instaladas a partir da ISO do Omarchy. E numa unidade sem encriptação, uma reposição é uma eliminação e não um apagamento seguro, por isso, se os dados eram sensíveis, faça antes uma instalação de raiz.

## Sudo sem palavra-passe

Por vezes quer que o `sudo` pare de pedir a palavra-passe, sobretudo quando um agente de IA está a fazer um trabalho de sistema prolongado por si. _Configuração > Segurança > Sudo sem Palavra-passe_ pergunta durante quanto tempo quer permitir o acesso: **15 minutos**, **1 Hora**, **1 Dia** ou **Permanentemente**. Aparece um ícone de aviso vermelho ao lado dos outros indicadores da barra de menus enquanto o acesso estiver ativo. Clique nele ou execute o comando outra vez para desligar o acesso. Também pode indicar o seu próprio número de minutos (de 1 a 1440) com `omarchy-sudo-passwordless 30`, ou usar `omarchy-sudo-passwordless permanent`.

O acesso temporizado expira automaticamente, incluindo imediatamente após retomar de uma suspensão que tenha ultrapassado o prazo. Reiniciar o computador termina-o mais cedo. O acesso permanente sobrevive aos reinícios e mantém-se ativado até o desativar.

Atualizar ou remover o pacote de definições do Omarchy termina qualquer concessão temporária antes de o suporte à sua expiração mudar. Se o comando comunicar um erro de autorização ou de limpeza, resolva-o antes de tentar ativar outra concessão; um erro não significa que o acesso sem palavra-passe esteja inativo.

Tenha os olhos bem abertos quanto a isto: enquanto estiver ativo, tudo o que estiver a ser executado como o seu utilizador pode fazer tudo como root sem lhe ser pedido nada. É exatamente esse o objetivo, e é também exatamente esse o risco.

## Chaves de Assinatura

A chave pública para todas as assinaturas das ISO e para os pacotes do repositório do Omarchy é `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verificar em openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). O pacote `omarchy/omarchy-keyring` também a contém e será utilizado para distribuir eventuais atualizações sem complicações.

Pode encontrar a assinatura de qualquer lançamento de ISO adicionando `.sig` ao seu URL, como `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
