# Segurança

O Omarchy leva a segurança extremamente a sério. Isto foi feito para ser um sistema operativo que podes usar para fazer _Trabalho a Sério_ no _Mundo Real_. Onde perder um portátil não pode levar a uma emergência de segurança. Portanto, eis o que fazemos:

1. *Encriptação total do disco é obrigatória*: Este é o passo mais importante para garantir a proteção física dos teus dados. Se o teu computador se perder ou for roubado, os dados estão totalmente encriptados usando o LUKS padrão (Linux Unified Key Setup).
2. *A firewall está ativada por predefinição*: Todo o tráfego de entrada está bloqueado por predefinição, exceto na porta 53317 para o [LocalSend](https://localsend.org/). Até o ssh está desativado até o ativares através de _Configuração > Segurança > SSHD_, que abre a porta 22 (com limite de taxa contra força bruta) como parte da configuração. Até bloqueamos o acesso ao Docker usando a configuração [ufw-docker](https://github.com/chaifeng/ufw-docker) para impedir que os teus contentores sejam acidentalmente expostos ao mundo.
3. *O Arch tem sempre as atualizações mais recentes*: O Arch, a distribuição subjacente na qual o Omarchy assenta, é uma distribuição rolling. Isto significa que qualquer vulnerabilidade de segurança que seja descoberta e corrigida em qualquer pacote fica rapidamente disponível para instalação usando `omarchy-update`. Dessa forma, estás sempre a executar as versões mais recentes e mais seguras de tudo.
4. *O Omarchy mantém os seus próprios pacotes e mirror*: Por predefinição, o Omarchy só depende de pacotes dos repositórios core/extra/multilib do próprio Arch e do seu próprio Repositório de Pacotes do Omarchy. Podes instalar software diretamente a partir do AUR, mas a instalação base não o faz — apenas algumas instalações opcionais, como os navegadores de terceiros, vão buscar ao AUR.
5. *A Cloudflare protege-nos contra DDoS*: A infraestrutura de distribuição do Omarchy — os ISOs, os pacotes do Omarchy, o mirror do Arch — está protegida atrás do formidável escudo DDoS da Cloudflare e alojada na sua CDN. Isto proporciona uma disponibilidade soberba.

## Alterar as tuas palavras-passe

Numa instalação encriptada, tens duas palavras-passe: a que desbloqueia a unidade no arranque e a que usas para iniciar sessão e para `sudo`. A configuração define-as como iguais. Ambas podem ser alteradas em _Atualizar > Palavra-passe_ no menu do Omarchy — _Encriptação da Unidade_ para a primeira, _Utilizador_ para a segunda. Alterar a palavra-passe da unidade pede primeiro a atual, por isso tem-na à mão. Se uma alteração for interrompida, executa _Encriptação da Unidade_ novamente: pede a palavra-passe que desbloqueia a unidade agora e conclui a alteração.

## Entregar um computador que já usaste

Se vais entregar o teu computador a outra pessoa, não tens de o reinstalar. Executa _Configuração > Repor Computador_ no menu do Omarchy, escreve `reset` para confirmar e reinicia. Isto apaga todas as contas de utilizador e tudo o que está em `/home`, elimina todos os pacotes e alterações ao sistema que fizeste desde a instalação e limpa a identidade da máquina — ligações de rede, chaves de anfitrião, tudo. O que volta a arrancar é o assistente de configuração do primeiro arranque, pronto para o novo proprietário introduzir o seu próprio nome, a sua palavra-passe e a sua palavra-passe de encriptação.

Funciona ao restaurar o instantâneo de base que o instalador cria, por isso só está disponível em máquinas instaladas a partir do ISO do Omarchy. E, numa unidade sem encriptação, uma reposição é uma eliminação e não um apagamento seguro, por isso, se os dados eram sensíveis, faz antes uma instalação de raiz.

## Sudo sem palavra-passe

Às vezes queres que o `sudo` deixe de pedir, na maioria das vezes quando um agente de IA está a fazer um longo período de trabalho de sistema por ti. _Configuração > Segurança > Sudo sem Palavra-passe_ pergunta durante quanto tempo permitir o acesso: **15 minutos**, **1 Hora**, **1 Dia** ou **Permanentemente**. Aparece um ícone de aviso vermelho ao lado dos outros indicadores da barra de menus enquanto o acesso estiver ativo. Clica nele ou executa o comando novamente para desativar o acesso. Também podes passar o teu próprio número de minutos (de 1 a 1440) com `omarchy-sudo-passwordless 30`, ou usar `omarchy-sudo-passwordless permanent`.

O acesso temporizado expira automaticamente, incluindo imediatamente após retomar de uma suspensão que ultrapassou o prazo. Reiniciar o computador termina-o mais cedo. O acesso permanente sobrevive aos reinícios e mantém-se ativado até o desativares.

Atualizar ou remover o pacote de definições do Omarchy termina qualquer concessão temporária antes que o seu suporte de expiração mude. Se o comando comunicar um erro de autorização ou de limpeza, resolve-o antes de tentares ativar outra concessão; um erro não significa que o acesso sem palavra-passe esteja inativo.

Sê lúcido quanto a isto: enquanto estiver ativado, qualquer coisa a ser executada como o teu utilizador pode fazer qualquer coisa como root sem que te seja pedido. É exatamente esse o objetivo, e é também exatamente esse o risco.

## Chaves de Assinatura

A chave pública para todas as assinaturas de ISO e para o pacote do repositório do Omarchy é `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verificar em openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). O pacote `omarchy/omarchy-keyring` também a contém e será usado para distribuir eventuais atualizações sem problemas.

Podes encontrar a assinatura de qualquer lançamento de ISO adicionando `.sig` ao seu URL, como `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
