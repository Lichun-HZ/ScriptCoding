#!/usr/bin/python
# https://www.w3cschool.cn/python3/python3-data-type.html

# Number, String, Tuple, List, Set, Dictionary

"""
1：Number类型: 包括int, float, bool, complex
"""

a, b, c, d = 20, 5.5, True, 4+3j
print(type(a), type(b), type(c), type(d))

a=111
print("isinstance(a,int) =", isinstance(a,int))

'''
isinstance和type的区别在于：
type（）不会认为子类是一种父类类型。
isinstance（）会认为子类是一种父类类型。
'''
class A:
    pass

class B(A):
    pass

print("isinstance(A(), A) =", isinstance(A(), A))
print("(type(A()) == A) =", type(A()) == A)
print("isinstance(B(), A) =", isinstance(B(), A))
print("(type(B()) == A) =", type(B()) == A)