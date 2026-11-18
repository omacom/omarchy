# Instalação em Dual Boot

Você pode instalar o Omarchy em uma única partição ao lado do Windows ou de outras instalações.

Esse método de instalação ainda vem com criptografia LUKS para a partição por padrão, então, na prática, não é diferente de usar o disco inteiro e simplesmente exige que haja espaço livre disponível no disco.

## Criando Espaço no Windows

Para instalar ao lado do Windows, digite `disk management` no menu Iniciar e selecione a opção **Criar e formatar partições do disco rígido**.

 ![dual-boot-1](images/dual-boot-1.webp)

Encontre a partição apropriada, clique com o botão direito e escolha **Diminuir Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Insira a quantidade pela qual você quer diminuir o volume. Note que esse será o tamanho da sua futura instalação do Omarchy, incluindo a partição de boot.

 ![dual-boot-3](images/dual-boot-3.webp)

Quando terminar, você deverá ver algo assim, onde a seção de 50GB é onde vamos instalar o Omarchy neste exemplo.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalando o Omarchy

O processo de instalação do Omarchy é, na prática, o mesmo do normal. Depois de selecionar seu disco, você terá a opção **Free space install**. Selecione essa opção para evitar apagar o disco inteiro.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirme se tudo parece certo e espere a instalação terminar como de costume. É aqui também que você pode optar por instalar sem criptografia (não recomendado), assim como em uma instalação no disco inteiro.
 ![dual-boot-6](images/dual-boot-6.webp)

## Adicionando Outras Instalações ao Bootloader

Quando terminar sua instalação do Omarchy, você vai notar que o bootloader Limine agora é o padrão. Com ele, você também pode adicionar opções ao Limine para suas outras instalações, como o Windows.

Para adicionar outros sistemas operacionais, execute `limine-scan` e siga as instruções para adicionar as entradas que você quer à sua configuração do Limine. O menu de boot fica oculto por padrão e inicia o Omarchy após um segundo. Para escolher o Windows ou outra entrada, pressione qualquer tecla assim que o Limine iniciar; quando o menu aparecer, use as teclas de seta para selecionar uma entrada e pressione Enter. Se o Omarchy iniciar antes de você pressionar uma tecla, reinicie e tente novamente. Se você ativou _Setup > Direct Boot_, o firmware ignora o Limine completamente, então escolha o Limine no menu de boot da BIOS ou execute _Setup > Direct Boot_ novamente para remover a entrada.

## Bitlocker

É importante notar que esse método de instalação não é compatível com o Bitlocker, pois ele criptografa o disco inteiro, não apenas a partição. Se você encontrar um erro dizendo que o Bitlocker está ativado, inicie no Windows, vá para **Settings -> Privacy & Security -> Device encryption** e desative o Bitlocker. Pode levar algum tempo para descriptografar o disco.

 ![dual-boot-7](images/dual-boot-7.webp)
