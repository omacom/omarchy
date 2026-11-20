# Segurança

Omarchy leva segurança extremamente a sério. Este é um sistema operacional feito para você usar para fazer _Trabalho de Verdade_ no _Mundo Real_. Onde perder um laptop não pode levar a uma emergência de segurança. Então, aqui está o que fazemos:

1. *A criptografia de disco completo está ativada por padrão*: Este é o passo mais importante para proteger fisicamente seus dados. Se o seu computador for perdido ou roubado, os dados ficam totalmente criptografados usando o padrão LUKS (Linux Unified Key Setup). O instalador permite desativar isso em máquinas descartáveis (veja [Primeiros passos](02-getting-started.md)); uma instalação sem criptografia não tem nada dessa proteção, e qualquer pessoa com o disco em mãos pode lê-lo.
2. *O firewall está ativado por padrão*: Todo o tráfego de entrada é bloqueado por padrão, com algumas exceções: a porta 53317 para o [LocalSend](https://localsend.org/); consultas DNS ao próprio resolvedor do computador no endereço da bridge do Docker (172.17.0.1), aceitas a partir das faixas de endereços privados que o Docker atribui aos seus contêineres; e DNS multicast (porta 5353), que permite que impressoras e outros dispositivos na sua rede se encontrem e também anuncia o nome do seu computador ali. Além dessas, o firewall mantém as permissões padrão do UFW para ping, para obter um endereço do seu roteador (DHCP) e para descoberta UPnP. Até o ssh fica desligado até você ativá-lo em _Setup > Security > SSHD_, que abre a porta 22 (com limite de taxa contra força bruta) como parte da configuração. Nós até restringimos o acesso ao Docker usando a configuração do [ufw-docker](https://github.com/chaifeng/ufw-docker) para impedir que seus contêineres sejam expostos ao mundo por acidente.
3. *O Arch sempre tem as atualizações mais recentes*: O Arch, a distro subjacente sobre a qual o Omarchy é construído, é uma distribuição rolling. Isso significa que qualquer vulnerabilidade de segurança descoberta e corrigida em qualquer pacote fica disponível para instalação rapidamente usando `omarchy-update`. Assim, você está sempre rodando as versões mais recentes e mais seguras de tudo.
4. *O Omarchy mantém seus próprios pacotes e espelho*: Por padrão, o Omarchy depende apenas de pacotes dos repositórios core/extra/multilib do próprio Arch e do seu próprio Omarchy Package Repository. Você pode instalar software diretamente do AUR, mas a instalação base não faz isso — apenas algumas instalações opcionais, como os navegadores de terceiros, vêm do AUR.
5. *A Cloudflare nos protege contra DDoS*: A infraestrutura de distribuição do Omarchy — as ISOs, os pacotes do Omarchy, o espelho do Arch — fica protegida atrás do formidável escudo anti-DDoS da Cloudflare e hospedada na CDN deles. Isso proporciona uma disponibilidade excelente.

## Alterando suas senhas

Você tem duas senhas em uma instalação criptografada: a que desbloqueia o disco na inicialização e a que você usa para fazer login e usar o `sudo`. A configuração define as duas como iguais. Ambas podem ser alteradas em _Update > Password_ no menu do Omarchy — _Drive Encryption_ para a primeira, _User_ para a segunda. Alterar a senha do disco pede a senha atual primeiro, então tenha ela em mãos. Se uma alteração for interrompida, execute _Drive Encryption_ novamente: ele pede a senha que desbloqueia o disco agora e conclui a alteração.

## Passando adiante uma máquina que você já usou

Se você está passando sua máquina para outra pessoa, não precisa reinstalá-la. Execute _Remove > Factory Reset_ no menu do Omarchy, digite `reset` para confirmar e reinicie. Isso apaga todas as contas de usuário e tudo em `/home`, descarta todos os pacotes e alterações do sistema que você fez desde a instalação e limpa a identidade da máquina — conexões de rede, chaves de host e tudo mais. O que volta é o assistente de configuração da primeira inicialização, pronto para o novo dono inserir seu próprio nome, senha e senha de criptografia.

Isso funciona restaurando o snapshot básico que o instalador cria, então só está disponível em máquinas instaladas a partir da ISO do Omarchy. E em um disco sem criptografia, uma redefinição é uma exclusão, não uma limpeza segura, então, se os dados eram confidenciais, faça uma instalação limpa.

## sudo sem senha

Às vezes você quer que o `sudo` pare de pedir senha, na maioria das vezes quando um agente de IA está fazendo um longo trabalho no sistema para você. _Setup > Security > Passwordless Sudo_ pergunta por quanto tempo permitir o acesso: **15 minutos**, **1 hora**, **1 dia** ou **Permanentemente**. Um ícone de aviso vermelho aparece ao lado dos outros indicadores da barra de menus enquanto o acesso está ativo. Clique nele ou execute o comando novamente para desativar o acesso. Você também pode passar seu próprio número de minutos (de 1 a 1440) com `omarchy-sudo-passwordless 30`, ou usar `omarchy-sudo-passwordless permanent`.

O acesso temporário expira automaticamente, inclusive imediatamente após retomar de uma suspensão que cruzou o prazo. Reiniciar o computador o encerra antes. O acesso permanente sobrevive a reinicializações e permanece ativado até você desativá-lo.

Atualizar ou remover o pacote de configurações do Omarchy encerra qualquer concessão temporária antes que o suporte à sua expiração mude. Se o comando relatar um erro de autorização ou de limpeza, resolva-o antes de tentar ativar outra concessão; um erro não significa que o acesso sem senha está inativo.

Tenha os olhos bem abertos sobre isso: enquanto estiver ativado, qualquer coisa rodando como seu usuário pode fazer qualquer coisa como root sem ser questionada. É exatamente esse o objetivo, e é também exatamente esse o risco.

## Chaves de assinatura

A chave pública de todas as assinaturas de ISO e de pacotes do repositório Omarchy é `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifique em openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). O pacote `omarchy/omarchy-keyring` também contém essa chave e será usado para distribuir quaisquer possíveis atualizações de forma transparente.

Você pode encontrar a assinatura de qualquer lançamento de ISO adicionando `.sig` à sua URL, como `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
