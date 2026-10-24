# Segurança

O Omarchy leva a segurança muito a sério. Ele foi feito para ser um sistema operacional que você pode usar para fazer _Trabalho de Verdade_ no _Mundo Real_. Onde perder um notebook não pode virar uma emergência de segurança. Então aqui está o que fazemos:

1. *A criptografia de disco completo é obrigatória*: Este é o passo mais importante para proteger fisicamente seus dados. Se seu computador for perdido ou roubado, os dados estarão totalmente criptografados usando o LUKS padrão (Linux Unified Key Setup).
2. *O firewall é ativado por padrão*: Todo o tráfego de entrada é bloqueado por padrão, exceto a porta 53317 para o [LocalSend](https://localsend.org/). Até o ssh fica desligado até você ativá-lo em _Configuração > Segurança > SSHD_, que abre a porta 22 (com limitação de taxa contra força bruta) como parte da configuração. Nós até restringimos o acesso ao Docker usando a configuração [ufw-docker](https://github.com/chaifeng/ufw-docker) para evitar que seus contêineres sejam acidentalmente expostos para o mundo.
3. *O Arch sempre tem as atualizações mais recentes*: O Arch, a distribuição subjacente sobre a qual o Omarchy é construído, é uma distribuição rolling. Isso significa que qualquer vulnerabilidade de segurança descoberta e corrigida em qualquer pacote fica rapidamente disponível para instalação com `omarchy-update`. Assim, você está sempre executando as versões mais recentes e seguras de tudo.
4. *O Omarchy mantém seus próprios pacotes e espelho*: O Omarchy depende apenas de pacotes dos próprios repositórios core/extra/multilib do Arch e do seu próprio Repositório de Pacotes do Omarchy por padrão. Você pode instalar software diretamente do AUR, mas a instalação base não o faz — apenas algumas instalações opcionais, como os navegadores de terceiros, vêm do AUR.
5. *A Cloudflare nos protege de DDoS*: Toda a infraestrutura de distribuição do Omarchy — as ISOs, os pacotes do Omarchy, o espelho do Arch — está protegida atrás do formidável escudo anti-DDoS da Cloudflare e hospedada na CDN deles. Isso proporciona uma disponibilidade excelente.

## Alterando suas senhas

Você tem duas senhas em uma instalação criptografada: a que desbloqueia o disco na inicialização e a que você usa para fazer login e `sudo`. A configuração as torna iguais. Ambas podem ser alteradas em _Atualizar > Senha_ no menu do Omarchy — _Criptografia do disco_ para a primeira, _Usuário_ para a segunda. Alterar a senha do disco pede a atual primeiro, então tenha-a à mão. Se uma alteração for interrompida, execute _Criptografia do disco_ de novo: ela pede a senha que desbloqueia o disco agora e conclui a alteração.

## Repassando uma máquina que você já usou

Se você está entregando sua máquina para outra pessoa, não precisa reinstalá-la. Execute _Configuração > Redefinir computador_ no menu do Omarchy, digite `reset` para confirmar e reinicie. Isso apaga todas as contas de usuário e tudo em `/home`, descarta todos os pacotes e alterações do sistema que você fez desde a instalação e limpa a identidade da máquina — conexões de rede, chaves de host e tudo. O que volta é o assistente de configuração da primeira inicialização, pronto para seu novo dono inserir seu próprio nome, senha e senha de criptografia.

Ele funciona restaurando o snapshot base que o instalador cria, então só está disponível em máquinas instaladas a partir da ISO do Omarchy. E em um disco sem criptografia, uma redefinição é uma exclusão, e não uma eliminação segura, então se os dados eram sensíveis, faça uma instalação nova em vez disso.

## Sudo sem senha

Às vezes você quer que o `sudo` pare de pedir senha, mais frequentemente quando um agente de IA está fazendo um longo trabalho de sistema para você. _Configuração > Segurança > Sudo sem senha_ pergunta por quanto tempo permitir o acesso: **15 minutos**, **1 hora**, **1 dia** ou **Permanentemente**. Um ícone de aviso vermelho aparece ao lado dos outros indicadores da barra de menus enquanto o acesso está ativo. Clique nele ou execute o comando de novo para desativar o acesso. Você também pode passar seu próprio número de minutos (de 1 a 1440) com `omarchy-sudo-passwordless 30`, ou usar `omarchy-sudo-passwordless permanent`.

O acesso temporário expira automaticamente, inclusive imediatamente após retomar de uma suspensão que ultrapassou o prazo. Reiniciar o computador o encerra mais cedo. O acesso permanente sobrevive às reinicializações e permanece ativado até você desativá-lo.

Atualizar ou remover o pacote de configurações do Omarchy encerra qualquer concessão temporária antes que seu suporte de expiração mude. Se o comando relatar um erro de autorização ou de limpeza, resolva-o antes de tentar ativar outra concessão; um erro não significa que o acesso sem senha está inativo.

Seja claro quanto a isso: enquanto estiver ativado, qualquer coisa executando como seu usuário pode fazer qualquer coisa como root sem ser solicitado. Esse é todo o objetivo, e também é todo o risco.

## Chaves de assinatura

A chave pública de todas as assinaturas de ISO e pacotes do repositório do Omarchy é `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifique em openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). O pacote `omarchy/omarchy-keyring` também a contém e será usado para distribuir quaisquer atualizações potenciais perfeitamente.

Você pode encontrar a assinatura de qualquer versão de ISO adicionando .sig à URL. Como https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
