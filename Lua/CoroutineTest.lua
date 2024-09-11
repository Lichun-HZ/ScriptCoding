#!/usr/bin/lua
-- https://www.cnblogs.com/thammer/p/18112064
local co

function routine()
    print("��Э�����庯��ִ��ʱ����ѯ����Э��״̬:", coroutine.status(co))
    coroutine.yield()
    print("�˳�Э����")
end

function test1()
    co = coroutine.create(routine)
    print("�մ�����Э��ʱ��״̬:", coroutine.status(co))
    coroutine.resume(co)
    print("����resume����Э�̣�yield���״̬:", coroutine.status(co))
    coroutine.resume(co)
    print("Э���˳����״̬:", coroutine.status(co))
end

--[[ 
Э��״̬	          ˵��
running	    ����״̬��Э�����庯������ִ��ʱ��״̬
suspended	����״̬��Э�̵���yeild�����߸ոմ������ʱ��״̬
normal	    ����״̬��Э���Ѽ��resume��������ִ�����в��ڴ�Э���У�ͨ����Э��Ƕ��ʱ
dead	    ����״̬��Э�����庯��ִ����ϣ��������庯��ִ���쳣��ֹͣ���״̬
--]]

local co1, co2

function routine1()
    print("��һ��Э��")
    print("�ڵ�һ��Э�̲�ѯ���ĵ�һ��Э��״̬:", coroutine.status(co1))
    print("�ڵ�һ��Э�̲�ѯ���ĵڶ���Э��״̬:", coroutine.status(co2))
    coroutine.resume(co2)
    print("��һ��Э���˳���")
end

function routine2()
    print("�ڶ���Э��")
    print("�ڵڶ���Э�̲�ѯ���ĵ�һ��Э��״̬:", coroutine.status(co1))
    print("�ڵڶ���Э�̲�ѯ���ĵڶ���Э��״̬:", coroutine.status(co2))
    print("�ڶ���Э���˳���")
end

function test2()
    co1 = coroutine.create(routine1)
    co2 = coroutine.create(routine2)
    coroutine.resume(co1)
end

--[[ 
1. ��ڳ����һ�ε���resume������Э�̣�����Э�̺�����ʱ����ʱ������һ��ִ��Ȩ���л���resume�����в���"a", "b"�����˵�һ��thread���Ͳ������������ݸ���Э�̺�����Ĳ���p1, p2��
2. Э��ִ�����е���yield�ó�ִ��Ȩ��ִ�����лص���ں�����resume���õķ���ǰϦ�� yield�Ĳ���"c", "d"����Ϊresume�Ĵӵڶ���ʼ�ķ���ֵ�б�ִ��Ȩ�ص���ں����塣
3. ��ں��������ִ�����У��ڶ��ε���resume��ִ��Ȩ�ٴλ�Э��ִ�����У���ʱЭ��ִ������λ����һ��yield���õķ���ǰϦ��resume���ݵĲ���e����Ϊ��yield�ķ���ֵ��Э��ִ�����м���ִ�С�
4. Э�̺�����ִ�е����أ��ó�ִ��Ȩ������ֵ��Ϊ��һ����ں�����ִ�����еĵڶ���resume���õķ���ֵ��ִ�������ٴλص���ں����壬��ʱЭ��������״̬���dead��
5. ��ں������ٴ�ִ��resume,���ڴ�ʱЭ���Ѿ����ˣ�����resumeִ�н����ʧ�ܵģ�����ִ�н��false�ʹ�����Ϣ
--]]
function test3()
    local co = coroutine.create(function(p1, p2)
        print("���ݸ�Э����������Ĳ���:", p1, p2)
        while true do
            local yieldRet;
            yieldRet = coroutine.yield("c", "d")
            print("Э�̵�һ�ε���yield�ķ���ֵ�б�:", yieldRet)
            local coRet = "f"
            return coRet
        end
    end)

    local resRet, value1, value2 = coroutine.resume(co, "a", "b")
    print("��һ�ε���resume�ķ���ֵ�б�:", resRet, value1, value2)
     
    resRet, value1 = coroutine.resume(co, "e")
    print("�ڶ��ε���resume�ķ���ֵ�б�:", resRet, value1)
     
    resRet, value1 = coroutine.resume(co, "g")
    print("�����ε���resume�ķ���ֵ�б�:", resRet, value1)
end

test1()
test2()
test3()