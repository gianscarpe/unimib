"""

Gianluca Scarpellini - lab2 - Visual Information processing and Management

g.scarpellini1[at]disco.unimib.it

Pyramidal blending: Blend 2 images using laplacian pyramids
"""

import cv2
import numpy as np
import argparse
from matplotlib import pyplot as plt

parser = argparse.ArgumentParser(description='Pyramid blend 2 images')
parser.add_argument('--img1', type=str, help='First image to blend')
parser.add_argument('--img2', type=str, help='Second image to blend')
parser.add_argument('--gaussian_filter', type=int, help='Gaussian filter', default=15)
parser.add_argument('--pyramid_levels', type=int, help='Gaussian filter', default=3)
parser.add_argument('--mask_window_size', type=int, help='Mask window size', default=30)
parser.add_argument('--mask', type=str, help='Mask for blending', default='default')

args = parser.parse_args()

img1_path = args.img1
img2_path = args.img2
mask_path = args.mask
w_size = args.mask_window_size

GAUSSIAN_FILTER_SIZE = args.gaussian_filter
N_LAYERS = args.pyramid_levels


def get_default_mask(img1_shape, w_size_blend):
    start_blend = img1_shape[1] // 2 - w_size_blend // 2
    blend_filter = np.transpose(
        np.repeat(np.concatenate([np.ones(start_blend),
                                  np.linspace(1, 0, num=w_size_blend, endpoint=False),
                                  np.zeros(img1_shape[1] - start_blend - w_size_blend)
                                  ])[:, np.newaxis],
                  img1_shape[0],
                  axis=1)
    )

    mask = np.repeat(blend_filter[:, :, np.newaxis],
                     3,
                     axis=2)
    return mask.astype('float32')


def gaussian_pyramid_level(previous_level_image):
    previous_level_dim = (previous_level_image.shape[1] // 2,
                          previous_level_image.shape[0] // 2)
    filtered_img = cv2.GaussianBlur(previous_level_image,
                                    (GAUSSIAN_FILTER_SIZE, GAUSSIAN_FILTER_SIZE), cv2.BORDER_TRANSPARENT)

    current_level_image = cv2.resize(filtered_img, previous_level_dim)

    return current_level_image.astype('float32')


def laplacian_pyramid_level(previous_level_image, current_level_image):
    previous_level_dim = (previous_level_image.shape[1],
                          previous_level_image.shape[0])
    current_level_image = cv2.resize(current_level_image, previous_level_dim)

    result = previous_level_image - current_level_image
    return result.astype('float32')


def build_pyramids(img):
    laplacian_pyramid = []
    gaussian_pyramid = [img]
    current_level = 0

    for i in range(N_LAYERS):
        previous_level = gaussian_pyramid[-1]
        current_level = gaussian_pyramid_level(previous_level)
        laplacian_current = laplacian_pyramid_level(previous_level, current_level)
        gaussian_pyramid.append(current_level)
        laplacian_pyramid.append(laplacian_current)
    laplacian_pyramid.append(current_level)

    return laplacian_pyramid, gaussian_pyramid


def combine_pyramids(p1, p2, mp):
    result = []

    for i in range(len(p1)):
        current = p1[i] * mp[i] + p2[i] * (1 - mp[i])
        result.append(current)
    return result


def collapse_pyramid(pyramid):
    result = pyramid[-1]
    for i in range(len(pyramid) - 2, -1, -1):
        next_level = pyramid[i]
        next_level_dim = (next_level.shape[1],
                          next_level.shape[0])

        result = cv2.resize(result, next_level_dim) + next_level

    return result


def show_pyramid(pyramid):
    for i in range(len(pyramid)):

        toshow = pyramid[i]
        if toshow.shape[-1] == 3:
            toshow = toshow.astype('float32')
            toshow = cv2.cvtColor(toshow, cv2.COLOR_BGR2RGB)

        plt.figure()
        plt.imshow(toshow)


if __name__ == '__main__':
    im1 = cv2.imread(img1_path) / 255.
    im2 = cv2.imread(img2_path) / 255.
    if mask_path == 'default':
        mask = get_default_mask(im1.shape, w_size)
    else:
        mask = cv2.imread(mask_path) / 255.

    current_level = im1
    gaussian_pyramid = []
    left_laplacian_pyramid, left_gaussian_pyramid = build_pyramids(im1)
    right_laplacian_pyramid, right_gaussian_pyramid = build_pyramids(im2)
    _, mask_pyramid = build_pyramids(mask)

    show_pyramid(mask_pyramid)
    combined = combine_pyramids(left_laplacian_pyramid, right_laplacian_pyramid, mask_pyramid)

    result = collapse_pyramid(combined)

    out_to_show = cv2.cvtColor(result, cv2.COLOR_BGR2RGB)
    plt.imshow(out_to_show)
    plt.show()
