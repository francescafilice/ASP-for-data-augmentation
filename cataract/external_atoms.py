import math

def sqrt(n):
    return int(math.sqrt(n))

def dist(rx, cx, ry, cy):
    c = abs(cx-cy)
    r = abs(rx-ry)
    return int(math.sqrt(c*c+r*r))