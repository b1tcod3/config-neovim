# Configuración Neovim

Mi configuración personal de Neovim para desarrollo web y programación general.

## Requisitos

- Neovim 0.11+
- Git
- Navegador de terminal compatible con colores true color

## Instalación

### Opción 1: Clonar directamente (Linux/macOS)

```bash
git clone https://github.com/b1tcod3/config-neovim.git ~/.config/nvim
```

### Opción 2: Clonar y usar como starting point

```bash
git clone https://github.com/b1tcod3/config-neovim.git ~/nvim-config
cp -r ~/nvim-config/* ~/.config/nvim/
```

## Plugins Incluidos

- **Tema**: Tokyo Night
- **UI**: noice.nvim, lualine, bufferline, nvim-tree
- **Navegación**: telescope, aerial, vim-easymotion
- **LSP**: Configuración nativa con mason (PHP, Python, Rust, Lua)
- **Autocompletado**: blink.cmp
- **Formateo**: conform.nvim (PHP, Blade, Python)
- **Treesitter**: PHP, Blade, HTML, CSS, JS, TS
- **Extras**: Comment, mini.surround, mini.pairs, nvim-ts-autotag

## Atajos de Teclado

### General

| Atajo | Acción |
|-------|--------|
| `<Leader>w` | Guardar archivo |
| `<Leader>wa` | Guardar todos |
| `<Leader>wq` | Guardar y salir |
| `<Leader>qq` | Salir |
| `<C-s>` | Guardar (normal/insert) |
| `<Leader>nt` | Toggle NvimTree |
| `<Leader>e` | Abrir explorador de archivos |

### Navegación

| Atajo | Acción |
|-------|--------|
| `<Leader>ff` | Buscar archivos (Telescope) |
| `<Leader>fg` | Buscar contenido (grep) |
| `<Leader>fb` | Buscar buffers |
| `<Leader>fh` | Buscar ayuda |
| `<Leader>bn` | Buffer siguiente |
| `<Leader>bp` | Buffer anterior |
| `<Leader>bd` | Cerrar buffer |

### LSP

| Atajo | Acción |
|-------|--------|
| `gd` | Ir a definición |
| `gr` | Ver referencias |
| `gi` | Ir a implementación |
| `K` | Mostrar documentación (hover) |
| `<Leader>rn` | Renombrar símbolo |

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
| `gc` | Comentar (visual) |

### Otros

| Atajo | Acción |
|-------|--------|
| `<Leader>tp` | Toggle auto-pairs |
| `<Leader>tt` | Ver todos (TODO comments) |
| `ga` | EasyAlign (alinear código) |
| `<Leader>ao` | Toggle Aerial (símbolos) |

## Instalación de LSP y Treesitter

Los servidores LSP y parsers se instalan automáticamente con Mason al abrir Neovim por primera vez:

```bash
# Instalar servidores LSP (desde Neovim)
:Mason

# Instalar parsers de Treesitter
:TSInstall php blade html css javascript typescript
```

## Solución de Problemas

Si tienes errores al iniciar:
1. Ejecuta `:Lazy` para ver errores de plugins
2. Ejecuta `:checkhealth` para verificar la configuración
3. Asegúrate de tener Neovim 0.11+

## Estructura de Archivos

```
nvim/
├── init.lua          # Entry point
├── lazy-lock.json    # Versiones de plugins (opcional)
├── lua/
│   ├── core/
│   │   ├── options.lua  # Opciones de Neovim
│   │   └── keymaps.lua  # Atajos de teclado
│   └── plugins/
│       └── init.lua     # Configuración de plugins
└── after/
    ├── ftplugin/    # Configuración por tipo de archivo
    └── plugin/      # Plugins adicionales
```

## LICENSE

MIT