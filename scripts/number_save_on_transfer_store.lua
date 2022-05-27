-- Save number_answered / original caller_id to database

--api = freeswitch.API()

if (session:ready()) then

    answered_extension = session:getVariable("dialed_user")
    caller_id = session:getVariable("sip_from_user") or ""
    domain_uuid = session:getVariable("domain_uuid") or ""

    if (answered_extension ~= nil and caller_id ~= nil) then
        freeswitch.consoleLog("INFO", "[RING_ALERT] Got answered call from "..caller_id.." to "..answered_extension.."\n")
        session:execute('hash', 'insert/transfer_store/'..answered_extension..domain_uuid..'/'..caller_id)
    end
end
