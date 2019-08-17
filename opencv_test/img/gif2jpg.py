import sys
from PIL import Image

argv = sys.argv
argc = len(argv)

# argument check
if argc != 4:
    print("argument error")
    print("%s [input filename] [output filename] ['rgb' or 'gray']" % argv[0])
    exit()

# color style
if argv[3] == 'rgb':
    color = 'RGB'
else :
    color = 'L'

# convert image
Image.open(argv[1]).convert(color).save(argv[2])
