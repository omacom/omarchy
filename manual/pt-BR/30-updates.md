# Atualizações

O Omarchy e seus pacotes são mantidos atualizados por meio de _Atualização > Omarchy_ no menu do Omarchy (`Super + Space`).

O próprio Omarchy é instalado como pacotes normais do pacman a partir do [Repositório de Pacotes do Omarchy](https://github.com/omacom-io/omarchy-pkgs), então uma atualização instala [a versão mais recente do Omarchy](https://github.com/omacom/omarchy/releases), executa qualquer migração pendente para deixar seu sistema em sincronia com a versão mais recente e atualiza todos os pacotes do sistema a partir do [Espelho Arch do Omarchy](https://github.com/omacom-io/omarchy-mirror) e da [AUR](https://aur.archlinux.org/) (se você tiver instalado algum pacote da AUR).

Quando novas versões são lançadas, um ícone de seta circular aparecerá à direita do seu relógio. Clique nele e o processo de atualização começará.

![update-available](images/update-available.webp)

### Quatro canais

O Omarchy é atualizado por quatro canais: stable, RC, edge e dev. As novas instalações começam no canal stable, que acompanha as [versões oficiais](https://github.com/omacom/omarchy/releases/), bem como o [espelho Arch stable do Omarchy](https://github.com/omacom-io/omarchy-mirror) que roda um mês atrás da versão mais recente, para que possamos identificar qualquer nova incompatibilidade que exija mudanças de configuração antes que ela cause problemas para as pessoas.

Mas se você quiser ajudar a detectar esses possíveis problemas, pode rodar no canal edge. Isso manterá seus pacotes do Omarchy acompanhando as compilações de desenvolvimento mais recentes e permite que você atualize para os pacotes Arch mais recentes assim que eles ficarem disponíveis. Você só deve fazer isso se tiver experiência com Linux e souber como recuperar um sistema que apresenta problemas.

Antes de qualquer nova versão principal, faremos a validação final usando o canal RC. Se você tiver interesse em ajudar no polimento final, venha bater um papo em #omarchy-release-candidates no Discord.

Por fim, há o canal dev, que vincula o Omarchy diretamente a um checkout git do código-fonte em `~/omarchy`, combinado com os pacotes edge. Você só deve usar esse canal se for um usuário experiente de Linux, estiver trabalhando diretamente no Omarchy e estiver disposto a tolerar quebras.

Você pode alternar entre canais usando _Atualização > Canal_ no menu do Omarchy (ou `omarchy channel set <stable|rc|edge|dev>` no terminal, com `omarchy channel current` para ver onde você está).

### Trocando de kernel

O Omarchy inicializa seu próprio kernel `linux-omarchy`, mas você pode manter outros instalados ao lado dele, como o kernel `linux` padrão do Arch ou uma compilação experimental que estiver testando. Quando há mais de um, _Atualização > Kernel_ no menu do Omarchy lista todos eles com uma marca de seleção ao lado daquele que inicializa por padrão. Escolha outro, digite sua senha uma vez, e ele inicializará após a próxima reinicialização. Os outros kernels permanecem no menu de inicialização, então você ainda pode escolher um manualmente se o novo padrão lhe der problemas. No terminal, é `omarchy kernel` para ver o padrão atual, `omarchy kernel list` para ver o que está instalado e `omarchy kernel set <kernel>` para trocar.

### Atualizações de firmware

Seus pacotes não são a única coisa que fica desatualizada. Muitos laptops e periféricos distribuem firmware de BIOS, SSD e dock por meio do Linux Vendor Firmware Service, e _Atualização > Firmware_ no menu do Omarchy buscará e instalará o que seu hardware tiver esperando. Ele instala o `fwupd` na primeira vez que você o executa. Muitos firmwares só podem ser gravados durante uma reinicialização, então não se surpreenda se pedirem uma.

Quando você precisar mudar uma configuração na própria BIOS, mantenha `Alt` pressionado no menu do sistema (`Super + Escape`) e _Reiniciar_ se transforma em _Reiniciar para a BIOS_, que reinicia direto na configuração do firmware sem precisar acertar a tecla certa na inicialização. No terminal, é `omarchy system firmware`.

### Aviso sobre atualizações diretas com pacman/yay

Se você já conhece o Arch, pode ficar tentado a simplesmente executar `pacman -Syu` ou `yay -Syu` por conta própria, mas, se fizer isso, perderá o snapshot, as migrações e as atualizações de configuração que o Omarchy executa junto com os novos pacotes. É por isso que o Omarchy na verdade interromperá uma atualização direta do sistema e o direcionará para `omarchy update`. (Se você realmente sabe o que está fazendo, a proteção informará como ignorá-la para uma única transação.)

### Revertendo atualizações problemáticas

Se você algum dia tiver um problema depois de fazer uma atualização, pode reverter seu sistema para o snapshot tirado antes da atualização. Basta reiniciar e escolher no menu de inicialização o snapshot de antes de você iniciar a atualização.

![bootloader](images/bootloader.webp)

Se de alguma forma seus arquivos de configuração forem corrompidos, você também pode executar uma reinstalação do Omarchy usando `omarchy reinstall` no terminal. Isso reinstalará todos os pacotes padrão do Omarchy, colocará você no stable (edge no Apple Silicon) e fará downgrade de qualquer pacote que esteja novo demais, além de redefinir todos os arquivos de configuração. Observe que todas as suas alterações de configuração de usuário nos padrões do Omarchy serão sobrescritas ao fazer isso!
