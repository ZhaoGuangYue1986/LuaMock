
local NeedTestTable = {}
local msgManager = require("MsgManager")

function NeedTestTable.test_use_non_arg_function()
    --msgManager is a global table requited by other file
    return msgManager.getMsg();
end

function NeedTestTable.test_use_one_arg_function(code)
    --msgManager is a global table requited by other file
    return msgManager.getMsgByCode(code);
end


return NeedTestTable