# Plan: Suporte Completo ao Idioma Português do Brasil (pt-BR)

## 1. Visão Geral & Objetivo

Tornar o **Omarchy** nativamente amigável e completamente localizado para usuários e desenvolvedores que utilizam o Português do Brasil (pt-BR), cobrindo:
1. **Ambiente do Sistema & Terminal:** Locales (`pt_BR.UTF-8`), timezone (`America/Sao_Paulo` ou seleção guiada), layout de teclado (`br-abnt2` e variantes) no console (`vconsole.conf`), XKB e Hyprland.
2. **Quickshell Desktop & Menus:** Criação da camada de localização dos menus (`omarchy-menu.jsonc`), permitindo que rótulos e descrições sejam exibidos em pt-BR com preservação das ações e comandos subjacentes.
3. **CLI & Utilitários de Gerenciamento:** Criação do comando `omarchy locale set pt-br` (ou `omarchy-locale-set`) e integração de seleção no menu `Setup > Localization`.
4. **Preservação de Invariantes:** Manter compatibilidade com atalhos baseados em Latin-keysym no Hyprland (`SUPER + W`, etc.) e contratos com scripts que dependem de saídas numéricas ou POSIX.

---

## 2. Análise de Impacto por Componente

### A. Console, Sistema e XKB (Base OS)
- **`/etc/locale.gen` e `/etc/locale.conf`:** Adição e compilação de `pt_BR.UTF-8 UTF-8` via `locale-gen` quando selecionado.
- **`/etc/vconsole.conf`:**
  - `KEYMAP=br-abnt2`
  - `XKBLAYOUT=br`
  - `XKBVARIANT=abnt2` (ou nativo).
- **Hyprland (`default/hypr/input.lua`):** Já lê dinamicamente `vconsole.XKBLAYOUT` e `vconsole.XKBVARIANT`. Como o layout `br` utiliza alfabeto latino, as teclas de atalho globais (`SUPER + <tecla>`) permanecem totalmente funcionais sem necessidade de prefixar com `us,`.
- **Cedilha no XCompose / GTK:** Usuários com teclado US-International no Brasil necessitam do compose para cedilha (`+c = ç`). Omarchy já possui `install/user/xcompose.sh` que deve garantir suporte à acentuação e cedilha.

### B. Menus e UI do Quickshell (`omarchy-menu.jsonc` & `Menu.qml`)
- O arquivo de menu `default/omarchy/omarchy-menu.jsonc` atualmente possui strings estáticas em inglês.
- **Estratégia de Internacionalização (i18n):**
  - O Omarchy permite extensões em `~/.config/omarchy/extensions/omarchy-menu.jsonc` ou o carregamento por localidade:
  - Adição de catálogo localizado `default/omarchy/omarchy-menu.pt_BR.jsonc` ou suporte a dicionário de tradução nos loaders do Quickshell.
  - Alternativamente, criar um catálogo declarativo onde cada item pode ter chave de tradução, ou carregar fallback de acordo com a variável `LANG`.

### C. Comandos CLI e Seleção Interativa
- Criação dos utilitários:
  - `bin/omarchy-locale-set`: Permite alterar locale do sistema de forma segura via `localectl` e `locale-gen`.
  - `bin/omarchy-keyboard-set`: Permite escolher layout de teclado (`br-abnt2`, `us-intl`, etc.) com persistência imediata em `/etc/vconsole.conf` e recarga no Hyprland.
  - `bin/omarchy-menu-keyboard`: Menu interativo estilo `omarchy-menu-timezone` para trocar o layout em tempo real.

---

## 3. Plano de Implementação em Fases

### Fase 1: Utilitários CLI de Configuração de Idioma & Teclado
- Criar `bin/omarchy-keyboard-set` e `bin/omarchy-menu-keyboard`.
- Atualizar `bin/omarchy` (`GROUP_DESCRIPTIONS`) se novos grupos forem expostos.
- Criar ou ajustar script de persistência para `localectl` e geração de `pt_BR.UTF-8`.

### Fase 2: Configuração de Teclado no Hyprland & XCompose
- Validar comportamento do `br-abnt2` e `us-intl` com `input.lua`.
- Assegurar que `install/user/xcompose.sh` e `.XCompose` incluam os atalhos de acentuação pt-BR.

### Fase 3: Localização dos Menus do Quickshell
- Criar a versão em português dos menus principais: `omarchy-menu.pt_BR.jsonc` (Apps, Aprender, Disparar, Estilo, Configurações, Instalar, Remover, Atualizar, Sistema).
- Adaptar o carregador do `Menu.qml` para verificar `LANG` / configuração do usuário antes de recorrer ao padrão em inglês.

### Fase 4: Verificação e Testes
- Testar roteamento do CLI com `./test/cli`.
- Validar se `./test/shell` continua passando sem regressões.
