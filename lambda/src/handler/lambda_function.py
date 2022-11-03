import unzip_requirements
from transformers import AutoTokenizer, GPT2LMHeadModel
import os
import boto3
import tweepy
import random

BUCKET_NAME = "random-tweet-bucket"
s3 = boto3.resource("s3")
bucket = s3.Bucket(BUCKET_NAME)

api_token = os.getenv("API_TOKEN")
api_secret = os.getenv("API_TOKEN_SECRET")
bearer_token = os.getenv("BEARER_TOKEN")
access_token = os.getenv("ACCESS_TOKEN")
access_token_secret = os.getenv("ACCESS_TOKEN_SECRET")


def create_tweet(text: str) -> None:
    client = tweepy.Client(
        bearer_token=bearer_token,
        consumer_key=api_token,
        consumer_secret=api_secret,
        access_token=access_token,
        access_token_secret=access_token_secret,
    )
    client.create_tweet(text=text)


def generate_random_tweet(model, tokenizer, input: str) -> str:
    input_ids = tokenizer(input, return_tensors="pt").input_ids
    outputs = model.generate(
        input_ids,
        do_sample=True,
        max_length=50,
        top_k=50,
        top_p=0.95,
    )

    return tokenizer.batch_decode(outputs, skip_special_tokens=True)[0]


def download_s3_folder(bucket_obj, s3_folder, local_dir=None):
    """
    Download the contents of a folder directory
    """
    for obj in bucket_obj.objects.filter(Prefix=s3_folder):
        target = (
            obj.key
            if local_dir is None
            else os.path.join(local_dir, os.path.relpath(obj.key, s3_folder))
        )
        if not os.path.exists(os.path.dirname(target)):
            os.makedirs(os.path.dirname(target))
        if obj.key[-1] == "/":
            continue
        bucket_obj.download_file(obj.key, target)


def get_trend() -> str:
    # make the API connection
    auth = tweepy.OAuth2BearerHandler(bearer_token)
    api = tweepy.API(auth)

    # get list with dictionaries with information of locations available to get trending topics
    trending_places = api.available_trends()

    # return a random place - get the list of an element using randint
    random_place = trending_places[random.randint(0, len(trending_places) - 1)]

    # get the trending topics from that place
    random_woeid = random_place["woeid"]
    random_trends = api.get_place_trends(random_woeid)[0]["trends"]

    # get a random trend
    random_trend = random_trends[random.randint(0, len(random_trends) - 1)]["name"]

    return random_trend


def lambda_handler(event: dict, context: dict) -> dict:
    download_s3_folder(bucket, "lambda/model/", local_dir="/tmp/model/")
    tokenizer = AutoTokenizer.from_pretrained("/tmp/model")
    model = GPT2LMHeadModel.from_pretrained(
        "/tmp/model", pad_token_id=tokenizer.eos_token_id
    )
    trend = get_trend()
    random_tweet = generate_random_tweet(model, tokenizer, trend)
    text_to_tweet = f""" 
    {random_tweet}
    
#{trend}
    """
    create_tweet(text_to_tweet)

    return {"Tweet": "Successfully tweeted."}
