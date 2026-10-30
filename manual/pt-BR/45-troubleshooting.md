# Solução de problemas

### Quebrei meu sistema com uma atualização!

Primeiro, tente [reverter seu sistema](47-system-snapshots.md) para a versão anterior à sua atualização recente. Se isso não funcionar, use `omarchy-debug` para compartilhar seu problema no #omarchy-help no Discord. E se tudo isso falhar, você pode reinstalar as configurações e os pacotes padrão usando `omarchy-reinstall`.

### Por que alguns aplicativos estão tão grandes na minha tela?

O Omarchy presume uma tela de alta resolução 2x, o que exige definir `GDK_SCALE` como 2 em `~/.config/hypr/monitors.lua`. Mas se você estiver em uma tela 1x, pode alterar `local omarchy_gdk_scale = 2` para 1 (e depois reiniciar qualquer aplicativo que esteja grande demais). Consulte [o manual sobre monitores](33-monitors.md).

No Spotify, você pode usar `Ctrl + Minus` para reduzir a UI (e `Ctrl + Plus` para aumentá-la).

### Por que todos os meus atalhos da tecla Super pararam de funcionar?

Em alguns notebooks ASUS ROG e TUF, `Fn + Super` é uma combinação fácil de passar despercebida que alterna um bloqueio da tecla Windows no firmware (pensado para jogos, para você não sair de um jogo por acidente). Nada na tela avisa que isso aconteceu. Enquanto o bloqueio estiver ativo, Super não emite absolutamente nada — então todos os atalhos do Omarchy que usam Super simplesmente param, e parece que o Hyprland quebrou.

Pressione `Fn + Super` uma vez antes de fuçar em `~/.config/hypr/`, e se isso não trouxer o Super de volta, pressione novamente para não deixar o bloqueio ativado. Isso não é o Fn-lock, que só altera o que a fileira de teclas F faz.

### Meu Wi-Fi, Bluetooth, áudio ou trackpad simplesmente parou de funcionar

Antes de reiniciar, tente reiniciar apenas o subsistema problemático. _Update > Hardware_ no menu do Omarchy tem Wi-Fi, Bluetooth, Audio e Trackpad, e recarregar um deles resolve a maioria das situações do tipo "estava funcionando cinco minutos atrás" — um headset Bluetooth que não quer reconectar, um trackpad que morreu depois de uma suspensão, um som que sumiu quando você desconectou um monitor.

### Por que meus alto-falantes externos não estão tocando?

Provavelmente porque eles não estão definidos como a saída principal. Clique no ícone de alto-falante no lado direito da barra, e ele abrirá o popup de volume onde você pode escolher o dispositivo de saída (e mixar os volumes por aplicativo também).

### Os alto-falantes do meu notebook estão com um som estranho

Em alguns notebooks, o Omarchy aplica automaticamente um ajuste de alto-falante que corrige a resposta de frequência dos alto-falantes integrados. `omarchy audio tuning status` informa se há um ajuste ativo na sua máquina, e `omarchy audio tuning off` o desativa se você preferir ouvir os alto-falantes sem correção.

### Por que não consigo fazer login ou usar sudo com a minha senha?

Você provavelmente a digitou errado vezes demais e foi bloqueado. Se isso estiver acontecendo na tela de bloqueio, você pode pressionar `CTRL + ALT + F2` para iniciar um novo TTY onde pode fazer login como root e depois executar `faillock --reset --user [your-username]`. Isso vai redefinir o bloqueio, e você está liberado.

### Por que os prompts de autorização do 1Password para o 1Password SSH Agent / CLI não estão aparecendo?

Isso pode acontecer por 2 motivos:

Para que o prompt de aprovação completo apareça, Settings > Advanced > Use Hardware Acceleration precisa estar ativado. _Observação: isso exige uma reinicialização para começar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou, se você não tiver aberto o 1Password desde que ligou o computador, o prompt não vai aparecer.
