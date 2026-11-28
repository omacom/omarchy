# Solução de problemas

### Quebrei meu sistema com uma atualização!

Primeiro, tente [reverter seu sistema](47-system-snapshots.md) para a versão anterior à atualização recente. Se isso não funcionar, use `omarchy-debug` para compartilhar seu problema em #omarchy-help no Discord. E se tudo isso falhar, você pode reinstalar as configurações e os pacotes padrão usando `omarchy-reinstall`.

### Por que alguns aplicativos estão tão grandes na minha tela?

O Omarchy pressupõe uma tela de alta resolução 2x, então ele define `GDK_SCALE` como 2 até você escolher uma escala no painel do monitor. Se você estiver em uma tela 1x e os aplicativos GTK ou X11 aparecerem grandes demais, escolha 1x para ela no painel do monitor, ou adicione `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (e depois reinicie qualquer aplicativo que esteja grande demais). Veja [o manual sobre monitores](33-monitors.md).

Para o Spotify, você pode usar `Ctrl + Minus` para reduzir a interface (e `Ctrl + Plus` para aumentá-la).

### Por que todos os meus atalhos com a tecla Super pararam de funcionar?

Em alguns notebooks ASUS ROG e TUF, `Fn + Super` é uma combinação fácil de passar despercebida que alterna um bloqueio da tecla Windows no firmware (feito para jogos, para você não sair de um jogo sem querer). Nada na tela avisa que isso aconteceu. Enquanto o bloqueio estiver ativado, a Super não emite nada — então todo atalho do Omarchy que usa Super simplesmente para, e parece que o Hyprland quebrou.

Pressione `Fn + Super` uma vez antes de fuçar em `~/.config/hypr/`, e se isso não trouxer a Super de volta, pressione de novo para não deixar o bloqueio ativado. Isso não é o Fn-lock, que só altera o que a fileira de teclas F faz.

### Meu Wi-Fi, Bluetooth, áudio ou trackpad simplesmente parou de funcionar

Antes de reiniciar, tente reiniciar sozinho o subsistema com problema. _Update > Hardware_ no menu do Omarchy tem Wi-Fi, Bluetooth, Audio e Trackpad, e recarregar um deles resolve a maioria das situações do tipo "funcionava cinco minutos atrás" — um fone Bluetooth que não quer reconectar, um trackpad que morreu depois de uma suspensão, o som que sumiu quando você desconectou um monitor.

### Por que meus alto-falantes externos não estão tocando?

Provavelmente porque eles não estão definidos como a saída principal. Clique no ícone de alto-falante no lado direito da barra, e ele vai abrir o popup de volume, onde você pode escolher o dispositivo de saída (e também ajustar o volume por aplicativo).

### Os alto-falantes do meu notebook estão com um som estranho

Em alguns notebooks, o Omarchy aplica automaticamente um ajuste de alto-falantes que corrige a resposta de frequência dos alto-falantes integrados. `omarchy audio tuning status` informa se há um ativo na sua máquina, e `omarchy audio tuning off` o desativa, se você preferir ouvir os alto-falantes sem correção.

### Por que não consigo fazer login ou usar o sudo com minha senha?

Provavelmente você a digitou errado dez vezes e ficou bloqueado. O bloqueio expira sozinho depois de dois minutos. Se você não puder esperar, e isso estiver acontecendo na tela de bloqueio, você pode pressionar `CTRL + ALT + F2` para iniciar um novo TTY, onde você pode fazer login como root e depois executar `faillock --reset --user [your-username]`. Isso vai limpar o bloqueio, e está tudo resolvido.

### Minha senha é aceita, mas eu volto para a tela de login

Um arquivo de ambiente de sessão quebrado pode impedir a área de trabalho de iniciar, mesmo quando sua senha está correta. Vale especialmente a pena verificar isso depois de editar `~/.config/uwsm/env.d/`.

Pressione `Ctrl + Alt + F2`, faça login com seu nome de usuário e senha normais e inspecione o journal do usuário da inicialização atual:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Procure um erro que mencione um dos seus arquivos de ambiente, como `bad substitution`, logo antes de uma mensagem dizendo que a marca de saída do env não foi encontrada. Mova esse arquivo para fora de `env.d` antes de tentar fazer login novamente. Por exemplo, se o erro mencionar `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

O UWSM ignora um arquivo com erro de sintaxe, mas um erro fatal que só aparece enquanto o arquivo é executado, como `bad substitution`, ainda pode impedir a área de trabalho de iniciar. Um rollback para um snapshot do sistema não repara esses arquivos, porque `/home` não é revertida.

Quando você conseguir fazer login, corrija a cópia salva antes de movê-la de volta. `sh -n` detecta erros de sintaxe sem executar o arquivo, mas não consegue detectar todos os erros que ocorrem quando ele é carregado via source. Mantenha um terminal funcionando aberto enquanto testa as alterações.

### Por que os prompts de autorização do 1Password para o 1Password SSH Agent / CLI não estão aparecendo?

Isso pode acontecer por 2 motivos:

Para o prompt de aprovação completo aparecer, Settings > Advanced > Use Hardware Acceleration precisa estar ativado. _Nota: Isso requer uma reinicialização para começar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou, se você não abriu o 1Password desde que ligou o computador, o prompt não vai aparecer.
