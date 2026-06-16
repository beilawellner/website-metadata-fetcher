# =============================================================================
# CAS Compliance Findings Test Fixture (Terraform / AWS)
# =============================================================================
# Purpose:
#   Each resource below is INTENTIONALLY MISCONFIGURED to trigger a specific
#   Checkov check (CKV_*) that maps to a CAS detection rule (APPSEC_AWS_*)
#   which carries compliance_standards / compliance_controls metadata.
#
#   Commit this file to a repo and run a CAS IaC scan. The resulting findings
#   should be normalized with populated compliance fields, allowing you to
#   verify the compliance normalization pipeline.
#
# Mapping reference (Checkov check  ->  CAS rule  ->  #compliance_standards):
#   CKV_AWS_70   -> APPSEC_AWS_70    (36)  S3 bucket policy overly permissive
#   CKV2_AWS_55  -> APPSEC2_AWS_55   (34)  EMR cluster no security configuration
#   CKV_AWS_83   -> APPSEC_AWS_83    (34)  Elasticsearch domain no HTTPS
#   CKV_AWS_79   -> APPSEC_AWS_79    (33)  EC2 instance no IMDSv2
#   CKV_AWS_81   -> APPSEC_AWS_81    (29)  MSK cluster no encryption in transit
#   CKV_AWS_27   -> APPSEC_AWS_27    (27)  SQS queue no SSE
#   CKV_AWS_359  -> APPSEC_AWS_359   (26)  Neptune cluster no IAM auth
#   CKV_AWS_98   -> APPSEC_AWS_98    (24)  SageMaker endpoint no encryption
#   CKV_AWS_65   -> APPSEC_AWS_65    (24)  ECS cluster container insights disabled
#   CKV_AWS_134  -> APPSEC_AWS_134   (23)  ElastiCache Redis no snapshot retention
#   CKV_AWS_316  -> APPSEC_AWS_316   (23)  CodeBuild privileged mode
#   CKV_AWS_21   -> APPSEC_AWS_21    (20)  S3 object versioning disabled
#   CKV_AWS_47   -> APPSEC_AWS_47    (19)  DAX cluster no encryption at rest
#   CKV_AWS_58   -> APPSEC_AWS_58    (19)  EKS cluster no secrets encryption
#   CKV_AWS_89   -> APPSEC_AWS_89    (18)  DMS replication instance public
#   CKV_AWS_209  -> APPSEC_AWS_209   (18)  MQ broker not CMK encrypted
#   CKV_AWS_149  -> APPSEC_AWS_149   (17)  Secrets Manager secret not CMK encrypted
#   CKV_AWS_366  -> APPSEC_AWS_366   (16)  Cognito identity pool unauth identities
#   CKV_AWS_87   -> APPSEC_AWS_87    (13)  Redshift cluster publicly accessible
#   CKV_AWS_331  -> APPSEC_AWS_331   (12)  Transit Gateway auto-accept attachments
#   CKV_AWS_258  -> APPSEC_AWS_258   (11)  Lambda function URL AuthType NONE
#   CKV_AWS_303  -> APPSEC_AWS_303   (8)   SSM document public
#   CKV_AWS_158  -> APPSEC_AWS_158   (6)   CloudWatch log group default encryption
#   CKV_AWS_238  -> APPSEC_AWS_238   (2)   GuardDuty detector disabled
#   CKV_AWS_227  -> APPSEC_AWS_227   (2)   KMS key disabled
# =============================================================================

provider "aws" {
  region = "us-east-1"
}

# -----------------------------------------------------------------------------
# CKV_AWS_70 / APPSEC_AWS_70 - S3 bucket policy overly permissive to any principal
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "compliance_test" {
  bucket = "cas-compliance-test-bucket"
}

