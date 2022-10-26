import unzip_requirements
from transformers import AutoTokenizer, AutoModelForCausalLM
import os
import boto3

s3 = boto3.resource("s3")


def download_s3_folder(bucket_name, s3_folder, local_dir=None):
    """
    Download the contents of a folder directory
    Args:
        bucket_name: the name of the s3 bucket
        s3_folder: the folder path in the s3 bucket
        local_dir: a relative or absolute directory path in the local file system
    """
    bucket = s3.Bucket(bucket_name)
    for obj in bucket.objects.filter(Prefix=s3_folder):
        target = (
            obj.key
            if local_dir is None
            else os.path.join(local_dir, os.path.relpath(obj.key, s3_folder))
        )
        if not os.path.exists(os.path.dirname(target)):
            os.makedirs(os.path.dirname(target))
        if obj.key[-1] == "/":
            continue
        bucket.download_file(obj.key, target)


def lambda_handler(event, context: dict) -> dict:
    download_s3_folder("random-tweet-bucket", "lambda/model/", local_dir="/tmp/model/")
    model = AutoModelForCausalLM.from_pretrained("/tmp/model")
    tokenizer = AutoTokenizer.from_pretrained("/tmp/model")
    prompt = "Today I believe we can finally"
    input_ids = tokenizer(prompt, return_tensors="pt").input_ids

    outputs = model.generate(input_ids, do_sample=True, max_length=30)
    return tokenizer.batch_decode(outputs, skip_special_tokens=True)
