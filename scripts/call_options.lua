--[[
        call_option.lua : Add a participate in conference room.
--]]

    require "resources.functions.config";

    domain_name = session:getVariable("domain_name");
    domain_uuid = session:getVariable("domain_uuid")
    sip_from_user = session:getVariable('sip_from_user')
    conference_id = tostring(sip_from_user).."_"..tostring(domain_name)
    conference_id  = string.gsub(conference_id,"^+","")
    
    freeswitch.consoleLog("err","[ Conference ] Conference started : ".. tostring(conference_id).."\n");
    callerid_number = sip_from_user
    extension = session:getVariable("digits") or nil;
    freeswitch.consoleLog("info","[ Conference ] calller id : "..tostring(callerid_number).."\n");
    api = freeswitch.API();
    freeswitch.consoleLog("info","[ Conference ]  created conference_id : "..tostring(conference_id).."\n");

    if tostring(extension) == "" or tostring(extension) == "nil" then
        freeswitch.consoleLog("info","[ Conference ] : Joining A Conference Room \n");
        session:execute("conference",conference_id.."@default+flags{json-events|mintwo|dist-dtmf}")
        return
    end

	api = freeswitch.API();
    	cmd = "user_data ".. sip_from_user .."@" ..domain_name.." var outbound_caller_id_number";
   	outbound_caller_id_number = api:executeString(cmd);

    	cmd = "user_data ".. sip_from_user .."@" ..domain_name.." var outbound_caller_id_name";
    	outbound_caller_id_name = api:executeString(cmd);

	if not outbound_caller_id_number or outbound_caller_id_number == "" or outbound_caller_id_number == nil then
		callerid_number = session:getVariable("caller_id_number");
	else
		callerid_number = outbound_caller_id_number;
	end

	if not outbound_caller_id_name or outbound_caller_id_name == "" or outbound_caller_id_name == nil then
		callerid_number = session:getVariable("caller_id_name");
	else
		callerid_name = outbound_caller_id_name;
	end


    uuid = session:getVariable("uuid");
    freeswitch.consoleLog("info","[ Conference ] : Joining B Conference Room " ..uuid.."\n");

    aleguuid = session:getVariable("aleg_uuid");
    freeswitch.consoleLog("info","[ Conference ] : A Leg UUID ==== " ..tostring(aleguuid).."\n");
    originating_leg_uuid = session:getVariable("originating_leg_uuid");
    
    freeswitch.consoleLog("info","[ Conference ] : originating_leg_uuid ==== " ..tostring(originating_leg_uuid).."\n");
    apicmd = "create_uuid";

    origination_uuid = api:executeString(apicmd);

    freeswitch.consoleLog("info","[ Conference ] origination_uuid : "..tostring(origination_uuid).."\n")

    aleg_uuid = session:getVariable('aleg_uuid')
    freeswitch.consoleLog("info","[ Conference ] aleg_uuid : "..tostring(aleg_uuid).."\n")

    cmd = "uuid_setvar ".. origination_uuid .." aleg_uuid="..tostring(aleg_uuid);
    api = freeswitch.API();
    result = api:executeString(cmd);

    freeswitch.consoleLog("info","[ Conference ] conference_id : "..tostring(conference_id).."\n");

	cmd = "user_exists id ".. extension .." "..domain_name;
    	user_exists = api:executeString(cmd);

	if user_exists == "true" then

		api = freeswitch.API();
    		cmd = "user_data ".. sip_from_user .."@" ..domain_name.." var effective_caller_id_number";
	   	outbound_caller_id_number = api:executeString(cmd);

    		cmd = "user_data ".. sip_from_user .."@" ..domain_name.." var effective_caller_id_name";
	    	outbound_caller_id_name = api:executeString(cmd);

		if not outbound_caller_id_number or outbound_caller_id_number == "" or outbound_caller_id_number == nil then
			callerid_number = session:getVariable("caller_id_number");
		else
			callerid_number = outbound_caller_id_number;
		end

		if not outbound_caller_id_name or outbound_caller_id_name == "" or outbound_caller_id_name == nil then
			callerid_number = session:getVariable("caller_id_name");
		else
			callerid_name = outbound_caller_id_name;
		end

		dialstring = "{origination_uuid="..origination_uuid..",origination_caller_id_number="..callerid_number..",origination_caller_id_name="..tostring(callerid_name).."}user/"..extension.."@"..domain_name;
	else
		api = freeswitch.API();
    		cmd = "user_data ".. sip_from_user .."@" ..domain_name.." var outbound_caller_id_number";
   		outbound_caller_id_number = api:executeString(cmd);

	    	cmd = "user_data ".. sip_from_user .."@" ..domain_name.." var outbound_caller_id_name";
	    	outbound_caller_id_name = api:executeString(cmd);

		if not outbound_caller_id_number or outbound_caller_id_number == "" or outbound_caller_id_number == nil then
			callerid_number = session:getVariable("caller_id_number");
		else
			callerid_number = outbound_caller_id_number;
		end

		if not outbound_caller_id_name or outbound_caller_id_name == "" or outbound_caller_id_name == nil then
			callerid_number = session:getVariable("caller_id_name");
		else
			callerid_name = outbound_caller_id_name;
		end

		dialstring = "{origination_uuid="..origination_uuid..",origination_caller_id_number="..tostring(callerid_number)..",origination_caller_id_name="..tostring(callerid_name).."}sofia/external/"..extension.."@128.136.235.202:5060"
	end

    freeswitch.consoleLog("info","[ Conference ] Dial String : "..tostring(dialstring).."\n");
    user_valu="bgapi originate "..tostring(dialstring).. " &conference("..conference_id..")"

    freeswitch.consoleLog("info","[ Conference ]  : Calling C Party and Joined to Conference Room "..conference_id.."\n")

    -- Execute API to originate new call.

    api = freeswitch.API();
    reply = api:executeString(user_valu);
    session:execute("conference",conference_id.."@default+flags{moderator|mintwo}")


    if tostring(aleguuid) == "" or tostring(aleguuid) == "nil" then
       aleguuid = originating_leg_uuid
    end

    apicmd = "uuid_bridge "..tostring(aleguuid) .." "..origination_uuid;
    result = api:executeString(apicmd);        
    freeswitch.consoleLog("info","[ Conference ]  : result : "..result.."\n")
    freeswitch.consoleLog("info","[ Conference ]  : After Conference Room\n")
