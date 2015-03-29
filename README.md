# auto-image-cutter
A matlab program to cut text columns from image.

## Example

There is a simple example to show the function of this program.

### Original Image

Image from: Zhejiang University Advanced Honor Class of Engineering Education Entrance Practice 2015, Module 2, Section 1, Problem B.

![Original Image](sample/sample.bmp)

### Configure

```Matlab
left_bleed = 8;
right_bleed = 12;
bw_threshold_detect_offset = 0.61803398874989484820458683436;
blank_column_lightness_threshold = 0.985211;
run_length_encoding_minimal_distance = 10;
```

### Result

![Result Image 1](sample/sample.bmp.cut001.bmp)
* * *
![Result Image 2](sample/sample.bmp.cut002.bmp)
* * *
![Result Image 3](sample/sample.bmp.cut003.bmp)
* * *
![Result Image 4](sample/sample.bmp.cut004.bmp)
* * *
![Result Image 5](sample/sample.bmp.cut005.bmp)
