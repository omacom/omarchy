# Atualizações

O Omarchy e os seus pacotes mantêm-se atualizados através de _Update > Omarchy_ no menu do Omarchy (`Super + Space`).

O próprio Omarchy é instalado como pacotes pacman normais a partir do [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), por isso uma atualização instala [a versão mais recente do Omarchy](https://github.com/omacom/omarchy/releases), executa as migrações pendentes para sincronizar o seu sistema com a versão mais recente e atualiza todos os pacotes do sistema a partir do [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) e do [AUR](https://aur.archlinux.org/) (se tiver instalado algum pacote do AUR).

Quando forem lançadas novas versões, vai aparecer um ícone de seta circular à direita do seu relógio. Clique nele e o processo de atualização começa.

![update-available](images/update-available.webp)

### Quatro canais

O Omarchy é atualizado através de quatro canais: stable, RC, edge e dev. As novas instalações começam no canal stable, que acompanha as [versões oficiais](https://github.com/omacom/omarchy/releases/), bem como o [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) estável, que segue com um mês de atraso em relação ao mais recente, para podermos detetar novas incompatibilidades que exijam alterações de configuração antes de causarem problemas às pessoas.

Mas se quiser ajudar a detetar esses potenciais problemas, pode usar o canal edge. Isso mantém os seus pacotes Omarchy a acompanhar as compilações de desenvolvimento mais recentes e permite-lhe atualizar para os pacotes Arch mais recentes assim que estiverem disponíveis. Só deve fazer isto se tiver experiência com Linux e souber recuperar um sistema com problemas.

Antes de cada nova versão principal, fazemos a validação final através do canal RC. Se estiver interessado em ajudar no aperfeiçoamento final, apareça em #omarchy-release-candidates no Discord.

Por fim, há o canal dev, que liga o Omarchy diretamente a um checkout git do código-fonte em `~/omarchy`, combinado com os pacotes edge. Só deve usar este canal se for um utilizador Linux experiente, estiver a trabalhar diretamente no Omarchy e estiver disposto a tolerar falhas.

Pode alternar entre canais através de _Update > Channel_ no menu do Omarchy (ou `omarchy channel set <stable|rc|edge|dev>` no terminal, com `omarchy channel current` para ver onde está).

### Mudar de kernel

O Omarchy arranca com o seu próprio kernel `linux-omarchy`, mas pode manter outros instalados ao lado, como o kernel `linux` padrão do Arch ou uma compilação experimental que esteja a testar. Quando há mais do que um, _Update > Kernel_ no menu do Omarchy lista-os com uma marca junto ao que arranca por predefinição. Escolha outro, introduza a sua palavra-passe uma vez e ele arrancará após o próximo reinício. Os outros kernels mantêm-se no menu de arranque, por isso ainda pode escolher um manualmente se a nova predefinição lhe der problemas. No terminal, é `omarchy kernel` para ver a predefinição atual, `omarchy kernel list` para ver o que está instalado e `omarchy kernel set <kernel>` para mudar.

### Atualizações de firmware

Os seus pacotes não são a única coisa que fica desatualizada. Muitos portáteis e periféricos disponibilizam firmware de BIOS, SSD e dock através do Linux Vendor Firmware Service, e _Update > Firmware_ no menu do Omarchy vai buscar e instala o que o seu hardware tiver à espera. Instala o `fwupd` na primeira vez que o executar. Muito firmware só pode ser escrito durante um reinício, por isso não se surpreenda se lhe for pedido um.

Quando precisar de alterar uma definição na própria BIOS, mantenha premido `Alt` no menu do sistema (`Super + Escape`) e _Reboot_ transforma-se em _Reboot to BIOS_, que reinicia diretamente para a configuração do firmware sem ter de apanhar a tecla certa no arranque. No terminal, é `omarchy system firmware`.

### Aviso sobre atualizações diretas com pacman/yay

Se já está familiarizado com o Arch, pode ser tentador executar simplesmente `pacman -Syu` ou `yay -Syu` por si próprio, mas se o fizer, perde o snapshot, as migrações e as atualizações de configuração que o Omarchy executa juntamente com os novos pacotes. É por isso que o Omarchy impede mesmo uma atualização direta do sistema e o encaminha para `omarchy update`. (Se sabe mesmo o que está a fazer, a proteção indica-lhe como a contornar numa única transação.)

### Reverter atualizações problemáticas

Se alguma vez tiver um problema depois de fazer uma atualização, pode reverter o seu sistema para o snapshot criado antes da atualização. Basta reiniciar e escolher no menu de arranque o snapshot de antes de iniciar a atualização.

![bootloader](images/bootloader.webp)

Se, de alguma forma, os seus ficheiros de configuração ficarem corrompidos, também pode fazer uma reinstalação do Omarchy com `omarchy reinstall` no terminal. Isto vai reinstalar todos os pacotes predefinidos do Omarchy, colocá-lo no canal stable (edge no Apple Silicon), fazer downgrade de quaisquer pacotes demasiado recentes e repor todos os ficheiros de configuração. Tenha em atenção que todas as alterações que fez, como utilizador, à configuração predefinida do Omarchy serão substituídas ao fazer isto!
