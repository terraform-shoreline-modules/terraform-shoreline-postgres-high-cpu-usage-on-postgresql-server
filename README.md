
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# High CPU Usage on PostgreSQL Server
---

High CPU usage on a PostgreSQL server is a common incident that can impact overall system performance. This issue occurs when the server's CPU usage is abnormally high, which can lead to slow database queries, reduced server performance, and even downtime. Identifying the root cause of the high CPU usage and implementing effective mitigation measures are critical to resolving this incident.

### Parameters
```shell
export PID="PLACEHOLDER"

export LOG_FILE_PATH="PLACEHOLDER"

export MAXIMUM_NUMBER_OF_CONNECTIONS="PLACEHOLDER"

export INSTANCE_NAME="PLACEHOLDER"

export REGION_RESOURCE_GROUP_PROJECT_NAME="PLACEHOLDER"

export NEW_INSTANCE_TYPE="PLACEHOLDER"

export ZONE_NAME="PLACEHOLDER"
```

## Debug

### Check CPU usage by process ID (replace ${PID} with PostgreSQL process ID)
```shell
top -p ${PID}
```

### Check active queries on PostgreSQL database
```shell
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"
```

### Identify the query with the highest CPU usage
```shell
sudo -u postgres psql -c "SELECT pid, query, usename, datname, state, query_start FROM pg_stat_activity ORDER BY query_cpu_time DESC LIMIT 1;"
```

### Check for any long-running queries
```shell
sudo -u postgres psql -c "SELECT pid, query, usename, datname, state, query_start FROM pg_stat_activity WHERE state='active' AND query_start < NOW() - interval '5 minutes';"
```

### Check for any blocked queries
```shell
sudo -u postgres psql -c "SELECT pid, usename, blocked_pid, query_start FROM pg_stat_activity WHERE state='active' AND waiting='t';"
```

### Check if there are any slow queries using pgBadger (replace <LOG_FILE_PATH> with PostgreSQL log file path)
```shell
pgbadger ${LOG_FILE_PATH} -f stderr -p '%t:%r:%u@%d:[%p]:' -T -j 10
```

### An increase in the number of incoming requests to the PostgreSQL server, exceeding its processing capacity.
```shell


#!/bin/bash



# Set variables

LIMIT="${MAXIMUM_NUMBER_OF_CONNECTIONS}"



# Get the current number of connections

CURRENT_CONNECTIONS=$(netstat -an | grep 'ESTABLISHED' | wc -l)



# Check if the number of connections exceeds the limit

if [ $CURRENT_CONNECTIONS -gt $LIMIT ]; then

    echo "Number of connections ($CURRENT_CONNECTIONS) exceeds the limit ($LIMIT)."

    echo "Please increase the maximum number of connections or optimize the queries."

else

    echo "Number of connections is within the limit."

fi


```

### Insufficient memory allocation to the PostgreSQL server, leading to excessive swapping and increased CPU usage.
```shell


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


```

## Repair

### Consider upgrading the server hardware or adding more resources, such as CPU cores or memory, to tackle the high CPU usage.
```shell


#!/bin/bash



SERVER_NAME=${INSTANCE_NAME}

RGP_NAME=${REGION_RESOURCE_GROUP_PROJECT_NAME}

NEW_INSTANCE_TYPE=${NEW_INSTANCE_TYPE}

ZONE_NAME=${ZONE_NAME}



# Change instance types

case ${CLOUD_PROVIDER} in

    "aws")

        # Stop the instance before modifying

        aws ec2 stop-instances --region $RGP_NAME --instance-ids $SERVER_NAME



        # Modify the instance type

        aws ec2 modify-instance-attribute --region $RGP_NAME --instance-id $SERVER_NAME --instance-type $NEW_INSTANCE_TYPE



        # Start the instance again

        aws ec2 start-instances --region $RGP_NAME --instance-ids $SERVER_NAME

        ;;

    "azure")

        az vm resize --resource-group $RGP_NAME --name $SERVER_NAME --size $NEW_INSTANCE_TYPE

        ;;

    "gcp")

        gcloud compute instances set-machine-type $SERVER_NAME --machine-type $NEW_INSTANCE_TYPE --project $RGP_NAME --zone=$ZONE_NAME

        ;;

    *)

        echo "Error unsupported cloud provider! Supported cloud providers [aws, azure, gcp]."

        exit 1

esac


```