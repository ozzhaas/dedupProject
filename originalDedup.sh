#! /bin/bash

#This is a program that will find duplicate files 
#and remove or mark them for review. 

#The directory that you would like to search 
#must be passed to the program as a command line argument.


dir=$[ $1 ]

echo "Deduplication has begun!"

echo "Chosen directory: " 
echo $1


fdupes -rnS $1 > ~/Desktop/dupes.txt 


			
