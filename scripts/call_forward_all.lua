--create the api object
        api = freeswitch.API();

--includes
        require "resources.functions.config";
        require "resources.functions.channel_utils";
        local Database = require "resources.functions.database"
        local Settings = require "resources.functions.lazy_settings"

--include json library
        local json
        if (debug["sql"]) then
                json = require "resources.functions.lunajson"
        end

        local function empty(t)
                return (not t) or (#t == 0)
        end

--check if the session is ready
        if not session:ready() then return end

--connect to the database
        local dbh = Database.new('system');
        local settings = Settings.new(dbh, domain_name, domain_uuid);

--get dialled extension number
        domain_uuid = session:getVariable("domain_uuid")
        extension_uuid = session:getVariable("extension_uuid")
        forward_all_destination = session:getVariable("forward_all_destination")
        context = session:getVariable("context")

--get extension details
        local sql = "select * from v_extensions ";
        sql = sql .. "where domain_uuid = :domain_uuid ";
        local params = {domain_uuid = domain_uuid};
        if (extension_uuid ~= nil) then
                sql = sql .. "and extension_uuid = :extension_uuid ";
                params.extension_uuid = extension_uuid;
        else
                sql = sql .. "and (extension = :extension or number_alias = :extension) ";
                params.extension = extension;
        end
        local row = dbh:first_row(sql, params)
        if not row then return end

        extension_uuid = row.extension_uuid;
        extension = row.extension;
        local number_alias = row.number_alias or '';
        local accountcode = row.accountcode;
        local forward_all_enabled = row.forward_all_enabled;
        local last_forward_all_destination = row.forward_all_destination;
        local follow_me_uuid = row.follow_me_uuid;
        local toll_allow = row.toll_allow or '';
        local forward_caller_id_uuid = row.forward_caller_id_uuid;
	local outbound_caller_id_number = row.outbound_caller_id_number;

--get the caller_id for outbound call
        local forward_caller_id = ""
        if not empty(forward_caller_id_uuid) then
                local sql = "select destination_number, "..
                        "destination_caller_id_number,destination_caller_id_name " ..
                        "from v_destinations where domain_uuid = :domain_uuid and " ..
                        "destination_type = 'inbound' and destination_uuid = :destination_uuid";
                local params = {domain_uuid = domain_uuid; destination_uuid = forward_caller_id_uuid}
                local row = dbh:first_row(sql, params)
                if row then
                        caller_id_number = row.destination_caller_id_number
                        if empty(caller_id_number) then
                                caller_id_number = row.destination_number
                        end
                        caller_id_name = row.destination_caller_id_name
                        if empty(caller_id_name) then
                                caller_id_name = row.destination_number
                        end
                end
		session:consoleLog("info","call forward uuid exists")
        else
--		local sql = "select destination_number,destination_caller_id_number,destination_caller_id_name"
--				.. " from v_destinations where domain_uuid= :domain_uuid and destination_type = 'inbound' and destination_number = :destination_number";
--		local params = {domain_uuid = domain_uuid; destination_number = outbound_caller_id_number}
--		local row = dbh:first_row(sql, params)
--		if row then
--                       caller_id_number = row.destination_caller_id_number
--                        session:consoleLog("info","caller id is"..caller_id_number)
--			if empty(caller_id_number) then
--                                caller_id_number = row.destination_number
--                        end
--                        caller_id_name = row.destination_caller_id_name
--                        if empty(caller_id_name) then
--                                caller_id_name = row.destination_number
--                        end
		caller_id_number = session:getVariable("caller_id_number");
		caller_id_name = session:getVariable("caller_id_name");
		session:consoleLog("info","Caller ID is " ..caller_id_number);
               -- end
	--	session:consoleLog("info","call forward uuid assigned")
	end
		

--set the caller id
        session:execute("set", "outbound_caller_id_number="..caller_id_number);
        session:execute("set", "outbound_caller_id_name="..caller_id_name);

--transfer the call
        session:execute("transfer", forward_all_destination .. " XML " .. context);

--disconnect from database
        dbh:release()
