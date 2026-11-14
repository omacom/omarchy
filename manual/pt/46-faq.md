# FAQ

### Como alterno entre esquemas de teclado?

Edite o ficheiro `~/.config/hypr/input.lua` e adicione isto para alternar entre esquemas com `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

A barra mostrará automaticamente o esquema de teclado atual assim que tiver vários esquemas configurados (e também pode clicar nela para alternar).

### Como mudo o formato do relógio para 12 horas?

Clique com o botão direito do rato no relógio na barra para percorrer os formatos comuns, incluindo os de 12 horas. Também pode definir o formato diretamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Isto apresentará domingo 10:55 AM.

### Como mudo o meu fuso horário?

Execute _Atualizar > Fuso Horário_ no menu do Omarchy e escolha a partir da lista. Se o fuso horário estiver certo mas o próprio relógio tiver dessincronizado, _Atualizar > Hora_ reinicia a sincronização da hora por si.

### Como mudo o meu DNS, partilho o meu Wi-Fi ou verifico a velocidade da minha ligação?

Tudo isso está em [redes](35-networking.md).

### Como verifico a velocidade do meu disco?

_Ativar > Teste de Velocidade > Teste de Velocidade do Disco_ mede a velocidade de leitura e escrita em tempo real na sua unidade, ou `omarchy disk speedtest` a partir do terminal.

### Como adiciono uma impressora?

A impressão está configurada e a funcionar logo de origem, e adiciona cada impressora a partir de _Definições de Impressão_ no lançador de aplicações (`Super + Space`).

Escolha _Adicionar_ e aguarde um momento enquanto procura: uma impressora ligada por USB, e a maioria das impressoras de rede, são encontradas por si. Se a sua não estiver na lista, escolha _Impressora de Rede > Internet Printing Protocol (ipp)_ e introduza o seu endereço — o próprio ecrã da impressora ou a sua página web indicar-lhe-á qual é, normalmente algo como `192.168.1.50` com uma fila de `ipp/print`. _Avançar_ apresenta então um controlador, em que uma impressora moderna funciona melhor com o perfil sem controlador _IPP Everywhere_ e uma mais antiga prefere o controlador próprio do modelo.

Clique com o botão direito do rato numa impressora e escolha _Definir como Predefinida_ para escolher aquela a que as suas aplicações recorrem primeiro, e _Propriedades_ para definir o tamanho do papel, duplex e qualidade.

A descoberta automática, em que as impressoras na rede aparecem sem serem adicionadas, está temporariamente desativada enquanto está a ser reformulada, razão pela qual o primeiro passo acima é seu em vez de automático. Imprimir para um ficheiro PDF funciona sem qualquer impressora.

### Como mudo onde são guardadas as capturas de ecrã ou as gravações de ecrã?

As capturas de ecrã guardadas vão para `~/Pictures/Screenshots` por predefinição. Para utilizar outro diretório, adicione isto a um ficheiro em `~/.config/uwsm/env.d/` (como `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Pode fazer o mesmo para as gravações de ecrã utilizando `OMARCHY_SCREENRECORD_DIR`.

O Omasnap cria automaticamente o seu diretório de capturas de ecrã. Crie o diretório de gravações de ecrã e, em seguida, reinicie o Omarchy para que qualquer uma das alterações ao ambiente entre em vigor.

### Como ponho as colunas + webcam a funcionar no meu Apple Studio Display?

Pensaria que devia funcionar tudo ligando apenas por USB C, mas infelizmente não é o caso. A solução que encontrei para pôr tudo a funcionar de forma fiável é utilizar [o cabo WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Depois, as colunas e a webcam funcionam às mil maravilhas.

Lembre-se de que tem controlo de brilho integrado no Omarchy para os ecrãs Apple (tanto o Studio como o XDR) utilizando os botões normais de brilho do teclado.

### Como me livro de todo o software extra?

Se não quiser programas como o Obsidian ou o LibreOffice ou qualquer outro material pré-instalado, pode removê-lo muito facilmente.

Execute _Remover > Pacote_ para ver todos os pacotes instalados. Depois, pode selecionar qualquer pacote que pretenda remover com tab, e começar a remover tudo o que selecionou com return.

E pode utilizar _Remover > Aplicação Web_ a partir do menu do Omarchy para remover qualquer uma das aplicações web pré-instaladas que não queira.

Ou execute _Remover > Pré-instalados_ para varrer todos os extras pré-instalados — aplicações web, TUIs, e aplicações opcionais — de uma só vez. As teclas de atalho que as lançavam desaparecem com eles, pelo que fica com uma folha limpa de atalhos para preencher com os seus em `~/.config/hypr/bindings.lua`.

---

Para erros e coisas avariadas, consulte [a secção de Resolução de Problemas](45-troubleshooting.md).
