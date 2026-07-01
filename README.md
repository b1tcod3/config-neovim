# Configuración Neovim

Mi configuración personal de Neovim para desarrollo web (PHP/Laravel, Python, Rust, Lua) y programación general.

## Requisitos

- **Neovim 0.11+** — usa la API nativa de LSP (`vim.lsp.config`, `vim.lsp.enable`)
- **Git** — para clonar el repositorio y que lazy.nvim instale plugins
- **Nerd Font** — para los iconos en lualine, bufferline, nvim-tree, etc.
- **Terminal con true color** — necesario para el theme Tokyo Night

## Instalación

```bash
git clone https://github.com/b1tcod3/config-neovim.git ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
```

Al abrir Neovim, lazy.nvim descarga todos los plugins automáticamente. Mason instala los LSP servers en segundo plano.

### Post-instalación

Ejecuta estos comandos dentro de Neovim para completar la configuración:

```vim
:TSUpdate        " Descarga los parsers de Treesitter
:Mason           " Verifica que los LSP servers estén instalados
:checkhealth     " Diagnóstico completo del sistema
```

---

## Estructura del proyecto

```
~/.config/nvim/
├── init.lua                  # Entry point
├── lazy-lock.json            # Lock de versiones de plugins
├── .gitignore                # Archivos ignorados por git
├── lua/
│   ├── core/
│   │   ├── options.lua       # Opciones globales de Neovim
│   │   ├── keymaps.lua       # Atajos de teclado
│   │   ├── autocmds.lua      # Auto-comandos (eventos)
│   │   └── php-namespace.lua # Inserción automática de namespace PHP
│   └── plugins/
│       └── init.lua          # Declaración y configuración de plugins
└── after/
    ├── ftplugin/             # Configuración por tipo de archivo
    └── plugin/               # Plugins post-carga
```

---

## init.lua — Entry point

```lua
-- ~/.config/nvim/init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")
require("core.keymaps")
require("core.autocmds")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
```

| Línea | Explicación |
|-------|-------------|
| `mapleader = " "` | Define `<Space>` como tecla líder |
| `maplocalleader = " "` | `<Space>` también como líder local |
| `require("core.*")` | Carga options, keymaps y autocmds |
| `lazypath` | Ruta donde se instala lazy.nvim (~/.local/share/nvim/lazy/lazy.nvim) |
| `vim.loop.fs_stat` | Verifica si lazy.nvim ya está instalado; si no, lo clona |
| `vim.opt.rtp:prepend` | Agrega lazy.nvim al runtimepath antes de `setup()` |
| `require("lazy").setup("plugins")` | Inicializa lazy.nvim con la configuración de `lua/plugins/init.lua` |

---

## lua/core/options.lua — Opciones de Neovim

```lua
local opt = vim.opt

opt.number = true              -- Números de línea
opt.relativenumber = true      -- Números relativos
opt.encoding = "utf-8"         -- Codificación UTF-8
opt.tabstop = 4                -- Un tab = 4 espacios
opt.shiftwidth = 4             -- Indentación = 4 espacios
opt.autoindent = true          -- Indentar automáticamente
opt.expandtab = true           -- Tab → espacios
opt.backup = false             -- Sin archivos .bak
opt.writebackup = false
opt.swapfile = false           -- Sin archivos .swp
opt.updatetime = 300           -- Actualización cada 300ms (útil para diagnosticos LSP)
opt.clipboard = "unnamedplus"  -- Copia al portapapeles del sistema
opt.signcolumn = "yes"         -- Columna de signos siempre visible
opt.termguicolors = true       -- True color
opt.cursorline = true          -- Resaltar línea del cursor

-- Reconocer archivos *.blade.php como tipo 'blade'
vim.filetype.add({
  pattern = { ['.*%.blade%.php'] = 'blade' },
})
```

### Autocomandos en options.lua

- **Restaurar cursor**: al abrir un archivo, posiciona el cursor donde estaba la última vez.
- **Fold cerrado**: ejecuta `zM` al abrir archivos (todos los folds cerrados inicialmente).

---

## lua/core/keymaps.lua — Atajos de teclado

