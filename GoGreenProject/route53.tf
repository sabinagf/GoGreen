# get hosted zone details
# terraform aws data hosted zone
data "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

# create a record set in route 53
# terraform aws route 53 record
resource "aws_route53_record" "site_domain" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}
# resource "aws_acm_certificate" "acm_certificate" {
#   domain_name       = "www.snoballfight.org"
#   validation_method = "DNS"
# }

# resource "aws_route53_record" "example_validation" {
#   name    = aws_acm_certificate.example.domain_validation_options.0.resource_record_name
#   type    = aws_acm_certificate.example.domain_validation_options.0.resource_record_type
#   records = [aws_acm_certificate.example.domain_validation_options.0.resource_record_value]
#   zone_id = var.domain_name
#   }
