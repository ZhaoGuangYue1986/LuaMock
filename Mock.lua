---
-- Created by zhao guangyue (jeky_zhao@qq.com)
-- DateTime: 2020/3/1 9:45
-- Copyright (c) 2015 ostack. http://www.ostack.cn
-- This source code is licensed under BSD 3-Clause License (the "License").
-- You may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     https://opensource.org/licenses/BSD-3-Clause
--/
-------------------common use function---------------

local function isEq(expect, actual)
    if expect ~= nil and actual ~= nil then
        if 'table' == type(expect) then
            return isTableEq(expect, actual)
        else
            return expect == actual
        end
    end
    return false
end

local function isTableContains(tab, element)
    if tab ~= nil and 'table' == type(tab) then
        for key, val in pairs(tab) do
            if type(val) == type(element) then
                if isEq(element, val) then
                    return true
                end
            end
        end
        return true
    end
    return false
end

local function isTableEq(expect, actual)
    if expect ~= nil and actual ~= nil then
        if 'table' == type(expect) and 'table' == type(actual) and #expect == #actual then
            for key, val in pairs(expect) do
                if not isTableContains(actual, val) then
                    return false
                end
            end
            return true
        end
    end
    return false;
end

local function log(msg)
    print("[LUA MOCK] " .. msg)
end
-------------------class for Error-------------------
local Error = {}
function Error:new(msg, code)
    local err = { _l_err_code_ = code or 65535, _l_err_msg_ = msg or "" }
    setmetatable(err, self)
    self.__index = self;
    return err
end

function Error:throw()
    error(self._l_err_msg_, 0)
end

-------------------class for times--------------------
local Times = {}
function Times:new(times)
    local times = { _l_times_num_ = times or 0 }
    setmetatable(times, self)
    self.__index = self
    return times
end
function Times:set(times)
    self._l_times_num_ = times
end

function Times:get()
    return self._l_times_num_
end

function Times:increase(step)
    self._l_times_num_ = self._l_times_num_ + step
end

function Times:equal(other)
    local selfTimes = self._l_times_num_;
    local otherTimes = other._l_times_num_;
    return selfTimes ~= nil and otherTimes ~= nil and selfTimes == otherTimes
end

-------------------class for args--------------------
local Args = {}
function Args:new(...)
    local args = { _l_args_val_ = { ... } }
    setmetatable(args, self)
    self.__index = self
    return args
end

function Args:equal(other)
    local selfArgs = self._l_args_val_
    local otherArgs = other._l_args_val_
    return isTableEq(selfArgs, otherArgs)
end

function Args:toString()
    local argStr = ""
    for key, val in pairs(self._l_args_val_) do
        if argStr ~= "" then
            argStr = argStr .. ","
        end
        argStr = argStr .. tostring(val)
    end
    return "(" .. argStr .. ")"
end

-------------------class for Method--------------------
local Method = {}
function Method:new(className, methodName)
    local method = { _l_method_class_name = className, _l_method_name_ = methodName, _l_method_expect_calls_ = {}, _l_method_unexpect_calls_ = {}, _l_current_arg_ = {} }
    method.mock = self.mock
    method.with = self.with
    method.result = self.result
    method.times = self.times
    method.willRtn = self.willRtn
    method.verify = self.verify
    return method
end

function Method:times(times)
    self._l_current_arg_._l_method_expect_times:set(times);
    return self
end
function Method:with(...)
    self:mock(nil,0,...)
    return self
end

function Method:willRtn(result)
    self._l_current_arg_._l_method_rlt_ = result;
    return self
end

function Method:mock(result, times, ...)
    local args = Args:new(...)
    local currentMethodArgs = self._l_current_arg_._l_method_args_
    if currentMethodArgs ~= args then
        local expectArgs = Method:createExpectCallArgs(result, times, args)
        table.insert(self._l_method_expect_calls_, expectArgs)
        self._l_current_arg_ = expectArgs;
    else
        self._l_current_arg_._l_method_rlt_ = result
        self._l_current_arg_._l_method_expect_times = Times:new(1)
        self._l_current_arg_._l_method_actual_times_ = Times:new(0)
    end
    return self
end