| Modo | Atajo | Acción | Descripción |
|------|-------|--------|-------------|
| **Guardado** | | | |
| n | `<Leader>w` | `:w` | Guardar archivo |
| n | `<Leader>wa` | `:wa` | Guardar todos |
| n | `<Leader>wq` | `:wq` | Guardar y salir |
| n | `<Leader>qq` | `:q` | Salir |
| n | `<Leader>q!` | `:q!` | Forzar salida |
| n,i | `<C-s>` | `:w` | Guardar (modos normal e insert) |
| **Explorador** | | | |
| n | `<Leader>e` | `:NvimTreeToggle` | NvimTree (explorador de archivos) |
| n | `<Leader>nt` | `:NvimTreeToggle` | Toggle NvimTree |
| **Telescope** | | | |
| n | `<Leader>ff` | `find_files()` | Buscar archivos |
| n | `<Leader>fg` | `live_grep()` | Buscar contenido |
| n | `<Leader>fb` | `buffers()` | Buscar buffers abiertos |
| n | `<Leader>fh` | `help_tags()` | Buscar en ayuda |
| **Navegación** | | | |
| n | `<A-n>` | `:tabnext` | Pestaña siguiente |
| n | `<A-p>` | `:tabprevious` | Pestaña anterior |
| n | `<C-n>` | `:bnext` | Buffer siguiente |
| n | `<C-p>` | `:bprevious` | Buffer anterior |
| n | `<Leader>bn` | `:bnext` | Buffer siguiente |
| n | `<Leader>bp` | `:bprevious` | Buffer anterior |
| n | `<Leader>wd` | `:bdelete` | Cerrar buffer |
| n | `<Leader><PageUp>` | `:bprevious` | Buffer anterior |
| n | `<Leader><PageDown>` | `:bnext` | Buffer siguiente |
| **LSP** | | | |
| n | `gd` | `vim.lsp.buf.definition` | Ir a definición |
| n | `gr` | `vim.lsp.buf.references` | Ver referencias |
| n | `gi` | `vim.lsp.buf.implementation` | Ir a implementación |
| n | `gy` | `vim.lsp.buf.type_definition` | Ir a definición de tipo |
| n | `K` | `vim.lsp.buf.hover` | Mostrar documentación |
| n | `<Leader>rn` | `vim.lsp.buf.rename` | Renombrar símbolo |
| n,v | `<Leader>ca` | `vim.lsp.buf.code_action` | Code action / Importar clase |
| **Folding (Ufo)** | | | |
| n | `zR` | `ufo.openAllFolds()` | Abrir todos los folds |
| n | `zM` | `ufo.closeAllFolds()` | Cerrar todos los folds |
| n | `zr` | `ufo.openFoldsExceptKinds()` | Abrir excepto funciones |
| n | `zm` | `ufo.closeFoldsWith()` | Cerrar folds |
| n | `zj` | `ufo.goNextClosedFold()` | Fold siguiente |
| n | `zk` | `ufo.goPreviousClosedFold()` | Fold anterior |
| **Todo Comments** | | | |
| n | `<Leader>tt` | `:TodoTelescope` | Buscar TODOs |
| n | `]t` | `todo-comments next` | TODO siguiente |
| n | `[t` | `todo-comments prev` | TODO anterior |
| **Aerial** | | | |
| n | `<Leader>ao` | `:AerialToggle! right` | Toggle navegador de símbolos |
| **Comentarios** | | | |
| n | `<Leader>cc` | `Comment toggle linewise` | Comentar línea |
| n | `<Leader>cb` | `Comment toggle blockwise` | Comentar bloque |
| v | `<Leader>c` | `:Commentary` | Comentar selección |
| **EasyAlign** | | | |
| n,x | `ga` | `<Plug>(EasyAlign)` | Alinear código |
| **mini.pairs** | | | |
| n | `<Leader>tp` | toggle function | Activar/desactivar pares automáticos |

---

## lua/core/autocmds.lua — Auto-comandos

```lua
local php_ns = require("core.php-namespace")

-- Al guardar archivos .php, inserta namespace si no existe
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.php",
  callback = function()
    php_ns.auto_namespace()
  end,
})

-- Al guardar cualquier archivo, crea directorios padres si no existen
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local dir = vim.fn.expand("%:p:h")
    if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})
```

| Evento | Patrón | Acción |
|--------|--------|--------|
| `BufWritePre` | `*.php` | Inserta namespace PSR-4 automático (si no existe) |
| `BufWritePre` | `*` | Crea directorios padres automáticamente |

