# Configuración Neovim

Configuración personal de Neovim orientada a desarrollo web (PHP/Laravel, Python, Rust, Go, Lua y frontend) con LSP nativo, Treesitter, autocompletado y carga diferida de plugins.

## Requisitos

- **Neovim 0.12+** — se usa la API nativa `vim.lsp.config` / `vim.lsp.enable` y la rama `main` de `nvim-treesitter`. Probado con Neovim 0.13.0-dev.
- **Git** — para clonar el repositorio y para que lazy.nvim instale plugins.
- **tree-sitter-cli >= 0.26.1** y un compilador de C — necesarios para compilar los parsers de Treesitter.
- **Nerd Font** — para los iconos de lualine, bufferline, nvim-tree, etc.
- **Terminal con true color** — necesario para Tokyo Night.
- **ripgrep** (`rg`) y opcionalmente **fd** — búsquedas de Telescope.
- **Node.js** — recomendado para algunos servidores LSP instalados por Mason (intelephense, tailwindcss, emmet, etc.).

## Instalación

```bash
git clone https://github.com/b1tcod3/config-neovim.git ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
```

Al abrir Neovim, lazy.nvim instala lo que falte. Los parsers de Treesitter que no estén instalados se descargan en segundo plano al arrancar; para forzarlo:

```vim
:TSInstall c rust python astro go
:TSUpdate
```

### Post-instalación

```vim
:Lazy          " Estado de los plugins
:Mason         " Verificar/instalar servidores LSP
:checkhealth   " Diagnóstico completo
```

---

## Estructura del proyecto

```
~/.config/nvim/
├── init.lua                    # Entry point + configuración de lazy.nvim
├── lazy-lock.json              # Lock de versiones de plugins
├── .gitignore
├── lua/
│   ├── core/
│   │   ├── options.lua         # Opciones globales y filetype blade
│   │   ├── keymaps.lua         # Atajos de teclado
│   │   ├── autocmds.lua        # Guardado, cursor, yank, composer.json
│   │   └── php-namespace.lua   # Inserción automática de namespace PSR-4
│   └── plugins/
│       ├── init.lua            # Índice de la división de plugins
│       ├── ui.lua              # Tema, barras, explorador, símbolos
│       ├── editor.lua          # Pares, autotag, folds, comentarios, Copilot, Telescope
│       ├── lsp.lua             # Mason, nvim-lspconfig, blink.cmp
│       ├── treesitter.lua      # Parsers, highlight, indent, textobjects
│       ├── mini-surround.lua   # Surrounds custom de Blade/Laravel
│       └── render-markdown.lua # Render de Markdown
└── after/
    └── ftdetect/
        └── blade.lua           # Reconoce *.blade.php como filetype blade
```

---

## `init.lua` — Entry point

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")

-- Instala lazy.nvim si no existe y lo agrega al runtimepath
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  install = { missing = true, colorscheme = { "tokyonight" } },
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    cache = { enabled = true },
    rtp = {
      reset = true,
      disabled_plugins = {
        "gzip", "netrwPlugin", "tarPlugin",
        "tohtml", "tutor", "zipPlugin",
      },
    },
  },
  ui = { border = "rounded" },
})

