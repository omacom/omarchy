# FAQ

### Como alterno entre disposições de teclado?

Edite o ficheiro `~/.config/hypr/input.lua` e adicione isto para alternar entre disposições com `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

A barra vai mostrar automaticamente a disposição de teclado atual assim que tiver várias disposições configuradas (e também pode clicar nela para alternar).

### Como altero o formato do relógio para 12 horas?

Clique com o botão direito no relógio na barra para percorrer os formatos comuns, incluindo os de 12 horas. Também pode definir o formato diretamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Isto vai mostrar Domingo 10:55 AM.

### Como altero o fuso horário?

Execute _Setup > Region > Timezone_ no menu do Omarchy e escolha um da lista. Se o fuso horário estiver certo mas o próprio relógio estiver desfasado, _Update > Time_ reinicia a sincronização da hora por si.

### Como altero o DNS, partilho o Wi-Fi ou verifico a velocidade da ligação?

Está tudo em [rede](35-networking.md).

### Como verifico a velocidade do disco?

_Trigger > Speed Test > Disk Speed Test_ mede a velocidade de leitura e escrita em tempo real no disco, ou `omarchy disk speedtest` a partir do terminal.

### Como adiciono uma impressora?

A impressão está configurada e a funcionar logo de origem, e adiciona cada impressora manualmente a partir de _Print Settings_ no lançador de aplicações (`Super + Alt + Space`).

Escolha _Add_ e dê-lhe um momento para procurar: uma impressora ligada por USB, e a maioria das impressoras de rede, são encontradas por si. Se a sua não estiver na lista, escolha _Network Printer > Internet Printing Protocol (ipp)_ e introduza o endereço dela — o próprio ecrã da impressora ou a respetiva página web indica-lhe qual é, normalmente algo como `192.168.1.50` com uma fila de `ipp/print`. _Forward_ apresenta então um controlador, em que uma impressora moderna funciona melhor com o perfil sem controlador _IPP Everywhere_ e uma mais antiga prefere o controlador próprio do modelo.

Clique com o botão direito numa impressora e escolha _Set as Default_ para definir qual é a primeira que as aplicações procuram, e _Properties_ para definir o tamanho do papel, o duplex e a qualidade.

A descoberta automática, em que as impressoras na rede aparecem sem serem adicionadas, está temporariamente desligada enquanto está a ser reformulada, e é por isso que o primeiro passo acima é seu e não automático. Imprimir para um ficheiro PDF funciona sem nenhuma impressora.

### Como altero onde são guardadas as capturas de ecrã ou as gravações de ecrã?

As capturas de ecrã guardadas vão para `~/Pictures/Screenshots` por predefinição. Para utilizar outro diretório, adicione isto a um ficheiro em `~/.config/uwsm/env.d/` (como `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Pode fazer o mesmo para as gravações de ecrã utilizando `OMARCHY_SCREENRECORD_DIR`.

O Omasnap cria automaticamente o respetivo diretório de capturas de ecrã. Crie manualmente o diretório de gravações de ecrã e depois reinicie o Omarchy para qualquer uma das alterações ao ambiente entrar em vigor.

### Como ponho as colunas + a webcam a funcionar no Apple Studio Display?

Seria de pensar que bastava ligar por USB C para tudo funcionar, mas infelizmente não é o caso. A solução que encontrei para pôr tudo a funcionar de forma fiável é utilizar [o cabo WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Depois, as colunas e a webcam funcionam que é uma maravilha.

Lembre-se de que tem controlo de brilho integrado no Omarchy para os ecrãs Apple (tanto o Studio como o XDR) utilizando os botões normais de brilho do teclado.

### Como me livro de todo o software extra?

Se não quiser programas como o Obsidian ou o LibreOffice ou qualquer outro material pré-instalado, pode removê-lo muito facilmente.

Execute _Remove > Package_ para ver todos os pacotes instalados. Depois pode selecionar qualquer pacote que queira remover com tab e começar a remover tudo o que selecionou com return.

E pode utilizar _Remove > Web App_ a partir do menu do Omarchy para remover qualquer uma das aplicações web pré-instaladas que não queira.

Ou execute _Remove > Preinstalls_ para varrer todos os extras pré-instalados — aplicações web, TUIs e aplicações opcionais — de uma só vez. Os atalhos de teclado que as lançavam desaparecem com elas, pelo que fica com as associações de teclas em branco para preencher com as suas em `~/.config/hypr/bindings.lua`.

---

Para erros e avarias, consulte [a secção de Resolução de problemas](45-troubleshooting.md).