function Method:result(...)
    local actualArgs = Args:new(...)
    local expectArgs = self._l_method_expect_calls_
    for key, val in pairs(expectArgs) do
        if val._l_method_args_:equal(actualArgs) then
            val._l_method_actual_times_:increase(1)
            return val._l_method_rlt_
        else
            log("actualArgs:"..actualArgs:toString()..",mockArgs:"..val._l_method_args_:toString())    
        end
    end
    return Method:unExpectCalls(self, 1, ...)
end

function Method:verify()
    local msg = Method:checkExpectCalls(self)
    msg = msg .. Method:checkUnExpectCalls(self)
    return msg
end

function Method:getName()
    return self._l_method_class_name .. "." .. self._l_method_name_
end
------------------------private functions for method---------------------------------
function Method:checkExpectCalls(mockMethod)
    local msg = ""
    local expectCalls = mockMethod._l_method_expect_calls_
    for key, val in pairs(expectCalls) do
        if not val._l_method_expect_times:equal(val._l_method_actual_times_) then
            msg = msg .. Method:buildErrMsg(mockMethod._l_method_class_name, mockMethod._l_method_name_, val)
        end
    end
    return msg
end

function Method:checkUnExpectCalls(mockMethod)
    local msg = ""
    local unExpectCalls = mockMethod._l_method_unexpect_calls_
    for key, val in pairs(unExpectCalls) do
        msg = msg .. Method:buildErrMsg(mockMethod._l_method_class_name, mockMethod._l_method_name_, val)
    end
    return msg
end

function Method:buildErrMsg(className, functionName, mockMethod)
    local tabSpace = "   "
    local msg = ""..tabSpace .. className .. "." .. functionName .. mockMethod._l_method_args_:toString() .. " Call times not as expect\n"
    msg = msg .. tabSpace .. "Expect:" .. tostring(mockMethod._l_method_expect_times:get()) .. "\n"
    msg = msg .. tabSpace .. "Actual:" .. tostring(mockMethod._l_method_actual_times_:get())
    return msg
end

function Method:createExpectCallArgs(result, times, args)
    local actualTimes = Times:new(0)
    local expectTimes = Times:new(times)
    return { _l_method_args_ = args, _l_method_expect_times = expectTimes, _l_method_actual_times_ = actualTimes, _l_method_rlt_ = result }
end

function Method:unExpectCalls(self, times, ...)
    local args = Args:new(...)
    local actualTimes = Times:new(times)
    local expectTimes = Times:new(0)
    local unExpectCalls = self._l_method_unexpect_calls_
    for key, val in pairs(unExpectCalls) do
        if args:equal(val._l_method_args_) then
            val._l_method_actual_times_:increase(1)
            return nil
        end
    end
    local unExpectCall = { _l_method_args_ = args, _l_method_expect_times = expectTimes, _l_method_actual_times_ = actualTimes, _l_method_rlt_ = result }
    table.insert(self._l_method_unexpect_calls_, unExpectCall)
    return nil
end

-------------------class for Mock--------------------
local Mock = {}
function Mock:new(className)
    local mock = { _l_mock_class_name_ = className, _l_mock_methods_ = {} }
    setmetatable(mock, self)
    self.__index = self;
    return mock
end

function Mock:expectCall(functionName)
    local mockMethodKey = self._l_mock_class_name_ .. "-" .. functionName
    if self._l_mock_methods_[mockMethodKey] == nil then
        local mockMethod = Method:new(self._l_mock_class_name_, functionName)
        self[functionName] = function(...)
            return mockMethod:result(...)
        end
        self._l_mock_methods_.mockMethodKey = mockMethod
    end
    return self._l_mock_methods_.mockMethodKey
end



function Mock:mock(functionName, result, times, ...)
    local mockMethodKey = self._l_mock_class_name_ .. "-" .. functionName
    if self._l_mock_methods_[mockMethodKey] == nil then
        local mockMethod = Method:new(self._l_mock_class_name_, functionName):mock(result, times, ...)
        self[functionName] = function(...)
            return mockMethod:result(...)
        end
        self._l_mock_methods_.mockMethodKey = mockMethod
    else
        self._l_mock_methods_[mockMethodKey]:mock(result, times, ...)
    end
    return self._l_mock_methods_.mockMethodKey
end

function Mock:verify()
    local msg = ""
    local allMockMethods = self._l_mock_methods_
    for key, val in pairs(allMockMethods) do
        msg = msg .. val:verify()
    end
    self._l_mock_methods_ = {}
    if msg ~= "" then
        Error:new(msg):throw()
    end
end

return Mock