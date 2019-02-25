# The MIT License (MIT)
#
# Copyright (c) 2014-2019 Avant, Sean Lingren

############################
## ALB #####################
############################
resource "aws_security_group" "alb" {
  name_prefix = "${ var.name_prefix }-alb"
  vpc_id      = "${ var.vpc_id }"

  tags = "${ merge(
    map("Name", "${ var.name_prefix }-alb"),
    map("description", "Allow traffic into the vault alb"),
    var.tags ) }"
}

resource "aws_security_group_rule" "alb_in_80" {
  type              = "ingress"
  security_group_id = "${ aws_security_group.alb.id }"

  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["${ var.alb_allowed_ingress_cidrs }"]
}

resource "aws_security_group_rule" "alb_in_443" {
  type              = "ingress"
  security_group_id = "${ aws_security_group.alb.id }"

  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["${ var.alb_allowed_ingress_cidrs }"]
}

resource "aws_security_group_rule" "alb_out_8200" {
  type              = "egress"
  security_group_id = "${ aws_security_group.alb.id }"

  protocol                 = "tcp"
  from_port                = 8200
  to_port                  = 8200
  source_security_group_id = "${ aws_security_group.ec2.id }"
}

############################
## Public ALB ##############
############################
resource "aws_security_group" "public_alb" {
  count       = "${var.public_alb ? 1 : 0}"
  name_prefix = "${ var.name_prefix }-alb-public"
  vpc_id      = "${ var.vpc_id }"

  tags = "${ merge(
    map("Name", "${ var.name_prefix }-alb-public"),
    map("description", "Allow traffic into the public vault alb"),
    var.tags ) }"
}

resource "aws_security_group_rule" "public_alb_in_80" {
  count             = "${var.public_alb ? 1 : 0}"
  type              = "ingress"
  security_group_id = "${ aws_security_group.public_alb.id }"

  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["${ var.public_alb_allowed_ingress_cidrs }"]
}

resource "aws_security_group_rule" "public_alb_in_443" {
  count             = "${var.public_alb ? 1 : 0}"
  type              = "ingress"
  security_group_id = "${ aws_security_group.public_alb.id }"

  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["${ var.public_alb_allowed_ingress_cidrs }"]
}

resource "aws_security_group_rule" "public_alb_out_8200" {
  count             = "${var.public_alb ? 1 : 0}"
  type              = "egress"
  security_group_id = "${ aws_security_group.public_alb.id }"

  protocol                 = "tcp"
  from_port                = 8200
  to_port                  = 8200
  source_security_group_id = "${ aws_security_group.ec2.id }"
}


############################
## EC2 #####################
############################
resource "aws_security_group" "ec2" {
  name_prefix = "${ var.name_prefix }-ec2"
  vpc_id      = "${ var.vpc_id }"

  tags = "${ merge(
    map("Name", "${ var.name_prefix }-ec2"),
    map("description", "Allow traffic from alb->ec2 and ec2->ec2"),
    var.tags ) }"
}

resource "aws_security_group_rule" "ec2_in_8200" {
  type              = "ingress"
  security_group_id = "${ aws_security_group.ec2.id }"

  protocol                 = "tcp"
  from_port                = 8200
  to_port                  = 8200
  source_security_group_id = "${ aws_security_group.alb.id }"
}

resource "aws_security_group_rule" "ec2_in_8201" {
  type              = "ingress"
  security_group_id = "${ aws_security_group.ec2.id }"

  protocol  = "tcp"
  from_port = 8201
  to_port   = 8201
  self      = true
}

resource "aws_security_group_rule" "ec2_out_all" {
  type              = "egress"
  security_group_id = "${ aws_security_group.ec2.id }"

  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