resource "aws_s3_bucket_policy" "compliance_test" {
  bucket = aws_s3_bucket.compliance_test.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = "${aws_s3_bucket.compliance_test.arn}/*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# CKV2_AWS_55 / APPSEC2_AWS_55 - EMR cluster without security configuration
# -----------------------------------------------------------------------------
resource "aws_emr_cluster" "compliance_test" {
  name          = "cas-compliance-emr"
  release_label = "emr-6.10.0"
  service_role  = "arn:aws:iam::123456789012:role/EMR_DefaultRole"

  master_instance_group {
    instance_type = "m5.xlarge"
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_83 / APPSEC_AWS_83 - Elasticsearch domain without HTTPS enforcement
# -----------------------------------------------------------------------------
resource "aws_elasticsearch_domain" "compliance_test" {
  domain_name           = "cas-compliance-es"
  elasticsearch_version = "7.10"

  domain_endpoint_options {
    enforce_https = false
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_79 / APPSEC_AWS_79 - EC2 instance not using IMDSv2
# -----------------------------------------------------------------------------
resource "aws_instance" "compliance_test" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t3.micro"

  metadata_options {
    http_tokens = "optional"
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_81 / APPSEC_AWS_81 - MSK cluster encryption in transit not enabled
# -----------------------------------------------------------------------------
resource "aws_msk_cluster" "compliance_test" {
  cluster_name           = "cas-compliance-msk"
  kafka_version          = "2.8.1"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    client_subnets  = ["subnet-0123456789abcdef0"]
    security_groups = ["sg-0123456789abcdef0"]
    storage_info {
      ebs_storage_info {
        volume_size = 100
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "PLAINTEXT"
      in_cluster    = false
    }
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_27 / APPSEC_AWS_27 - SQS queue without server-side encryption
# -----------------------------------------------------------------------------
resource "aws_sqs_queue" "compliance_test" {
  name = "cas-compliance-queue"
}

# -----------------------------------------------------------------------------
# CKV_AWS_359 / APPSEC_AWS_359 - Neptune cluster without IAM database auth
# -----------------------------------------------------------------------------
resource "aws_neptune_cluster" "compliance_test" {
  cluster_identifier                  = "cas-compliance-neptune"
  engine                              = "neptune"
  iam_database_authentication_enabled = false
  skip_final_snapshot                 = true
}

# -----------------------------------------------------------------------------
# CKV_AWS_98 / APPSEC_AWS_98 - SageMaker endpoint config no encryption at rest
# -----------------------------------------------------------------------------
resource "aws_sagemaker_endpoint_configuration" "compliance_test" {
  name = "cas-compliance-sagemaker"

  production_variants {
    variant_name           = "variant-1"
    model_name             = "cas-compliance-model"
    initial_instance_count = 1
    instance_type          = "ml.t2.medium"
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_65 / APPSEC_AWS_65 - ECS cluster with container insights disabled
# -----------------------------------------------------------------------------
resource "aws_ecs_cluster" "compliance_test" {
  name = "cas-compliance-ecs"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_134 / APPSEC_AWS_134 - ElastiCache Redis without backup retention
# -----------------------------------------------------------------------------
resource "aws_elasticache_cluster" "compliance_test" {
  cluster_id           = "cas-compliance-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  snapshot_retention_limit = 0
}

# -----------------------------------------------------------------------------
# CKV_AWS_316 / APPSEC_AWS_316 - CodeBuild project with privileged mode
# -----------------------------------------------------------------------------
resource "aws_codebuild_project" "compliance_test" {
  name         = "cas-compliance-codebuild"
  service_role = "arn:aws:iam::123456789012:role/codebuild-role"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type     = "GITHUB"
    location = "https://github.com/example/repo.git"
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_21 / APPSEC_AWS_21 - S3 object versioning disabled
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "compliance_test_versioning" {
  bucket = "cas-compliance-test-versioning"
}

resource "aws_s3_bucket_versioning" "compliance_test" {
  bucket = aws_s3_bucket.compliance_test_versioning.id
  versioning_configuration {
    status = "Suspended"
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_47 / APPSEC_AWS_47 - DAX cluster without encryption at rest
# -----------------------------------------------------------------------------
resource "aws_dax_cluster" "compliance_test" {
  cluster_name       = "cas-compliance-dax"
  iam_role_arn       = "arn:aws:iam::123456789012:role/dax-role"
  node_type          = "dax.r4.large"
  replication_factor = 1

  server_side_encryption {
    enabled = false
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_58 / APPSEC_AWS_58 - EKS cluster without secrets encryption
# -----------------------------------------------------------------------------
resource "aws_eks_cluster" "compliance_test" {
  name     = "cas-compliance-eks"
  role_arn = "arn:aws:iam::123456789012:role/eks-role"

  vpc_config {
    subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_89 / APPSEC_AWS_89 - DMS replication instance publicly accessible
# -----------------------------------------------------------------------------
resource "aws_dms_replication_instance" "compliance_test" {
  replication_instance_id    = "cas-compliance-dms"
  replication_instance_class = "dms.t3.micro"
  publicly_accessible        = true
  allocated_storage          = 50
}

# -----------------------------------------------------------------------------
# CKV_AWS_209 / APPSEC_AWS_209 - MQ broker not encrypted by CMK
# -----------------------------------------------------------------------------
resource "aws_mq_broker" "compliance_test" {
  broker_name        = "cas-compliance-mq"
  engine_type        = "ActiveMQ"
  engine_version     = "5.16.4"
  host_instance_type = "mq.t3.micro"

  user {
    username = "admin"
    password = "ChangeMe1234567890!"
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_149 / APPSEC_AWS_149 - Secrets Manager secret not encrypted by CMK
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "compliance_test" {
  name = "cas-compliance-secret"
}

# -----------------------------------------------------------------------------
# CKV_AWS_366 / APPSEC_AWS_366 - Cognito identity pool allows unauthenticated
# -----------------------------------------------------------------------------
resource "aws_cognito_identity_pool" "compliance_test" {
  identity_pool_name               = "cas_compliance_pool"
  allow_unauthenticated_identities = true
}

# -----------------------------------------------------------------------------
# CKV_AWS_87 / APPSEC_AWS_87 - Redshift cluster publicly accessible
# -----------------------------------------------------------------------------
resource "aws_redshift_cluster" "compliance_test" {
  cluster_identifier  = "cas-compliance-redshift"
  database_name       = "compliancedb"
  master_username     = "admin"
  master_password     = "ChangeMe1234567890!"
  node_type           = "dc2.large"
  cluster_type        = "single-node"
  publicly_accessible = true
  skip_final_snapshot = true
}

# -----------------------------------------------------------------------------
# CKV_AWS_331 / APPSEC_AWS_331 - Transit Gateway auto-accept VPC attachments
# -----------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "compliance_test" {
  description                     = "cas-compliance-tgw"
  auto_accept_shared_attachments  = "enable"
}

# -----------------------------------------------------------------------------
# CKV_AWS_258 / APPSEC_AWS_258 - Lambda function URL AuthType NONE
# -----------------------------------------------------------------------------
resource "aws_lambda_function_url" "compliance_test" {
  function_name      = "cas-compliance-lambda"
  authorization_type = "NONE"
}

# -----------------------------------------------------------------------------
# CKV_AWS_303 / APPSEC_AWS_303 - SSM document public
# -----------------------------------------------------------------------------
resource "aws_ssm_document" "compliance_test" {
  name            = "cas-compliance-ssm"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "compliance test"
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "example"
        inputs = {
          runCommand = ["echo hello"]
        }
      }
    ]
  })

  permissions = {
    type        = "Share"
    account_ids = "All"
  }
}

# -----------------------------------------------------------------------------
# CKV_AWS_158 / APPSEC_AWS_158 - CloudWatch log group default encryption (no KMS)
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "compliance_test" {
  name = "cas-compliance-loggroup"
}

# -----------------------------------------------------------------------------
# CKV_AWS_238 / APPSEC_AWS_238 - GuardDuty detector disabled
# -----------------------------------------------------------------------------
resource "aws_guardduty_detector" "compliance_test" {
  enable = false
}

# -----------------------------------------------------------------------------
# CKV_AWS_227 / APPSEC_AWS_227 - KMS key disabled
# -----------------------------------------------------------------------------
resource "aws_kms_key" "compliance_test" {
  description = "cas-compliance-kms"
  is_enabled  = false
}
