
    require "resources.functions.config";

    domain_name = session:getVariable("domain_name");
    domain_uuid = session:getVariable("domain_uuid")
    sip_from_user = session:getVariable('sip_from_user')
    conference_id = sip_from_user.."_"..domain_name
    callerid_number = sip_from_user
    extension = session:getVariable("digits") or nil;
    freeswitch.consoleLog("info","[ Conference ] calller id : "..tostring(callerid_number).."\n");
    api = freeswitch.API();
    freeswitch.consoleLog("info","[ Conference ] conference_id : "..tostring(conference_id).."\n");

    originating_leg_uuid = session:getVariable("originating_leg_uuid");
    freeswitch.consoleLog("info","[ Conference ] : originating_leg_uuid ==== " ..tostring(originating_leg_uuid).."\n");

    uuid = session:getVariable("uuid");
    freeswitch.consoleLog("info","[ Conference ] : Joining B Conference Room " ..uuid.."\n");




    if tostring(extension) == "" or tostring(extension) == "nil" then
        freeswitch.consoleLog("info","[ Conference ] : Joining A Conference Room \n");
        --session:execute("conference",conference_id.."@default+flags{json-events|mintwo}")
        cmd = "uuid_hold "..tostring(uuid);
    	api = freeswitch.API();
        result = api:executeString(cmd);
	--session:execute("park")
	return

    end

    uuid = session:getVariable("uuid");
    freeswitch.consoleLog("info","[ Conference ] : Joining B Conference Room " ..uuid.."\n");

    aleguuid = session:getVariable("aleg_uuid");
    freeswitch.consoleLog("info","[ Conference ] : A Leg UUID ==== " ..tostring(aleguuid).."\n");
    --originating_leg_uuid = session:getVariable("originating_leg_uuid");
    
    --freeswitch.consoleLog("info","[ Conference ] : originating_leg_uuid ==== " ..tostring(originating_leg_uuid).."\n");
    apicmd = "create_uuid";

    origination_uuid = api:executeString(apicmd);

    freeswitch.consoleLog("info","[ Conference ] origination_uuid : "..tostring(origination_uuid).."\n")

    aleg_uuid = session:getVariable('aleg_uuid')
    freeswitch.consoleLog("info","[ Conference ] aleg_uuid : "..tostring(aleg_uuid).."\n")

    cmd = "uuid_setvar ".. origination_uuid .." aleg_uuid="..tostring(aleg_uuid);
    api = freeswitch.API();
    result = api:executeString(cmd);

    freeswitch.consoleLog("info","[ Conference ] conference_id : "..tostring(conference_id).."\n");

    dialstring = "{origination_uuid="..origination_uuid..",origination_caller_id_number="..callerid_number.."}sofia/external/"..extension.."@128.136.235.202:5060"

    freeswitch.consoleLog("info","[ Conference ] Dial String : "..tostring(dialstring).."\n");
    --user_valu="bgapi originate "..tostring(dialstring).. " &conference("..conference_id..")"
    user_valu="bgapi originate "..tostring(dialstring).. " &bridge("..uuid..")"


    --freeswitch.consoleLog("info","[ Conference ]  : user_valu "..user_valu.."\n")
    --freeswitch.consoleLog("info","[ Conference ]  : Calling C Party and Joined to Conference Room "..conference_id.."\n")

    -- Execute API to originate new call.

    api = freeswitch.API();
    reply = api:executeString(user_valu);
    --session:execute("conference",conference_id.."@default+flags{moderator|mintwo}")


 --if tostring(aleguuid) == "" or tostring(aleguuid) == "nil" then
       --aleguuid = originating_leg_uuid

    --end


    --apicmd = "uuid_bridge "..tostring(aleguuid) .." "..origination_uuid;
    --result = api:executeString(apicmd);        
    --freeswitch.consoleLog("info","[ Conference ]  : result : "..result.."\n")

    --freeswitch.consoleLog("info","[ Conference ]  : After Conference Room\n")
