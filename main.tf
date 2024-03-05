# Define the AWS provider
provider "aws" {
  region = "ap-southeast-1"
}
#  VPC
resource "aws_vpc" "lap" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Lap-fianl-Vpc"
  }
}
#  Public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lap.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Lap-fianl-Subnet"
  }
}
#  NACL tường lửa cho subnet
resource "aws_network_acl" "allow_all" {
  vpc_id     = aws_vpc.lap.id
  subnet_ids = [aws_subnet.public.id]
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }
}
#  Internet gateway
resource "aws_internet_gateway" "lap" {
  vpc_id = aws_vpc.lap.id
  tags = {
    Name = "Lap-fianl-Gate"
  }
}
#  Route table
resource "aws_route_table" "lap" {
  vpc_id = aws_vpc.lap.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lap.id
  }
  tags = {
    Name = "Lap-fianl-Route"
  }
}
#  Map route table to subnet
resource "aws_route_table_association" "PubToInt" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.lap.id
}
#  Security Group
resource "aws_security_group" "final" {
  vpc_id      = aws_vpc.lap.id
  name        = "CICD-sg"
  description = "Security group create for final lap"
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "Lap-final-Security-group"
  }
}
# Create an S3 bucket
resource "aws_s3_bucket" "lap" {
  bucket = "lap-final-bucket-125777342244" # Replace with a unique bucket name
  tags = {
    Name = "Lap2-final-bucket"
  }
}
# Upload the index.html file to the S3 bucket
resource "aws_s3_bucket_object" "index" {
  bucket       = aws_s3_bucket.lap.id
  key          = "index.html"
  source       = "./data/index.html"
  content_type = "text/html"
}
# Make bucket public
resource "aws_s3_bucket_public_access_block" "example_block" {
  bucket                  = aws_s3_bucket.lap.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
# Add the additional statement to the S3 bucket policy
resource "aws_s3_bucket_policy" "example_policy" {
  bucket = aws_s3_bucket.lap.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
        ],
        Resource = ["arn:aws:s3:::${aws_s3_bucket.lap.id}/*"]
      },
    ],
  })
}
# Define the IAM Role
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "Final-iam-role" # Specify a unique name for the IAM role

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
# Create iam policy
resource "aws_iam_policy" "s3lap" {
  name        = "Final-iam-policy"
  description = "Provides full access to Amazon S3 for EC2 instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}
# Attach a policy to the IAM Role that grants S3 access
resource "aws_iam_policy_attachment" "ec2_s3_access_policy" {
  name       = "Final-iam-attachment"
  policy_arn = aws_iam_policy.s3lap.arn
  roles      = [aws_iam_role.ec2_s3_access_role.name]
}
#  IAM profile
resource "aws_iam_instance_profile" "last" {
  name = "Final-iam-profile"
  role = aws_iam_role.ec2_s3_access_role.name
}
# Tạo máy chủ EC2
resource "aws_instance" "main" {
  ami                    = "ami-0df7a207adb9748c7"    # AMI ID của Ubuntu
  instance_type          = "t2.micro"                 # Instance type của tôi       
  key_name               = aws_key_pair.fast.key_name # Key pair của tôi
  iam_instance_profile   = aws_iam_instance_profile.last.name
  subnet_id              = aws_subnet.public.id # Sub net của tôi
  vpc_security_group_ids = [aws_security_group.final.id]
  tags = {
    Name = "Terraform1"
  }
}
# Để tạo key pair, ta sử dụng resource aws_key_pair trong tệp Terraform.
resource "aws_key_pair" "fast" {
  key_name   = "key5.pub"           # Tên key pair
  public_key = file("key/key5.pub") # Đường dẫn đến file public key     
}




