#!/usr/bin/lua
require("lldebugger").start()

--������������������������������ԣ����Ҹ��������Եĳ�ʼֵ
---@class Class
---@field x integer
---@field y integer
Class = {x=0,y=0}

--����Ԫ�����������ģ����Ļ����ⲽ�����ܹؼ�
Class.__index = Class

--���췽�������췽���������������ģ�ϰ��������Ϊnew()
---@return Class
---@param x integer
---@param y integer
function Class.new(x,y)
    --����һ���±�instance�������µĶ���
    local instance = {}

    --��instance��Ԫ���趨ΪClass����ΪClass.__index����Class������instance.���ʲ����ڵ�Ԫ��ʱ������Class���в�ѯ��
    setmetatable(instance, Class)

    --����ֵ��ʼ�����ڴ�֮ǰ����instance.x����Ϊinstance����û��x�������Class.x��
    --instance.x = x����instance.x����ΪԪ��Class��û��__newindex�����Ի�Ϊ��instance����x�����x���൱��instance�Լ��ı���ֵ
    --��instance.x = x֮������ٷ���instance.x���ͻ����instance���Լ��ģ��������ٷ���Class.x��
    --��ˣ�instance���еı���ֻ���ڵ�һ�θ�ֵʱ�Żᴴ���������һֱ����Class���еġ���պ���������Ϊ�ϻ��������϶�����õģ�
    --������ʱ��ÿ��ʵ���������Ĭ��ֵ���ĸ�ʵ�������ˣ���Ϊ�䵥������һ���Լ��ı�����֮��ͷ����Լ��ģ�����ʵ�����ǹ�����ġ�
    instance.x = x
    instance.y = y

    return instance  --��������
end

 --���ﶨ�������������
function Class:print()
    print(self.x,self.y)
end

function Class:plus()
    self.x = self.x + 1
    self.y = self.y + 1
end

--�������µ�����Z
---@class SubClass : Class
---@field z integer
SubClass = {z = 0}

--���Ǻ��ඨ��һ�����������趨Ϊ����
SubClass.__index = SubClass

--����Ԫ��ΪClass����ΪClass.__indexΪClass�����Ե�������SubClass���Ҳ���ʱ���ᵽClass���в��ҡ�
setmetatable(SubClass, Class)

--�����ǹ��췽�������new��SubClass���еģ�Class������һ���Լ���new
---@return SubClass
function SubClass.new(x,y,z)
    --�������൱���������Ե�super ���������Ϊ���ø���Ĺ��캯��
    local instance = Class.new(x,y)

    --�������Ԫ�����ΪSubClass�ࣨ����ΪClass�࣬���޷�����SubClass�ı����ͺ�����
    setmetatable(instance, SubClass)

    --�µ����Գ�ʼ�������û�н��ᰴ������=0
    --instance.z = z

    return instance
end

 --����һ���µķ���
function SubClass:go()
    self.x = self.x + 10
end

 --�ض��常��ķ������൱��override
function SubClass:print()
    print(self.x,self.y,self.z)
end

local a = Class.new(1, 2)
a:plus()
a:print()

local b = SubClass.new(10, 20, 30)
b:plus()
b:print()
b.z = 30
b:print()

--[[

�ؼ����룺

Class = {x=0,y=0}
Class.__index = Class

SubClass = {z = 0}
SubClass.__index = SubClass
setmetatable(SubClass, Class)

local a = {}
setmetatable(a, Class)

local b = {}
setmetatable(b, SubClass)

--]]