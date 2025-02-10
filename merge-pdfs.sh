#!/bin/bash

###############################################################################
#   Simple bash-script to merge scans,images,docs etc. into one PDF document  # 
#                  [with optimized size for transfer via Web]                 #
#                   using ::ghostscript:: and ::ImageMagick::                 #
###############################################################################
# [v.1.0] TiReks33@gmail.com                                                  #
###############################################################################
                                   #
# Set-up custom settings-->        #
                                   #
CLEAR_CONVERTED_FILES=true         # if [true], if some files needs to conver-
                                   # -ting first, and if this converting 
                                   # successful, only files with original 
                                   # format will be remain; 
                                   #
                                   # [false] -- converted PDFs will be saved
                                   # in same folder as originals. 
                                   #
QUALITY="/ebook"                   # dPDFSETTINGS	Description::
                                   # [/prepress] -- Better quality, 300dpi, 
                                   # higher weight;
                                   # [/ebook] -- Medium quality, 300dpi, 
                                   # moderate weight;
                                   # [/screen] -- Lower quality, 72dpi, 
                                   # the lightest 
                                   #
OUTPUT_DIR="$HOME/__OUTPUT_PDFS__" # Result files directory path (will be
                                   # created if not exist already)
                                   #
OUTPUT_FNAME="ResultDocument"      # default result document name
                                   #
abortingcommand="_abort"           # this command uses for permanent exit app
                                   # (when 'set output file name' stage)
                                   #
FA="[FAILED]"                      # log string "macros"
SU="[SUCCESS]"                     #
WA="[WARNING]"                     #
                                   #
##############################################################################

# Begin execution-->

# 'logo'
echo "**Pdf-merge combiner script**"$'\n'

num_of_elem=$#

# check numb of args
if [ $num_of_elem -eq 0 ]
    then
        echo "No documents provided, need at least 1."
        exit 1
fi

# check directory permissions
mkdir -p "${OUTPUT_DIR}"
if [ $? -ne 0 ]; then
    echo "$FA path access error: ${OUTPUT_DIR} ; aborting"
    exit 1
fi

# temp variable for custom user output file name
customuserfname=$OUTPUT_FNAME

# enter output file name
read -p "Enter output file name,"$'\n'"or tipe \"${abortingcommand}\" to exit script[\"${OUTPUT_FNAME}\"]:"$'\n' customuserfname

# permanent exit
if [ "$customuserfname" == "${abortingcommand}" ]; then
    echo "aborting.."
    exit 0
fi

# if name not empty -> set user custom name for output file
if [ -n "$customuserfname" ]; then
    OUTPUT_FNAME=$customuserfname
    echo ""
fi

# array for cleaning converted files with non-Pdf extension
CONVERTEDARRAY=()

# array with input args in right format (spacing support in args names)
arg_array=( "$@" )

# array with processed (converted) files args
STRARRAY=()

# read and parse input file args
for arg in "${arg_array[@]}"
do
    # if arg is folder -> next arg
    if [[ -d $arg ]]; then
        continue
    fi


    # paths and names parsing :->    

    # full path (with file and ext.) ;
    # 4ex.::/home/alexander/bash_scripts/testdir4/CCF_000012.pdf
    fullfpath=$(realpath -- "$arg")
    #echo "FULL FILE PATH::${fullfpath}" 
    
    # only path (without file)
    # 4ex.::/home/alexander/bash_scripts/testdir4
    pathname=$(dirname -- "$arg")
    #echo "PATH NAME::${pathname}"

    # only file without path (with ext.)
    # 4ex.::CCF_000012.pdf
    basefname=$(basename -- "$arg") # this removes file path
    #echo "BASE FILE NAME::${basefname}"

    # only extension of the file (withoud dot)
    # 4ex.::pdf
    extension="${basefname##*.}"
    #echo "EXTENSION::${extension}"

    # only file name (without ext.)
    # 4ex.::CCF_000012
    clearfname="${basefname%.*}"
    #echo "CLEAR FILE NAME::${clearfname}"
    
   
    echo "Processing file [${fullfpath}].."

    tempfname="${pathname}/${clearfname}"

    if [ "${extension}" != "pdf" ]
    then
        echo "Document [${clearfname}] has non-PDF format(.${extension})," \
        "trying convert it to PDF.."
        
        # check if identical file exist -> add next number (for non-overwrite)                
        if [[ -e $tempfname.pdf || -L $tempfname.pdf ]] ; then
            i=0
            while [[ -e $tempfname-$i.pdf || -L $tempfname-$i.pdf ]] ; do
                let i++
            done
            tempfname=$tempfname-$i
        fi
        
#        echo "TEMPNAME::${tempfname}"
        
        # trying to convert input file to Pdf via ::ImageMagick::         
        convert "${pathname}/${basefname}" "${tempfname}.pdf"
        try2convert=$?
        if [ $try2convert != 0 ]; then 
        echo "$WA converting [${clearfname}] failed!"$'\n'
        continue;

        else 
            echo "$SU converting [${clearfname}] to PDF successful!"
            
            # if flag set -> add converted file in query to cleaning
            if $CLEAR_CONVERTED_FILES ; then
                CONVERTEDARRAY+=("${tempfname}.pdf")
            fi
        fi
    fi

    # add files to merging
    STRARRAY+=("${tempfname}.pdf")
    echo ""
done

# if no valid files -> exit
if [ -z "$STRARRAY" ]; then
    #echo "$WA no valid PDF-documents to merge. " \
    #"Final document may can be empty."
    printf "\n$FA no valid PDF-documents to merge; aborting.\n"
    exit 1
fi

# check if identical file already exist -> add number (for non-overwrite)
ResFile="${OUTPUT_DIR}/${OUTPUT_FNAME}"
if [[ -e $ResFile.pdf || -L $ResFile.pdf ]] ; then
    i=0
    while [[ -e $ResFile-$i.pdf || -L $ResFile-$i.pdf ]] ; do
        let i++
    done
    ResFile=$ResFile-$i
fi

#echo ""

# tmp array for displaying comma-separated entries
tmpArray2output=$(printf " %s," "${STRARRAY[@]}")
echo "Next PDFs will be merged into one file \"${OUTPUT_FNAME}.pdf\" and " \
"shrinked (compressed):"$'\n'"[${tmpArray2output%,} ]"
echo ""
echo "Processing output result file.." 
echo "" 

# merge
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite \
-sOutputFile="${ResFile}.pdf" "${STRARRAY[@]}" 

# shrink (compress)
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS="${QUALITY}" \
-dNOPAUSE -dQUIET -dBATCH -sOutputFile="${ResFile}shr.pdf" "${ResFile}.pdf"

echo "cleaning up stuffs.."

# delete source 'non-shrinked' file..
rm "${ResFile}.pdf"

# rename shrinked to default name
mv "${ResFile}shr.pdf" "${ResFile}.pdf"

# if flag set -> clean converted files
if $CLEAR_CONVERTED_FILES ; then
    if (( ${#CONVERTEDARRAY[@]} )); then
        rm "${CONVERTEDARRAY[@]}"
    fi
fi

echo ""
echo "Output merged PDF-document path: ${ResFile}.pdf"

echo ""
echo "The script has finished its work. Bye!"



