# LuaMock
一个使用起来超级方便的Lua Mock框架

（A very simple and easy use Lua Mock Framwork）

欢迎大家到 http://www.ostack.cn 交流编程经验

# TODO 
目前只支持对table表中声明的函数进行mock，后续考虑支持mock全局函数，不过因为lua 5.1和5.3 版本对全局env的方式不同，所以尚未考虑好怎么处理。
如果您对全局函数的Mock有任何想法或者建议的话，欢迎给我们提交issue，或者联系QQ/微信：316848526

Right now, we only support to mock the function which is declared in table, and we consider to support mock global function in few months, as the gloable env in lua vession 5.1 and 5.3 are different ,so I do not have any good idea to deal this problem ,if you have any suggestion ,welcome leave an issue or connect us with QQ/WeChat:316848526

# 使用示例（use example）sample.lua

local Mock = require("Mock")

local function testFoo()

    local TestMock = Mock:new("TestMock")
    
    TestMock:mock("foo", "outputPara", 1)
    
    print(TestMock.foo())
    
    print(TestMock.foo())
    
    TestMock:verify()
    
end

return testFoo()


# 相關倉庫
https://github.com/ostack/LuaUnit

https://github.com/ostack/LuaLogger

https://github.com/ostack/LuaMock
