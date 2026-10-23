# Segurança

O Omarchy leva a segurança extremamente a sério. Isto pretende ser um sistema operativo que pode usar para fazer _Trabalho a Sério_ no _Mundo Real_. Onde perder um portátil não pode levar a uma emergência de segurança. Por isso, eis o que fazemos:

1. *A encriptação de todo o disco é obrigatória*: este é o passo mais importante para assegurar a proteção física dos seus dados. Se o seu computador se perder ou for roubado, os dados estão totalmente encriptados usando o LUKS (Linux Unified Key Setup) padrão.
2. *A firewall está ativada por predefinição*: todo o tráfego de entrada está bloqueado por predefinição, exceto a porta 53317 para o [LocalSend](https://localsend.org/). Até o ssh está desligado até o ligar através de _Configurar > Segurança > SSHD_, que abre a porta 22 (com limitação de ritmo contra força bruta) como parte da configuração. Chegamos até a restringir o acesso ao Docker usando a configuração [ufw-docker](https://github.com/chaifeng/ufw-docker) para impedir que os seus contentores sejam acidentalmente expostos ao mundo.
3. *O Arch tem sempre as atualizações mais recentes*: o Arch, a distribuição subjacente sobre a qual o Omarchy é construído, é uma distribuição rolling. Isto significa que qualquer vulnerabilidade de segurança que seja descoberta e corrigida em qualquer pacote fica rapidamente disponível para instalação usando `omarchy-update`. Assim, está sempre a executar as versões mais recentes e mais seguras de tudo.
4. *O Omarchy mantém os seus próprios pacotes e espelho*: o Omarchy só depende, por predefinição, de pacotes dos próprios repositórios core/extra/multilib do Arch e do seu próprio Repositório de Pacotes Omarchy. Pode instalar software diretamente do AUR, mas a instalação de base não o faz — só algumas instalações opcionais, como os navegadores de terceiros, vão buscar ao AUR.
5. *A Cloudflare protege-nos de DDoS*: toda a infraestrutura de distribuição do Omarchy — as ISO, os pacotes Omarchy, o espelho Arch — está protegida atrás do formidável escudo DDoS da Cloudflare e alojada na sua CDN. Isto proporciona uma disponibilidade soberba.

## Mudar as suas palavras-passe

Tem duas palavras-passe numa instalação encriptada: a que desbloqueia a unidade no arranque e aquela com que inicia sessão e usa `sudo`. A configuração torna-as iguais. Ambas podem ser mudadas em _Atualizar > Palavra-passe_ no menu Omarchy — _Encriptação do disco_ para a primeira, _Utilizador_ para a segunda. Mudar a palavra-passe da unidade pede primeiro a atual, por isso tenha-a à mão. Se uma mudança for interrompida, execute _Encriptação do disco_ de novo: ele pede a palavra-passe que desbloqueia a unidade agora e termina a mudança.

## Entregar uma máquina que já usou

Se estiver a entregar a sua máquina a outra pessoa, não tem de a reinstalar. Execute _Configurar > Repor computador_ no menu Omarchy, escreva `reset` para confirmar e reinicie. Isso apaga todas as contas de utilizador e tudo em `/home`, deita fora todos os pacotes e alterações ao sistema que fez desde a instalação, e limpa a identidade da máquina — ligações de rede, chaves de anfitrião e tudo. O que volta a aparecer é o assistente de configuração do primeiro arranque, pronto para o seu novo dono introduzir o seu próprio nome, palavra-passe e palavra-passe de encriptação.

Funciona restaurando o instantâneo de base que o instalador cria, por isso só está disponível em máquinas instaladas a partir da ISO do Omarchy. E numa unidade sem encriptação, uma reposição é eliminação, e não uma limpeza segura, por isso, se os dados forem sensíveis, faça em vez disso uma instalação limpa.

## Sudo sem palavra-passe

Por vezes queremos que o `sudo` deixe de pedir, mais frequentemente quando um agente de IA está a fazer uma longa sequência de trabalho de sistema por si. _Configurar > Segurança > Sudo sem palavra-passe_ pergunta durante quanto tempo permitir o acesso: **15 minutos**, **1 Hora**, **1 Dia** ou **Permanentemente**. Um ícone de aviso vermelho aparece ao lado dos outros indicadores da barra de menus enquanto o acesso estiver ativo. Clique nele ou execute o comando de novo para desligar o acesso. Também pode passar o seu próprio número de minutos (de 1 a 1440) com `omarchy-sudo-passwordless 30`, ou usar `omarchy-sudo-passwordless permanent`.

O acesso temporizado expira automaticamente, incluindo imediatamente após retomar de uma suspensão que tenha ultrapassado o prazo. Reiniciar o computador termina-o mais cedo. O acesso permanente sobrevive a reinícios e mantém-se ativado até o desativar.

Atualizar ou remover o pacote de definições do Omarchy termina qualquer concessão temporária antes de o seu suporte de expiração mudar. Se o comando comunicar um erro de autorização ou de limpeza, resolva-o antes de tentar ativar outra concessão; um erro não significa que o acesso sem palavra-passe esteja inativo.

Tenha os olhos bem abertos em relação a isto: enquanto estiver ligado, qualquer coisa a correr como o seu utilizador pode fazer qualquer coisa como root sem que lhe seja pedido. É esse todo o objetivo, e é também todo o risco.

## Chaves de assinatura

A chave pública para todas as assinaturas de ISO e pacotes do repositório Omarchy é `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verificar em openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). O pacote `omarchy/omarchy-keyring` também a contém e será usado para distribuir sem problemas quaisquer potenciais atualizações.

Pode encontrar a assinatura de qualquer lançamento ISO adicionando .sig ao URL. Como https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
