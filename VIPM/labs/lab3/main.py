import cv2
from matplotlib import pyplot as plt
import math
import numpy as np

eps = np.finfo(float).eps
coudble = 1 / math.log10(1 + 1)


def get_scaling_factors(im):
    R = im[:, :, 0] + eps
    G = im[:, :, 1] + eps
    B = im[:, :, 2] + eps

    den = R + G + B
    return (R / den), (G / den), (B / den)


def get_decoupled_ycbcr(im, scaling):
    decoupled = cv2.cvtColor(im, cv2.COLOR_RGB2YCR_CB)
    y = decoupled[:, :, 0] / 255.
    denom = ((np.repeat(y[:, :, np.newaxis] + eps, 3, axis=2)) * 255) + 1
    color = im / denom
    return y.astype('float32'), color.astype('float32')


def get_decoupled_paper(im, scaling):
    R = im[:, :, 0]
    G = im[:, :, 1]
    B = im[:, :, 2]
    y = scaling[0] * R + scaling[1] * G + scaling[2] * B
    y = y / 255.

    denom = ((np.repeat(y[:, :, np.newaxis] + eps, 3, axis=2)) * 255) + 1

    color = im / denom
    return y.astype('float32'), color.astype('float32')


def get_layers(im, scaling):
    diagonal = np.hypot(im.shape[0], im.shape[1])
    intensity, color = get_decoupled_paper(im, scaling)
    log_intensity = coudble * np.log10(intensity + 1)

    large_scale = cv2.bilateralFilter(log_intensity, d=2, sigmaColor=40, sigmaSpace=0.015 * diagonal)
    detail = (log_intensity - large_scale).astype('float32')

    color = coudble * np.log10(color + 1)
    return color, log_intensity, large_scale, detail


if __name__ == '__main__':
    flash = (cv2.cvtColor(cv2.imread('images/giantFlash.jpg'),
                          cv2.COLOR_BGR2RGB))
    scaling = get_scaling_factors(flash)

    log_color_flash, log_intensity_flash, log_large_scale_flash, log_detail_flash = get_layers(flash, scaling)

    _, axs = plt.subplots(4, figsize=(20, 20))

    axs[0].imshow(log_color_flash)
    axs[0].set_title('Color')

    axs[1].imshow(log_intensity_flash, cmap='gray')
    axs[1].set_title('Intensity')

    axs[2].imshow(log_large_scale_flash, cmap='gray')
    axs[2].set_title('Large scale')

    axs[3].imshow(log_detail_flash, cmap='gray')
    axs[3].set_title('Detail')

    noFlash = (cv2.cvtColor(cv2.imread('images/giantNo-flash.jpg'),
                            cv2.COLOR_BGR2RGB)).astype('float32')

    log_color_noflash, log_intensity_noflash, log_large_scale_noflash, log_detail_noflash = get_layers(noFlash, scaling)

    plt.figure()
    _, axs = plt.subplots(4, figsize=(20, 20))

    axs[0].imshow(log_color_noflash)
    axs[0].set_title('Color')

    axs[1].imshow(log_intensity_noflash, cmap='gray')
    axs[1].set_title('Intensity')

    axs[2].imshow(log_large_scale_noflash, cmap='gray')
    axs[2].set_title('Large scale')

    axs[3].imshow(log_detail_noflash, cmap='gray')
    axs[3].set_title('Detail')

    plt.figure()

    weight = (log_large_scale_noflash + log_detail_flash)
    minw = np.min(weight)
    weight = (weight - minw)
    maxw = np.max(weight)
    weight = weight / maxw

    log_color_flash = (log_color_flash - np.min(log_color_flash))
    maxw = np.max(log_color_flash)
    log_color_flash = log_color_flash / maxw

    out = (np.repeat(weight[:, :, np.newaxis], 3,
                     axis=2) * log_color_flash)

    minout = np.min(out)
    out = (out - minw)
    maxw = np.max(out)
    out = out / maxw

    plt.imshow(out)
    plt.show()
