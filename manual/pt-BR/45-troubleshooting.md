# Solução de problemas

### Quebrei meu sistema com uma atualização!

Primeiro, tente [reverter seu sistema](47-system-snapshots.md) para a versão anterior à sua atualização recente. Se isso não funcionar, use `omarchy-debug` para compartilhar seu problema no #omarchy-help no Discord. E se tudo isso falhar, você pode reinstalar as configurações e pacotes padrão usando `omarchy-reinstall`.

### Por que alguns aplicativos estão tão grandes na minha tela?

O Omarchy pressupõe uma tela de alta resolução 2x, então ele define `GDK_SCALE` como 2 até você escolher uma escala no painel do monitor. Se você estiver em uma tela 1x e os aplicativos GTK ou X11 ficarem grandes demais, escolha 1x para ela no painel do monitor, ou adicione `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (e depois reinicie qualquer aplicativo que esteja grande demais). Veja [o manual sobre monitores](33-monitors.md).

Para o Spotify, você pode usar `Ctrl + Minus` para reduzir a interface (e `Ctrl + Plus` para aumentá-la).

### Por que todos os meus atalhos com a tecla Super pararam de funcionar?

Em alguns notebooks ASUS ROG e TUF, `Fn + Super` é um atalho fácil de passar despercebido que ativa e desativa um bloqueio da tecla Windows no firmware (feito para jogos, para você não sair de um jogo sem querer). Nada na tela avisa que isso aconteceu. Enquanto o bloqueio está ativado, a tecla Super não emite nada — então todos os atalhos do Omarchy que usam Super simplesmente param, e parece que o Hyprland quebrou.

Pressione `Fn + Super` uma vez antes de fuçar em `~/.config/hypr/`, e se isso não trouxer a Super de volta, pressione de novo para não deixar o bloqueio ativado. Isso não é o Fn-lock, que só muda o comportamento da fileira de teclas F.

### Meu Wi-Fi, Bluetooth, áudio ou trackpad simplesmente parou de funcionar

Antes de reiniciar, tente reiniciar o subsistema problemático sozinho. _Update > Hardware_ no menu do Omarchy tem Wi-Fi, Bluetooth, Audio e Trackpad, e recarregar um deles resolve a maioria das situações do tipo "funcionava cinco minutos atrás" — um headset Bluetooth que não reconecta, um trackpad que morreu depois de uma suspensão, um som que sumiu quando você desconectou um monitor.

### Por que minhas caixas de som externas não estão tocando?

Provavelmente porque elas não estão definidas como saída principal. Clique no ícone de alto-falante no lado direito da barra, e ele abrirá o popup de volume onde você pode escolher o dispositivo de saída (e mixar os volumes por aplicativo também).

### O som dos alto-falantes do meu notebook está estranho

Em alguns notebooks, o Omarchy aplica automaticamente um ajuste de alto-falante que corrige a resposta de frequência dos alto-falantes embutidos. `omarchy audio tuning status` informa se um ajuste está ativo na sua máquina, e `omarchy audio tuning off` o desativa se você preferir ouvir os alto-falantes sem correção.

### Por que não consigo fazer login ou usar sudo com minha senha?

Você provavelmente digitou a senha errada vezes demais e foi bloqueado. Se isso estiver acontecendo na tela de bloqueio, você pode pressionar `CTRL + ALT + F2` para iniciar um novo TTY onde você pode fazer login como root e depois executar `faillock --reset --user [your-username]`. Isso vai zerar o bloqueio, e você está liberado.

### Minha senha é aceita, mas volto para a tela de login

Um arquivo de ambiente de sessão quebrado pode impedir a área de trabalho de iniciar mesmo quando sua senha está correta. Vale especialmente a pena verificar isso depois de editar `~/.config/uwsm/env.d/`.

Pressione `Ctrl + Alt + F2`, faça login com seu nome de usuário e senha normais e inspecione o journal do usuário da inicialização atual:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Procure um erro que nomeie um dos seus arquivos de ambiente, como `bad substitution`, logo antes de uma mensagem dizendo que a marca de saída do env não foi encontrada. Mova esse arquivo para fora de `env.d` antes de tentar fazer login de novo. Por exemplo, se o erro nomear `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

O UWSM ignora um arquivo com erro de sintaxe, mas um erro fatal que só aparece enquanto o arquivo é executado, como `bad substitution`, ainda pode impedir a área de trabalho de iniciar. Uma reversão para um snapshot do sistema não repara esses arquivos, porque `/home` não é revertido.

Quando você conseguir fazer login, corrija a cópia salva antes de movê-la de volta. `sh -n` detecta erros de sintaxe sem executar o arquivo, mas não consegue detectar todos os erros que ocorrem quando ele é carregado via source. Mantenha um terminal funcionando aberto enquanto testa as alterações.

### Por que os prompts de autorização do 1Password para o 1Password SSH Agent / CLI não estão aparecendo?

Isso pode acontecer por 2 motivos:

Para que o prompt de aprovação completo apareça, Settings > Advanced > Use Hardware Acceleration precisa estar ativado. _Observação: isso exige uma reinicialização para começar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou, se você não abriu o 1Password desde que ligou o computador, o prompt não vai aparecer.