require("core.keymaps")
require("core.autocmds")
```

| Elemento | Explicación |
|---|---|
| `mapleader = " "` | `<Space>` es la tecla líder. |
| `core.options` | Opciones antes de cargar plugins. |
| `vim.uv.fs_stat` | Comprueba si lazy.nvim está instalado (API moderna; `vim.loop` está deprecado). |
| `performance.cache` | Caché de módulos Lua. |
| `disabled_plugins` | Desactiva plugins de runtime que no se usan (netrw, gzip, tar, zip, tutor, tohtml). |
| `checker = false` | Evita comprobaciones de actualización en segundo plano; usa `:Lazy check` cuando quieras. |

---

## `lua/core/options.lua`

| Opción | Valor |
|---|---|
| `number`, `relativenumber` | Números absolutos y relativos |
| `cursorline` | Resalta la línea actual |
| `signcolumn` | `yes:2` (ancho estable para diagnósticos) |
| `termguicolors` | True color |
| `tabstop`, `shiftwidth` | 4 |
| `expandtab` | Tabs → espacios |
| `backup`, `writebackup`, `swapfile` | Desactivados |
| `undofile` | Undo persistente |
| `clipboard` | `unnamedplus` |
| `ignorecase` + `smartcase` | Búsqueda inteligente |
| `scrolloff`, `sidescrolloff` | 8 |
| `splitbelow`, `splitright`, `splitkeep` | Divisiones predecibles |
| `foldenable`, `foldcolumn` | Folds activos, columna de 1 |
| `foldlevel`, `foldlevelstart` | 99 (folds abiertos al abrir archivos) |
| `confirm` | Confirmación al cerrar con cambios |
| `breakindent` | Indentación visual en líneas largas |
| `pumheight` | 12 |

Los diagnósticos se configuran al cargar el LSP (`lua/plugins/lsp.lua`): texto virtual, signos, subrayado, `update_in_insert = false`, orden por severidad y ventana flotante redondeada.

### Filetype Blade

La detección está centralizada en `after/ftdetect/blade.lua`:

```lua
vim.filetype.add({
  pattern = { [".*%.blade%.php"] = "blade" },
})
```

---

## `lua/core/autocmds.lua`

Todas las autocmds viven en el grupo `UserAutocmds`.

| Evento | Acción |
|---|---|
| `BufWritePre` | Crea los directorios padres si no existen, inserta el namespace PHP y formatea con LSP. |
| `BufReadPost` | Restaura la posición del cursor (solo buffers normales). |
| `TextYankPost` | Resalta brevemente el texto copiado. |
| `BufWritePost` (composer.json) | Invalida la caché de PSR-4. |

### Formateo al guardar

Se ejecuta solo si:

1. El buffer es normal (`buftype == ""`).
2. No tiene `vim.b.disable_autoformat = true`.
3. Hay al menos un cliente LSP que soporte `textDocument/formatting`.

```lua
local clients = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/formatting" })
if #clients == 0 then return end

