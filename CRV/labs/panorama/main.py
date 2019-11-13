import cv2
from matplotlib import pyplot as plt
import numpy as np


def merge_images(im, im2):
    orb = cv2.ORB_create()

    kp1, des1 = orb.detectAndCompute(im, None)
    kp2, des2 = orb.detectAndCompute(im2, None)

    # BFMatcher with default params
    bf = cv2.BFMatcher()
    matches = bf.knnMatch(des1, des2, k=2)
    # Apply ratio test
    good = []
    for m, n in matches:
        if m.distance < 0.75 * n.distance:
            good.append([m])
    # cv.drawMatchesKnn expects list of lists as matches.
    img3 = cv2.drawMatchesKnn(im, kp1, im2, kp2, good, None, flags=cv2.DrawMatchesFlags_NOT_DRAW_SINGLE_POINTS)


    MIN_MATCH_COUNT = 4
    if len(good) > MIN_MATCH_COUNT:
        src_pts = np.float32([kp1[m[0].queryIdx].pt for m in good]).reshape(-1, 1, 2)
        dst_pts = np.float32([kp2[m[0].trainIdx].pt for m in good]).reshape(-1, 1, 2)
        M, mask = cv2.findHomography(src_pts, dst_pts, cv2.RANSAC, 5.0)
        matchesMask = mask.ravel().tolist()
        h, w = im.shape
        pts = np.float32([[0, 0], [0, h - 1], [w - 1, h - 1], [w - 1, 0]]).reshape(-1, 1, 2)
        dst = cv2.perspectiveTransform(pts, M)
        img2 = cv2.polylines(im2, [np.int32(dst)], True, 255, 3, cv2.LINE_AA)
    else:
        print("Not enough matches are found - {}/{}".format(len(good), MIN_MATCH_COUNT))
        matchesMask = None

    # Cylindrical coordinates]
    # Warp source image to destination based on homography
    plt.imshow(im), plt.show()
    plt.imshow(cv2.warpPerspective(im, M, (im.shape[1], im.shape[0]))), plt.show()
    im_out = .5 * cv2.warpPerspective(im, M, (im2.shape[1], im2.shape[0])) + .5 * im2

    return im_out.astype('uint8')


im1 = cv2.imread('images/img1.jpg', cv2.IMREAD_GRAYSCALE)
im2 = cv2.imread('images/img2.jpg', cv2.IMREAD_GRAYSCALE)
im3 = cv2.imread('images/img3.jpg', cv2.IMREAD_GRAYSCALE)
plt.figure()
plt.imshow(im1)

plt.figure()
plt.imshow(im2)
plt.figure()
im_out = merge_images(im1, im2)
plt.figure()
plt.imshow(im_out)
f = 20000
out = np.zeros(im_out.shape)
s = f
x_index, y_index = np.indices(im_out.shape)
warp_index_x = (s * np.arctan(x_index / f)).astype('int')
warp_index_y = (s * y_index / (np.sqrt(x_index ** 2 + f ** 2))).astype('int')
out[warp_index_x, warp_index_y] = im_out[x_index, y_index]
plt.figure()
plt.imshow(out)
plt.show()
