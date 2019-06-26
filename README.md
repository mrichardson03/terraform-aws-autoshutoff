# terraform-aws-autoshutoff

This Terraform module stops running EC2 instances nightly across all regions, helping prevent surprise bills.  It will
create the Lambda function, an IAM role, the IAM role policies, a CloudWatch schedule/trigger, and a CloudWatch log
group.

## Usage

Ensure that there is a valid configuration for the
[AWS provider](https://www.terraform.io/docs/providers/aws/index.html) in your root module, then add the following:

```terraform
module "autoshutoff" {
  source  = "github.com/mrichardson03/terraform-aws-autoshutoff.git"
}
```

Instances you wish to exempt from the automatic shut off should be tagged with `AutoShutOff = false` (configurable
via `shutoff_tag_name` and `shutoff_tag_value`).

## Configuration

* `lambda_function_name`: The name of the created Lambda function.  Default is `AutoShutOff`.
* `shutoff_tag_name`: Tag name for instances exempt from automatic shutdown.  Default is `AutoShutOff`.
* `shutoff_tag_value`: Tag value for instances exempt from automatic shutdown.  Default is `false`.
* `shutoff_time`: Cron format expression for auto shutoff time. Default is `cron(0 4 * * ? *)`, or 0400 UTC.
  Formatting examples may be found in the
  [AWS Documentation](https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html).
* `tags`: A map of tags to apply to all created resources.

## Releases

* 0.1: Initial release.
