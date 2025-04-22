#!/bin/bash
FATFS_VERSION="R0.15a"
MX="STM32CubeMX"
IDE="stm32cubeide"
FW="STM32Cube_FW_F7_V1.17.2"

#DESTINATIONS=("STM32CubeMX","stm32cubeide","STM32Cube_FW_F7")
# Iterate over the array using a for loop
#for item in "${DESTINATIONS[@]}"; do
#    echo "$item"
#done
#

MX_EN=1
IDE_EN=1
FW_EN=1

echo "This script will attempt to copy FATFS $FATFS_VERSION files into STM23CubeMX, STM32Cube FW and STM32CubeIde"  

# Set the destination directory (default to current directory if not provided)
destination="${3:-.}"

# Get the directory of the current script
script_dir="$(dirname "$(realpath "$0")")"

#create a log file
LOG="$script_dir/fatfs15_update.log"
touch $LOG

############################ CUBEMX #####################################################
if [ $MX_EN -ne 0 ]; then 
echo ""
echo "1 - Files to be copied to $MX directory"
echo "Locating the installation directories..."

results=($(locate -b "$MX"))

# Check if any results were found
if [ ${#results[@]} -eq 0 ]; then
    echo "No files found matching '$MX'."
    exit 1
fi

# Specify the file to copy
dir_to_copy="$script_dir/$MX/*"
echo "Directory $dir_to_copy will be copied recursively where $MX is installed"
echo "..."

# Iterate over each result and check if it is a binary executable
for file in "${results[@]}"; do
    if [ -e "$file" ]; then  # Check if the file exists
        # Get the base name of the located file
        base_name=$(basename "$file")
        
		# Check if the base name matches the provided filename
		if [[ "$base_name" == "$MX" ]]; then
		    if [[ $(file "$file") == *"executable"* ]]; then
		        echo "$file is a binary executable."
		        # Get the directory of the binary file
				destination="$(dirname "$(realpath "$file")")"
				echo "Directory content will be copied to $destination"			
		        cp -r $dir_to_copy $destination
		    #else
		        #echo "$file is not a binary executable."
		    fi
		#else
            #echo "$file does not match the specified filename '$IDE'."
        fi    
    #else
        #echo "$file does not exist."
    fi
done

echo "$(date): $MX update done!" >> $LOG 

fi	#[$MX_EN -ne 0]

############################ CUBEIDE #####################################################
if [ $IDE_EN -ne 0 ]; then 
echo ""
echo "2 - Files to be copied to $IDE directory (will require root privileges if stored in /opt)"
echo "Locating the installation directories..."

results=($(locate -b "$IDE"))

# Check if any results were found
if [ ${#results[@]} -eq 0 ]; then
    echo "No files found matching '$IDE'."
    exit 1
fi

# Specify the file to copy
dir_to_copy="$script_dir/$IDE/*"
echo "Directory $dir_to_copy will be copied recursively where $IDE is installed"
echo "..."

# Iterate over each result and check if it is a binary executable
for file in "${results[@]}"; do
    if [ -e "$file" ]; then  # Check if the file exists
        # Get the base name of the located file
        base_name=$(basename "$file")
        
		# Check if the base name matches the provided filename
		if [[ "$base_name" == "$IDE" ]]; then		
		    if [[ $(file "$file") == *"executable"* ]]; then
		        echo "$file is a binary executable."
		        # Get the directory of the binary file
				destination="$(dirname "$(realpath "$file")")"
				echo "Directory content will be copied to $destination"		
				sudo cp -r $dir_to_copy $destination
		    #else
		        #echo "$file is not a binary executable."
		    fi
		#else
            #echo "$file does not match the specified filename '$IDE'."
        fi    
    #else
        #echo "$file does not exist."
    fi
done

echo "$(date): $IDE update done!" >> $LOG 

fi	#[$IDE_EN -ne 0]

############################ CUBE FW #####################################################
if [ $FW_EN -ne 0 ]; then 
echo ""
echo "3 - Files to be copied to $FW directory"
echo "Locating the installation directories..."

results=($(locate -b "$FW"))

# Check if any results were found
if [ ${#results[@]} -eq 0 ]; then
    echo "No directory found matching '$FW'."
    exit 1
fi

# Specify the file to copy
dir_to_copy="$script_dir/$FW/Middlewares/Third_Party/FatFs"
echo "Directory $dir_to_copy will be copied recursively where $FW is installed"
echo "..."

# Iterate over each result and check if it is a binary executable
for directory in "${results[@]}"; do
    if [ -e "$directory" ]; then  # Check if the file exists
        # Get the base name of the located file
        base_name=$(basename "$directory")
        
		# Check if the base name matches the provided filename
		if [[ "$base_name" == "$FW" ]]; then		
		    if [[ $(file "$directory") == *"directory"* ]]; then
		        echo "$directory directoty found!"
		        destination="$directory/Middlewares/Third_Party"
		        if [[ "$destination/FatFs" == $dir_to_copy ]]; then
		        	echo "Destination directory is the source directory so do not delete it! Moving on..."
		        else
		        	echo "Current FATFS will first be deleted from $destination if it exists"
					rm -rf "$destination/FatFs"				
		        	echo "Copying new FATFS files to $destination"		
					cp -r $dir_to_copy $destination
				fi
		    else
		        echo "$file is not a binary executable."
		    fi
		else
            echo "$file does not match the specified filename '$FW'."
        fi    
    else
        echo "$file does not exist."
    fi
done

echo "$(date): $FW update done!" >> $LOG 

fi	#[$FW_EN -ne 0]


