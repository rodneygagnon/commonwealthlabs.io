terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment to use S3 backend for state
  # backend "s3" {
  #   bucket         = "commonwealthlabs-terraform-state"
  #   key            = "landing/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "commonwealthlabs-terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "commonwealthlabs-landing"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Provider for ACM certificate (must be in us-east-1 for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "commonwealthlabs-landing"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# S3 bucket for static site
resource "aws_s3_bucket" "landing" {
  bucket = "commonwealthlabs-landing-${var.environment}"
}

resource "aws_s3_bucket_public_access_block" "landing" {
  bucket = aws_s3_bucket.landing.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "landing" {
  bucket = aws_s3_bucket.landing.id

  versioning_configuration {
    status = "Enabled"
  }
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "landing" {
  name                              = "commonwealthlabs-landing-${var.environment}"
  description                       = "OAC for Commonwealth Labs landing page"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 bucket policy for CloudFront access
resource "aws_s3_bucket_policy" "landing" {
  bucket = aws_s3_bucket.landing.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.landing.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.landing.arn
          }
        }
      }
    ]
  })
}

# ACM Certificate (must be in us-east-1 for CloudFront)
resource "aws_acm_certificate" "landing" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }
}

# CloudFront Function for URL rewriting (append index.html to directory requests)
resource "aws_cloudfront_function" "url_rewrite" {
  name    = "commonwealthlabs-url-rewrite-${var.environment}"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<-EOF
    function handler(event) {
      var request = event.request;
      var uri = request.uri;

      // If URI ends with '/' append index.html
      if (uri.endsWith('/')) {
        request.uri += 'index.html';
      }
      // If URI doesn't have a file extension, append /index.html
      else if (!uri.includes('.')) {
        request.uri += '/index.html';
      }

      return request;
    }
  EOF
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "landing" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "Commonwealth Labs Landing Page - ${var.environment}"
  price_class         = "PriceClass_100"  # US, Canada, Europe

  aliases = var.enable_custom_domain ? concat([var.domain_name], var.subject_alternative_names) : []

  origin {
    domain_name              = aws_s3_bucket.landing.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.landing.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.landing.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.landing.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.url_rewrite.arn
    }
  }

  # Handle SPA routing - serve index.html for 404s
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.enable_custom_domain ? false : true
    acm_certificate_arn            = var.enable_custom_domain ? aws_acm_certificate.landing.arn : null
    ssl_support_method             = var.enable_custom_domain ? "sni-only" : null
    minimum_protocol_version       = var.enable_custom_domain ? "TLSv1.2_2021" : null
  }
}
