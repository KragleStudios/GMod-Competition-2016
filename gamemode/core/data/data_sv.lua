require("mysqloo")

local config = GAMEMODE.config.mysql
local db = mysqloo.connect(config.host, config.user, config.pass, config.db, 3306)

db.waiting_queries = {}
	
function db:onConnected()
	print('Database connection established!')

	if (#self.waiting_queries > 0) then
		for k,v in pairs(self.waiting_queries) do
			self:query(v.sql, v.callback)
		end
	end
end

function db:query(sql, callback)
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