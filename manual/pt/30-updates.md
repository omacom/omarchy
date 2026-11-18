# Atualizações

O Omarchy e os teus pacotes são mantidos atualizados através de _Atualizar > Omarchy_ no menu Omarchy (`Super + Space`).

O próprio Omarchy está instalado como pacotes pacman normais a partir do [Repositório de Pacotes Omarchy](https://github.com/omacom-io/omarchy-pkgs), pelo que uma atualização instala [a versão mais recente do Omarchy](https://github.com/omacom/omarchy/releases), executa quaisquer migrações pendentes para deixar o teu sistema sincronizado com o mais recente e atualiza todos os pacotes do sistema a partir do [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) e do [AUR](https://aur.archlinux.org/) (se tiveres instalado algum pacote AUR).

Quando forem lançadas novas versões, um ícone de seta circular vai aparecer à direita do teu relógio. Clica nele e o processo de atualização vai começar.

![update-available](images/update-available.webp)

### Quatro canais

O Omarchy é atualizado através de quatro canais: stable, RC, edge e dev. As novas instalações começam no canal stable, que acompanha as [versões oficiais](https://github.com/omacom/omarchy/releases/), bem como o [Omarchy Arch mirror stable](https://github.com/omacom-io/omarchy-mirror) que vai com um mês de atraso em relação ao mais recente, para podermos apanhar quaisquer novas incompatibilidades que exijam alterações de configuração antes de causarem problemas às pessoas.

Mas se quiseres ajudar a detetar esses potenciais problemas, podes correr no canal edge. Isso vai manter os teus pacotes Omarchy a acompanhar as compilações de desenvolvimento mais recentes e permite-te atualizar para os pacotes Arch mais recentes assim que estiverem disponíveis. Só deves fazer isto se tiveres experiência com Linux e souberes como recuperar um sistema que tenha problemas.

Antes de qualquer grande lançamento novo, vamos estar a fazer a validação final usando o canal RC. Se estiveres interessado em ajudar no polimento final, aparece no #omarchy-release-candidates no Discord.

Por fim, há o canal dev, que liga o Omarchy diretamente a um checkout git do código-fonte em `~/omarchy`, combinado com os pacotes edge. Só deves usar este canal se fores um utilizador Linux experiente, estiveres a trabalhar diretamente no Omarchy e estiveres disposto a tolerar falhas.

Podes alternar entre canais usando _Atualizar > Canal_ a partir do menu Omarchy (ou `omarchy-channel-set` no terminal).

### Mudar de kernel

O Omarchy arranca com o seu próprio kernel `linux-omarchy`, mas podes manter outros instalados ao lado dele, como o kernel `linux` padrão do Arch ou uma compilação experimental que estejas a testar. Quando há mais do que um, _Atualizar > Kernel_ no menu Omarchy lista-os com uma marca de verificação ao lado daquele que arranca por predefinição. Escolhe outro, introduz a tua palavra-passe uma vez e ele vai arrancar após o próximo reinício. Os outros kernels permanecem no menu de arranque, por isso ainda podes escolher um manualmente se o novo predefinido te der problemas. No terminal, é `omarchy-kernel` para ver o predefinido atual, `omarchy-kernel list` para o que está instalado e `omarchy-kernel set <kernel>` para mudar.

### Atualizações de firmware

Os teus pacotes não são a única coisa que fica desatualizada. Muitos portáteis e periféricos disponibilizam firmware da BIOS, do SSD e da dock através do Linux Vendor Firmware Service, e _Atualizar > Firmware_ no menu Omarchy vai buscar e instalar o que o teu hardware tiver à espera. Instala o `fwupd` na primeira vez que o executares. Muito firmware só pode ser escrito durante um reinício, por isso não te surpreendas se te for pedido um.

Quando precisares de mudar uma definição na própria BIOS, mantém premido `Alt` no menu do sistema (`Super + Escape`) e _Reiniciar_ transforma-se em _Reiniciar para a BIOS_, o que reinicia diretamente para a configuração do firmware sem teres de apanhar a tecla certa no arranque. A partir do terminal, é `omarchy system firmware`.

### Aviso sobre atualizações diretas com pacman/yay

Se já estás familiarizado com o Arch, podes sentir-te tentado a executar simplesmente `pacman -Syu` ou `yay -Syu` por ti próprio, mas se o fizeres, vais perder o instantâneo, as migrações e as atualizações de configuração que o Omarchy executa juntamente com os novos pacotes. É por isso que o Omarchy vai mesmo impedir uma atualização direta do sistema e apontar-te para `omarchy update`. (Se souberes mesmo o que estás a fazer, a proteção vai dizer-te como contorná-la para uma única transação.)

### Reverter atualizações problemáticas

Se alguma vez tiveres um problema depois de fazeres uma atualização, podes reverter o teu sistema para o instantâneo tirado antes da atualização. Basta reiniciares e escolheres no menu de arranque o instantâneo de antes de teres começado a atualização.

![bootloader](images/bootloader.webp)

Se, de alguma forma, os teus ficheiros de configuração tiverem sido corrompidos, também podes executar uma reinstalação do Omarchy usando `omarchy reinstall` no terminal. Isto vai reinstalar todos os pacotes Omarchy predefinidos, colocar-te no stable e repor versões anteriores de quaisquer pacotes que sejam demasiado novos, e repor todos os ficheiros de configuração. Nota que todas as alterações de configuração de utilizador que fizeste aos valores predefinidos do Omarchy serão substituídas ao fazeres isto!
