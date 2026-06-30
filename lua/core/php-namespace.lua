local M = {}

function M.find_project_root()
  local path = vim.fn.expand('%:p:h')
  local found = vim.fs.find('composer.json', { upward = true, path = path })[1]
  if found then
    return vim.fn.fnamemodify(found, ':h')
  end
  return nil
end

function M.get_psr4_mappings(root)
  local composer_file = root .. '/composer.json'
  local file = io.open(composer_file, 'r')
  if not file then
    return nil
  end
  local content = file:read('*all')
  file:close()

  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    return nil
  end

  local autoload = data.autoload
  if not autoload or not autoload['psr-4'] then
    return nil
  end

  return autoload['psr-4']
end

function M.compute_namespace(filepath, project_root, mappings)
  local rel_path = filepath:sub(#project_root + 2)
  rel_path = rel_path:gsub('\\', '/')

  for ns_prefix, dir_prefix in pairs(mappings) do
    local dir = dir_prefix:gsub('\\', '/'):gsub('/+$', '')
    local escaped_dir = dir:gsub('([%.%+%-%*%?%[%]%(%)%%])', '\\%1')

    if rel_path:find('^' .. escaped_dir) then
      local subpath = rel_path:sub(#dir + 1):gsub('^/', '')

      local dir_part = vim.fn.fnamemodify(subpath, ':h'):gsub('^%.$', '')
      local ns_suffix = dir_part:gsub('/', '\\')
      if ns_suffix ~= '' then
        ns_suffix = '\\' .. ns_suffix
      end

      return ns_prefix:gsub('\\$', '') .. ns_suffix
    end
  end

  return nil
end

function M.has_namespace()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    if line:find('^%s*namespace%s+') then
      return true
    end
  end
  return false
end

function M.get_php_tag_index(lines)
  for i, line in ipairs(lines) do
    if line:find('<?php') then
      return i
    end
  end
  return nil
end

function M.get_declare_index(lines, after)
  for i = after, #lines do
    local trimmed = vim.trim(lines[i])
    if trimmed ~= '' then
      if trimmed:find('^declare%s*%(') then
        return i
      end
      return nil
    end
  end
  return nil
end

function M.insert_namespace(namespace)
  local ns_line = 'namespace ' .. namespace .. ';'
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local php_idx = M.get_php_tag_index(lines)

  if php_idx then
    local insert_after = php_idx
    local declare_idx = M.get_declare_index(lines, php_idx + 1)
    if declare_idx then
      insert_after = declare_idx
    end
    local ns_added = {}
    table.insert(ns_added, '')
    table.insert(ns_added, ns_line)
    if insert_after + 1 > #lines or vim.trim(lines[insert_after + 1] or '') ~= '' then
      table.insert(ns_added, '')
    end
    vim.api.nvim_buf_set_lines(0, insert_after, insert_after, false, ns_added)
  else
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { '<?php', '', ns_line, '' })
  end
end

function M.auto_namespace()
  if vim.bo.filetype ~= 'php' then
    return
  end

  if M.has_namespace() then
    return
  end

  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    return
  end

  local root = M.find_project_root()
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

  M.insert_namespace(namespace)
end

return M
