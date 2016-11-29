require("mysqloo")

local config = GM.config.mysql
local db = mysqloo.connect(config.host, config.user, config.pass, config.db, 3306)

db.waiting_queries = {}
db.persistant_fields = {}
	
function db:onConnected()
	print('Database connection established!')

	if (#self.waiting_queries > 0) then
		for k,v in pairs(self.waiting_queries) do
			self:doQuery(v.sql, v.callback)
		end
	end

	self:query("CREATE TABLE IF NOT EXISTS `player_data` (`steamid` varchar(255) NOT NULL)")
end

function db:onConnectionFailed(err)
	error(err)
end

function db:doQuery(sql, callback)
	local query = self:query(sql)

	function query:onSuccess(data)
		callback(data, true)
	end
	
	function query:onError(error)
		if (db:status() == mysqloo.DATABASE_NOT_CONNECTED) then
			table.insert(db.waiting_queries, {sql = sql, callback = callback})

			print('Query failed running, attempting to reconnect to the database and run the query')
			db:connect()
		else
			callback(error, false)
		end
	end

	query:start()
end

--Takes a toFormat string and the things to insert, and escapes each thing to insert, and returns the clean sql
function db:createSql(string, ...)
	local parts = {...}

	for k,v in pairs(parts) do
		if (type(v) == "player") then
			parts[k] = v:SteamID()
		end

		parts[k] = self:escape(v)
	end

	return string.format(string, unpack(parts))
end

function db:addPersistantField(name, type, ndocData, defaultValue)
	self:doQuery("ALTER TABLE `player_data` ADD '".. name .."' '".. type.."'")

	db.persistant_fields[ name ] = {type, ndocData, defaultValue}
end

db:connect()

local meta = FindMetaTable("Player")

function meta:saveData()
	local pData  = ndoc.table.pData[ self ]
	local values = ""

	for col, tbl  in pairs(db.persistant_fields) do
		local field = pData[ tbl[ 2 ] ]

		if (type(field) == "table") then
			field = util.TableToJSON(field)
		end

		values = values .. "`".. col .."` = '".. field .."', "
	end

	db:query("UPDATE `player_data` SET ".. values .. " WHERE `steamid` = '"..self:SteamID().."'", function(data, succ)
			if (succ) then
				print("Player data saved for: ".. self:Nick())
			else
				error(data)
			end
		end)
end

function meta:pullData()
	ndoc.table.pData[ self ] = {}

	db:doQuery("SELECT * FROM `player_data` WHERE `steamid` = '".. self:SteamID().."'", function(data, succ)
		if (succ and data[ 1 ]) then
			for k,v in pairs(data[ 1 ]) do

				local istotab = util.JSONToTable(v)
				if (type(istotab) == "table") then
					v = istotab
				end

				ndoc.table.pData[ self ][ k ] = (v or db.persistant_fields[ k ][ 3 ])
			end
		else
			
			db:doQuery("INSERT INTO `player_data` (`steamid`) VALUES ('".. self:SteamID() .."')", function()
				for k,v in pairs(db.persistant_fields) do
					ndoc.table.pData[ self ][ k ] = v[ 3 ]
				end
			end)
		
		end
	end)
end

hook.Add("PlayerInitialSpawn", "LoadData", function(ply) ply:pullData() end)
hook.Add("PlayerDisconnected", "SaveData", function(ply) ply:saveData() end)