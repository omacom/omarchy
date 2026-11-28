# Resolução de problemas

### Estraguei o meu sistema com uma atualização!

Primeiro, tenta [reverter o sistema](47-system-snapshots.md) para a versão anterior à tua atualização recente. Se isso não funcionar, usa `omarchy-debug` para partilhares o teu problema no #omarchy-help no Discord. E se tudo isso falhar, podes reinstalar as configurações e os pacotes predefinidos com `omarchy-reinstall`.

### Porque é que algumas aplicações aparecem tão grandes no meu ecrã?

O Omarchy parte do princípio de que tens um ecrã de alta resolução 2x, por isso define `GDK_SCALE` como 2 até escolheres uma escala no painel do monitor. Se estiveres num ecrã 1x e as aplicações GTK ou X11 aparecerem sobredimensionadas, escolhe 1x para ele no painel do monitor, ou adiciona `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (e depois reinicia qualquer aplicação que esteja sobredimensionada). Consulta [o manual sobre monitores](33-monitors.md).

Para o Spotify, podes usar `Ctrl + Minus` para encolher a interface (e `Ctrl + Plus` para a aumentar).

### Porque é que todos os meus atalhos com a tecla Super deixaram de funcionar?

Em alguns portáteis ASUS ROG e TUF, `Fn + Super` é uma combinação que passa facilmente despercebida e que liga e desliga um bloqueio da tecla Windows no firmware (pensado para jogar, para não saíres de um jogo por acidente). Não aparece nada no ecrã a indicar que isso aconteceu. Enquanto o bloqueio estiver ligado, a Super não emite absolutamente nada — por isso, todos os atalhos do Omarchy que usam Super simplesmente deixam de funcionar, e parece que foi o Hyprland que avariou.

Prime `Fn + Super` uma vez antes de ires mexer em `~/.config/hypr/` e, se isso não fizer a Super voltar, prime-a outra vez para não deixares o bloqueio ligado. Isto não é o Fn-lock, que só altera o que a linha de teclas F faz.

### O meu Wi-Fi, Bluetooth, áudio ou trackpad deixou simplesmente de funcionar

Antes de reiniciares, tenta reiniciar isoladamente o subsistema que está a dar problemas. _Update > Hardware_ no menu do Omarchy tem Wi-Fi, Bluetooth, Audio e Trackpad, e recarregar um deles resolve a maioria das situações "estava a funcionar há cinco minutos" — uns auscultadores Bluetooth que não voltam a ligar-se, um trackpad que deixou de responder depois de uma suspensão, o som que desapareceu quando desligaste um monitor.

### Porque é que as minhas colunas externas não estão a reproduzir som?

Provavelmente porque não estão definidas como a saída principal. Clica no ícone da coluna no lado direito da barra e vai abrir-se o popup de volume, onde podes escolher o dispositivo de saída (e também ajustar os volumes por aplicação).

### As colunas do meu portátil soam estranhas

Em alguns portáteis, o Omarchy aplica automaticamente um ajuste às colunas que corrige a resposta de frequência das colunas integradas. `omarchy audio tuning status` indica-te se está algum ativo na tua máquina, e `omarchy audio tuning off` desliga-o se preferires ouvir as colunas sem qualquer ajuste.

### Porque é que não consigo iniciar sessão nem usar sudo com a minha palavra-passe?

Provavelmente escreveste-a mal dez vezes e ficaste bloqueado. O bloqueio desaparece por si só ao fim de dois minutos. Se não puderes esperar, e isto estiver a acontecer no ecrã de bloqueio, podes premir `CTRL + ALT + F2` para abrir um novo TTY onde podes iniciar sessão como root e depois executar `faillock --reset --user [your-username]`. Isso vai limpar o bloqueio e estás pronto.

### A minha palavra-passe é aceite, mas volto ao ecrã de início de sessão

Um ficheiro de ambiente de sessão danificado pode impedir o ambiente de trabalho de arrancar, mesmo quando a tua palavra-passe está correta. Vale especialmente a pena verificar isto depois de editares `~/.config/uwsm/env.d/`.

Prime `Ctrl + Alt + F2`, inicia sessão com o teu nome de utilizador e a tua palavra-passe habituais e inspeciona o journal de utilizador do arranque atual:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Procura um erro que nomeie um dos teus ficheiros de ambiente, como `bad substitution`, logo antes de uma mensagem a dizer que a marca de saída do env não foi encontrada. Move esse ficheiro para fora de `env.d` antes de voltares a tentar iniciar sessão. Por exemplo, se o erro nomear `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

O UWSM ignora um ficheiro com um erro de sintaxe, mas um erro fatal que só surge enquanto o ficheiro está a ser executado, como `bad substitution`, pode ainda assim impedir o ambiente de trabalho de arrancar. Reverter para um snapshot do sistema não repara estes ficheiros, porque `/home` não é incluído na reversão.

Assim que conseguires iniciar sessão, corrige a cópia guardada antes de a voltares a mover para o lugar. `sh -n` deteta erros de sintaxe sem executar o ficheiro, mas não consegue detetar todos os erros que ocorrem quando ele é carregado. Mantém aberto um terminal que esteja a funcionar enquanto testas alterações.

### Porque é que não aparecem os meus pedidos de autorização do 1Password para o 1Password SSH Agent / CLI?

Isto pode acontecer por 2 razões:

Para o pedido de aprovação completo aparecer, Settings > Advanced > Use Hardware Acceleration tem de estar ativado. _Nota: Isto requer um reinício para começar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou, se não tiveres iniciado o 1Password desde o arranque, o pedido não vai aparecer.
