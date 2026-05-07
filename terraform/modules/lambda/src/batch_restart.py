import boto3
import json
import os

ecs = boto3.client("ecs")


def handler(event, context):
    print(f"Received event: {json.dumps(event)}")

    response = ecs.run_task(
        cluster=os.environ["ECS_CLUSTER"],
        taskDefinition=os.environ["BATCH_TASK_DEFINITION"],
        launchType="FARGATE",
        startedBy="lambda-restart",
        networkConfiguration={
            "awsvpcConfiguration": {
                "subnets": [os.environ["SUBNET_ID"]],
                "securityGroups": [os.environ["SECURITY_GROUP_ID"]],
                "assignPublicIp": "DISABLED",
            }
        },
    )

    task_arn = response["tasks"][0]["taskArn"]
    print(f"Batch task restarted: {task_arn}")
    return {"taskArn": task_arn}
