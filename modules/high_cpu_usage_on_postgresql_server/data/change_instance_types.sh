

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