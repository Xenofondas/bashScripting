#!/bin/bash
DEFAULTPATH=`pwd`

SRCFILESFOLDER='src'
LIBFILESFOLDER='lib'
INCFILESFOLDER='inc'
BINFILESFOLDER='bin'

SRCCOUNTER=0
LIBCOUNTER=0
INCCOUNTER=0
BINCOUNTER=0

LOGNAME=$(pwd)"/organize.log"

echo -e "########### Collect Utility V1.2 ###############\n"

if [[ $# == 0 ]]; then
    echo "You didn't choose any folder"
    exit;
fi

array=()

for folder in "$@"
do
    while IFS=  read -r -d $'\0'; do
    fileList+=("$REPLY")
    done < <(find $folder -type f \( -iname \*.cpp -o \-iname \*.c -o \-iname \*.cxx  -o \-iname \*.cc -o \-iname \*.h -o \-iname \*.hxx -o -executable -o \-iname \lib* \) -print0)
done


if [[ ${#fileList[@]} == 0 ]]; then
    echo 'No relevant files found...'
    exit;   
fi

echo -e  "The following "${#fileList[@]}" files found":
for i in "${fileList[@]}"
do
   echo "$i"
done

echo -e "\n 1. Type a prefered title for the log file(followed by .log extension):"
echo "Defaul name (organize.log) will be selected automatically after 20 seconds..."

read -t 20 NEWLOGNAME 

if [[ $NEWLOGNAME != "" ]]; then    
  LOGNAME=${LOGNAME%/*}"/"$NEWLOGNAME
fi

touch $LOGNAME

echo -e "\n 2. Type ENTER to move the files to the default locations (/bin, /src, /lib, /inc) or type a different path you prefer."
echo "Defaul locations will be selected automaticaly after 20 seconds..."

read -t 20 DESTFOLDER
START=$(date +%s.%N)

if [[ "$DESTFOLDER" != "" ]] ; then
    SRCFILESFOLDER="$DESTFOLDER""/"$SRCFILESFOLDER
    LIBFILESFOLDER="$DESTFOLDER""/"$LIBFILESFOLDER
    INCFILESFOLDER="$DESTFOLDER""/"$INCFILESFOLDER
    BINFILESFOLDER="$DESTFOLDER""/"$BINFILESFOLDER
fi

    mkdir -p "$SRCFILESFOLDER"
    mkdir -p "$LIBFILESFOLDER"
    mkdir -p "$INCFILESFOLDER"
    mkdir -p "$BINFILESFOLDER"

moveFile () {
    if [[ -f ""$2"/$(basename "$1")" ]];then 
        echo "The file $(basename "$1") already exist in "$2" folder. Press ENTER if you want to overwrite it or type a new name:"
        read newFileName
        if  [[ $newFileName != "" ]]; then
            mv "$1" "$2"/$newFileName | echo `date` $file "successfully moved to folder:"$2 >>$3
        else 
            mv "$1" "$2" | echo `date` $file "successfully moved to folder:"$2 >>$3
        fi
    else 
        mv "$1" "$2" | echo `date` $file "successfully moved to folder:"$2 >>$3
    fi
}

for file in "${fileList[@]}"
do
    extention=$(echo "$file" |cut -f2 -d ".") 
      
	if [ $extention = "h" ] || [ $extention = "hxx" ];  then
        moveFile "$file" "$INCFILESFOLDER" $LOGNAME
        ((INCCOUNTER++))
    elif [ $extention = "cpp" ] || [ $extention = "c" ] || [ $extention = "cxx" ] || [ $extention = "cc" ]; then 
        moveFile "$file" "$SRCFILESFOLDER" $LOGNAME
        ((SRCCOUNTER++))        
    elif [[ "$file" == *"lib"* ]]; then
        moveFile "$file" "$LIBFILESFOLDER" $LOGNAME
        ((LIBCOUNTER++))
    elif [[ -x "$file" ]]; then
        moveFile "$file" "$BINFILESFOLDER" $LOGNAME
        ((BINCOUNTER++))
    fi
done   

echo -e "*****Exexution Summary**********\n" 
echo "Total header files moved: "$INCCOUNTER
echo "Total source files moved: "$SRCCOUNTER
echo "Total include files moved: "$LIBCOUNTER
echo "Total binary files moved: "$BINCOUNTER

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo "Proccesing time: " $DIFF "seconds."