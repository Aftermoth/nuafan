--[[

Copyright (C) 2016 Aftermoth, Zolan Davis

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation; either version 2.1 of the License,
or (at your option) version 3 of the License.

http://www.gnu.org/licenses/lgpl-2.1.html

--]]

local function lookup(t,n)
--[[
			returns
			nil 		if invalid
			false 		if not found
			string		if found
]]
	local m , a = string.match(n,'^([^:]+:)([^:]+)$')
	if m then
-- pre-generate possible * matches
		local ps = {}
		table.insert(ps,a)
		local s,r = a,""
		while s and s~="" do
			table.insert(ps,s..'*')
			s,r = string.match(s, '^(.*)(_[^_]*'..r..')$')
		end
		s,r = a,""
		while s and s~="" do
			table.insert(ps,'*'..s)
			r,s = string.match(a,'^('..r..'[^_]*_)(.*)$')
		end
-- inclusion -- '*' order
		for _,v in ipairs(ps) do
			if t[m..v] then
				return t[m..v]
			end
		end
-- exclusion -- entry order
		if t[m..'-'] then
			local ok
			for _,g in ipairs(t[m..'-']) do
				ok = true
				for _,v in ipairs(ps) do
					if g[1][v] then
						ok = false
						break
					end
				end
				if ok then
					return g[2]
				end
			end
		end
-- any in mod
		if t[m] then
			return t[m]
		end
-- any
		if t['*'] then
			return t['*']
		end
-- no match
		return false
	end
-- invalid
	return nil
end


local here = minetest.get_modpath(minetest.get_current_modname())..'/'

local mkmlist = function ()
	local list = {}
	local s
	for ln in io.lines(here.."depends.txt") do
		s=string.match(ln,'([^%s:?]+)')
		if s then list[s] = 1 end
	end
	return list
end
local mlist = mkmlist() 

local function split(s,pfx,val)
	local t={}
	for v in string.gmatch(s,'([^,]+)') do t[pfx..v] = val end
	return t
end
local function parse(s,s2)
	local t,h = {}, {}
	local m,e,a,c = string.match(s,'^([^:]+:?(-?))([^,]*(,?).*)$')
	if e ~= '' then
		t = split(a,'',1)
		for n,_ in pairs(t) do
			table.insert(h,n)
		end
		table.sort(h)
		return { [0] = m, [1] = { [0]=table.concat(h,","), [1]=t, [2]=s2 }}
	elseif c ~= '' then
		t = split(a,m,s2)
		return t
	elseif s ~= '0' then
		return { [s] = s2 }
	end
	return {}
end

local function mkflist(src)
	src=here..src
	local list = {}
	local s1,s2,p,h
	local fh = io.open(src)
	if fh then
		io.close(fh)
		for ln in io.lines(src) do
			s1,s2=string.match(ln,'^([^%s]+)%s*([^%s]*)')
			if s1 then
				if s1 == "*" or string.sub(s1,1,1) == "@" or mlist[string.match(s1,'^([^:]+)') or ':'] then  -- mod ok
					p = parse(s1,s2)
					if p[0] then
						if not list[p[0] ] then
							list[p[0] ] = {}
							h=true
						else
							h=p[1][0]
							for _,t in ipairs(list[p[0] ]) do
								if h == t[0] then
									t[2]=p[1][2]
									h=false
									break
								end
							end
						end
						if h then
							table.insert(list[p[0] ],p[1])
						end
					else
						for k,v in pairs(p) do
							if not (list[k] and list[k]=='X') then
								list[k] = v
							end
						end
					end
				end
			end
		end
	end
	return list
end

return lookup, mlist, mkflist('f_xconstruct.txt'), mkflist('f_xdestruct.txt'), mkflist('f_callbacks.txt')
