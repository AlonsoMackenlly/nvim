-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set

-- Move to window using the <ctrl> hjkl keys
map("v", "jk", "<esc>", { desc = "Lazy <Escape>", remap = true })
map("i", "jk", "<esc>", { desc = "Lazy <Escape>", remap = true })
map("t", "qq", "exit<cr>", { desc = "Lazy <Escape>", remap = true })

-- Cyrillic

-- Обратите внимание, что в отличие от langmap, здесь присутствуют все символы раскладок,
-- даже те, которые дублируют друг-друга.
-- Исключение: ряд цифр, который при переводе принесет больше неудобств, чем пользы
local ru =
  [[ËЙЦУКЕНГШЩЗХЪ/ФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,ёйцукенгшщзхъфывапролджэячсмитьбю.]]
local en = [[~QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?`qwertyuiop[]asdfghjkl;'zxcvbnm,./]]

local function escape(str)
  -- Эти символы должны быть экранированы, если встречаются в langmap
  local escape_chars = [[;,."|\]]
  return vim.fn.escape(str, escape_chars)
end

-- Наборы символов, введенных с зажатым шифтом
local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]

vim.opt.langmap = vim.fn.join({
  --  ; - разделитель, который не нужно экранировать
  --  |
  escape(ru_shift)
    .. ";"
    .. escape(en_shift),
  escape(ru) .. ";" .. escape(en),
}, ",")

local function map_translated_ctrls()
  -- Маппинг Ctlr+ регистронезависимый, поэтому убираем заглавные буквы
  local en_list = vim.split(en:gsub("%u", ""), "")
  local modes = { "n", "o", "i", "c", "t", "v" }

  for _, char in ipairs(en_list) do
    local keycode = "<C-" .. char .. ">"
    local tr_char = vim.fn.tr(char, en, ru)
    local tr_keycode = "<C-" .. tr_char .. ">"

    -- Предотвращаем рекурсию, если символ содержится в обеих раскладках
    if not en:find(tr_char, 1, true) then
      local term_keycodes = vim.api.nvim_replace_termcodes(keycode, true, true, true)
      vim.keymap.set(modes, tr_keycode, function()
        vim.api.nvim_feedkeys(term_keycodes, "m", true)
      end)
    end
  end
end

map_translated_ctrls()

local function get_current_layout_id()
  local cmd = "im-select"
  if vim.fn.executable(cmd) then
    local output = vim.split(vim.trim(vim.fn.system(cmd)), "\n")
    return output[#output] -- Выведет com.apple.keylayout.RussianWin для русской раскладки
    -- и com.apple.keylayout.ABC для английской
  end
end

-- Функция для проверки, содержится ли символ в langmap
local function langmap_contains(langmap_str, char)
  -- Разбиваем langmap на пары
  for pair in langmap_str:gmatch("[^,]+") do
    local original, mapped = pair:match("(.-)(.)")
    -- Проверяем, совпадает ли символ с одной из букв в паре
    if original == char or mapped == char then
      return true
    end
  end
  return false
end

local function set_missing()
  local en_list = vim.split(en, "")

  for i, char in ipairs(en_list) do
    local char = en_list[i]
    local tr_char = vim.fn.tr(char, en, ru)
    if not (char == tr_char or langmap_contains(char, tr_char)) then
      -- Если символ не дублирующийся, например 'б' и 'ю'
      if not en:find(tr_char, 1, true) then
        vim.keymap.set("n", tr_char, function()
          vim.api.nvim_feedkeys(char, "n", true)
          --  | - здесь нужно использовать noremap
        end)
      else -- Символ дублируется, например ',', '.' и т.д.
        vim.keymap.set("n", tr_char, function()
          if get_current_layout_id() == "com.apple.keylayout.RussianWin" then
            vim.api.nvim_feedkeys(char, "n", true)
          else
            vim.api.nvim_feedkeys(tr_char, "n", true)
          end
        end)
      end
    end
  end
end

set_missing()
