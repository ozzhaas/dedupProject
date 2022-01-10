#!/bin/bash
# Find duplicate files using shell script
# Remove duplicate files interactively
TMP_FILE=$(mktemp /tmp/temp_file.XXX)
DUP_FILE=$(mktemp /tmp/dup_file.XXX)

function add_file() {
  # Store the hash of the file if not already added
  echo "$1" "$2"  >> $TMP_FILE
}

function red () {
   # print colored output
   /bin/echo -e "\e[01;31m$1\e[0m" 1>&2
}


function del_file() {
    # Delete the duplicate file
    rm -f "$1" 2>/dev/null
    [[ $? == 0 ]] && red "File \"$1\" deleted"
}

function archive_file() {
	#Discard one of the duplicate files
	mv "$1" ~/Desktop/tmpdupes/
    [[ $? == 0 ]] && red "File \"$1\" archived."
}
 



function srch_file() {

  # Store the filename in this variable
  local NEW="$1"
  # Before we check hash value of file, make this variable null
  local SUM="0"

  # If file exists and the temporary file's size is zero
  if [ -f $NEW ] && [ ! -s $TMP_FILE ];then
     # Print Store the hash value of file. This value will be later stored in RET which is further used to check duplicate file
     echo $(sha512sum ${NEW} | awk -F' ' '{print $1}')
     # Exit the loop here
     return
  fi

  # If the size of temporary file is non-zero read temporary file line by line in a loop. Each line is stored in ELEMENT variable
  while read ELEMENT; do
    # Get the hash value of input file
    SUM=$(sha512sum ${NEW} | awk -F' ' '{print $1}')

    # Get the hash value of file collected from temporary file
    ELEMENT_SUM=$(echo $ELEMENT | awk -F' ' '{print $1}')
    ELEMENT_FILENAME=$(echo $ELEMENT | awk -F' ' '{print $2}')

    # if the hash value is same means we have found a duplicate file
    if [ "${SUM}" == "${ELEMENT_SUM}" ];then
       echo $ELEMENT_FILENAME > $DUP_FILE
       return 1
    else
       continue
    fi
  done<$TMP_FILE

  # If duplicate file is not found then just print the hash value of the file
  echo ${SUM} 

}


function begin_search_and_deduplication {

  local DIR_TO_SRCH="$1"

  for FILE in `find ${DIR_TO_SRCH} -type f`; do

     # this stores the return value from srch_file function
     RET=`srch_file ${FILE}`
     if [[ "${RET}" == "" ]];then
         FILE1=`cat $DUP_FILE`
         echo "$FILE1 is a duplicate of $FILE"
         while true; do
		 read -rp "Would you like to temporarily archive one of the files? $FILE1(1),  $FILE(2), or quit(3): " ANS
            if [ $ANS == "1" ];then
               archive_file $FILE1
               break
            elif [ $ANS == "2" ];then
               archive_file $FILE
               break
	   elif [ $ANS == "3" ]; then
		break
	   else 
		echo "Not a valid option. Please enter 1, 2, or 3."
	
            fi
         done
         continue
    elif [[ "${RET}" == "0" ]];then
         continue
    elif [[ "${RET}" == "1" ]];then 
         continue
    else
	# If the file hash is not found then it's entry is added in temporary file
	  add_file "${RET}" ${FILE}
          continue
      fi
      echo "No duplicate file(s) found."
  done
}

# This will read the user input to collect list of directories to search for duplicate files
echo "Enter directory name to search: "
echo "Press [ENTER] when ready"
echo

read DIR

begin_search_and_deduplication "${DIR}"
# Delete the temporary files once done
mv $TMP_FILE ~/Desktop/tmpdupes/
mv $DUP_FILE ~/Desktop/tmpdupes/


# Maybe use zip to compress files and then move the newly compressed duplicates to
# a specific directory/folder for review before deletion. Use "-r" for recursive.

# sort files by size "ls -S" 

# sort files by time they were last modified "ls -t"

# rm options - "rm -i" interactive mode, ask before deleting each file
