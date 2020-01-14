#!/usr/bin/env lua

local SEPARATOR_LENGTH = 50	
local files = {}

for _, filename in ipairs(arg) do
	local file = assert(io.open(filename, 'r'), 'Can’t open ‘'..filename..'’ …')
	files[filename] = file:read('a')
end

for filename, content in pairs(files) do
	files[filename] = string.gsub(content, '(### [^\n]+)\n',
		function (separator_line)
			local replacement = string.match(separator_line, '(### [^\n#]+)')
			replacement = string.match(replacement, '(.-)%s*$') -- strip whitespace
			local fill_char_nr = math.max(SEPARATOR_LENGTH - string.len(replacement) + 1, 0)
			replacement = replacement .. ' ' .. string.rep('#', fill_char_nr) .. '\n'
			return replacement
		end
	)
end

for filename, content in pairs(files) do
	local file = assert(io.open(filename, 'w'), 'Can’t open ‘'..filename..'’ …')
	file:write(content)
end

