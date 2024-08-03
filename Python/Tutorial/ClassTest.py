#!/usr/bin/python
# https://www.w3cschool.cn/python3/python3-class.html

"""
1：类基本结构
"""

class MyClass:
    r"""一个简单的类实例"""

    iParam = 0      # 公开类变量
    cParam = 0      # 公开类变量
    __private_Param = 0  # 私有类变量

    # 定义构造方法
    def __init__(self, p1, p2):
        self.iParam = p1           # 使用self，创建了一个与类变量iParam同名的实例变量
        self.__private_Param = p2  #
 
    # 定义私有实例方法
    def __f(self):
        print('hello world')
    
    # 定义公开实例方法
    def f(self):
        self.__f()

    # 类方法。类方法是绑定到类而不是实例的方法，其第一个参数是 cls，指向类本身。使用 @classmethod 装饰器定义。
    @classmethod
    def myclass_method(cls):
        cls.iParam = 1000      # 通过cls访问的变量，为类变量，所有实例共享，即使与实例变量同名，也是两个变量。
        MyClass.cParam = 10000 # 类变量也可以直接通过类名访问，类方法中推荐使用cls，不同类写法统一，要访问其他类的类变量，则只能使用类名。

    
    # 静态方法不绑定到实例或类，没有默认参数 self 或 cls，使用 @staticmethod 装饰器定义。
    # 静态方法通常用于封装逻辑上属于类但不依赖于实例或类属性的功能。因为它不能访问self或cls。
    @staticmethod
    def static_method(p1, p2):
        print(p1+p2)

# 实例化类
x = MyClass(1,2)
y = MyClass(10,20)

# 调用实例方法
x.f()

# 外部不能访问私有变量
# print("x.iParam =", x.__private_Param)

# 外部不能访问私有方法
# x.__f()

# 调用类方法，不需要实例化对象，使用类名直接调用。
MyClass.myclass_method()

print("MyClass.iParam =", MyClass.iParam)
print("MyClass.cParam =", MyClass.cParam)

# 有与类变量同名的实例变量，通过对象访问时，访问的是实例变量，通过类名访问时，访问的是类变量
print("x.iParam =", x.iParam)
print("y.iParam =", y.iParam)

# 无与类变量同名的实例变量，通过对象访问时，访问的类变量。
print("x.cParam =", x.cParam)
print("y.cParam =", y.cParam)

# 调用静态方法，不需要实例化对象，使用类名直接调用。
MyClass.static_method(1,2)

"""
2：类特殊方法
"""
class Vector:
   def __init__(self, a, b):
      self.a = a
      self.b = b

   def __str__(self):
      return 'Vector (%d, %d)' % (self.a, self.b)
   
   def __add__(self,other):
      return Vector(self.a + other.a, self.b + other.b)

v1 = Vector(2,10)
v2 = Vector(5,-2)
print (v1 + v2)