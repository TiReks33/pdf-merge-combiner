# pdf-merge-combiner
Simple bash-script to merge scans,images,docs etc. into one PDF document [with optimized size for transfer via Web] using ::ghostscript:: and ::ImageMagick:: 
## Description
Sometime we need to upload documents on Web or send it via e-mail with some size limitations (like 10-15 MiB), while 1 good (high dpi) scan-copy of document page may have size over 1.5-2 MiB, while you have about 20-25 pages; and more of that, you need to merge lot of scan pages to 1 monolitic PDF (if pages scanned separetely) via special software. 
This script resolve this kind of problem -- you put your files/folders as argument to the script (this may be documents with various formats, images etc.), script converts this to .PDF format, tries to optimize its sizes and merges all processed files to one optimized document.
By default, folder of successfully merged files is >> $HOME/__OUTPUT_PDFS__/ (but this and some more settings can be configured by user in beginning of the script file). 
## Dependencies
imagemagick, ghostscript
## Usage
Put all of yours files/directories paths (absolute or relative) as arguments.
## Example
```console
foo@bar:~$ /bin/bash merge-pdfs.sh ~/Pictures/Sabu_with_his_Tandy_1000_Computer.jpg ~/Documents/testtt/*
```
