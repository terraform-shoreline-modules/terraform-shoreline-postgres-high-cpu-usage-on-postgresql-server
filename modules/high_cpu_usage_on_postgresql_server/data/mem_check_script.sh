

#!/bin/bash



# Check the server's memory allocation

total_memory=$(free -m | awk '/^Mem:/{print $2}')

used_memory=$(free -m | awk '/^Mem:/{print $3}')



# Calculate the percentage of used memory

used_percentage=$(echo "scale=2; $used_memory/$total_memory*100" | bc -l)



# Check if the used memory is above a certain threshold

if [ $(echo "$used_percentage > 80" | bc) -ne 0 ]; then

    # If the used memory is above the threshold, check for excessive swapping

    swap_used=$(free -m | awk '/^Swap:/{print $3}')

    swap_total=$(free -m | awk '/^Swap:/{print $2}')

    swap_percentage=$(echo "scale=2; $swap_used/$swap_total*100" | bc -l)

    

    # If the swap usage is high, it may be causing excessive CPU usage

    if [ $(echo "$swap_percentage > 20" | bc) -ne 0 ]; then

        echo "Insufficient memory allocation to the PostgreSQL server, leading to excessive swapping and increased CPU usage."

        echo "The server is currently using $used_percentage% of its memory, and $swap_percentage% of its swap space."

        echo "Consider increasing the server's memory allocation or optimizing the server's configuration."

    fi

fi