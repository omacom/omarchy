# Instalação em Dual Boot

É possível instalar o Omarchy numa única partição ao lado do Windows ou de outras instalações.

Este método de instalação continua a vir com encriptação LUKS para a partição por predefinição, por isso efetivamente não é diferente de usar a unidade inteira e só exige que haja espaço livre disponível no disco.

## Criar espaço no Windows

Para instalar ao lado do Windows, escreva `disk management` no menu iniciar e selecione a opção **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Encontre a partição apropriada, clique com o botão direito e escolha **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Introduza a quantidade em que quer reduzir o volume. Note que este será o tamanho da sua futura instalação do Omarchy, incluindo a partição de arranque.

 ![dual-boot-3](images/dual-boot-3.webp)

Quando tiver terminado, deverá ver algo como isto, onde a secção de 50GB é onde vamos instalar o Omarchy neste exemplo.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalar o Omarchy

O processo de instalação do Omarchy é efetivamente o mesmo do normal. Depois de selecionar o seu disco, ser-lhe-á dada a opção de **Free space install**. Selecione essa opção para evitar apagar o disco inteiro.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirme que está tudo bem e espere que a instalação termine como habitualmente. Isto também é onde pode optar por instalar sem encriptação (não recomendado), tal como numa instalação com a unidade inteira.
 ![dual-boot-6](images/dual-boot-6.webp)

## Adicionar outras instalações ao carregador de arranque

Quando terminar a sua instalação do Omarchy, notará que o carregador de arranque Limine é agora a predefinição. Com ele, também pode adicionar opções ao Limine para as suas outras instalações, como o Windows.

Para o fazer, execute `limine-scan` e siga as indicações para adicionar os itens que quiser à sua configuração do limine. Depois, ao arrancar, verá as suas opções normais para o Omarchy, bem como o Gestor de Arranque do Windows ou outros.

## Bitlocker

É importante notar que este método de instalação não é compatível com o Bitlocker, já que ele encripta a unidade inteira, e não apenas a partição. Se encontrar um erro a indicar que o Bitlocker está ativado, arranque para o Windows, vá a **Settings -> Privacy & Security -> Device encryption** e desligue o Bitlocker. Pode demorar algum tempo a desencriptar a unidade.

 ![dual-boot-7](images/dual-boot-7.webp)
