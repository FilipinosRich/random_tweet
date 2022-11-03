import boto3
from mock import Mock
from moto import mock_s3
import os
import sys

sys.modules["unzip_requirements"] = Mock()

from handler import lambda_function

AWS_ACCOUNT_ID = "012345678910"
REGION = "eu-west-1"
BUCKET_NAME = "test-bucket"

os.environ["AWS_ACCOUNT_ID"] = AWS_ACCOUNT_ID
os.environ["AWS_DEFAULT_REGION"] = REGION


@mock_s3
def test_download_s3_folder(tmpdir):
    bucket_name = _create_bucket()
    bucket_conn = boto3.resource("s3").Bucket(bucket_name)
    _upload_object_to_bucket(
        bucket_name=bucket_name, key="lambda/model/pytorch_model.bin"
    )
    _upload_object_to_bucket(bucket_name=bucket_name, key="lambda/model/config.json")
    temp_dir = str(tmpdir.mkdir("temp"))
    lambda_function.download_s3_folder(
        bucket_conn, "lambda/model/", local_dir=f"{temp_dir}/"
    )
    assert os.path.isdir(temp_dir)
    assert len(os.listdir(temp_dir)) == 2


def _create_bucket(bucket_name: str = BUCKET_NAME, region: str = REGION) -> str:
    """
    We are mocking the AWS environment and thus have to create a mock bucket.
    """
    s3 = boto3.resource("s3", region_name=region)
    s3.create_bucket(
        Bucket=bucket_name, CreateBucketConfiguration={"LocationConstraint": region}
    )
    s3.BucketVersioning(bucket_name).enable()
    return bucket_name


def _upload_object_to_bucket(bucket_name: str, key: str, body: str = "") -> str:
    """
    We need to dump an object into our mock bucket.
    """
    s3_client = boto3.client("s3")
    version = s3_client.put_object(Bucket=bucket_name, Key=key, Body=body)
    return version
