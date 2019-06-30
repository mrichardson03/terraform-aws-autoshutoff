############################################################################################
# Copyright 2019 Palo Alto Networks.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
############################################################################################

variable "lambda_function_name" {
  description = "The name of the Lambda function."
  default     = "AutoShutOff"
}

variable "shutoff_tag_name" {
  description = "The tag name (used in Lambda environment variable)."
  default     = "AutoShutOff"
}

variable "shutoff_tag_value" {
  description = "The tag value (used in Lambda environment variable)."
  default     = "false"
}

variable "shutoff_time" {
  description = "Crontab expression for when (in UTC) to run the Lambda function."
  default     = "cron(0 4 * * ? *)"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  default     = {}
}

