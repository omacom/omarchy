# Atualizações

O Omarchy e os teus pacotes são mantidos atualizados através de _Atualizar > Omarchy_ no menu Omarchy (`Super + Space`).

O próprio Omarchy é instalado como pacotes pacman normais a partir do [Repositório de Pacotes Omarchy](https://github.com/omacom-io/omarchy-pkgs), por isso uma atualização instala [a versão mais recente do Omarchy](https://github.com/omacom/omarchy/releases), executa quaisquer migrações pendentes para colocar o teu sistema em sintonia com a versão mais recente e atualiza todos os pacotes do sistema a partir do [Espelho Arch do Omarchy](https://github.com/omacom-io/omarchy-mirror) e do [AUR](https://aur.archlinux.org/) (se tiveres instalado algum pacote do AUR).

Quando forem lançadas novas versões, aparece um ícone de seta circular à direita do teu relógio. Clica nele e o processo de atualização começa.

![update-available](images/update-available.webp)

### Quatro canais

O Omarchy é atualizado ao longo de quatro canais: stable, RC, edge e dev. As novas instalações começam no canal stable, que acompanha as [versões oficiais](https://github.com/omacom/omarchy/releases/), bem como o [espelho Arch estável do Omarchy](https://github.com/omacom-io/omarchy-mirror), que corre com um mês de atraso em relação ao mais recente, para podermos apanhar quaisquer novas incompatibilidades que exijam alterações de configuração antes de causarem problemas às pessoas.

Mas, se quiseres ajudar a detetar esses potenciais problemas, podes correr no canal edge. Isso mantém os teus pacotes Omarchy a acompanhar as compilações de desenvolvimento mais recentes e permite-te atualizar para os pacotes Arch mais recentes assim que fiquem disponíveis. Só deves fazer isto se tiveres experiência com Linux e souberes como recuperar um sistema com problemas.

Antes de qualquer nova versão principal, faremos a validação final usando o canal RC. Se estiveres interessado em ajudar no polimento final, aparece no #omarchy-release-candidates no Discord.

Por fim, há o canal dev, que liga o Omarchy diretamente a um checkout git do código-fonte em `~/omarchy`, combinado com os pacotes edge. Só deves usar este canal se fores um utilizador Linux experiente, estiveres a trabalhar diretamente no Omarchy e estiveres disposto a tolerar avarias.

Podes mudar de canal usando _Atualizar > Canal_ no menu Omarchy (ou `omarchy-channel-set` no terminal).

### Atualizações de firmware

Os teus pacotes não são a única coisa que fica desatualizada. Muitos portáteis e periféricos distribuem firmware de BIOS, SSD e docks através do Linux Vendor Firmware Service, e _Atualizar > Firmware_ no menu Omarchy obtém e instala o que o teu hardware tiver à espera. Instala o `fwupd` da primeira vez que o executares. Muito firmware só pode ser escrito durante um reinício, por isso não te surpreendas se te for pedido um.

### Aviso sobre atualizações diretas com pacman/yay

Se já estiveres familiarizado com o Arch, podes sentir-te tentado a simplesmente executar `pacman -Syu` ou `yay -Syu` por ti próprio, mas, se o fizeres, perdes o instantâneo, as migrações e as atualizações de configuração que o Omarchy executa juntamente com os novos pacotes. É por isso que o Omarchy interrompe, na verdade, uma atualização direta do sistema e te aponta antes para o `omarchy update`. (Se souberes mesmo o que estás a fazer, a proteção diz-te como a contornar para uma única transação.)

### Reverter atualizações más

Se alguma vez tiveres um problema depois de fazeres uma atualização, podes reverter o teu sistema para o instantâneo tirado antes da atualização. Basta reiniciares e escolheres, no menu de arranque, o instantâneo de antes de teres iniciado a atualização.

![bootloader](images/bootloader.webp)

Se, de alguma forma, os teus ficheiros de configuração tiverem sido corrompidos, também podes fazer uma reinstalação do Omarchy usando `omarchy reinstall` no terminal. Isto reinstala todos os pacotes predefinidos do Omarchy, coloca-te no canal stable e faz downgrade de quaisquer pacotes que sejam demasiado novos, e repõe todos os ficheiros de configuração. Nota que todas as tuas alterações de configuração de utilizador às predefinições do Omarchy serão substituídas ao fazeres isto!
