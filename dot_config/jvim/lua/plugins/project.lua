return {
  "DrKJeff16/project.nvim",
  config = function()
    local function default_name(path)
      local base = vim.fn.fnamemodify(path, ":t")
      local parent = vim.fn.fnamemodify(path, ":h:t")

      if parent == "." or parent == "" then
        return base
      end

      return ("%s/%s"):format(parent, base)
    end

    local function normalise_entries(entries)
      local normalised = {}
      local seen = {}

      for _, entry in ipairs(entries) do
        local item = entry
        if type(entry) == "string" then
          item = { path = entry, name = default_name(entry) }
        end

        if type(item) == "table" and type(item.path) == "string" and item.path ~= "" then
          if not seen[item.path] then
            item.name = item.name or default_name(item.path)
            table.insert(normalised, item)
            seen[item.path] = true
          end
        end
      end

      return normalised
    end

    local function migrate_legacy_history()
      local history_dir = vim.fn.stdpath("data") .. "/project_nvim"
      local legacy_file = history_dir .. "/project_history"
      local json_file = history_dir .. "/project_history.json"

      if vim.fn.filereadable(legacy_file) ~= 1 then
        return
      end

      local legacy_lines = vim.fn.readfile(legacy_file)
      if vim.tbl_isempty(legacy_lines) then
        return
      end

      local legacy_entries = {}
      for _, path in ipairs(legacy_lines) do
        if path ~= "" then
          table.insert(legacy_entries, { path = path, name = default_name(path) })
        end
      end

      if vim.tbl_isempty(legacy_entries) then
        return
      end

      local current_entries = {}
      if vim.fn.filereadable(json_file) == 1 then
        local decoded = vim.json.decode(table.concat(vim.fn.readfile(json_file), "\n"))
        if type(decoded) == "table" then
          current_entries = decoded
        end
      end

      local merged = normalise_entries(current_entries)
      for _, entry in ipairs(normalise_entries(legacy_entries)) do
        table.insert(merged, entry)
      end
      merged = normalise_entries(merged)

      vim.fn.mkdir(history_dir, "p")
      vim.fn.writefile({ vim.json.encode(merged) }, json_file)
    end

    migrate_legacy_history()
    require("project").setup({})
  end
}
