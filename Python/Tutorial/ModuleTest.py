#!/usr/bin/python
# https://www.w3cschool.cn/python3/python3-module.html

"""
1：引入sys标准库
"""
import sys

print('命令行参数如下:')
for i in sys.argv:
    print(i)

print('\n\nPython 路径为：', sys.path, '\n')

"""
2：引入自定义Module
"""
# 导入模块，这样做并没有把直接定义在 Support 中的函数名称写入到当前符号表里，只是把模块 Support 的名字写到了那里。
# 需要使用模块名称来访问函数
import Support

# 现在可以调用模块里包含的函数了
Support.print_func("w3cschool1")

# 如果你打算经常使用一个函数，你可以把它赋给一个本地的名称。
myprint = Support.print_func
myprint("w3cschool2")

# from ... import, 让你从模块中导入一个指定的部分到当前命名空间中，访问该模块内容时就不用添加模块名了。
# from modname import func1, func2  # 把一个模块的部分内容导入到当前的命名空间。
# from modname import *             # 把一个模块的所有内容全都导入到当前的命名空间，应避免使用，会污染当前命名空间。
from Support import print_func
print_func("w3cschool3")


"""
3：内置的函数 dir() 可以找到模块内定义的所有名称。以一个字符串列表(List)的形式返回。
"""
import Support, sys
print(dir(Support))
print(dir(sys))