vim.lsp.buf.format({
  bufnr = buf,
  async = false,
  timeout_ms = 2000,
  filter = function(client)
    return client:supports_method("textDocument/formatting")
  end,
})
```

Para desactivarlo en un buffer concreto:

```vim
:lua vim.b.disable_autoformat = true
```

> Nota: `intelephense` (versión gratuita) no expone formateo, así que en PHP el guardado no se bloquea esperando un formateador que no existe.

---

## `lua/core/php-namespace.lua` — Namespace PSR-4 automático

Al guardar un archivo PHP, si no tiene `namespace`, se calcula a partir de `composer.json`:

```
1. ¿Es filetype php?                    → No → return
2. ¿Tiene nombre de archivo?            → No → return
3. ¿Ya tiene namespace?                 → Sí → return
4. Buscar composer.json hacia arriba    → No → return
5. Leer autoload.psr-4                  → No → return
6. Calcular el namespace                → No → return
7. Insertar después de <?php o declare  → fin
```

Características:

- Soporta valores PSR-4 como string **o array**:
  ```json
  {
    "autoload": {
      "psr-4": {
        "App\\": ["app/", "src/"],
        "Lib\\": "lib/"
      }
    }
  }
  ```
- Usa el prefijo de directorio **más específico** (la coincidencia más larga).
- Comprueba límites de directorio, no solo prefijos de texto.
- Cachea la raíz del proyecto y los mappings, invalidando por `mtime` de `composer.json`.
- Solo inspecciona las primeras 300 líneas del buffer.
- Si el archivo no tiene `<?php` y ya contiene texto, no lo modifica.
- Inserta después de `declare(strict_types=1);` cuando existe.

Ejemplo: `app/Models/User.php` con `"App\\": "app/"` → `namespace App\Models;`.

---

## Plugins

### `lua/plugins/ui.lua`

| Plugin | Propósito | Carga |
|---|---|---|
| `tokyonight.nvim` | Tema | Inmediata, prioridad 1000 |
| `noice.nvim` | UI de cmdline, mensajes y notificaciones | `VeryLazy` |
| `todo-comments.nvim` | Resalta TODO/FIXME/HACK y búsqueda | `VeryLazy` |
| `lualine.nvim` | Barra de estado | Inmediata |
| `bufferline.nvim` | Buffers tipo pestañas | Inmediata |
| `nvim-tree.lua` | Explorador lateral | Comandos / tecla |
| `aerial.nvim` | Navegador de símbolos | `VeryLazy` / tecla |

### `lua/plugins/editor.lua`

| Plugin | Propósito | Carga |
|---|---|---|
| `mini.pairs` | Pares automáticos | Inmediata |
| `nvim-ts-autotag` | Cierre/renombrado de etiquetas | Por filetype |
| `nvim-ufo` | Folds con Treesitter | `VeryLazy` |
| `Comment.nvim` | Comentarios | Teclas `gc` / `gbc` |
| `copilot.vim` | GitHub Copilot | `InsertEnter` |
| `vim-easy-align` | Alineación | Inmediata |
| `leap.nvim` | Salto rápido | Inmediata |
| `vim-be-good` | Minijuegos | Comando `:VimBeGood` |
| `vim-slint` | Soporte Slint | Filetype `slint` |
| `telescope.nvim` | Buscador fuzzy | Comando / teclas |

### `lua/plugins/lsp.lua`

| Plugin | Propósito |
|---|---|
| `mason.nvim` | Gestor de servidores y herramientas |
| `mason-lspconfig.nvim` | Integración Mason ↔ nvim-lspconfig |
| `nvim-lspconfig` | Configuraciones LSP |
| `blink.cmp` | Autocompletado |

Mason y LSP se cargan al abrir el primer archivo (`BufReadPre`/`BufNewFile`), no al arrancar Neovim. Los comandos `:Mason*` siguen disponibles porque están declarados como comandos de carga diferida.

### `lua/plugins/treesitter.lua`

- `nvim-treesitter` (rama `main`, sin lazy-loading).
- Instala solo los parsers que falten: `c`, `lua`, `vim`, `vimdoc`, `query`, `php`, `html`, `css`, `javascript`, `typescript`, `rust`, `python`, `astro`, `go`, `markdown`, `markdown_inline`, `blade`.
- Highlight e indent nativos vía `vim.treesitter.start()` en `FileType`.
- `nvim-treesitter-textobjects` para navegar funciones y clases; se carga al usar sus atajos.

### Servidores LSP instalados por Mason

| Servidor | Lenguaje |
|---|---|
| `intelephense` | PHP |
| `pyright` | Python |
| `rust_analyzer` | Rust |
| `lua_ls` | Lua |
| `tailwindcss` | Tailwind CSS |
| `astro` | Astro |
| `emmet_ls` | HTML / Blade |
| `html` | HTML |
| `gopls` | Go |

Las capacidades de completado se configuran una sola vez:

```lua
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})
```

Los atajos LSP son buffer-local y se crean en `LspAttach`, así que solo existen donde hay un cliente activo.

### blink.cmp y Copilot

- **Fuentes**: LSP, snippets y buffer.
- **Snippets**: `vim.snippet` (preset `default`). No se usa LuaSnip.
- **Tab / Shift-Tab**: navegar opciones.
- **Enter**: aceptar opción.
- **Ctrl-J**: aceptar sugerencia de Copilot.
- Copilot no mapea Tab (`vim.g.copilot_no_tab_map = true`), por lo que no compite con blink.cmp.

---

## Rendimiento

Mediciones con `nvim --headless --startuptime`:

| Escenario | Arranque |
|---|---|
| Configuración anterior (plugins eager) | ~700 ms |
| Configuración actual, primera ejecución | ~300 ms |
| Configuración actual, ejecuciones en caliente | ~190–290 ms |

Cambios principales:

- **Lazy-loading**: Telescope, nvim-tree, Copilot, Mason/LSP, blink, `nvim-be-good`, Slint y textobjects se cargan solo cuando se necesitan.
- **LuaSnip eliminado**: blink usa `vim.snippet`; se ahorran ~38 ms y una dependencia.
- **Folds sin autocmd costoso**: se eliminó `openAllFolds()` en cada `BufEnter`/`FileType`; ahora se usa `foldlevelstart = 99`.
- **Formateo filtrado**: no se llama a `vim.lsp.buf.format` si no hay cliente con soporte de formato.
- **PHP namespace con caché**: no se lee `composer.json` ni se recorre el buffer completo en cada guardado.
- **lazy.nvim**: caché de módulos y plugins de runtime desactivados.

Para perfilar tu propio arranque:

```bash
nvim --startuptime /tmp/startup.log +qa
```

Dentro de Neovim: `:Lazy profile`.

---

## Atajos de teclado

### General

| Atajo | Acción |
|---|---|
| `<Leader>w` | Guardar |
| `<Leader>wa` | Guardar todos |
| `<Leader>wq` | Guardar y salir |
| `<Leader>qq` | Salir |
| `<Leader>q!` | Forzar salida |
| `<C-s>` (normal/insert) | Guardar sin salir de insert |
| `<Leader>tp` | Activar/desactivar mini.pairs |
| `<Leader>e` | Toggle NvimTree |
| `<C-j>` (insert) | Aceptar sugerencia Copilot |

### Telescope

| Atajo | Acción |
|---|---|
| `<Leader>ff` | Buscar archivos |
| `<Leader>fg` | Buscar contenido |
| `<Leader>fb` | Buscar buffers |
| `<Leader>fh` | Buscar ayuda |
| `<Leader>tt` | Buscar TODOs |

### Buffers y pestañas

| Atajo | Acción |
|---|---|
| `<A-n>` / `<A-p>` | Pestaña siguiente / anterior |
| `<C-n>` / `<C-p>` | Buffer siguiente / anterior |
| `<Leader>bn` / `<Leader>bp` | Buffer siguiente / anterior |
| `<Leader>wd` | Cerrar buffer |
| `<Leader><PageUp>` / `<Leader><PageDown>` | Buffer anterior / siguiente |

### LSP (solo en buffers con cliente)

| Atajo | Acción |
|---|---|
| `gd` | Ir a definición |
| `gr` | Ver referencias |
| `gi` | Ir a implementación |
| `gy` | Ir a definición de tipo |
| `K` | Documentación (hover) |
| `<Leader>rn` | Renombrar símbolo |
| `<Leader>ca` | Code action / importar clase (normal y visual) |

### Diagnósticos

| Atajo | Acción |
|---|---|
| `[d` / `]d` | Error anterior / siguiente |
| `<Leader>d` | Ver detalle del error |
| `<Leader>dl` | Lista de errores |

### Funciones y clases (Treesitter textobjects)

| Atajo | Acción |
|---|---|
| `]m` / `[m` | Inicio de función siguiente / anterior |
| `]M` / `[M` | Fin de función siguiente / anterior |
| `]c` / `[c` | Inicio de clase siguiente / anterior |
| `]C` / `[C` | Fin de clase siguiente / anterior |

Funcionan en modos normal, visual y operator-pending.

### Folds (ufo)

| Atajo | Acción |
|---|---|
| `zR` | Abrir todos |
| `zM` | Cerrar todos |
| `zr` | Abrir folds excepto funciones |
| `zm` | Cerrar folds |
| `zj` / `zk` | Fold siguiente / anterior |

### Comentarios

| Atajo | Acción |
|---|---|
| `gc` | Comentar (normal/visual) |
| `gbc` | Comentario de bloque |
| `<Leader>cc` | Comentar línea |
| `<Leader>cb` | Comentar bloque |

### Otros

| Atajo | Acción |
|---|---|
| `<Leader>ao` | Toggle Aerial (símbolos) |
| `<Leader>s` / `<Leader>S` | Leap forward / backward |
| `ga` | EasyAlign (normal/visual) |
| `]t` / `[t` | TODO siguiente / anterior |

---

## Surrounds custom de Blade/Laravel

Con `mini.surround`, después de `sa` puedes usar estas claves:

| Secuencia | Resultado |
|---|---|
| `saiw` | `@island ... @endisland` |
| `sapw` | `@php ... @endphp` |
| `safw` | `@if ... @endif` |
| `saew` | `@foreach ... @endforeach` |
| `sasw` | `@section ... @endsection` |
| `sahw` | `@push ... @endpush` |
| `sadw` | `@error ... @enderror` |
| `saaw` | `@auth ... @endauth` |
| `sagw` | `@guest ... @endguest` |
| `saww` | `@env ... @endenv` |

En modo visual, `S` añade el surround seleccionado.

---

## Solución de problemas

```vim
:checkhealth        " Diagnóstico general
:checkhealth lsp    " Estado de los servidores LSP
:Lazy               " Estado de plugins
:Mason              " Servidores y herramientas
:TSInstall          " Instalar parsers de Treesitter
:TSUpdate           " Actualizar parsers
```

- **No aparece el autocompletado**: abre un archivo real (el LSP se carga en `BufReadPre`) y comprueba con `:checkhealth lsp`.
- **No se formatea al guardar**: el servidor debe soportar `textDocument/formatting`. `intelephense` gratuito no lo hace. Comprueba también `vim.b.disable_autoformat`.
- **No se inserta el namespace**: verifica que exista `composer.json` con `autoload.psr-4`, que el archivo sea `filetype=php` y que no tenga ya un `namespace`.
- **Blade sin resaltado**: instala el parser con `:TSInstall blade`.
- **Errores tras actualizar plugins**: `:Lazy sync` y luego `:TSUpdate`.

---

## LICENSE

MIT
