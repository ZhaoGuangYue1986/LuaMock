----------------use sample----------------
-----0.设置lua的检索路径
-----0.Set lua search path for test
package.path = package.path .. ";..\\..\\?.lua;"

-----1.1引入LuaMock模块
-----1.1Require LuaMock Model
local Mock = require("LuaMock.Mock")

-----1.2 创建一个mock对象，并使用package.preload预加载测试文件中的返回Mock
-----1.2 create a mock object and use package.preload to reset the required file return val;
local requiredMsgManagerMocker = Mock:new("MsgManager")
package.preload["MsgManager"] = function() return requiredMsgManagerMocker end

-----2.1引入luaUnit模块,可以从https://github.com/ostack/LuaUnit下载[LuaUnit feature]
-----2.1Require LuaUnit Model, you can download form https://github.com/ostack/LuaUnit[LuaUnit feature]
local LuaUnit = require("LuaUnit.LuaUnit")

-----2.2派生一个测试类[LuaUnit feature]
-----2.2 derive a lua Testcase from LuaUnit[LuaUnit feature]
local TestCases = LuaUnit:derive("TestCases")

-----2.2引入要测试的文件，如果我么要mock测试文件中require的table表，这一步必须放在1.2 package.preload 之后
-----2.2 require files we need test，if we need mock local var in test file，this step must place below the 1.2 package.preload
local NeedTestTable = require("needTest_use_require")

-----4.1如果需要测试前准备的话，可以重写setUp方法,此方法将在所有用例运行前调用[LuaUnit feature]
-----4.1Third override setUp function if needed, this function will called before all test case run[LuaUnit feature]
function TestCases:setUp()
    ----You can use needTrace function to open lua debug trace
    Assert:needTrace(false)
    print("Test Unit set up func")
end

-----4.2如果需要测试前准备的话，可以重写tearDown方法,此方法将在所有用例运行完以后调用[LuaUnit feature]
-----4.2 Third override tearDown function if needed, this function will called after all test case run[LuaUnit feature]
function TestCases:tearDown()
    ----You can use needTrace function to open lua debug trace
    Assert:needTrace(false)
    print("Test Unit tearDown func")
end

-----4.3如果需要用例前测试前准备的话，可以重写caseSetUp方法,此方法将在每个用例运行前调用[LuaUnit feature]
-----4.3Third override tearDown function if needed, this function will called before each test case run[LuaUnit feature]
function TestCases:caseSetUp()
    print("Test Unit caseSetUp func")
end
-----4.4如果需要用例前测试前准备的话，可以重写caseSetUp方法,此方法将在每个用例运行前调用[LuaUnit feature]
-----4.4Third override tearDown function if needed, this function will called before each test case run[LuaUnit feature]
function TestCases:caseTearDown()
    print("Test Unit caseTearDown func")
    requiredMsgManagerMocker:verify();
end
-----5.1编写我们的测试用例。测试用例的名字必须以test开头[LuaUnit feature]
-----5.1Write our test code, test name should start with test[LuaUnit feature]
function TestCases:test_mock_non_arg_func_used_in_need_test_files()
    local mockedMsg = "Mocked msg";
    requiredMsgManagerMocker:mock("getMsg",mockedMsg,1)
    local rtnMsg = NeedTestTable:test_use_non_arg_function();
    Assert:equal(mockedMsg,rtnMsg)
end

function TestCases:test_mock_one_arg_func_used_in_need_test_files()
    local mockedCodeMsg = "Code_300";
    requiredMsgManagerMocker:mock("getMsgByCode",mockedCodeMsg,1,200)
    local rtnCodeMsg = NeedTestTable.test_use_one_arg_function(200);
    Assert:equal(mockedCodeMsg,rtnCodeMsg);
end

return TestCases:run()
