
package.path = package.path .. ";..\\..\\?.lua;"
local Mock = require("LuaMock.Mock")
----require lib of luaUnit
local LuaUnit = require("LuaUnit.LuaUnit")
local NeedTestTable = require("needTest")

----derive a TestCases
local TestCases = LuaUnit:derive("TestCases")

function TestCases:setUp()
    ----You can use needTrace function to open lua debug trace
    Assert:needTrace(false)
    print("Test Unit set up func")
end

-----4.如果需要测试前准备的话，可以重写tearDown方法,此方法将在所有用例运行完以后调用
-----4.Third override tearDown function if needed, this function will called after all test case run
function TestCases:tearDown()
    ----You can use needTrace function to open lua debug trace
    Assert:needTrace(false)
    print("Test Unit tearDown func")
end

----setup for case
function TestCases:caseSetUp()
    print("Test Unit caseSetUp func")
    globalMsgManager = Mock:new("globalMsgManager")
end
----teardown for case
function TestCases:caseTearDown()
    print("Test Unit caseTearDown func")
    globalMsgManager:verify();
end


function TestCases:testmock_non_arg_func_used_in_need_test_files()
    local mockedMsg = "Mocked msg";
    globalMsgManager:mock("getMsg",mockedMsg,1)
    local rtnMsg = NeedTestTable.test_use_non_arg_function();
    Assert:equal(mockedMsg,rtnMsg)
end

function TestCases:testmock_one_arg_func_used_in_need_test_files()
    local mockedCodeMsg = "Code_300";
    globalMsgManager:mock("getMsgByCode",mockedCodeMsg,1,200)
    local rtnCodeMsg = NeedTestTable:test_use_one_arg_function(200);
    Assert:equal(mockedCodeMsg,rtnCodeMsg);
end

return TestCases:run()