---

## lua/core/php-namespace.lua — Namespace automático PHP

Este módulo implementa la inserción automática de `namespace ...;` en archivos PHP según las reglas PSR-4 definidas en `composer.json`.

### Flujo de `auto_namespace()`:

```
1. ¿Es archivo PHP?           → No → return
2. ¿Ya tiene namespace?        → Sí → return (no duplicar)
3. Buscar composer.json        → No → return
4. Leer autoload.psr-4         → No → return
5. Computar namespace          → No → return
6. Insertar línea namespace
```

### Función `compute_namespace(filepath, root, mappings)`

Toma la ruta relativa del archivo respecto al proyecto, la compara con los prefijos PSR-4 y construye el namespace.

**Ejemplo**: `app/Models/User.php` con `"App\\": "app/"` → `namespace App\Models;`

### Función `insert_namespace(namespace)`

Inserta la línea `namespace ...;` después de `<?php` (o después de `declare(...)` si existe), con una línea en blanco antes y después para formateo limpio.

---

## lua/plugins/init.lua — Plugins

| Plugin | Propósito | Configuración destacada |
|--------|-----------|------------------------|
| **tokyonight.nvim** | Tema oscuro Tokyo Night | `lazy = false, priority = 1000` — se carga primero |
| **noice.nvim** | UI moderna (cmdline, messages, notificaciones) | `bottom_search`, `command_palette`, mensajes de modo como notificación |
| **todo-comments.nvim** | Resalta y navega TODO, FIXME, HACK, etc. | Integrado con Telescope (`<Leader>tt`) |
| **mini.pairs** | Pares automáticos `()`, `[]`, `{}`, `""` | Toggleable con `<Leader>tp` |
| **nvim-ts-autotag** | Cierre automático de etiquetas HTML | Solo en insert mode para `.html`, `.php`, `.blade` |
| **nvim-ufo** | Folding con treesitter + indent | Vista plegada con icono y conteo de líneas; auto-open folds al entrar |
| **lualine.nvim** | Barra de estado minimalista | Configuración por defecto con devicons |
| **bufferline.nvim** | Pestañas de buffers con iconos | Offset para NvimTree |
| **nvim-tree.lua** | Explorador de archivos lateral | Muestra archivos ignorados por git (`git.ignore = false`) |
| **aerial.nvim** | Navegador de símbolos | Backends: treesitter + LSP, ancho mínimo 40 |
| **Comment.nvim** | Comentar/descomentar líneas y bloques | Atajos `gc` (visual), `<Leader>cc` (línea), `<Leader>cb` (bloque) |
| **copilot.vim** | GitHub Copilot | Sin configuración extra |
| **leap.nvim** | Navegación rápida tipo "jump anywhere" | Atajos `<Leader>s` / `<Leader>S` |
| **vim-easy-align** | Alinear código verticalmente | Atajo `ga` en normal y visual |
| **vim-be-good** | Minijuegos para practicar Vim | — |
| **mini.surround** | Añadir, borrar, cambiar rodeadores (`'`, `"`, `(`, `[`, `{`) | Carga inmediata |
| **vim-slint** | Soporte para Slint UI | — |
| **nvim-treesitter** | Parsers sintácticos + highlight + indent | 13 parsers: php, html, css, js, ts, rust, python, astro, lua, vim, etc. |
| **telescope.nvim** | Buscador fuzzy | Ignora node_modules, .git, dist, build |
| **nvim-lspconfig** | Configuración LSP nativa | Mason + blink.cmp + 8 servidores |
| **blink.cmp** | Autocompletado | Menú con Tab/Shift-Tab, fuentes: LSP + snippets + buffer |

### Servidores LSP instalados (via Mason)

| Servidor | Lenguaje | Configuración |
|----------|----------|---------------|
| `intelephense` | PHP | Usa `blink.cmp` para autocompletado |
| `pyright` | Python | Usa `blink.cmp` para autocompletado |
| `rust_analyzer` | Rust | Usa `blink.cmp` para autocompletado |
| `lua_ls` | Lua | Usa `blink.cmp` para autocompletado |
| `tailwindcss` | CSS/Tailwind | Autocompletado de clases, colores inline, linting |
| `astro` | Astro | Soporte nativo para componentes `.astro` |
| `emmet_ls` | HTML/Blade | Expansión de abreviaturas Emmet |
| `html` | HTML | Validación, hover, autocompletado de etiquetas |

