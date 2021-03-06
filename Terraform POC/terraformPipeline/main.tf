
#himanitest root credentials
provider "aws" {
region  = ""
access_key = ""
secret_key = ""
}

#S3 Bucket to store

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-us-east-1-88321018183"
  acl    = "private"
}

# #CodePipeline IAM role

resource "aws_iam_role" "codepipeline_role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
#Finshed codepipline role
#Started Codebuild role

resource "aws_iam_role" "cbd_build" {
  name               = "testnamenew"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

  resource "aws_iam_role_policy" "example" {
  role = "${aws_iam_role.cbd_build.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
    "Effect" :"Allow",
    "Action": [
      "s3:*"
    ],
    "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
  },
  {
      "Effect": "Allow",
      "Action": [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:GetParametersByPath"
    ],
    "Resource":  ["arn:aws:ssm:*:798347044677:parameter/secure/aue1/c1/codebuild/*"]
  },
  {
      "Effect": "Allow",
      "Action": [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases"
    ],
    "Resource":  ["arn:aws:codebuild:*:798347044677:report-group/${aws_iam_role.cbd_build.name}*"]
    }

  ]
}
POLICY
}

#Finished Codebuild Role
#Started Second Codebuild Role
resource "aws_iam_role" "cbd_buildSecond" {
  name               = "testnamenewsecond"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

  resource "aws_iam_role_policy" "examplesecond" {
  role = "${aws_iam_role.cbd_buildSecond.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
    "Effect" :"Allow",
    "Action": [
      "s3:*"
    ],
    "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
  },
  {
      "Effect": "Allow",
      "Action": [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:GetParametersByPath"
    ],
    "Resource":  ["arn:aws:ssm:*:798347044677:parameter/secure/aue1/c1/codebuild/*"]
  },
  {
      "Effect": "Allow",
      "Action": [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases"
    ],
    "Resource":  ["arn:aws:codebuild:*:798347044677:report-group/${aws_iam_role.cbd_buildSecond.name}*"]
    }

  ]
}
POLICY
}

#Here I am giving access to another account s3 bucket

resource "aws_iam_role_policy" "examplesecondofsecond" {
role = "${aws_iam_role.cbd_buildSecond.name}"

policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": ["*"],
            "Action": ["s3:ListAllMyBuckets"]
        },
        {
            "Effect": "Allow",
            "Resource":[ "arn:aws:s3:::${aws_s3_bucket.codepipeline_bucket.arn}/*"],
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ]
          },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": ["arn:aws:s3:::${aws_s3_bucket.codepipeline_bucket.arn}/*"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::newbucket45151",
                "arn:aws:s3:::newbucket45151/*"
            ]
        }


    ]
}
POLICY
}

//Building Codebuild project

resource "aws_codebuild_project" "build" {
name          = "testproject"
description   = "testprojectdesc"
service_role  = aws_iam_role.cbd_build.arn

artifacts {
  type = "CODEPIPELINE"
}

cache {
  type     = "S3"
  location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
}

environment {
  compute_type                = "BUILD_GENERAL1_SMALL"
   image                       = "aws/codebuild/standard:3.0"
   type                        = "LINUX_CONTAINER"
   image_pull_credentials_type = "CODEBUILD"

   environment_variable {
     name  = "SOME_KEY1"
     value = "SOME_VALUE1"
   }
 }

logs_config {
  cloudwatch_logs {
    group_name  = "testgrp"
    stream_name = "teststream"
  }
}

source {
  type      = "CODEPIPELINE"
  buildspec = "appspec.yml"
}
}
#Building Second Codbuild Project for provision

resource "aws_codebuild_project" "buildSecond" {
name          = "testprojectsecond"
description   = "testprojectdesc"
service_role  = aws_iam_role.cbd_buildSecond.arn

artifacts {
  type = "CODEPIPELINE"
}

cache {
  type     = "S3"
  location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
}

environment {
  compute_type                = "BUILD_GENERAL1_SMALL"
   image                       = "aws/codebuild/standard:3.0"
   type                        = "LINUX_CONTAINER"
   image_pull_credentials_type = "CODEBUILD"

   environment_variable {
     name  = "SOME_KEY1"
     value = "SOME_VALUE1"
   }
 }

logs_config {
  cloudwatch_logs {
    group_name  = "testgrp"
    stream_name = "teststream"
  }
}

source {
  type      = "CODEPIPELINE"
  buildspec = "appspec2.yml"
}
}

#Creating codepipeline

resource "aws_codepipeline" "codepipeline" {
 name     = "tf-test-pipeline"
 role_arn = aws_iam_role.codepipeline_role.arn

 artifact_store {
   location = aws_s3_bucket.codepipeline_bucket.bucket
   type     = "S3"

   # encryption_key {
   #   id   = "${data.aws_kms_alias.s3kmskey.arn}"
   #   type = "KMS"
   # }
 }


 stage {
   name = "Source"

   action {
     name             = "Source"
     category         = "Source"
     owner            = "ThirdParty"
     provider         = "GitHub"
     version          = "1"
     output_artifacts = ["sourceOutput"]
     run_order        = "1"
     configuration = {
        Owner  = "himanipuri-3pillar"
        Repo   = "testets"
        Branch = "master"
        OAuthToken           = "f6a99cb62cd0d83f8de1823ab8b6e5eb460b550b"
        PollForSourceChanges = "false"
      }
}
}

 stage {
     name = "Build"
     action {
       name             = "Build"
       category         = "Build"
       owner            = "AWS"
       provider         = "CodeBuild"
       input_artifacts  = ["sourceOutput"]
       output_artifacts = ["buildOutput"]
       version          = "1"
       configuration = {
         ProjectName = aws_codebuild_project.build.name
         PrimarySource = "sourceOutput"
       }
     }
   }

   stage {
    name = "Provision"
    action {
      name            = "Provision"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["sourceOutput"]
      version         = "1"
      configuration = {
        ProjectName   = aws_codebuild_project.buildSecond.name
        PrimarySource = "sourceOutput"
      }
}
}
}
