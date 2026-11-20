# Instalação em Dual Boot

Você pode instalar o Omarchy em uma única partição ao lado do Windows ou de outras instalações.

Este método de instalação ainda vem com criptografia LUKS para a partição por padrão, então, na prática, não é diferente de usar o disco inteiro e simplesmente exige que haja espaço livre disponível no disco.

## Liberando Espaço no Windows

Para instalar ao lado do Windows, digite `disk management` no menu Iniciar e selecione a opção **Criar e formatar partições do disco rígido**.

 ![dual-boot-1](images/dual-boot-1.webp)

Encontre a partição apropriada, clique com o botão direito e escolha **Diminuir Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Insira a quantidade pela qual você quer diminuir o volume. Observe que esse será o tamanho da sua futura instalação do Omarchy, incluindo a partição de inicialização.

 ![dual-boot-3](images/dual-boot-3.webp)

Quando terminar, você deverá ver algo assim, em que a seção de 50GB é onde instalaremos o Omarchy neste exemplo.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalando o Omarchy

O processo de instalação do Omarchy é, na prática, o mesmo de sempre. Depois de selecionar seu disco, você terá a opção **Instalação em espaço livre**. Selecione essa opção para evitar apagar o disco inteiro.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirme que está tudo certo e aguarde a instalação terminar normalmente. É também aqui que você pode optar por instalar sem criptografia (não recomendado), assim como em uma instalação no disco inteiro.
 ![dual-boot-6](images/dual-boot-6.webp)

## Adicionando Outras Instalações ao Bootloader

Ao concluir a instalação do Omarchy, você notará que o bootloader Limine agora é o padrão. Com ele, você também pode adicionar ao Limine opções para suas outras instalações, como o Windows.

Para adicionar outros sistemas operacionais, execute `limine-scan` e siga as instruções para adicionar as entradas desejadas à sua configuração do Limine. O menu de inicialização permanece oculto por padrão e inicia o Omarchy após um segundo. Para escolher o Windows ou outra entrada, pressione qualquer tecla assim que o Limine iniciar; quando o menu aparecer, use as teclas de seta para selecionar uma entrada e pressione Enter. Se o Omarchy iniciar antes de você pressionar uma tecla, reinicie e tente novamente.

## Bitlocker

É importante observar que este método de instalação não é compatível com o Bitlocker, pois ele criptografa o disco inteiro, não apenas a partição. Se você encontrar um erro informando que o Bitlocker está ativado, inicialize no Windows, vá para **Configurações -> Privacidade e segurança -> Criptografia do dispositivo** e desative o Bitlocker. Pode levar algum tempo para descriptografar o disco.

 ![dual-boot-7](images/dual-boot-7.webp)
