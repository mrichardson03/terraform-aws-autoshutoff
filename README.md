# terraform-aws-autoshutoff

This Terraform plan is used to create an AWS Lambda function that stops running EC2 instances across all regions on a
scheduled basis.

It will create the Lambda function, an IAM role, the IAM role policies, a CloudWatch schedule/trigger, and a CloudWatch
log group.

## Scheduling

* The default schedule is daily at 0400 UTC and there is a `shutoff_time` variable that may be used to adjust this
  schedule.
* The format for the `shutoff_time` variable is in `cron` format.  Examples may be found in the
  [AWS Documentation](https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html).

## Exemptions

* Instance you wish to exempt from the schedule may be marked with a tag name `AutoShutOff` and value of `false`.
* The tag name and value variables may be overridden in the `variables.tf` file.

## Execution

* You must have defined credentials and the appropriate permissions in AWS in order to apply this Terraform plan.
* The environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` may be used or a properly configured
  AWS CLI instance.
