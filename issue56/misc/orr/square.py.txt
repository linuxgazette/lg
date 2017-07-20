#! /usr/bin/python
"""square.py -- Make some noise about a square.
"""

class Square:
	def __init__(self, length, width):
		self.length = length
		self.width = width

	def area(self):
		return self.length * self.width

my_square = Square(5, 2)
print my_square.area()
