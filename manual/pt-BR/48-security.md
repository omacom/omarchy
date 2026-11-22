# Segurança

Omarchy leva a segurança extremamente a sério. Este é um sistema operacional feito para você usar para fazer _Trabalho de Verdade_ no _Mundo Real_. Onde perder um laptop não pode levar a uma emergência de segurança. Então, eis o que fazemos:

1. *A criptografia de disco completo vem ativada por padrão*: Esta é a etapa mais importante para garantir a proteção física dos seus dados. Se o seu computador for perdido ou roubado, os dados estarão totalmente criptografados usando o LUKS padrão (Linux Unified Key Setup). O instalador permite abrir mão disso em máquinas descartáveis (veja [Primeiros passos](02-getting-started.md)); uma instalação sem criptografia não tem nada dessa proteção, e qualquer pessoa de posse da unidade pode lê-la.
2. *O firewall vem ativado por padrão*: Todo o tráfego de entrada é bloqueado por padrão, com algumas exceções: a porta 53317 para o [LocalSend](https://localsend.org/); consultas DNS ao próprio resolvedor do computador no endereço da bridge do Docker (172.17.0.1), aceitas a partir dos intervalos de endereços privados que o Docker atribui aos seus contêineres; e DNS multicast (porta 5353), que permite que impressoras e outros dispositivos na sua rede encontrem uns aos outros e também anuncia o nome do seu computador por ali. Além dessas, o firewall mantém as permissões padrão do UFW para ping, para obter um endereço do seu roteador (DHCP) e para descoberta UPnP. Até o ssh fica desligado até você ativá-lo em _Configuração > Segurança > SSHD_, que autoriza a sua chave SSH, desativa os logins por senha e só então abre a porta 22 (com limite de taxa contra força bruta). Nós até restringimos o acesso ao Docker usando a configuração do [ufw-docker](https://github.com/chaifeng/ufw-docker) para impedir que os seus contêineres sejam expostos acidentalmente ao mundo.
3. *O Arch sempre tem as atualizações mais recentes*: O Arch, a distro subjacente sobre a qual o Omarchy é construído, é uma distribuição rolling. Isso significa que qualquer vulnerabilidade de segurança que seja descoberta e corrigida em qualquer pacote fica rapidamente disponível para instalação usando `omarchy-update`. Assim, você está sempre executando as versões mais recentes e mais seguras de tudo.
4. *O Omarchy mantém os seus próprios pacotes e mirror*: Por padrão, o Omarchy depende apenas de pacotes dos repositórios core/extra/multilib do próprio Arch (os do Arch Linux ARM em máquinas ARM, além do Asahi ALARM no Apple Silicon) e do seu próprio Repositório de Pacotes do Omarchy. Você pode instalar software diretamente da AUR, mas a instalação base não faz isso — apenas algumas instalações opcionais, como os navegadores de terceiros, vêm da AUR.
5. *A Cloudflare nos protege de DDoS*: A infraestrutura de distribuição do Omarchy — as ISOs, os pacotes do Omarchy, o mirror do Arch — é protegida pelo formidável escudo anti-DDoS da Cloudflare e hospedada na CDN deles. Isso proporciona uma disponibilidade soberba.

## Alterando as suas senhas

Em uma instalação criptografada, você tem duas senhas: a que desbloqueia a unidade na inicialização e a que você usa para fazer login e `sudo`. A configuração inicial deixa as duas iguais. Ambas podem ser alteradas em _Atualizar > Senha_ no menu do Omarchy — _Criptografia da unidade_ para a primeira, _Usuário_ para a segunda. Alterar a senha da unidade pede a senha atual primeiro, então tenha-a em mãos. Se uma alteração for interrompida, execute _Criptografia da unidade_ novamente: ele pede a senha que desbloqueia a unidade agora e conclui a alteração.

## Repassando uma máquina que você já usou

Se você vai entregar a sua máquina para outra pessoa, não precisa reinstalá-la. Execute _Remover > Redefinição de fábrica_ no menu do Omarchy, digite `reset` para confirmar, insira a sua senha de criptografia da unidade se solicitado e reinicie. Isso apaga todas as contas de usuário e tudo em `/home`, descarta todos os pacotes e alterações do sistema que você fez desde a instalação e limpa a identidade da máquina — conexões de rede, chaves de host, tudo. O que volta a subir é o assistente de configuração da primeira inicialização, pronto para o novo proprietário inserir o próprio nome, a própria senha e a própria senha de criptografia.

Isso funciona restaurando o snapshot de referência que o instalador captura, então só está disponível em máquinas instaladas a partir da ISO do Omarchy. E, em uma unidade sem criptografia, uma redefinição é uma exclusão, e não um apagamento seguro, então, se os dados eram sensíveis, faça uma instalação limpa.

## Sudo sem senha

Às vezes você quer que o `sudo` pare de pedir senha, na maioria das vezes quando um agente de IA está fazendo um longo trecho de trabalho no sistema por você. _Configuração > Segurança > Sudo sem senha_ pergunta por quanto tempo permitir o acesso: **15 minutos**, **1 Hora**, **1 Dia** ou **Permanentemente**. Um ícone de aviso vermelho aparece ao lado dos outros indicadores da barra de menu enquanto o acesso está ativo. Clique nele ou execute o comando novamente para desativar o acesso. Você também pode passar o seu próprio número de minutos (de 1 a 1440) com `omarchy-sudo-passwordless 30`, ou usar `omarchy-sudo-passwordless permanent`.

O acesso por tempo expira automaticamente, inclusive logo depois de retomar de uma suspensão que ultrapassou o prazo. Reiniciar o computador o encerra antes da hora. O acesso permanente sobrevive às reinicializações e permanece ativado até você desativá-lo.

Atualizar ou remover o pacote de configurações do Omarchy encerra qualquer concessão temporária antes que o suporte à expiração dela mude. Se o comando relatar um erro de autorização ou de limpeza, resolva-o antes de tentar ativar outra concessão; um erro não significa que o acesso sem senha está inativo.

Encare este de olhos bem abertos: enquanto estiver ativado, qualquer coisa executando como o seu usuário pode fazer qualquer coisa como root sem ser questionada. É exatamente esse o objetivo, e é também exatamente esse o risco.

## Chaves de assinatura

A chave pública de todas as assinaturas das ISOs e do pacote do repositório do Omarchy é `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verificar em openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). O pacote `omarchy/omarchy-keyring` também contém essa chave e será usado para distribuir quaisquer possíveis atualizações de forma transparente.

Você pode encontrar a assinatura de qualquer lançamento de ISO adicionando `.sig` à URL dele, como `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
