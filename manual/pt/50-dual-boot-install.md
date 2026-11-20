# Instalação em Dual Boot

Pode instalar o Omarchy numa única partição ao lado do Windows ou de outras instalações.

Este método de instalação continua a incluir, por predefinição, encriptação LUKS para a partição, pelo que, na prática, não é diferente de uma instalação no disco inteiro e requer apenas que exista espaço livre disponível no disco.

## Libertar Espaço no Windows

Para instalar ao lado do Windows, escreva `disk management` no menu Iniciar e selecione a opção **Criar e formatar partições do disco rígido**.

 ![dual-boot-1](images/dual-boot-1.webp)

Encontre a partição adequada, clique com o botão direito do rato e escolha **Reduzir Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Introduza a quantidade pela qual pretende reduzir o volume. Tenha em atenção que esse será o tamanho da sua futura instalação do Omarchy, incluindo a partição de arranque.

 ![dual-boot-3](images/dual-boot-3.webp)

Quando terminar, deverá ver algo semelhante a isto, em que a secção de 50GB é onde vamos instalar o Omarchy neste exemplo.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalar o Omarchy

O processo de instalação do Omarchy é, na prática, igual ao normal. Depois de selecionar o disco, ser-lhe-á apresentada a opção **Instalação em espaço livre**. Selecione essa opção para evitar apagar o disco inteiro.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirme que está tudo bem e aguarde que a instalação termine, como habitualmente. É também aqui que pode optar por instalar sem encriptação (não recomendado), tal como numa instalação no disco inteiro.
 ![dual-boot-6](images/dual-boot-6.webp)

## Adicionar Outras Instalações ao Gestor de Arranque

Quando terminar a instalação do Omarchy, vai notar que o gestor de arranque Limine passou a ser o predefinido. Com ele, também pode adicionar ao Limine opções para as suas outras instalações, como o Windows.

Para adicionar outros sistemas operativos, execute `limine-scan` e siga as instruções para adicionar as entradas que pretende à sua configuração do Limine. O menu de arranque permanece oculto por predefinição e arranca o Omarchy após um segundo. Para escolher o Windows ou outra entrada, prima qualquer tecla assim que o Limine arrancar; quando o menu aparecer, utilize as teclas de seta para selecionar uma entrada e prima Enter. Se o Omarchy arrancar antes de premir uma tecla, reinicie e tente novamente.

## Bitlocker

É importante notar que este método de instalação não é compatível com o Bitlocker, uma vez que este encripta o disco inteiro, e não apenas a partição. Se se deparar com um erro a indicar que o Bitlocker está ativado, arranque no Windows, aceda a **Definições -> Privacidade e segurança -> Encriptação do dispositivo** e desative o Bitlocker. Poderá demorar algum tempo a desencriptar o disco.

 ![dual-boot-7](images/dual-boot-7.webp)
