# Segurança

O Omarchy leva a segurança extremamente a sério. Isto destina-se a ser um sistema operativo que pode utilizar para fazer _Trabalho a Sério_ no _Mundo Real_. Onde perder um portátil não pode dar origem a uma emergência de segurança. Por isso, eis o que fazemos:

1. *A encriptação completa do disco está ativada por defeito*: Este é o passo mais importante para garantir a proteção física dos seus dados. Se o seu computador for perdido ou roubado, os dados estão totalmente encriptados com o LUKS (Linux Unified Key Setup) padrão. O instalador permite-lhe optar por não o fazer em máquinas descartáveis (consulte [Primeiros passos](02-getting-started.md)); uma instalação sem encriptação não tem nenhuma desta proteção, e qualquer pessoa que tenha o disco pode lê-lo.
2. *A firewall está ativada por defeito*: Todo o tráfego de entrada está bloqueado por defeito, com algumas exceções: a porta 53317 para o [LocalSend](https://localsend.org/); consultas DNS para o resolver do próprio computador no endereço da bridge do Docker (172.17.0.1), aceites a partir dos intervalos de endereços privados que o Docker atribui aos seus contentores; e DNS multicast (porta 5353), que permite que impressoras e outros dispositivos na sua rede se encontrem uns aos outros e também anuncia aí o nome do seu computador. Além dessas, a firewall mantém as permissões padrão do UFW para ping, para obter um endereço a partir do seu router (DHCP) e para a descoberta UPnP. Até o ssh está desligado até o ativar através de _Configuração > Segurança > SSHD_, que abre a porta 22 (com limite de taxa contra força bruta) como parte da configuração. Até bloqueamos o acesso ao Docker com a configuração [ufw-docker](https://github.com/chaifeng/ufw-docker) para impedir que os seus contentores fiquem acidentalmente expostos ao mundo.
3. *O Arch tem sempre as atualizações mais recentes*: O Arch, a distribuição subjacente sobre a qual o Omarchy é construído, é uma distribuição rolling. Isto significa que qualquer vulnerabilidade de segurança que seja descoberta e corrigida em qualquer pacote fica rapidamente disponível para instalação com `omarchy-update`. Dessa forma, está sempre a executar as versões mais recentes e mais seguras de tudo.
4. *O Omarchy mantém os seus próprios pacotes e espelho*: Por defeito, o Omarchy só depende de pacotes dos repositórios core/extra/multilib do próprio Arch e do seu próprio Repositório de Pacotes Omarchy. Pode instalar software diretamente a partir do AUR, mas a instalação base não o faz — apenas algumas instalações opcionais, como os navegadores de terceiros, vão buscar ao AUR.
5. *A Cloudflare protege-nos contra DDoS*: A infraestrutura de distribuição do Omarchy — os ISOs, os pacotes Omarchy, o espelho Arch — está protegida atrás do formidável escudo DDoS da Cloudflare e alojada na CDN deles. Isto proporciona uma disponibilidade soberba.

## Alterar as suas palavras-passe

Numa instalação encriptada, tem duas palavras-passe: a que desbloqueia o disco no arranque e a que utiliza para iniciar sessão e para o `sudo`. A configuração inicial torna-as iguais. Ambas podem ser alteradas em _Atualizar > Palavra-passe_ no menu Omarchy — _Encriptação do Disco_ para a primeira, _Utilizador_ para a segunda. Alterar a palavra-passe do disco pede primeiro a atual, por isso tenha-a à mão. Se uma alteração for interrompida, execute _Encriptação do Disco_ outra vez: pede a palavra-passe que desbloqueia o disco agora e conclui a alteração.

## Entregar uma máquina que já utilizou

Se vai entregar a sua máquina a outra pessoa, não tem de a reinstalar. Execute _Remover > Reposição de Fábrica_ no menu Omarchy, escreva `reset` para confirmar e reinicie. Isto apaga todas as contas de utilizador e tudo o que está em `/home`, descarta todos os pacotes e alterações ao sistema que fez desde a instalação e limpa a identidade da máquina — ligações de rede, chaves de anfitrião e tudo. O que volta a arrancar é o assistente de configuração do primeiro arranque, pronto para o novo proprietário introduzir o seu próprio nome, palavra-passe e palavra-passe de encriptação.

Funciona ao restaurar o snapshot de base que o instalador cria, por isso só está disponível em máquinas instaladas a partir do ISO do Omarchy. E num disco sem encriptação, uma reposição é uma eliminação e não um apagamento seguro, por isso, se os dados eram sensíveis, faça antes uma instalação de raiz.

## Sudo sem palavra-passe

Por vezes, quer que o `sudo` pare de perguntar, sobretudo quando um agente de IA está a fazer um longo período de trabalho de sistema por si. _Configuração > Segurança > Sudo sem Palavra-passe_ pergunta durante quanto tempo quer permitir o acesso: **15 minutos**, **1 Hora**, **1 Dia** ou **Permanentemente**. Aparece um ícone de aviso vermelho junto aos outros indicadores da barra de menus enquanto o acesso estiver ativo. Clique nele ou execute o comando outra vez para desligar o acesso. Também pode passar o seu próprio número de minutos (de 1 a 1440) com `omarchy-sudo-passwordless 30`, ou utilizar `omarchy-sudo-passwordless permanent`.

O acesso temporizado expira automaticamente, incluindo imediatamente após retomar de uma suspensão que tenha ultrapassado o prazo. Reiniciar o computador termina-o mais cedo. O acesso permanente sobrevive aos reinícios e mantém-se ativado até o desativar.

Atualizar ou remover o pacote de definições do Omarchy termina qualquer concessão temporária antes de o respetivo suporte de expiração mudar. Se o comando comunicar um erro de autorização ou de limpeza, resolva-o antes de tentar ativar outra concessão; um erro não significa que o acesso sem palavra-passe esteja inativo.

Não se iluda quanto a isto: enquanto estiver ativo, tudo o que estiver a ser executado como o seu utilizador pode fazer qualquer coisa como root sem lhe ser pedido. É exatamente esse o objetivo, e é também exatamente esse o risco.

## Chaves de assinatura

A chave pública para todas as assinaturas dos ISOs e para os pacotes do repositório Omarchy é `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verificar em openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). O pacote `omarchy/omarchy-keyring` também a contém e será utilizado para distribuir quaisquer eventuais atualizações sem problemas.

Pode encontrar a assinatura de qualquer lançamento ISO ao adicionar `.sig` ao seu URL, como `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
