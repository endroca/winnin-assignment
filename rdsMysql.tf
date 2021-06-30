resource "aws_security_group" "rds_group" {
  name        = "rds_group"
  description = "AWS RDS connection"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["127.0.0.1/32"]
    self = true
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds" {
  allocated_storage    = "${var.rds.allocated_storage}"
  engine               = "${var.rds.engine}"
  engine_version       = "${var.rds.engine_version}"
  instance_class       = "${var.rds.instance_class}"
  name                 = "${var.rds.name}"
  username             = "${var.rds.username}"
  password             = "${var.rds.password}"
  parameter_group_name = "${var.rds.parameter_group_name}"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_group.id]

  provisioner "local-exec" {
    command = "mysql --host=${self.address} --port=${self.port} --user=${self.username} --password=${self.password} < ./schema.sql"
  }
}