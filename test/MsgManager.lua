
local MsgManager = {}

function MsgManager.getMsg()
    --globalTable is a global table requited by other file
    return MsgManager.msg or "Msg from MsgManager:getMsgManager function";
end

function MsgManager.setMsgRlt(msgInfo)
    --globalTable is a global table requited by other file
    MsgManager.msg =  msgInfo
end

function MsgManager.getMsgByCode(code)
    print("Code:"..code)
    if code == 200 then
        return "Code_200"
    else
        return "Code_Unknown"
    end    
end
return MsgManager