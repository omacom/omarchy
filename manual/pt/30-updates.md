# Atualizações

O Omarchy e os teus pacotes mantêm-se atualizados através de _Atualizar > Omarchy_ no menu do Omarchy (`Super + Space`).

O próprio Omarchy é instalado como pacotes normais do pacman a partir do [Repositório de Pacotes do Omarchy](https://github.com/omacom-io/omarchy-pkgs), por isso uma atualização instala [a versão mais recente do Omarchy](https://github.com/omacom/omarchy/releases), executa quaisquer migrações pendentes para sincronizar o teu sistema com a versão mais recente e atualiza todos os pacotes do sistema a partir do [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) e do [AUR](https://aur.archlinux.org/) (se tiveres instalado algum pacote do AUR).

Quando forem lançadas novas versões, vai aparecer um ícone de seta circular à direita do teu relógio. Clica nele e o processo de atualização arranca.

![update-available](images/update-available.webp)

### Quatro canais

O Omarchy é atualizado através de quatro canais: stable, RC, edge e dev. As instalações novas começam no canal stable, que acompanha as [versões oficiais](https://github.com/omacom/omarchy/releases/), bem como o [mirror estável do Omarchy Arch](https://github.com/omacom-io/omarchy-mirror) que está um mês atrás do mais recente, para podermos detetar quaisquer novas incompatibilidades que exijam alterações de configuração antes de causarem problemas às pessoas.

Mas se quiseres ajudar a detetar esses potenciais problemas, podes usar o canal edge. Isso vai manter os teus pacotes do Omarchy a acompanhar as compilações de desenvolvimento mais recentes e permite-te atualizar para os pacotes Arch mais recentes assim que estiverem disponíveis. Só deves fazer isto se tiveres experiência com Linux e souberes como recuperar um sistema com problemas.

Antes de qualquer nova versão principal, vamos estar a fazer a validação final com o canal RC. Se tiveres interesse em ajudar no polimento final, aparece no #omarchy-release-candidates no Discord.

Por fim, há o canal dev, que liga o Omarchy diretamente a um checkout git do código-fonte em `~/omarchy`, combinado com os pacotes edge. Só deves usar este canal se fores um utilizador experiente de Linux, estiveres a trabalhar diretamente no Omarchy e estiveres disposto a tolerar falhas.

Podes alternar entre canais com _Atualizar > Canal_ no menu do Omarchy (ou `omarchy-channel-set` no terminal).

### Mudar de kernel

O Omarchy arranca com o seu próprio kernel `linux-omarchy`, mas podes manter outros instalados ao lado, como o kernel `linux` padrão do Arch ou uma compilação experimental que estejas a testar. Quando houver mais do que um, _Atualizar > Kernel_ no menu do Omarchy lista-os com um visto ao lado daquele que arranca por predefinição. Escolhe outro, introduz a tua palavra-passe uma vez e ele arrancará após o próximo reinício. Os outros kernels permanecem no menu de arranque, por isso ainda podes escolher um manualmente se o novo padrão te der problemas. No terminal, é `omarchy-kernel` para ver o padrão atual, `omarchy-kernel list` para o que está instalado e `omarchy-kernel set <kernel>` para mudar.

### Atualizações de firmware

Os teus pacotes não são a única coisa que fica desatualizada. Muitos portáteis e periféricos disponibilizam firmware da BIOS, do SSD e da dock através do Linux Vendor Firmware Service, e _Atualizar > Firmware_ no menu do Omarchy vai buscar e instalar o que o teu hardware tiver à espera. Instala o `fwupd` da primeira vez que o executares. Muito firmware só pode ser gravado durante um reinício, por isso não te surpreendas se te for pedido um.

### Aviso sobre atualizações diretas com pacman/yay

Se já conheces o Arch, podes ser tentado a executar simplesmente `pacman -Syu` ou `yay -Syu` por ti próprio, mas se o fizeres, vais perder o snapshot, as migrações e as atualizações de configuração que o Omarchy executa juntamente com os novos pacotes. É por isso que o Omarchy vai mesmo impedir uma atualização direta do sistema e encaminhar-te para `omarchy update`. (Se souberes mesmo o que estás a fazer, a proteção indica-te como contorná-la para uma única transação.)

### Reverter atualizações problemáticas

Se alguma vez tiveres um problema depois de fazeres uma atualização, podes reverter o teu sistema para o snapshot tirado antes da atualização. Basta reiniciares e escolheres no menu de carregamento de arranque o snapshot de antes de teres iniciado a atualização.

![bootloader](images/bootloader.webp)

Se, de alguma forma, os teus ficheiros de configuração tiverem sido corrompidos, também podes fazer uma reinstalação do Omarchy com `omarchy reinstall` no terminal. Isto vai reinstalar todos os pacotes predefinidos do Omarchy, colocar-te no canal stable e fazer o downgrade de quaisquer pacotes que sejam demasiado recentes, e repor todos os ficheiros de configuração. Nota que todas as alterações de configuração de utilizador que fizeste aos padrões do Omarchy serão substituídas ao fazeres isto!
