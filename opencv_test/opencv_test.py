import cv2
import numpy as np

## read image
img = cv2.imread("img/jpg/whiteline.jpg")
img_detected = cv2.imread("img/jpg/whiteline.jpg")

## convert to grayscale
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
ret, img_bin = cv2.threshold(img_gray, 200, 255, cv2.THRESH_BINARY)

## Edge filter
img_edge = cv2.Canny(img_bin, 100, 400)

## detect lines
img_line = cv2.HoughLinesP(img_edge, rho=1, theta=np.pi/360, threshold=60, minLineLength=10, maxLineGap=10)
for x1,y1,x2,y2 in img_line[0]:
  cv2.line(img_detected, (x1,y1), (x2,y2), (0,0,255), 2)

## write image
cv2.imwrite("img/jpg/whiteline_detected.jpg", img_detected)

## show images
cv2.imshow("color", img)
cv2.imshow("lines", img_detected)
cv2.waitKey(0)
cv2.destroyAllWindows()
