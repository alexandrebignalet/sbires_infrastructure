output alb_zone_id {
  value = "${aws_lb.api.zone_id}"
}

output alb_dns_name {
  value = "${aws_lb.api.dns_name}"
}

output alb_listener {
  value = "${aws_lb_listener.http.arn}"
}

output alb_security_group {
  value = "${aws_security_group.api_alb.id}"
}
