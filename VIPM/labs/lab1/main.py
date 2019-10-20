import cv2
import numpy as np

path = "./underexposed.jpg"


def _mask(img):
    img = cv2.bitwise_not(img)
    mask = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    blured_img = cv2.GaussianBlur(mask, (15, 15), cv2.BORDER_DEFAULT)
    return blured_img


def _local_contrast_correction(img, mask):
    exponent = np.repeat((2 ** ( (np.full((mask.shape), 128.) - mask) / 128))[:, :, np.newaxis],
                         3,
                         2)
    out = 255 * (img / 255.) ** exponent
    return out.astype(np.uint8)


if __name__ == "__main__":
    img = cv2.imread(path)
    mask = _mask(img)
    cv2.imshow("Original", img)
    cv2.imshow("Mask", mask)
    cv2.waitKey()
    out = _local_contrast_correction(img, mask)
    cv2.imshow("Corrected", out)
    cv2.waitKey()
