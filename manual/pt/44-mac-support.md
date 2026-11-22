# Suporte para Mac

## Omarchy para Apple Silicon

O Omarchy para Apple Silicon é uma solução oficial da Omacom, lançada pela primeira vez com o Omarchy 4.5. Instala-se ao lado do macOS e escolhe entre os dois quando o seu Mac arranca.

Recebeu um aviso sobre o Omarchy Mac? Vá para [Vir do Omarchy Mac](#coming-from-omarchy-mac).

Corre nestes Macs:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Os Macs M4 e mais recentes ainda não são suportados. O suporte para M4 está a ser testado no canal edge e vem a seguir. O instalador verifica o seu Mac antes de alterar o que quer que seja.

Em qualquer Mac com Apple Silicon, incluindo o M4 e mais recentes, pode correr o Omarchy numa máquina virtual com o [Try Omarchy](https://github.com/omacom/try-omarchy).

### O que precisa

- macOS 15 Sequoia ou posterior, e uma conta de administrador
- Espaço livre em disco para o Omarchy. O instalador sugere um tamanho e permite-lhe alterá-lo.
- Uma cópia de segurança do seu Mac, alimentação e uma ligação à internet. A instalação transfere vários gigabytes.

### Instalação

Instala a partir do macOS. Instale o Omarchy Installer com o [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Ou transfira o Omarchy Installer mais recente da sua [página de lançamentos](https://github.com/omacom/omarchy-mac-installer/releases) e abra-o.

O instalador verifica o seu Mac, mostra-lhe o plano e abre espaço para o Omarchy ao reduzir a partição do macOS. O macOS permanece no disco e não é necessária nenhuma pen USB. Quando a primeira fase estiver concluída, ele orienta-o a terminar a configuração no macOS Recovery: desligue, mantenha premido o botão de alimentação até aparecer "Loading startup options", escolha Omarchy e siga os passos.

No primeiro arranque, o Omarchy pede uma palavra-passe que encripta o seu disco. Não existe chave de recuperação: se se esquecer da palavra-passe, os seus ficheiros do Omarchy não podem ser recuperados.

Para alternar entre o Omarchy e o macOS mais tarde, desligue e, em seguida, mantenha premido o botão de alimentação até aparecerem as opções de arranque e escolha uma.

### Vir do Omarchy Mac

O Omarchy Mac faz agora parte do Omarchy para Apple Silicon, e todos os Macs que o corriam são suportados. A sua instalação atual continua a funcionar e os seus pacotes de sistema continuam a atualizar, mas já não recebe atualizações do Omarchy. Não há prazo nem atualização no local: faça uma cópia de segurança, remova a instalação antiga, instale de novo e restaure. Os passos 2 a 5 acontecem no macOS, por isso abra esta página no telemóvel antes de reiniciar.

1. **Faça a cópia de segurança a partir do Omarchy, para fora do Mac.** Remover a instalação antiga apaga-a, e o macOS não consegue ler o disco do Omarchy. Copie a sua pasta pessoal para um disco externo ou outro computador, incluindo chaves SSH e GPG, perfis do navegador e trabalho não enviado. Guarde a sua lista de pacotes com `pacman -Qqe > ~/packages.txt`. Faça também uma cópia de segurança do macOS, uma vez que tanto a remoção como a instalação redimensionam o seu disco.
2. **Arranque o seu Mac no macOS.** Desligue, mantenha premido o botão de alimentação até aparecerem as opções de arranque e escolha macOS.
3. **Instale o Omarchy Installer** como mostrado em [Instalação](#installing).
4. **Remova a instalação antiga.** Abra o Omarchy Installer e escolha Installation > Remove Omarchy. Ele mostra o que vai eliminar e devolve o espaço ao macOS. Se não reconhecer a sua instalação, para sem alterar o disco. Peça ajuda no [Discord](https://discord.gg/tXFUdasqhY) em vez de eliminar partições à mão, o que pode apagar o macOS.
5. **Instale o Omarchy para Apple Silicon** com o instalador.
6. **Restaure os seus ficheiros.** Reponha as suas definições uma parte de cada vez, em vez de copiar todo o `~/.config` por cima dos novos valores predefinidos, uma vez que as definições antigas podem substituí-los.

### Bom saber

- Nos MacBooks M1 e M2, desperte do modo de suspensão ao abrir a tampa ou ao premir o botão de alimentação.
- Dúvidas ou problemas: pergunte no nosso [Discord](https://discord.gg/tXFUdasqhY).

O [README do instalador](https://github.com/omacom/omarchy-mac-installer#readme) abrange os canais de lançamento, a atualização do instalador e a remoção do Omarchy.

## Macs Intel

Num teste simples, conseguimos obter ganhos de desempenho de 36% num MacBook Pro de 2019 só por instalar o Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalar o Omarchy no Mac

O Omarchy só suporta ser o **único** sistema operativo instalado de momento. Durante a instalação, o disco será apagado e o MacOS deixará de poder arrancar.

Ainda o pode restaurar mais tarde através do Internet Recovery, se quiser.

Para esta parte, vamos partir do princípio de que já consultou [Primeiros passos](02-getting-started.md) e tem a sua pen USB pronta. Se não o fez, avance e faça-o agora.

#### Desativar o Secure Boot

É necessário desativar o Secure Boot da Apple para arrancar a partir da pen USB de arranque, bem como o sistema operativo. Para o desativar, faça o seguinte:

1. Desligue o seu Mac
2. Ligue-o e prima _imediatamente_ e mantenha premido Command-R até ver aparecer o ecrã de carregamento
3. Selecione o seu utilizador e introduza a sua palavra-passe, se lhe for pedido
4. Quando estiver no ecrã de recuperação, escolha **Utilities > Startup Security Utility** na barra de menus
5. Introduza a sua palavra-passe quando lhe for pedido para se autenticar
6. Escolha "No Security" nas opções do Secure Boot
7. Escolha "Allow booting from external or removable media" nas opções do External Boot

#### Iniciar a instalação

1. Insira a pen USB
2. Reinicie o seu Mac e prima _imediatamente_ e mantenha premida a tecla Option até ver um ecrã com os dispositivos de arranque
3. Selecione o dispositivo EFI Boot cor de laranja
4. Continue com a [instalação como habitualmente](02-getting-started.md)

O instalador deteta o hardware do Mac e aplica automaticamente as correções necessárias: controladores e firmware Broadcom Wi-Fi, o controlador de teclado SPI nos modelos MacBook que dele precisam e uma correção de suspensão NVMe para esses mesmos modelos.

### Limitações conhecidas

Os membros da comunidade estão constantemente a trabalhar em soluções para estes desafios, por isso, se estes forem problemáticos para si, junte-se ao #omarchy-on-other no nosso [Discord](https://discord.gg/tXFUdasqhY) e veja se existe algum método atualizado para os resolver.

#### Dispositivos com chip T1

O chip Apple T1 foi introduzido no final de 2016 e utilizado exclusivamente nos modelos MacBook Pro de primeira geração com Touch Bar.
- MacBook Pro de 13 polegadas (2016, duas portas Thunderbolt 3) – Modelo: A1706
- MacBook Pro de 13 polegadas (2016, quatro portas Thunderbolt 3) – Modelo: A1708
- MacBook Pro de 15 polegadas (2016) – Modelo: A1707

#### Problemas conhecidos

- A Touch Bar não funciona
- O som não funciona

#### Dispositivos com chip T2

O Apple T2 Security Chip foi introduzido em 2017. O chip T2 foi descontinuado com a transição para o Apple silicon (chips da série M) a partir de 2020.

- iMac Pro (2017) – Modelo: A1862
- MacBook Pro de 13 polegadas (2018, quatro portas Thunderbolt 3) – Modelo: A1989
- MacBook Pro de 15 polegadas (2018) – Modelo: A1990
- MacBook Air (Retina, 13 polegadas, 2018) – Modelo: A1932
- Mac mini (2018) – Modelo: A1998
- MacBook Pro de 13 polegadas (2019, duas portas Thunderbolt 3) – Modelo: A2159
- MacBook Pro de 13 polegadas (2019, quatro portas Thunderbolt 3) – Modelo: A2178
- MacBook Pro de 15 polegadas (2019) – Modelo: A1990
- iMac (Retina 5K, 27 polegadas, 2020) – Modelo: A2115 (iMac20,1 e iMac20,2)
- MacBook Pro de 13 polegadas (2020, duas portas Thunderbolt 3) – Modelo: A2265
- MacBook Pro de 15 polegadas (2020) – Modelo: A1990

Nestes modelos, o instalador configura automaticamente o kernel `linux-t2` corrigido, a configuração de áudio T2, o firmware Broadcom Wi-Fi/Bluetooth da Apple e o controlo da ventoinha através do `t2fanrd`. A Touch Bar funciona com o suporte ao estilo Boot Camp incorporado no kernel.

#### iMac Retina 5K (2017)

O iMac de 27 polegadas de 2017 não tem chip T2, por isso o instalador configura-o como os outros Macs Intel.

- iMac (Retina 5K, 27 polegadas, 2017) – Modelo: A1419

#### Problemas conhecidos

- O ecrã não funciona à sua resolução nativa de 5120×2880: o painel é composto por dois blocos e o controlador de origem só acende um
- O som não funciona
- O controlo de brilho não tem efeito
- A suspensão bloqueia a máquina; só desligar e voltar a ligar a recupera

Um patcher da comunidade para este modelo corrige o ecrã, o som e o brilho: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
