API_Database = {}
local API = exports['GHMattiMySQL']

---------------------------------------------
---------------DATABASE SYSTEM---------------
---------------------------------------------
DBConnect = {
	driver = 'ghmattimysql',
	host = '127.0.0.1',
	database = 'ckdev',
	user = 'root',
	password = ''
}

local db_drivers = {}
local db_driver
local cached_prepares = {}
local cached_queries = {}
local prepared_queries = {}
local db_initialized = false

function API_Database.registerDBDriver(name, on_init, on_prepare, on_query)
	if not db_drivers[name] then
		db_drivers[name] = {on_init, on_prepare, on_query}

		if name == DBConnect.driver then
			db_driver = db_drivers[name]

			local ok = on_init(DBConnect)
			if ok then
				db_initialized = true
				for _, prepare in pairs(cached_prepares) do
					on_prepare(table.unpack(prepare, 1, table.maxn(prepare)))
				end

				for _, query in pairs(cached_queries) do
					async(
						function()
							query[2](on_query(table.unpack(query[1], 1, table.maxn(query[1]))))
						end
					)
				end

				cached_prepares = nil
				cached_queries = nil
			else
				error('Conexão com o banco de dados perdida.')
			end
		end
	else
		error('Banco de dados registrado.')
	end
end

function API_Database.format(n)
	local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1.'):reverse()) .. right
end

function API_Database.prepare(name, query)
	prepared_queries[name] = true

	if db_initialized then
		db_driver[2](name, query)
	else
		table.insert(cached_prepares, {name, query})
	end
end

function API_Database.query(name, params, mode)
	if not prepared_queries[name] then
		error('query ' .. name .. " doesn't exist.")
	end

	if not mode then
		mode = 'query'
	end

	if db_initialized then
		return db_driver[3](name, params or {}, mode)
	else
		local r = async()
		table.insert(cached_queries, {{name, params or {}, mode}, r})
		return r:wait()
	end
end

function API_Database.execute(name, params)
	return API_Database.query(name, params, 'execute')
end

---------------------------------------------
---------------EXECUTE  SYSTEM---------------
---------------------------------------------
local queries = {}

local function on_init(cfg)
	return API ~= nil
end

local function on_prepare(name, query)
	queries[name] = query
end

local function on_query(name, params, mode)
	local query = queries[name]
	local _params = {}
	_params._ = true

	for k, v in pairs(params) do
		_params['@' .. k] = v
	end

	local r = async()

	if mode == 'execute' then
		API:QueryAsync(
			query,
			_params,
			function(affected)
				r(affected or 0)
			end
		)
	elseif mode == 'scalar' then
		API:QueryScalarAsync(
			query,
			_params,
			function(scalar)
				r(scalar)
			end
		)
	else
		API:QueryResultAsync(
			query,
			_params,
			function(rows)
				r(rows, #rows)
			end
		)
	end
	return r:wait()
end

Citizen.CreateThread(
	function()
		API:Query('SELECT 1')
		API_Database.registerDBDriver('ghmattimysql', on_init, on_prepare, on_query)
	end
)
----------	USER THIGNS -------------
API_Database.prepare('FCRP/CreateUser', 'INSERT INTO users(identifier, name, banned) VALUES(@identifier, @name, 0); SELECT LAST_INSERT_ID() AS id')
API_Database.prepare('FCRP/SelectUser', 'SELECT * from users WHERE identifier = @identifier')
API_Database.prepare('FCRP/BannedUser', 'SELECT banned from users WHERE user_id = @user_id')
API_Database.prepare('FCRP/SetBanned', 'UPDATE users SET banned = 1 WHERE user_id = @user_id')
API_Database.prepare('FCRP/Whitelisted', 'SELECT * from whitelist WHERE identifier = @identifier')

-------- CHARACTER THIGNS -----------
API_Database.prepare('FCRP/CreateCharacter', "INSERT INTO characters(user_id, characterName, groups) VALUES (@user_id, @charName, '{\"user\":true}'); SELECT LAST_INSERT_ID() AS id")
API_Database.prepare('FCRP/GetCharacters', 'SELECT * from characters WHERE user_id = @user_id')
API_Database.prepare('FCRP/GetCharacter', 'SELECT * from characters WHERE charid = @charid')
API_Database.prepare('FCRP/DeleteCharacter', 'DELETE FROM characters WHERE charid = @charid')
API_Database.prepare('FCRP/GetUserIdByCharId', 'SELECT user_id from characters WHERE charid = @charid')
API_Database.prepare('FCRP/GetCharNameByCharId', 'SELECT characterName from characters WHERE charid = @charid')
API_Database.prepare('FCRP/UpdateLevel', 'UPDATE characters SET level = @level WHERE charid = @charid')
API_Database.prepare('FCRP/UpdateXP', 'UPDATE characters SET xp = @xp WHERE charid = @charid')

-------- CHARACTER DATATABLE --------
API_Database.prepare('FCRP/SetCData', 'CALL setData(@target, @key, @value, @charid)')
API_Database.prepare('FCRP/GetCData', 'CALL getData(@target, @charid, @key)')
API_Database.prepare('FCRP/RemCData', 'CALL remData(@target, @key, @charid)')
API_Database.prepare('FCRP/SetCWeaponData', 'UPDATE characters SET weapons = @weapons WHERE charid = @charid')
-- API_Database.prepare('FCRP/GetCWeaponData', 'SELECT weapons FROM characters WHERE charid = @charid')

-------- INVENTORY THINGS -----------
API_Database.prepare('FCRP/Inventory', 'CALL inventories(@id, @charid, @itemName, @itemCount, @typeInv);')

---------- HORSE THINGS -------------
API_Database.prepare('FCRP/CreateHorse', 'INSERT INTO horses(charid, model, name) VALUES (@charid, @model, @name); SELECT LAST_INSERT_ID() AS id')
API_Database.prepare('FCRP/GetHorses', 'SELECT * from horses WHERE charid = @charid')
API_Database.prepare('FCRP/GetHorse', 'SELECT * from horses WHERE id = @id')
API_Database.prepare('FCRP/DeleteHorse', 'DELETE FROM horses WHERE charid = @charid')

---------- HORSE THINGS -------------
API_Database.prepare('FCRP/CreatePosse', 'INSERT INTO posses(charid, members, name) VALUES (@charid, @members, @name); SELECT LAST_INSERT_ID() AS id')
API_Database.prepare('FCRP/GetPosseById', 'SELECT * from posses WHERE id = @id')
