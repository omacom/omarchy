# Solução de problemas

### Quebrei meu sistema com uma atualização!

Primeiro tente [reverter seu sistema](47-system-snapshots.md) para a versão anterior à sua atualização recente. Se isso não funcionar, use `omarchy-debug` para compartilhar seu problema em #omarchy-help no Discord. E se tudo isso falhar, você pode reinstalar as configurações e os pacotes padrão usando `omarchy-reinstall`.

### Por que alguns aplicativos estão tão grandes na minha tela?

O Omarchy pressupõe uma tela de alta resolução 2x, o que exige definir `GDK_SCALE` como 2 em `~/.config/hypr/monitors.lua`. Mas se você está em uma tela 1x, pode mudar `local omarchy_gdk_scale = 2` para 1 (e depois reiniciar qualquer aplicativo que esteja grande demais). Veja [o manual sobre monitores](33-monitors.md).

Para o Spotify, você pode usar `Ctrl + Minus` para encolher a interface (e `Ctrl + Plus` para aumentá-la).

### Meu Wi-Fi, Bluetooth, áudio ou trackpad simplesmente parou de funcionar

Antes de reiniciar, tente reiniciar só o subsistema problemático. _Atualizar > Hardware_ no menu do Omarchy tem Wi-Fi, Bluetooth, Áudio e Trackpad, e recarregar um deles resolve a maioria das situações do tipo "funcionava há cinco minutos" — um fone Bluetooth que não reconecta, um trackpad que morreu depois de uma suspensão, um som que sumiu quando você desplugou um monitor.

### Por que minhas caixas de som externas não estão tocando?

Provavelmente porque elas não estão definidas como saída principal. Clique no ícone de alto-falante no lado direito da barra, e ele abrirá o popup de volume onde você pode escolher o dispositivo de saída (e misturar os volumes por aplicativo também).

### As caixas de som do meu notebook soam estranhas

Em alguns notebooks, o Omarchy aplica automaticamente um ajuste de alto-falantes que corrige a resposta de frequência das caixas de som embutidas. `omarchy audio tuning status` diz se há um ativo na sua máquina, e `omarchy audio tuning off` o desliga se você prefere ouvir as caixas de som sem ajuste.

### Por que não consigo fazer login ou sudo com minha senha?

Você provavelmente a digitou errado muitas vezes e ficou bloqueado. Se isso estiver acontecendo na tela de bloqueio, você pode pressionar `CTRL + ALT + F2` para iniciar um novo TTY onde pode fazer login como root e depois executar `faillock --reset --user [your-username]`. Isso vai redefinir o bloqueio, e você estará pronto para continuar.

### Por que as solicitações de autorização do 1Password para o 1Password SSH Agent / CLI não estão aparecendo?

Isso pode acontecer por 2 motivos:

Para que a solicitação de aprovação rica apareça, Settings > Advanced > Use Hardware Acceleration precisa estar ativado. _Observação: isso exige uma reinicialização para começar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou, se você não abriu o 1Password desde a inicialização, a solicitação não vai aparecer.
