import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info('## ENVIRONMENT VARIABLES')
    logger.info(os.environ)
    logger.info('## EVENT')
    logger.info(event)

    client = boto3.client('ec2')
    ec2_regions = [region['RegionName'] for region in client.describe_regions()['Regions']]

    tag_name = os.getenv('SHUTOFF_TAG_NAME')
    tag_value = os.getenv('SHUTOFF_TAG_VALUE')

    filter_exempt = [
        {
            'Name': 'tag:' + tag_name,
            'Values': [tag_value]
        }
    ]

    filter_running = [
        {
            'Name': 'instance-state-name',
            'Values': ['pending', 'running']
        }
    ]

    for region in ec2_regions:
        ec2 = boto3.resource('ec2',region_name=region)
        running_instances = [r for r in ec2.instances.filter(Filters=filter_running)]
        exempt_instances = [x for x in ec2.instances.filter(Filters=filter_exempt)]
        stop_instances = [s for s in running_instances if s.id not in [x.id for x in exempt_instances]]

        for instance in stop_instances:
            result = instance.stop()
            logger.info(result)
