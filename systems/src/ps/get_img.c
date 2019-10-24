#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>

#define IMG_WIDTH  640
#define IMG_HEIGHT 480
#define IMG_PIXELS IMG_WIDTH * IMG_HEIGHT

unsigned int* map_addr;
inline uint8_t read_pixel(uint32_t read_addr);

int main(void)
{
    int i, uiofd;
    FILE *fp;
    uint8_t *img;
    clock_t start, end;

    /* open uio */
    uiofd = open("/dev/uio0", O_RDWR);
    if (uiofd < 0) {
        perror("uio open:");
        return errno;
    }

    /* set map_addr */
    map_addr = (unsigned int*)mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, uiofd, 0);
    if (!map_addr){
        fprintf(stderr, "mmap failed\n");
        return errno;
    }
    
    /* malloc img */
    img = (uint8_t*)malloc(sizeof(uint8_t) * (IMG_PIXELS));
    if (img == NULL) {
      printf("cannot malloc img\n");
      return 1;
    }

    /* pixel-data into img */
    start = clock();
    for (i=0; i<IMG_PIXELS; i++) {
      img[i] = read_pixel(i);
    }
    end = clock();
    printf("pixels reading time: %lf[sec]\n", (double)(end-start)/CLOCKS_PER_SEC);

    /* open pgm file */
    fp = fopen("img.pgm", "wb");
    if (fp == NULL) {
        fprintf(stderr, "file open failed\n");
        return errno;
    }

    /* write pgm */
    fprintf(fp, "P5\n%d %d\n%d\n", IMG_WIDTH, IMG_HEIGHT, 255);
    if(fwrite(img, sizeof(uint8_t), IMG_PIXELS, fp) < IMG_PIXELS) {
        fprintf(stderr, "fwrite failed\n");
        return errno;
    }

    if (munmap(map_addr, 4096) != 0) {
        fprintf(stderr, "file munmap failed\n");
        return errno;
    }
    fclose(fp);
    free(img);
    close(uiofd);

    return errno;
}

uint8_t read_pixel(uint32_t read_addr) {
  /* set r_addr */
  map_addr[0] = 5;
  map_addr[1] = read_addr;

  /* read pixel */
  map_addr[2] = 1;

  return map_addr[3];
}
