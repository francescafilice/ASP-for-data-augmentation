from __future__ import division

def isRatioRespected(x, y):
    divisor = x if x > y else y
    dividend = x if x <= y else y
    ratio = round(dividend/divisor, 2)
    return ratio > round(2/3,2)