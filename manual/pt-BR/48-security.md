# Segurança

O Omarchy leva a segurança extremamente a sério. Este deve ser um sistema operacional que você pode usar para fazer _Trabalho de Verdade_ no _Mundo Real_. Onde perder um laptop não pode levar a uma emergência de segurança. Então, eis o que fazemos:

1. *A criptografia de disco completo está ativada por padrão*: Este é o passo mais importante para garantir a proteção física dos seus dados. Se o seu computador for perdido ou roubado, os dados estarão totalmente criptografados usando o LUKS (Linux Unified Key Setup) padrão. O instalador permite desativar isso em máquinas descartáveis (consulte [Primeiros passos](02-getting-started.md)); uma instalação sem criptografia não tem nada dessa proteção, e qualquer pessoa com o disco em mãos pode lê-lo.
2. *O firewall está ativado por padrão*: Todo o tráfego de entrada é bloqueado por padrão, com algumas exceções: a porta 53317 para o [LocalSend](https://localsend.org/); consultas DNS ao resolver do próprio computador no endereço da bridge do Docker (172.17.0.1), aceitas a partir das faixas de endereços privados que o Docker atribui aos seus contêineres; e DNS multicast (porta 5353), que permite que impressoras e outros dispositivos na sua rede se encontrem e também anuncia o nome do seu computador ali. Além dessas, o firewall mantém as permissões padrão do UFW para ping, para obter um endereço do seu roteador (DHCP) e para descoberta UPnP. Até mesmo o ssh fica desativado até você ativá-lo em _Configuração > Segurança > SSHD_, o que abre a porta 22 (com limite de taxa contra força bruta) como parte da configuração. Nós até restringimos o acesso ao Docker usando a configuração do [ufw-docker](https://github.com/chaifeng/ufw-docker) para impedir que seus contêineres sejam expostos acidentalmente ao mundo.
3. *O Arch sempre tem as atualizações mais recentes*: O Arch, a distribuição subjacente na qual o Omarchy é baseado, é uma distribuição rolling. Isso significa que qualquer vulnerabilidade de segurança descoberta e corrigida em qualquer pacote fica rapidamente disponível para instalação usando `omarchy-update`. Dessa forma, você está sempre executando as versões mais recentes e mais seguras de tudo.
4. *O Omarchy mantém seus próprios pacotes e espelho*: Por padrão, o Omarchy depende apenas de pacotes dos repositórios core/extra/multilib do próprio Arch e do seu próprio Omarchy Package Repository. Você pode instalar software diretamente do AUR, mas a instalação base não faz isso — apenas algumas instalações opcionais, como os navegadores de terceiros, obtêm pacotes do AUR.
5. *A Cloudflare nos protege contra DDoS*: A infraestrutura de distribuição do Omarchy — as ISOs, os pacotes do Omarchy, o espelho do Arch — está protegida por trás do formidável escudo contra DDoS da Cloudflare e hospedada na CDN dela. Isso proporciona uma disponibilidade excelente.

## Alterando suas senhas

Você tem duas senhas em uma instalação criptografada: a que desbloqueia o disco na inicialização e a que você usa para fazer login e usar `sudo`. A configuração define as duas como iguais. Ambas podem ser alteradas em _Atualizar > Senha_ no menu do Omarchy — _Criptografia do Disco_ para a primeira, _Usuário_ para a segunda. Alterar a senha do disco pede a senha atual primeiro, então tenha-a em mãos. Se uma alteração for interrompida, execute _Criptografia do Disco_ novamente: ele pede a senha que desbloqueia o disco agora e conclui a alteração.

## Passando adiante uma máquina que você já usou

Se você for entregar sua máquina para outra pessoa, não precisa reinstalá-la. Execute _Configuração > Redefinir Computador_ no menu do Omarchy, digite `reset` para confirmar e reinicie. Isso apaga todas as contas de usuário e tudo em `/home`, descarta todos os pacotes e alterações do sistema que você fez desde a instalação e limpa a identidade da máquina — conexões de rede, chaves de host e tudo. O que volta a subir é o assistente de configuração da primeira inicialização, pronto para o novo proprietário inserir seu próprio nome, senha e senha de criptografia.

Isso funciona restaurando o snapshot de referência que o instalador cria, então só está disponível em máquinas instaladas a partir da ISO do Omarchy. E, em um disco sem criptografia, uma redefinição é uma exclusão, não uma limpeza segura, então, se os dados eram confidenciais, faça uma instalação limpa.

## sudo sem senha

Às vezes você quer que o `sudo` pare de pedir senha, na maioria das vezes quando um agente de IA está fazendo um longo trecho de trabalho no sistema para você. _Configuração > Segurança > Sudo sem Senha_ pergunta por quanto tempo permitir o acesso: **15 minutos**, **1 Hora**, **1 Dia** ou **Permanentemente**. Um ícone vermelho de aviso aparece ao lado dos outros indicadores da barra de menus enquanto o acesso estiver ativo. Clique nele ou execute o comando novamente para desativar o acesso. Você também pode passar seu próprio número de minutos (de 1 a 1440) com `omarchy-sudo-passwordless 30`, ou usar `omarchy-sudo-passwordless permanent`.

O acesso por tempo limitado expira automaticamente, inclusive imediatamente após retomar de uma suspensão que ultrapassou o prazo. Reiniciar o computador o encerra antes da hora. O acesso permanente sobrevive a reinicializações e permanece ativado até você desativá-lo.

Atualizar ou remover o pacote de configurações do Omarchy encerra qualquer concessão temporária antes que o suporte ao seu vencimento mude. Se o comando relatar um erro de autorização ou de limpeza, resolva-o antes de tentar ativar outra concessão; um erro não significa que o acesso sem senha esteja inativo.

Tenha os olhos bem abertos quanto a isso: enquanto estiver ativado, qualquer coisa em execução como seu usuário pode fazer qualquer coisa como root sem que nada seja solicitado. Esse é exatamente o objetivo, e também é exatamente o risco.

## Chaves de assinatura

A chave pública para todas as assinaturas de ISO e para o pacote do repositório do Omarchy é `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifique em openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). O pacote `omarchy/omarchy-keyring` também contém essa chave e será usado para distribuir quaisquer possíveis atualizações sem complicações.

Você pode encontrar a assinatura de qualquer lançamento de ISO adicionando `.sig` à sua URL, como `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
