output "id" {
  description = "Bucket name. Available only once the bucket policy and public access block are in place."
  value       = aws_s3_bucket.this.id

  depends_on = [
    aws_s3_bucket_policy.this,
    aws_s3_bucket_public_access_block.this,
  ]
}

output "arn" {
  description = "Bucket ARN."
  value       = aws_s3_bucket.this.arn
}
