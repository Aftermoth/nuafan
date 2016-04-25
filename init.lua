--[[

Copyright (C) 2016 Aftermoth, Zolan Davis

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation; either version 2.1 of the License,
or (at your option) version 3 of the License.

http://www.gnu.org/licenses/lgpl-2.1.html

--]]

nuafan = {}

nuafan.demo = function(ip,ep)
	local players, near, pp = {}, 8
	for _,player in ipairs(minetest.get_connected_players()) do
		pp = player:getpos()
		if math.abs(pp.x-ip.x) + math.abs(pp.y-ip.y) + math.abs(pp.z-ip.z) < near then
			table.insert(players,player)
		end
	end
	if players[1] then
		local m, p = minetest, '('..ep.x..','..ep.y..','..ep.z..')'
		local i, e = m.get_node_or_nil(ip).name, m.get_node_or_nil(ep).name
		local j, f = m.registered_nodes[i].description, (e=="air" and "Nothing") or m.registered_nodes[e].description
		j, f =(j=="" and '['..i..']') or j, (f=="" and '['..e..']') or f
		for _,pp in ipairs(players) do
			m.chat_send_player(pp:get_player_name(),j..' sees '..f..' at '..p)
		end
	end
end

-- Local --


local this = minetest.get_current_modname()
local here = minetest.get_modpath(this)..'/'
local lookup, mlist, xclist, xdlist, cblist = dofile(here..'mkfilters.lua')

local function shallow(t)
	local d = {}
		for a,b in pairs(t) do
			d[a] = b
		end
	return d
end

local function upgrade()
	local mod,c,d,s
	for nn,dfn in pairs(minetest.registered_nodes) do
		
		mod,c = string.match(nn,'^([^:]+):([^:]+)$')
		if mod and mlist[mod] then
			d = nil
			
			if not (lookup(xdlist,'@safemode:'..mod) and type(dfn.after_destruct) == "function") then
				s = lookup(xdlist,nn)
				if not s then
					d=shallow(dfn)
					d.after_destruct = function (pos, old)
						nua.event(pos)
					end
				end
			end
			
			if not (lookup(xclist,'@safemode:'..mod) and type(dfn.on_construct) == "function") then
				s = lookup(xclist,nn)
				if s~="X" then
					local s2 = lookup(cblist,nn)
					if not s or (s2 and s2~="") then
						if not d then d=shallow(dfn) end
						if s2 and s2~="" then
							if s then
								d.on_construct = function (pos)
												minetest.get_meta(pos):set_string('on_nbr_update',s2)
											end
							else
								d.on_construct = function (pos)
												minetest.get_meta(pos):set_string('on_nbr_update',s2)
												nua.event(pos)
											end
							end
						else
							d.on_construct = function (pos)
											nua.event(pos)
										end
						end
					end
				end
			end
			
			if d then
				minetest.register_node(':'..nn,d)
			end
		end
	end
end

upgrade()
