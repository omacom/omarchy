# Solução de problemas

### Quebrei meu sistema com uma atualização!

Primeiro, tente [reverter seu sistema](47-system-snapshots.md) para a versão anterior à sua atualização recente. Se isso não funcionar, use `omarchy-debug` para compartilhar seu problema no #omarchy-help no Discord. E se tudo isso falhar, você pode reinstalar as configurações e pacotes padrão usando `omarchy-reinstall`.

### Por que alguns aplicativos estão tão grandes na minha tela?

O Omarchy presume uma tela de alta resolução 2x, então ele define `GDK_SCALE` como 2 até você escolher uma escala no painel do monitor. Se você estiver em uma tela 1x e os aplicativos GTK ou X11 ficarem enormes, escolha 1x para ela no painel do monitor, ou adicione `hl.env("GDK_SCALE", "1")` em `~/.config/hypr/monitors.lua` (e depois reinicie qualquer aplicativo que estiver enorme). Veja [o manual sobre monitores](33-monitors.md).

No Spotify, você pode usar `Ctrl + Minus` para encolher a interface (e `Ctrl + Plus` para aumentá-la).

### Por que todos os meus atalhos com a tecla Super pararam de funcionar?

Em alguns laptops ASUS ROG e TUF, `Fn + Super` é uma combinação fácil de passar despercebida que ativa e desativa um bloqueio da tecla Windows no firmware (feito para jogos, para você não sair de um jogo por acidente). Nada na tela avisa que isso aconteceu. Enquanto o bloqueio estiver ativo, Super não emite absolutamente nada — então todo atalho do Omarchy que usa Super simplesmente para, e parece que o Hyprland quebrou.

Pressione `Fn + Super` uma vez antes de fuçar em `~/.config/hypr/`, e se isso não trouxer Super de volta, pressione de novo para não deixar o bloqueio ativo. Isso não é o Fn-lock, que só muda o que a fileira de teclas F faz.

### Meu Wi-Fi, Bluetooth, áudio ou trackpad simplesmente parou de funcionar

Antes de reiniciar, tente reiniciar só o subsistema problemático. _Update > Hardware_ no menu do Omarchy tem Wi-Fi, Bluetooth, Audio e Trackpad, e recarregar um deles resolve a maioria das situações do tipo "estava funcionando cinco minutos atrás" — um headset Bluetooth que não reconecta, um trackpad que morreu depois de uma suspensão, um som que sumiu quando você desconectou um monitor.

### Por que minhas caixas de som externas não estão tocando?

Provavelmente porque elas não estão definidas como a saída principal. Clique no ícone de alto-falante no lado direito da barra, e ele abrirá o popup de volume onde você pode escolher o dispositivo de saída (e ajustar os volumes por aplicativo também).

### As caixas de som do meu laptop estão com um som estranho

Em alguns laptops, o Omarchy aplica automaticamente um ajuste de som que corrige a resposta de frequência das caixas de som integradas. `omarchy audio tuning status` diz se um ajuste está ativo na sua máquina, e `omarchy audio tuning off` desativa ele se você preferir ouvir as caixas de som sem correção nenhuma.

### Por que não consigo fazer login ou usar sudo com minha senha?

Você provavelmente digitou ela errada vezes demais e foi bloqueado. Se isso estiver acontecendo na tela de bloqueio, você pode apertar `CTRL + ALT + F2` para iniciar um novo TTY onde você pode fazer login como root, então executar `faillock --reset --user [your-username]`. Isso vai zerar o bloqueio, e você está pronto para continuar.

### Por que minhas solicitações de autorização do 1Password para o 1Password SSH Agent / CLI não estão aparecendo?

Isso pode acontecer por 2 motivos:

Para que a solicitação de aprovação completa apareça, Settings > Advanced > Use Hardware Acceleration precisa estar ativado. _Nota: Isso requer uma reinicialização para começar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou, se você não abriu o 1Password desde que ligou o computador, a solicitação não vai aparecer.
