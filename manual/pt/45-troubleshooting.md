# Resolução de problemas

### Parti o meu sistema com uma atualização!

Tenta primeiro [reverter o teu sistema](47-system-snapshots.md) para a versão anterior à atualização recente. Se isso não resultar, usa `omarchy-debug` para partilhares o teu problema em #omarchy-help no Discord. E se tudo isso falhar, podes reinstalar as configurações e os pacotes predefinidos com `omarchy-reinstall`.

### Porque é que algumas aplicações aparecem tão grandes no meu ecrã?

O Omarchy parte do princípio de que tens um ecrã de alta resolução 2x, por isso define `GDK_SCALE` como 2 até escolheres uma escala no painel do monitor. Se estiveres num ecrã 1x e as aplicações GTK ou X11 aparecerem demasiado grandes, escolhe 1x para ele no painel do monitor, ou adiciona `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (e depois reinicia qualquer aplicação que esteja demasiado grande). Consulta [o manual sobre monitores](33-monitors.md).

No Spotify, podes usar `Ctrl + Minus` para reduzir a interface (e `Ctrl + Plus` para a aumentar).

### Porque é que todas as minhas combinações de teclas com Super deixaram de funcionar?

Em alguns portáteis ASUS ROG e TUF, `Fn + Super` é uma combinação fácil de não reparar que ativa e desativa um bloqueio da tecla Windows no firmware (pensado para quando estás a jogar, para não saíres de um jogo por acidente). Nada no ecrã indica que isso aconteceu. Enquanto o bloqueio estiver ativo, a tecla Super não emite absolutamente nada — por isso, todas as combinações do Omarchy que usam Super simplesmente deixam de funcionar, e parece que o Hyprland avariou.

Prime `Fn + Super` uma vez antes de começares a mexer em `~/.config/hypr/`, e se isso não fizer a tecla Super voltar, prime-a outra vez para não deixares o bloqueio ativo. Isto não é o Fn-lock, que só altera o comportamento da linha de teclas F.

### O meu Wi-Fi, Bluetooth, áudio ou trackpad deixou simplesmente de funcionar

Antes de reiniciares, tenta reiniciar apenas o subsistema problemático. _Update > Hardware_ no menu do Omarchy tem Wi-Fi, Bluetooth, Audio e Trackpad, e recarregar um deles resolve a maioria das situações do tipo «funcionava há cinco minutos» — um headset Bluetooth que não volta a ligar-se, um trackpad que deixou de responder depois de uma suspensão, ou o som que desapareceu quando desligaste um monitor.

### Porque é que as minhas colunas externas não estão a tocar?

Provavelmente porque não estão definidas como a saída principal. Clica no ícone da coluna no lado direito da barra e vai abrir-se a janela emergente de volume, onde podes escolher o dispositivo de saída (e também misturar os volumes por aplicação).

### O som das colunas do meu portátil está estranho

Em alguns portáteis, o Omarchy aplica automaticamente um ajuste das colunas que corrige a resposta de frequência das colunas incorporadas. `omarchy audio tuning status` indica se tens um ajuste ativo na tua máquina, e `omarchy audio tuning off` desliga-o se preferires ouvir as colunas sem qualquer correção.

### Porque é que não consigo iniciar sessão nem usar sudo com a minha palavra-passe?

Provavelmente escreveste-a mal demasiadas vezes e ficaste bloqueado. Se isto estiver a acontecer no ecrã de bloqueio, podes premir `CTRL + ALT + F2` para iniciar um novo TTY onde podes iniciar sessão como root e depois executar `faillock --reset --user [your-username]`. Isso vai repor o bloqueio e estás pronto a continuar.

### Porque é que os pedidos de autorização do 1Password para o 1Password SSH Agent / CLI não aparecem?

Isto pode acontecer por 2 motivos:

Para que o pedido de aprovação completo apareça, Settings > Advanced > Use Hardware Acceleration tem de estar ativado. _Nota: Isto requer um reinício para começar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou, se ainda não abriste o 1Password desde que arrancaste o computador, o pedido não vai aparecer.
