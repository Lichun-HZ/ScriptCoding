#!/usr/bin/python3
# Filename: Support.py

def print_func( par ):
    print ("Hello : ", par)
    return

def print_func2( par ):
    print ("Hello2 : ", par)
    return

"""
每个模块都有一个 __name__ 属性，当其值是 '__main__' 时，表明该模块自身在运行，否则是被引入。
__name__ 与 __main__ 底下是双下划线，是“_ _”去掉中间的空格。
"""

if __name__ == '__main__':
    print('程序自身在运行')
else:
    print('我来自另一模块')