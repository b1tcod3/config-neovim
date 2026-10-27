local M = {}

-- Solo se inspeccionan las primeras líneas: el namespace de PHP vive al inicio.
local MAX_SCAN_LINES = 300

local root_cache = {}
local mappings_cache = {}

function M.clear_cache()
  root_cache = {}
  mappings_cache = {}
end

local function get_buf(buf)
  if buf == nil or buf == 0 then
    return vim.api.nvim_get_current_buf()
  end
  return buf
end

function M.get_head_lines(buf)
  buf = get_buf(buf)
  local count = vim.api.nvim_buf_line_count(buf)
  return vim.api.nvim_buf_get_lines(buf, 0, math.min(count, MAX_SCAN_LINES), false)
end

function M.find_project_root(buf)
  buf = get_buf(buf)
  local filepath = vim.api.nvim_buf_get_name(buf)
  if filepath == "" then
    return nil
  end

  local dir = vim.fn.fnamemodify(filepath, ":h")
  if root_cache[dir] ~= nil then
    return root_cache[dir] or nil
  end

  local root = vim.fs.root(dir, "composer.json")
  root_cache[dir] = root or false
  return root
end

function M.get_psr4_mappings(root)
  local composer_file = root .. "/composer.json"
  local stat = vim.uv.fs_stat(composer_file)
  local cached = mappings_cache[root]
  local mtime = stat and (stat.mtime.sec .. ":" .. stat.mtime.nsec) or 0

  if cached and stat and cached.mtime == mtime then
    return cached.data
  end

  local file = io.open(composer_file, "r")
  if not file then
    mappings_cache[root] = { mtime = 0, data = nil }
    return nil
  end

  local content = file:read("*all")
  file:close()

  local ok, data = pcall(vim.json.decode, content)
  local mappings = ok and data and data.autoload and data.autoload["psr-4"] or nil

  mappings_cache[root] = {
    mtime = mtime,
    data = mappings,
  }

  return mappings
end

function M.compute_namespace(filepath, project_root, mappings)
  local rel_path = filepath:sub(#project_root + 2):gsub("\\", "/")

  local best_prefix, best_dir_len = nil, -1

  for ns_prefix, dir_prefix in pairs(mappings) do
    -- Composer permite tanto un string como un array de directorios.
    local dirs = type(dir_prefix) == "table" and dir_prefix or { dir_prefix }

    for _, dir in ipairs(dirs) do
      dir = tostring(dir):gsub("\\", "/"):gsub("/+$", "")

      local matches = dir == ""
        or rel_path == dir
        or rel_path:sub(1, #dir + 1) == dir .. "/"

      if matches and #dir > best_dir_len then
        best_prefix, best_dir_len = ns_prefix, #dir
      end
    end
  end

  if not best_prefix or best_prefix == "" then
    return nil
  end

  local subpath = rel_path:sub(best_dir_len + 1):gsub("^/", "")
  local dir_part = vim.fn.fnamemodify(subpath, ":h"):gsub("^%.$", "")
  local ns_suffix = dir_part:gsub("/", "\\")

  if ns_suffix ~= "" then
    ns_suffix = "\\" .. ns_suffix
  end

  return (best_prefix:gsub("\\$", "")) .. ns_suffix
end

function M.has_namespace(lines)
  lines = lines or M.get_head_lines(0)

  for _, line in ipairs(lines) do
    if line:find("^%s*namespace%s+") then
      return true
    end
  end

  return false
end

function M.get_php_tag_index(lines)
  for i, line in ipairs(lines) do
    if line:find("<?php") then
      return i
    end
  end
  return nil
end

function M.get_declare_index(lines, after)
  for i = after, #lines do
    local trimmed = vim.trim(lines[i])
    if trimmed ~= "" then
      if trimmed:find("^declare%s*%(") then
        return i
      end
      return nil
    end
  end
  return nil
end

function M.insert_namespace(buf, namespace, lines)
  buf = get_buf(buf)
  lines = lines or M.get_head_lines(buf)

  local ns_line = "namespace " .. namespace .. ";"
  local php_idx = M.get_php_tag_index(lines)

  if not php_idx then
    local only_blank = true
    for _, line in ipairs(lines) do
      if vim.trim(line) ~= "" then
        only_blank = false
        break
      end
    end

    if not only_blank then
      return
    end

    vim.api.nvim_buf_set_lines(buf, 0, 0, false, { "<?php", "", ns_line, "" })
    return
  end

  local insert_after = php_idx
  local declare_idx = M.get_declare_index(lines, php_idx + 1)
  if declare_idx then
    insert_after = declare_idx
  end

  local ns_added = { "", ns_line }
  if insert_after + 1 > #lines or vim.trim(lines[insert_after + 1] or "") ~= "" then
    table.insert(ns_added, "")
  end

  vim.api.nvim_buf_set_lines(buf, insert_after, insert_after, false, ns_added)
end

function M.auto_namespace(buf)
  buf = get_buf(buf)

  if vim.bo[buf].filetype ~= "php" then
    return
  end

  local filepath = vim.api.nvim_buf_get_name(buf)
  if filepath == "" then
    return
  end

  local lines = M.get_head_lines(buf)
  if M.has_namespace(lines) then
    return
  end

  local root = M.find_project_root(buf)
  if not root then
    return
  end

  local mappings = M.get_psr4_mappings(root)
  if not mappings then
    return
  end

  local namespace = M.compute_namespace(filepath, root, mappings)
  if not namespace then
    return
  end

  M.insert_namespace(buf, namespace, lines)
end

return M
