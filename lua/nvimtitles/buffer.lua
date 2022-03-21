local constants = require'nvimtitles.constants'

local M = {}

-- b: search backwards from the current cursor position
-- n: do not move the cursor when searching
-- c: allow the current cursor position as a possible match
local SEARCH_FLAGS = 'bnc'

local CURRENT_BUFFER = 0
local STRICT_INDEXING = 0

local function get_row(search)
  local row = vim.fn.searchpos(search, SEARCH_FLAGS)[1]
  return row - 1
end

function M.get_last_full_timestamp()
  return get_row(constants.FULL_TS_FORMAT)
end

function M.get_last_arrow_timestamp()
  return get_row(constants.ARROW)
end

function M.get_last_single_timestamp()
  return get_row(constants.SINGLE_TS_FORMAT)
end

function M.get_last_partial_timestamp()
  return get_row(constants.TS_FORMAT)
end

function M.get_last_blank_line()
  return get_row(constants.BLANK_LINE)
end

-- inserts text at the given line_nr, pushing any existing text in that spot downwards
function M.insert_line(line_nr, text)
  local lines = {text}

  vim.api.nvim_buf_set_lines(
    CURRENT_BUFFER,
    line_nr,
    line_nr,
    STRICT_INDEXING,
    lines
  )
end

-- replaces all the text at a given line_nr with the provided text
function M.replace_line(line_nr, text)
  local lines = {text}

  vim.api.nvim_buf_set_lines(
    CURRENT_BUFFER,
    line_nr,
    line_nr + 1,
    STRICT_INDEXING,
    lines
  )
end

function M.append_line(line_nr, text)
  local lines = vim.api.nvim_buf_get_lines(
    CURRENT_BUFFER,
    line_nr,
    line_nr + 1,
    STRICT_INDEXING
  )
  local new_line = lines[1] .. text
  M.replace_line(line_nr, new_line)
end

function M.get_line(line_nr)
  local lines = vim.api.nvim_buf_get_lines(
    CURRENT_BUFFER,
    line_nr,
    line_nr + 1,
    STRICT_INDEXING
  )
  return lines[1]
end

function M.get_lines()
  return vim.api.nvim_buf_get_lines(
    CURRENT_BUFFER,
    0,
    -1,
    STRICT_INDEXING
  )
end

function M.set_lines()
  vim.api.nvim_buf_set_lines(
    CURRENT_BUFFER,
    0,
    -1,
    STRICT_INDEXING
  )
return M
