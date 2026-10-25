# Segurança

A Omarchy leva a segurança extremamente a sério. Isto pretende ser um sistema operativo que pode usar para fazer _Trabalho a Sério_ no _Mundo Real_. Onde perder um portátil não pode dar origem a uma emergência de segurança. Por isso, eis o que fazemos:

1. *A encriptação completa do disco é obrigatória*: Este é o passo mais importante para garantir a proteção física dos seus dados. Se o seu computador for perdido ou roubado, os dados estão totalmente encriptados com o LUKS (Linux Unified Key Setup) standard.
2. *A firewall está ativada por omissão*: Todo o tráfego de entrada está bloqueado por omissão, exceto a porta 53317 para o [LocalSend](https://localsend.org/). Até o ssh está desligado até o ativar através de _Setup > Security > SSHD_, que abre a porta 22 (com limitação de taxa contra força bruta) como parte da configuração. Até restringimos o acesso ao Docker com a configuração [ufw-docker](https://github.com/chaifeng/ufw-docker) para impedir que os seus contentores fiquem acidentalmente expostos ao mundo.
3. *O Arch tem sempre as atualizações mais recentes*: O Arch, a distribuição subjacente em que a Omarchy se baseia, é uma distribuição rolling. Isto significa que qualquer vulnerabilidade de segurança que seja descoberta e corrigida em qualquer pacote fica rapidamente disponível para instalação com `omarchy-update`. Dessa forma, está sempre a executar as versões mais recentes e mais seguras de tudo.
4. *A Omarchy mantém os seus próprios pacotes e mirror*: Por omissão, a Omarchy só depende de pacotes dos repositórios core/extra/multilib do próprio Arch e do seu próprio Omarchy Package Repository. Pode instalar software diretamente a partir do AUR, mas a instalação base não o faz — só algumas instalações opcionais, como os browsers de terceiros, vão buscar pacotes ao AUR.
5. *A Cloudflare protege-nos contra DDoS*: A infraestrutura de distribuição da Omarchy — os ISOs, os pacotes Omarchy, o mirror do Arch — está protegida pelo formidável escudo contra DDoS da Cloudflare e alojada na sua CDN. Isto proporciona uma disponibilidade soberba.

## Alterar as suas palavras-passe

Numa instalação encriptada, tem duas palavras-passe: a que desbloqueia a unidade no arranque e a que utiliza para iniciar sessão e para o `sudo`. A configuração define-as como iguais. Ambas podem ser alteradas em _Update > Password_ no menu Omarchy — _Drive Encryption_ para a primeira, _User_ para a segunda. Alterar a palavra-passe da unidade pede-lhe primeiro a atual, por isso tenha-a à mão. Se uma alteração for interrompida, execute novamente _Drive Encryption_: pede-lhe a palavra-passe que desbloqueia agora a unidade e conclui a alteração.

## Passar a outra pessoa uma máquina que já utilizou

Se vai entregar a sua máquina a outra pessoa, não tem de a reinstalar. Execute _Setup > Reset Computer_ no menu Omarchy, escreva `reset` para confirmar e reinicie. Isso apaga todas as contas de utilizador e tudo o que está em `/home`, descarta todos os pacotes e todas as alterações ao sistema que fez desde a instalação e limpa a identidade da máquina — ligações de rede, chaves de host e tudo. O que volta a arrancar é o assistente de configuração do primeiro arranque, pronto para o novo proprietário introduzir o seu próprio nome, palavra-passe e palavra-passe de encriptação.

Funciona ao restaurar o snapshot de base que o instalador cria, por isso só está disponível em máquinas instaladas a partir do ISO Omarchy. E numa unidade sem encriptação, uma reposição é uma eliminação e não um apagamento seguro, por isso, se os dados eram sensíveis, faça antes uma instalação de raiz.

## sudo sem palavra-passe

Às vezes, quer que o `sudo` deixe de a pedir, na maioria das vezes quando um agente de IA está a fazer um longo período de trabalho de sistema por si. _Setup > Security > Passwordless Sudo_ pergunta durante quanto tempo deve permitir o acesso: **15 minutes**, **1 Hour**, **1 Day** ou **Permanently**. Aparece um ícone de aviso vermelho ao lado dos outros indicadores da barra de menus enquanto o acesso estiver ativo. Clique nele ou execute novamente o comando para desativar o acesso. Também pode passar o seu próprio número de minutos (de 1 a 1440) com `omarchy-sudo-passwordless 30`, ou usar `omarchy-sudo-passwordless permanent`.

O acesso temporizado expira automaticamente, incluindo imediatamente após retomar de uma suspensão que tenha ultrapassado o prazo. Reiniciar o computador termina-o mais cedo. O acesso permanente sobrevive aos reinícios e mantém-se ativado até o desativar.

Atualizar ou remover o pacote de definições da Omarchy termina qualquer concessão temporária antes de o suporte à sua expiração mudar. Se o comando indicar um erro de autorização ou de limpeza, resolva-o antes de tentar ativar outra concessão; um erro não significa que o acesso sem palavra-passe esteja inativo.

Veja isto com lucidez: enquanto estiver ativo, tudo o que estiver a ser executado como o seu utilizador pode fazer tudo como root sem que lhe seja pedido nada. É exatamente esse o objetivo, e é também exatamente esse o risco.

## Chaves de Assinatura

A chave pública para todas as assinaturas de ISO e para os pacotes do repositório Omarchy é `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verificar em openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). O pacote `omarchy/omarchy-keyring` também a contém e será utilizado para distribuir quaisquer potenciais atualizações de forma transparente.

Pode encontrar a assinatura de qualquer versão ISO ao adicionar .sig ao URL. Como https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
