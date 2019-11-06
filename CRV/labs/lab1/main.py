"""

Gianluca Scarpellini - lab1 - Computer and Robot Vision

g.scarpellini1[at]disco.unimib.it

DLT: projection matrix estimation using SVD and MSE

"""

import numpy as np
import cv2
from matplotlib import pyplot as plt

points_im = np.array([
    (1864, 1682),
    (1572, 1862),
    (2628, 1719),
    (654, 1818),
    (1271, 1604),
    (136, 2145),
    (3096, 1678),
    (2086, 1944)
])

points_w = np.array([
    (450, 740, 45),
    (297, 591, 50),
    (510, 1190, 1),
    (252, 130, 49),
    (492, 385, 85),
    (0, 0, 0),
    (538, 1415, 13),
    (140, 870, 35)
])

H = np.zeros([16, 12])
i = 0
for point_im, point_w in (zip(points_im, points_w)):
    H[i, :] = np.array([-point_w[0], -point_w[1], -point_w[2], -1, 0, 0, 0, 0,
                        point_im[0] * point_w[0], point_im[0] * point_w[1],
                        point_im[0] * point_w[2], point_im[0]
                        ])

    H[i + 1, :] = np.array([0, 0, 0, 0, -point_w[0], -point_w[1], -point_w[2], -1,
                            point_im[1] * point_w[0], point_im[1] * point_w[1],
                            point_im[1] * point_w[2], point_im[1]
                            ])
    i += 2

_, _, vh = np.linalg.svd(H, full_matrices=True)

# Column with lower singular value
P = np.reshape(vh[-1, :], [3, 4])

results = [P @ np.array([x, y, z, 1]) for x, y, z in points_w]
results = np.array([(int(result[0] / result[2]), int(result[1] / result[2])) for result in results])

im = cv2.cvtColor(cv2.imread('./im.jpg'), cv2.COLOR_BGR2RGB)

plt.imshow(im)
for x, y in results:
    plt.plot(x, y, 'bo', markersize=3)
for u, v in points_im:
    plt.plot(u, v, 'go', markersize=3)
plt.show()

mse = (np.linalg.norm(results - points_im, axis=0)).mean(axis=0)
print(f'MSE {mse}')
