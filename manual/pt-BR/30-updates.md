# Atualizações

O Omarchy e seus pacotes são mantidos atualizados por _Atualizar > Omarchy_ no menu do Omarchy (`Super + Space`).

O próprio Omarchy é instalado como pacotes comuns do pacman a partir do [Repositório de Pacotes do Omarchy](https://github.com/omacom-io/omarchy-pkgs), então uma atualização instala [a versão mais recente do Omarchy](https://github.com/omacom/omarchy/releases), executa quaisquer migrações pendentes para sincronizar seu sistema com o mais recente e atualiza todos os pacotes do sistema a partir do [Espelho Arch do Omarchy](https://github.com/omacom-io/omarchy-mirror) e do [AUR](https://aur.archlinux.org/) (se você tiver algum pacote do AUR instalado).

Quando novas versões forem lançadas, um ícone de seta circular aparecerá à direita do seu relógio. Clique nele e o processo de atualização começará.

![update-available](images/update-available.webp)

### Quatro canais

O Omarchy é atualizado em quatro canais: stable, RC, edge e dev. Novas instalações começam no canal stable, que acompanha os [lançamentos oficiais](https://github.com/omacom/omarchy/releases/), bem como o [espelho Arch stable do Omarchy](https://github.com/omacom-io/omarchy-mirror), que está um mês atrás do mais recente, para que possamos detectar qualquer nova incompatibilidade que exija alterações de configuração antes que ela cause problemas para as pessoas.

Mas se você quiser ajudar a identificar esses possíveis problemas, pode usar o canal edge. Isso manterá seus pacotes do Omarchy acompanhando as compilações de desenvolvimento mais recentes e permitirá que você atualize para os pacotes mais recentes do Arch assim que eles estiverem disponíveis. Você só deve fazer isso se for experiente com Linux e souber como recuperar um sistema com problemas.

Antes de qualquer novo lançamento importante, faremos a validação final usando o canal RC. Se você estiver interessado em ajudar no polimento final, venha nos acompanhar em #omarchy-release-candidates no Discord.

Por fim, há o canal dev, que vincula o Omarchy diretamente a um checkout git do código-fonte em `~/omarchy`, combinado com os pacotes edge. Você só deve usar esse canal se for um usuário Linux experiente, trabalhando diretamente no Omarchy e disposto a tolerar quebras.

Você pode alternar entre canais usando _Atualizar > Canal_ no menu do Omarchy (ou `omarchy-channel-set` no terminal).

### Atualizações de firmware

Seus pacotes não são a única coisa que fica obsoleta. Muitos notebooks e periféricos distribuem firmware de BIOS, SSD e dock pelo Linux Vendor Firmware Service, e _Atualizar > Firmware_ no menu do Omarchy buscará e instalará o que quer que seu hardware esteja aguardando. Ele instala o `fwupd` na primeira vez que você o executa. Muito firmware só pode ser gravado durante uma reinicialização, então não se surpreenda se lhe pedirem uma.

### Aviso sobre atualizações diretas pelo pacman/yay

Se você já está familiarizado com o Arch, pode ser tentado a simplesmente executar `pacman -Syu` ou `yay -Syu` por conta própria, mas se você fizer isso, perderá o snapshot, as migrações e as atualizações de configuração que o Omarchy executa junto com os novos pacotes. É por isso que o Omarchy na verdade interromperá uma atualização direta do sistema e o apontará para o `omarchy update`. (Se você realmente sabe o que está fazendo, a proteção lhe dirá como ignorá-la para uma única transação.)

### Revertendo atualizações ruins

Se você algum dia tiver um problema depois de fazer uma atualização, poderá reverter seu sistema para o snapshot tirado antes da atualização. Basta reiniciar e escolher no menu de inicialização o snapshot de antes de você iniciar a atualização.

![bootloader](images/bootloader.webp)

Se de alguma forma seus arquivos de configuração tiverem sido corrompidos, você também poderá realizar uma reinstalação do Omarchy usando `omarchy reinstall` no terminal. Isso reinstalará todos os pacotes padrão do Omarchy, colocará você no stable, fará downgrade de quaisquer pacotes que sejam novos demais e redefinirá todos os arquivos de configuração. Observe que todas as suas alterações de usuário nas configurações padrão do Omarchy serão sobrescritas ao fazer isso!
