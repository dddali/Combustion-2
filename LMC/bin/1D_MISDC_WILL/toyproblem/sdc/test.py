import t
from math import *
import matplotlib.pyplot as plt

C = 2.0

misdc_iters = [1, 2, 3, 4, 5, 6, 7, 8]

#dts = [min(abs(0.1/d), 0.125)]
dts = [0.25]
for j in range(5):
    dts.append(dts[j]/2)

E = []
for n in misdc_iters:
    e = []
    for dt in dts:
        e.append(t.solve_it(C, dt, max_iter=n))
    E.append(e)
    
    print 'misdc iterations: ', n
    for i in range(len(e)-1):
        print log(e[i+1]/e[i])/log(dts[i+1]/dts[i])
    
    plt.loglog(dts, e, label=str(n), marker='.')

plt.xlabel('dt')
plt.ylabel('L^1 error')
plt.legend()
plt.legend(loc=2)
plt.show()
