
local NeedTestTable = {}

function NeedTestTable.test_use_non_arg_function()
    --globalMsgManager is a global table requited by other file
    return globalMsgManager.getMsg();
end

function NeedTestTable:test_use_one_arg_function(code)
    --globalMsgManager is a global table requited by other file
    print("test_use_one_arg_function:"..code)
    return globalMsgManager.getMsgByCode(code);
end


return NeedTestTable