# Instalação em dual boot

Você pode instalar o Omarchy em uma única partição ao lado do Windows ou de outras instalações.

Este método de instalação ainda vem com criptografia LUKS para a partição por padrão, então na prática não é diferente da instalação no disco inteiro e simplesmente exige que haja espaço livre disponível no disco.

## Criando espaço no Windows

Para instalar ao lado do Windows, digite `disk management` no menu Iniciar e selecione a opção **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Encontre a partição adequada, clique com o botão direito e escolha **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Digite a quantidade pela qual você quer reduzir o volume. Observe que esse será o tamanho da sua futura instalação do Omarchy, incluindo a partição de boot.

 ![dual-boot-3](images/dual-boot-3.webp)

Quando você terminar, deverá ver algo assim, onde a seção de 50GB é onde instalaremos o Omarchy neste exemplo.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalando o Omarchy

O processo de instalação do Omarchy é na prática o mesmo que o normal. Depois de selecionar seu disco, você terá a opção de **Free space install**. Selecione essa opção para evitar apagar o disco inteiro.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirme que está tudo certo e espere a instalação terminar normalmente. É também aqui que você pode optar por instalar sem criptografia (não recomendado), assim como em uma instalação no disco inteiro.
 ![dual-boot-6](images/dual-boot-6.webp)

## Adicionando outras instalações ao bootloader

Quando você terminar a instalação do Omarchy, notará que o bootloader Limine é o padrão agora. Com ele, você também pode adicionar opções ao Limine para suas outras instalações, como o Windows.

Para fazer isso, execute `limine-scan` e siga as solicitações para adicionar os itens que quiser à sua configuração do limine. Aí, quando você inicializar, verá suas opções normais do Omarchy, assim como o Windows Boot Manager ou outros.

## Bitlocker

É importante observar que este método de instalação não é compatível com o Bitlocker, pois ele criptografa o disco inteiro, e não apenas a partição. Se você encontrar um erro afirmando que o Bitlocker está ativado, inicialize o Windows, vá em **Settings -> Privacy & Security -> Device encryption** e desative o Bitlocker. Pode levar algum tempo para descriptografar o disco.

 ![dual-boot-7](images/dual-boot-7.webp)
