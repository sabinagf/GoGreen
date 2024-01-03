#Create SNS Topic
resource "aws_sns_topic" "sns_topic" {
  name = "sns-topic"
}
#Create SNS SUbscription
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "sabinagf7@gmail.com"
}
