# Resolução de problemas

### Parti o meu sistema com uma atualização!

Primeiro, tenta [reverter o sistema](47-system-snapshots.md) para a versão anterior à tua atualização recente. Se isso não resultar, usa `omarchy-debug` para partilhares o teu problema no #omarchy-help no Discord. E se tudo isso falhar, podes reinstalar as configurações e os pacotes predefinidos com `omarchy-reinstall`.

### Porque é que algumas aplicações são tão grandes no meu ecrã?

O Omarchy pressupõe um ecrã de alta resolução 2x, o que exige definir `GDK_SCALE` como 2 em `~/.config/hypr/monitors.lua`. Mas se estiveres num ecrã 1x, podes mudar `local omarchy_gdk_scale = 2` para 1 (e depois reiniciar qualquer aplicação que esteja sobredimensionada). Consulta [o manual sobre monitores](33-monitors.md).

No Spotify, podes usar `Ctrl + Minus` para reduzir a interface (e `Ctrl + Plus` para a aumentar).

### Porque é que todos os meus atalhos com a tecla Super deixaram de funcionar?

Em alguns portáteis ASUS ROG e TUF, `Fn + Super` é uma combinação fácil de premir sem reparar que ativa e desativa um bloqueio da tecla Windows ao nível do firmware (pensado para gaming, para não saíres de um jogo por acidente). Nada no ecrã te diz que isso aconteceu. Enquanto o bloqueio estiver ativo, a tecla Super não emite absolutamente nada — portanto, todos os atalhos do Omarchy que usam Super simplesmente param, e parece que o Hyprland avariou.

Prime `Fn + Super` uma vez antes de começares a mexer em `~/.config/hypr/` e, se isso não trouxer a tecla Super de volta, prime-a outra vez para não deixares o bloqueio ligado. Isto não é o Fn-lock, que só muda o comportamento da fila de teclas F.

### O meu Wi-Fi, Bluetooth, áudio ou trackpad deixou simplesmente de funcionar

Antes de reiniciares, tenta reiniciar sozinho o subsistema problemático. _Update > Hardware_ no menu do Omarchy tem Wi-Fi, Bluetooth, Audio e Trackpad, e recarregar um deles resolve a maioria das situações do tipo "isto estava a funcionar há cinco minutos" — uns auscultadores Bluetooth que não voltam a ligar, um trackpad que morreu depois de uma suspensão, som que desapareceu quando desligaste um monitor.

### Porque é que as minhas colunas externas não reproduzem som?

Provavelmente porque não estão definidas como a saída principal. Clica no ícone da coluna no lado direito da barra e isso abre a janela de volume, onde podes escolher o dispositivo de saída (e também ajustar o volume por aplicação).

### As colunas do meu portátil soam estranhas

Em alguns portáteis, o Omarchy aplica automaticamente uma afinação das colunas que corrige a resposta de frequência das colunas integradas. `omarchy audio tuning status` diz-te se está alguma ativa na tua máquina, e `omarchy audio tuning off` desativa-a se preferires ouvir as colunas sem qualquer correção.

### Porque é que não consigo iniciar sessão nem usar o sudo com a minha palavra-passe?

Provavelmente escreveste-a mal demasiadas vezes e ficaste bloqueado. Se isto estiver a acontecer no ecrã de bloqueio, podes premir `CTRL + ALT + F2` para iniciares um novo TTY onde podes iniciar sessão como root, e depois executar `faillock --reset --user [your-username]`. Isso repõe o bloqueio e estás pronto a continuar.

### Porque é que os meus pedidos de autorização do 1Password para o 1Password SSH Agent / CLI não estão a aparecer?

Isto pode acontecer por 2 motivos:

Para o pedido de aprovação completo aparecer, Settings > Advanced > Use Hardware Acceleration tem de estar ativado. _Nota: Isto exige um reinício para começar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou, se não tiveres iniciado o 1Password desde que ligaste o computador, o pedido não vai aparecer.
