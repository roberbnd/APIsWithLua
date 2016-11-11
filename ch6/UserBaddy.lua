-- UserBaddy.lua
--
-- A subclass of Baddy that users can provide scripts for.
--

local Baddy = require 'Baddy'

local function is_in_table(needle, haystack)
  for _, value in pairs(haystack) do
    if value == needle then
      return true
    end
  end
  return false
end

local UserBaddy = Baddy:new({})

-- Set up a new baddy.
-- This expects a table with keys {home, color, chars, script}.
function UserBaddy:new(b)
  assert(b)  -- Require a table of initial values.
  b.pos        = b.home
  b.dir        = {-1, 0}
  b.get_dir    = loadfile(b.script)()
  self.__index = self
  return setmetatable(b, self)
end

-- XXX
function s(p)
  return ('%d,%d'):format(p[1], p[2])
end

function UserBaddy:move_if_possible(grid, player)

  -- Determine which directions are possible to move in.
  local deltas = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
  local possible_dirs = {}
  for _, delta in pairs(deltas) do
    if self:can_move_in_dir(delta, grid) then
      table.insert(possible_dirs, pair(delta))
    end
  end

  -- Call the user-defined movement function.
  self.dir = self:get_dir(possible_dirs, grid, player)

  io.stderr:write('\n--- new call to UserBaddy:move_if_possible\n')
  io.stderr:write('possible_dirs:\n')
  for _, d in ipairs(possible_dirs) do
    io.stderr:write(('%s\n'):format(s(d)))
  end
  io.stderr:write(('Got self.dir = %s\n'):format(s(self.dir)))

  if not is_in_table(self.dir, possible_dirs) then
    self.dir = possible_dirs[1]
  end

  -- Update our position and saved old position.
  self.old_pos = self.pos
  _, self.pos  = self:can_move_in_dir(self.dir, grid)
end

return UserBaddy