### Blink.cmp — Autocompletado

- **Preset**: `"enter"` — Enter confirma selección
- **Tab/Shift-Tab**: navegar entre opciones
- **Fuentes**: `lsp` (servidores), `snippets` (LuaSnip), `buffer` (contenido del archivo)

### Formateo

El formateo se delega directamente al LSP al guardar (`vim.lsp.buf.format` en `BufWritePre`). Cada servidor LSP maneja su propio formateo:
- **intelephense** → PHP/Blade
- **rust_analyzer** → Rust
- **lua_ls** → Lua
- **pyright** → Python

---

## Atajos de teclado (tabla completa)

### General

| Atajo | Acción |
|-------|--------|
| `<Leader>w` | Guardar archivo |
| `<Leader>wa` | Guardar todos |
| `<Leader>wq` | Guardar y salir |
| `<Leader>qq` | Salir |
| `<Leader>q!` | Forzar salida |
| `<C-s>` | Guardar (normal/insert) |
| `<Leader>e` | Abrir NvimTree |
| `<Leader>nt` | Toggle NvimTree |
| `<Leader>tp` | Toggle auto-pairs |

### Navegación (Telescope)

| Atajo | Acción |
|-------|--------|
| `<Leader>ff` | Buscar archivos |
| `<Leader>fg` | Buscar contenido (grep) |
| `<Leader>fb` | Buscar buffers |
| `<Leader>fh` | Buscar ayuda |

### Buffers y pestañas

| Atajo | Acción |
|-------|--------|
| `<A-n>` | Pestaña siguiente |
| `<A-p>` | Pestaña anterior |
| `<C-n>` | Buffer siguiente |
| `<C-p>` | Buffer anterior |
| `<Leader>bn` | Buffer siguiente |
| `<Leader>bp` | Buffer anterior |
| `<Leader>wd` | Cerrar buffer |
| `<Leader><PageUp>` | Buffer anterior |
| `<Leader><PageDown>` | Buffer siguiente |

### LSP

| Atajo | Acción |
|-------|--------|
| `gd` | Ir a definición |
| `gr` | Ver referencias |
| `gi` | Ir a implementación |
| `gy` | Ir a definición de tipo |
| `K` | Mostrar documentación (hover) |
| `<Leader>rn` | Renombrar símbolo |
| `<Leader>ca` | Code action / Importar clase |
| `[d` | Error diagnóstico anterior |
| `]d` | Error diagnóstico siguiente |
| `<Leader>d` | Ver detalle del error (float) |
| `<Leader>dl` | Lista de todos los errores |

### Folding (Ufo)

| Atajo | Acción |
|-------|--------|
| `zR` | Abrir todos los folds |
| `zM` | Cerrar todos los folds |
| `zr` | Abrir folds excepto funciones |
| `zm` | Cerrar folds |
| `zj` | Fold siguiente |
| `zk` | Fold anterior |

### Comentarios

| Atajo | Acción |
|-------|--------|
| `<Leader>cc` | Comentar línea |
| `<Leader>cb` | Comentar bloque |
| `<Leader>c` (visual) | Comentar selección |

### Todo Comments

| Atajo | Acción |
|-------|--------|
| `<Leader>tt` | Buscar TODOs (Telescope) |
| `]t` | TODO siguiente |
| `[t` | TODO anterior |

### Otros

| Atajo | Acción |
|-------|--------|
| `<Leader>ao` | Toggle Aerial (símbolos) |
| `ga` | EasyAlign (alinear código) |
| `gc` | Comentar (modo visual) |

---

## Solución de problemas

```vim
:checkhealth     " Diagnóstico completo
:Lazy            " Estado de los plugins
:Mason           " Gestor de LSP servers
:Noice           " Historial de notificaciones (noice)
```

Si hay errores de plugins:
1. Ejecuta `:Lazy` y revisa pestañas de errores
2. `:Lazy update` para actualizar todos los plugins
3. `:Lazy clean` para limpiar plugins no usados

Si el LSP no funciona:
1. `:Mason` y verifica que los servidores estén instalados
2. `:LspInfo` para ver qué servidores están activos
3. Verifica que `composer.json` tenga `autoload.psr-4` para PHP

---

## LICENSE

MIT
