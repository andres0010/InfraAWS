resource "aws_s3_bucket" "giants-bucket" {
  bucket = "giants-bucket"

  tags = {
    Name = "giants-bucket"
  }
}

resource "aws_dynamodb_table" "terraform-lock" {
  name = "terraform-lock"
  read_capacity = 5
  write_capacity = 5
  hash_key = "lockID"

  attribute {
    name = "lockID"
    type = "S"
  }
  
}

resource "aws_s3_object" "giants-bucket-obj" {
  bucket       = aws_s3_bucket.giants-bucket.id
  key          = "index.html"
  source       = "./modulos/index.html"
  etag         = filemd5("./modulos/index.html")
  content_type = "text/html"
}


data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.giants-bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.s3_origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "giants-policy" {
  bucket = aws_s3_bucket.giants-bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

// CloudFront origin access identity to associate with the distribution
resource "aws_cloudfront_origin_access_identity" "s3_origin_access_identity" {
  comment = "S3 OAI for the Cloudfront Distribution"
}

// CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.giants-bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.giants-bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "giants S3 bucket"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.giants-bucket.id

    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "allow-all"

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront_domain_name" {
  description = "The domain name corresponding to the distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}
