# Resolução de problemas

### Estraguei o meu sistema com uma atualização!

Primeiro tente [repor o seu sistema](47-system-snapshots.md) para a versão anterior à sua atualização recente. Se isso não funcionar, use `omarchy-debug` para partilhar o seu problema em #omarchy-help no Discord. E se tudo isso falhar, pode reinstalar as configurações e pacotes predefinidos usando `omarchy-reinstall`.

### Porque é que algumas aplicações são tão grandes no meu ecrã?

O Omarchy assume um ecrã de alta resolução 2x, o que exige definir `GDK_SCALE` para 2 em `~/.config/hypr/monitors.lua`. Mas se estiver num ecrã 1x, pode mudar `local omarchy_gdk_scale = 2` para 1 (e depois reiniciar qualquer aplicação que esteja sobredimensionada). Veja [o manual sobre monitores](33-monitors.md).

Para o Spotify, pode usar `Ctrl + Minus` para encolher a interface (e `Ctrl + Plus` para a aumentar).

### O meu Wi-Fi, Bluetooth, áudio ou painel tátil deixou simplesmente de funcionar

Antes de reiniciar, tente reiniciar apenas o subsistema problemático. _Atualizar > Hardware_ no menu Omarchy tem Wi-Fi, Bluetooth, Áudio e Painel tátil, e recarregar um deles resolve a maioria das situações do tipo «funcionava há cinco minutos» — uns auriculares Bluetooth que não se reconectam, um painel tátil que morreu depois de uma suspensão, som que desapareceu quando desligou um monitor.

### Porque é que as minhas colunas externas não estão a reproduzir?

Provavelmente porque não estão definidas como saída principal. Clique no ícone de altifalante no lado direito da barra, e abrir-se-á a janela emergente de volume onde pode escolher o dispositivo de saída (e também misturar volumes por aplicação).

### As colunas do meu portátil soam estranhas

Em alguns portáteis, o Omarchy aplica automaticamente uma afinação de colunas que corrige a resposta de frequência das colunas integradas. `omarchy audio tuning status` diz-lhe se alguma está ativa na sua máquina, e `omarchy audio tuning off` desliga-a se preferir ouvir as colunas sem tratamento.

### Porque é que não consigo iniciar sessão ou usar sudo com a minha palavra-passe?

Provavelmente escreveu-a mal vezes demais e ficou bloqueado. Se isto estiver a acontecer no ecrã de bloqueio, pode premir `CTRL + ALT + F2` para iniciar um novo TTY onde pode iniciar sessão como root e depois executar `faillock --reset --user [your-username]`. Isso repõe o bloqueio, e fica pronto para continuar.

### Porque é que os meus pedidos de autorização do 1Password para o Agente SSH / CLI do 1Password não aparecem?

Isto pode acontecer por 2 motivos:

Para o pedido de aprovação completo aparecer, Definições > Avançadas > Usar aceleração por hardware tem de estar ligado. _Nota: isto exige um reinício para começar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou, se não tiver iniciado o 1Password desde o arranque, o pedido não aparecerá.
