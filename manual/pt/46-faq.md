# Perguntas frequentes

### Como alterno entre esquemas de teclado?

Edite o seu ficheiro `~/.config/hypr/input.lua` e adicione isto para alternar entre esquemas com `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

A barra mostrará automaticamente o seu esquema de teclado atual assim que tiver vários esquemas configurados (e também pode clicar nela para alternar).

### Como mudo o formato do relógio para 12 horas?

Clique com o botão direito no relógio da barra para percorrer os formatos comuns, incluindo os de 12 horas. Também pode definir o formato diretamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Isto mostrará Sunday 10:55 AM.

### Como mudo o meu fuso horário?

Execute _Atualizar > Fuso horário_ no menu Omarchy e escolha da lista. Se o fuso horário estiver certo, mas o próprio relógio tiver derivado, _Atualizar > Hora_ reinicia a sincronização da hora por si.

### Como mudo o meu DNS, partilho o meu Wi-Fi ou verifico a velocidade da minha ligação?

Isso vive tudo em [rede](35-networking.md).

### Como verifico quão rápido é o meu disco?

_Acionar > Teste de velocidade > Velocidade do disco_ mede a velocidade de leitura e escrita em tempo real da sua unidade, ou `omarchy disk speedtest` a partir do terminal.

### Porque é que não consigo entrar na minha conta Google no Chromium?

A versão simples de código aberto do Chromium não traz as credenciais OAuth que a Google exige para o início de sessão na conta. Execute _Instalar > Serviço > Conta Chromium_ no menu Omarchy para as adicionar, reinicie o navegador e o início de sessão passará.

### Como adiciono uma impressora?

A impressão está configurada e a funcionar de origem, e adiciona cada impressora por si a partir de _Definições de Impressão_ no lançador de aplicações (`Super + Space`).

Escolha _Adicionar_ e dê-lhe um momento para procurar: uma impressora ligada por USB, e a maioria das impressoras de rede, são encontradas por si. Se a sua não estiver na lista, escolha _Impressora de Rede > Internet Printing Protocol (ipp)_ e introduza o seu endereço — o próprio ecrã da impressora ou a sua página web dir-lhe-ão qual é, normalmente algo como `192.168.1.50` com uma fila de `ipp/print`. _Avançar_ oferece então um driver, onde uma impressora moderna funciona melhor com o perfil sem driver _IPP Everywhere_ e uma mais antiga quer o driver do próprio modelo.

Clique com o botão direito numa impressora e escolha _Definir como Predefinida_ para escolher aquela a que as suas aplicações recorrem primeiro, e _Propriedades_ para definir o tamanho do papel, a frente e verso e a qualidade.

A descoberta automática, em que as impressoras na rede aparecem sem serem adicionadas, está temporariamente desligada enquanto é reformulada, e é por isso que o primeiro passo acima é seu, e não automático. Imprimir para um ficheiro PDF funciona sem impressora nenhuma.

### Como mudo onde as capturas de ecrã ou gravações de ecrã são guardadas?

As capturas de ecrã guardadas vão para `~/Pictures/Screenshots` por predefinição. Para usar outro diretório, adicione isto a um ficheiro em `~/.config/uwsm/env.d/` (como `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Pode fazer o mesmo para gravações de ecrã usando `OMARCHY_SCREENRECORD_DIR`.

O Omasnap cria automaticamente o seu diretório de capturas de ecrã. Crie o diretório de gravação de ecrã por si e depois reinicie o Omarchy para qualquer das alterações ao ambiente produzir efeito.

### Como faço funcionar as colunas e a webcam no meu Apple Studio Display?

Seria de pensar que tudo funcionaria bastando ligar o USB C, mas infelizmente não é esse o caso. A solução que encontrei para o fazer funcionar de forma fiável é usar [o cabo WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Depois as colunas e a webcam funcionam às mil maravilhas.

Lembre-se de que tem controlo de brilho integrado no Omarchy para os ecrãs da Apple (tanto o Studio como o XDR) usando os botões normais de brilho do teclado.

### Como me livro de todo o software extra?

Se não quiser programas como o Obsidian ou o LibreOffice ou qualquer outro material pré-instalado, pode removê-lo muito facilmente.

Execute _Remover > Pacote_ para ver todos os pacotes instalados. Depois pode selecionar qualquer pacote que queira remover com tab, e começar a remover tudo o que selecionou com return.

E pode usar _Remover > App Web_ a partir do menu Omarchy para remover qualquer app web pré-instalada que não queira.

Ou execute _Remover > Pré-instaladas_ para varrer todos os extras pré-instalados — apps web, TUI e aplicações opcionais — de uma só vez. Os atalhos que as lançavam desaparecem com elas, por isso fica com uma folha limpa de associações para preencher com as suas em `~/.config/hypr/bindings.lua`.

---

Para erros e coisas estragadas, veja [a secção de Resolução de problemas](45-troubleshooting.md).
