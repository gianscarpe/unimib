import cv2
from matplotlib import pyplot as plt

import numpy as np

eps = 0.000001
eps1 = 0.0000001


def get_scaling_factors(im):
    R = im[:, :, 0]
    G = im[:, :, 1]
    B = im[:, :, 2]

    den = R + G + B
    return (R / den), (G / den), (B / den)

def get_wb_factors(im1, im2):




def get_decoupled(im, scaling):
    R = im[:, :, 0]
    G = im[:, :, 1]
    B = im[:, :, 2]
    I = scaling[0] * R + scaling[0] * G + scaling[0] * B
    color = im / np.repeat(I[:, :, np.newaxis], 3, axis=2)
    return I.astype('float32'), color.astype('float32')


def get_layers(im, scaling):
    diagonal = np.hypot(im.shape[0], im.shape[1])
    intensity, color = get_decoupled(im, scaling)
    log_intensity = np.log10(intensity + eps)
    log_color = np.log10(color + eps)

    large_scale = cv2.bilateralFilter(log_intensity, d=15, sigmaColor=40, sigmaSpace=0.015 * diagonal) + eps1
    detail = (log_intensity - large_scale).astype('float32')

    return log_color, log_intensity, large_scale, detail


if __name__ == '__main__':
    flash = (cv2.cvtColor(cv2.imread('images/lightCorrection/cakeFlash.jpg'),
                          cv2.COLOR_BGR2RGB) / 255.).astype('float32')
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

    noFlash = (cv2.cvtColor(cv2.imread('images/lightCorrection/cakeNo-flash.jpg'),
                            cv2.COLOR_BGR2RGB) / 255.).astype('float32')

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
    out = 10 ** (np.repeat((log_large_scale_noflash + log_detail_flash)[:, :, np.newaxis], 3,
                           axis=2) + log_color_flash)

    plt.imshow(out)
    plt.show()
