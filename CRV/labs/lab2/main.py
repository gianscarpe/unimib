import cv2
from matplotlib import pyplot as plt
import numpy as np
import glob
import pickle

images = glob.glob('images/*.jpg')
keypoints = []
scale_percent = 5
width = 300
height = 200
dim = (width, height)
objectpoints = []
path_image_founds = []
for im_name in images:

    im = cv2.cvtColor(cv2.imread(im_name), cv2.COLOR_BGR2RGB)

    im = cv2.resize(im, dim).astype('uint8')
    found, corners = cv2.findChessboardCorners(im, (7, 10))
    if found:
        path_image_founds.append(im_name)
        print(f'found for {im_name}')
        objp = np.zeros((10 * 7, 3), np.float32)
        objp[:, :2] = np.mgrid[0:7, 0:10].T.reshape(-1, 2)
        objectpoints.append(objp)
        points = np.squeeze(corners)
        keypoints.append(points)

ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(objectpoints, keypoints, dim,
                                                   None, None)
plt.show()


# Testing on image 1
i = 1
im = cv2.cvtColor(cv2.imread(path_image_founds[i]), cv2.COLOR_BGR2RGB)
im = cv2.resize(im, dim).astype('uint8')

points, e = cv2.projectPoints(objectpoints[i], rvecs[i], tvecs[i], mtx, dist)
points = np.squeeze(points.astype('uint8'))

keys = np.squeeze(keypoints[i])
plt.imshow(im)
plt.plot(keys[:, 0], keys[:, 1], 'go', markersize=2)
plt.plot(points[:, 0], points[:, 1], 'ro', markersize=2)

plt.show()

