# Resolução de problemas

### Parti o meu sistema com uma atualização!

Primeiro, tenta [reverter o teu sistema](47-system-snapshots.md) para a versão anterior à tua atualização recente. Se isso não resultar, usa `omarchy-debug` para partilhares o teu problema no #omarchy-help no Discord. E se tudo isso falhar, podes reinstalar as configurações e os pacotes predefinidos com `omarchy-reinstall`.

### Porque é que algumas aplicações aparecem tão grandes no meu ecrã?

O Omarchy parte do princípio de que tens um ecrã de alta resolução 2x, por isso define `GDK_SCALE` como 2 até escolheres uma escala no painel do monitor. Se estiveres num ecrã 1x e as aplicações GTK ou X11 aparecerem sobredimensionadas, escolhe 1x para ele no painel do monitor, ou adiciona `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (e depois reinicia qualquer aplicação que esteja sobredimensionada). Consulta [o manual sobre monitores](33-monitors.md).

No Spotify, podes usar `Ctrl + Minus` para reduzir a interface (e `Ctrl + Plus` para a aumentar).

### Porque é que todos os meus atalhos com a tecla Super deixaram de funcionar?

Em alguns portáteis ASUS ROG e TUF, `Fn + Super` é uma combinação fácil de passar despercebida que ativa e desativa um bloqueio da tecla Windows ao nível do firmware (pensado para jogar, para não saíres de um jogo por acidente). Nada no ecrã te diz que isso aconteceu. Enquanto o bloqueio estiver ativo, o Super não emite absolutamente nada — por isso, todos os atalhos do Omarchy que usam Super simplesmente param, e parece que o Hyprland se partiu.

Prime `Fn + Super` uma vez antes de ires escavar em `~/.config/hypr/`, e se isso não trouxer o Super de volta, prime-a outra vez para não deixares o bloqueio ativo. Isto não é o Fn-lock, que só muda o comportamento da fila de teclas F.

### O meu Wi-Fi, Bluetooth, áudio ou trackpad deixou simplesmente de funcionar

Antes de reiniciares, tenta reiniciar sozinho o subsistema problemático. _Update > Hardware_ no menu do Omarchy tem Wi-Fi, Bluetooth, Áudio e Trackpad, e recarregar um deles resolve a maioria das situações do género "estava a funcionar há cinco minutos" — uns auscultadores Bluetooth que não voltam a ligar, um trackpad que morreu depois de uma suspensão, som que desapareceu quando desligaste um monitor.

### Porque é que as minhas colunas externas não estão a tocar?

Provavelmente porque não estão definidas como a saída principal. Clica no ícone da coluna no lado direito da barra, e vai abrir o pop-up de volume onde podes escolher o dispositivo de saída (e ajustar também os volumes por aplicação).

### As colunas do meu portátil têm um som estranho

Em alguns portáteis, o Omarchy aplica automaticamente um ajuste das colunas que corrige a resposta de frequência das colunas incorporadas. `omarchy audio tuning status` diz-te se algum está ativo na tua máquina, e `omarchy audio tuning off` desliga-o se preferires ouvir as colunas sem qualquer correção.

### Porque é que não consigo iniciar sessão ou usar sudo com a minha palavra-passe?

Provavelmente escreveste-a mal vezes demais e ficaste bloqueado. Se isto estiver a acontecer no ecrã de bloqueio, podes carregar em `CTRL + ALT + F2` para iniciar um novo TTY onde podes iniciar sessão como root, e depois executar `faillock --reset --user [your-username]`. Isso vai repor o bloqueio, e estás pronto a seguir.

### A minha palavra-passe é aceite, mas volto ao ecrã de início de sessão

Um ficheiro de ambiente de sessão danificado pode impedir o ambiente de trabalho de arrancar mesmo quando a tua palavra-passe está correta. Isto vale especialmente a pena verificar depois de editares `~/.config/uwsm/env.d/`.

Prime `Ctrl + Alt + F2`, inicia sessão com o teu nome de utilizador e palavra-passe habituais, e inspeciona o jornal do utilizador do arranque atual:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Procura um erro que nomeie um dos teus ficheiros de ambiente, como `bad substitution`, mesmo antes de uma mensagem a dizer que a marca de saída do env não foi encontrada. Move esse ficheiro para fora de `env.d` antes de tentares iniciar sessão outra vez. Por exemplo, se o erro nomear `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

O UWSM ignora um ficheiro com um erro de sintaxe, mas um erro fatal que só aparece enquanto o ficheiro está a ser executado, como `bad substitution`, pode mesmo assim impedir o ambiente de trabalho de arrancar. Uma reversão para um instantâneo do sistema não repara estes ficheiros, porque `/home` não é revertido.

Assim que conseguires iniciar sessão, corrige a cópia guardada antes de a voltares a colocar no sítio. `sh -n` apanha erros de sintaxe sem executar o ficheiro, mas não consegue apanhar todos os erros que ocorrem quando ele é carregado. Mantém um terminal funcional aberto enquanto testas as alterações.

### Porque é que não aparecem os pedidos de autorização do 1Password para o 1Password SSH Agent / CLI?

Isto pode acontecer por 2 motivos:

Para que o pedido de aprovação completo apareça, Settings > Advanced > Use Hardware Acceleration tem de estar ativado. _Nota: Isto requer um reinício para começar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou, se não tiveres lançado o 1Password desde que ligaste o computador, o pedido não vai aparecer.
