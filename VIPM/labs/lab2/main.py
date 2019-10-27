import cv2
import numpy as np
import argparse
from matplotlib import pyplot as plt

parser = argparse.ArgumentParser(description='Pyramid blend 2 images')
parser.add_argument('--img1', type=str, help='First image to blend')
parser.add_argument('--img2', type=str, help='Second image to blend')
parser.add_argument('--gaussian_filter', type=int, help='Gaussian filter', default=15)
parser.add_argument('--pyramid_levels', type=int, help='Gaussian filter', default=3)

args = parser.parse_args()

img1_path = args.img1
img2_path = args.img2
GAUSSIAN_FILTER_SIZE = args.gaussian_filter
N_LAYERS = args.pyramid_levels


def gaussian_pyramid_level(previous_level_image):
    previous_level_dim = (previous_level_image.shape[0] // 2,
                          previous_level_image.shape[1] // 2)
    filtered_img = cv2.GaussianBlur(previous_level_image,
                                    (GAUSSIAN_FILTER_SIZE, GAUSSIAN_FILTER_SIZE), cv2.BORDER_DEFAULT)

    current_level_image = cv2.resize(filtered_img, previous_level_dim)

    return current_level_image


def laplacian_pyramid_level(previous_level_image, current_level_image):
    previous_level_dim = (previous_level_image.shape[0],
                          previous_level_image.shape[1])

    current_level_image = cv2.resize(current_level_image, previous_level_dim)

    result = previous_level_image - current_level_image
    return result


def blend_pyramids(pyramid1, pyramid2):
    result_pyramid = []
    for i in range(len(pyramid1)):
        blended_level = blend_images(pyramid1[i], pyramid2[i], 30)
        result_pyramid.append(blended_level)

    return result_pyramid


def build_pyramids(img):
    current_level = img
    laplacian_pyramid = []
    gaussian_pyramid = [img]

    for i in range(N_LAYERS):
        previous_level = current_level
        current_level = gaussian_pyramid_level(previous_level)
        laplacian_current = laplacian_pyramid_level(previous_level, current_level)
        gaussian_pyramid.append(current_level)
        laplacian_pyramid.append(laplacian_current)
    laplacian_pyramid.append(current_level)

    return laplacian_pyramid, gaussian_pyramid,


def blend_images(img1, img2, w_size_blend=30, alpha=0.5):
    start_blend = img1.shape[0] // 2 - w_size_blend // 2
    blend_filter = np.transpose(
        np.repeat(np.concatenate([np.ones(start_blend),
                                  np.linspace(1, 0, num=w_size_blend, endpoint=False),
                                  np.zeros(img1.shape[0] - start_blend - w_size_blend)
                                  ])[:, np.newaxis],
                  img1.shape[1],
                  axis=1)
    )

    mask = np.repeat(blend_filter[:, :, np.newaxis],
                     3,
                     axis=2)

    left_img = img1 * mask
    right_img = img2 * np.flip(mask)

    result = alpha * left_img + (1 - alpha) * right_img

    return result


def combine_pyramids(p1, p2, wp):
    result = []

    for i in range(len(p1)):
        current = blend_images(p1[i], p2[i])
        result.append(current)
    return result


def collapse_pyramid(pyramid):
    result = pyramid[-1]
    for i in range(len(pyramid) - 2, -1, -1):
        next_level = pyramid[i]
        result = .5 * cv2.resize(result, next_level.shape[:2]) + .5 * next_level

    return result


def show_pyramid(pyramid):
    for i in range(len(pyramid)):
        cv2.imshow(f'Level {i}', pyramid[i])
        cv2.waitKey()


if __name__ == '__main__':
    im1 = cv2.imread(img1_path) / 255.
    im2 = cv2.imread(img2_path) / 255.

    # blend_images(im1, im2, 309)

    current_level = im1
    gaussian_pyramid = []
    left_laplacian_pyramid, left_gaussian_pyramid = build_pyramids(im1)
    right_laplacian_pyramid, right_gaussian_pyramid = build_pyramids(im2)

    weight_pyramid = blend_pyramids(left_gaussian_pyramid, right_gaussian_pyramid)
    combined = combine_pyramids(left_laplacian_pyramid, right_laplacian_pyramid)

    result = collapse_pyramid(combined)
    cv2.imshow('Result', result)
    cv2.waitKey()

    cv2.destroyAllWindows()
