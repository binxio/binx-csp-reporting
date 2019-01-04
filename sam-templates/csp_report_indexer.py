from elasticsearch import Elasticsearch, RequestsHttpConnection
from requests_aws4auth import AWS4Auth
import boto3
from datetime import date
import os

INDEX_NAME = 'csp'
DOCTYPE = 'report'
SERVICE = 'es'
REGION = os.environ['REGION']
HOST = os.environ['DOMAIN_ENDPOINT']


def index_document(es: Elasticsearch, index_name: str, doctype: str, document: dict) -> None:
    """index a document in elasticsearch"""
    es.index(index=index_name, doc_type=doctype, body=document)


def get_current_year_month_day() -> str:
    """returns the iso date format yyyy-mm-dd"""
    return date.today().isoformat()


def get_index_with_date(index: str) -> str:
    """returns the index with date in the format index-yyyy-mm-dd"""
    return index + "-" + get_current_year_month_day()


def get_credentials():
    return boto3.Session().get_credentials()


def get_auth(credentials, region, service):
    return AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)


def get_es_client(host: str, aws_auth, port=443):
    """Returns the elasticsearch client"""
    return Elasticsearch(
        hosts=[{'host': host, 'port': port}],
        http_auth=aws_auth,
        use_ssl=True,
        verify_certs=True,
        connection_class=RequestsHttpConnection
    )


def process_csp_report_event(event: dict) -> [dict]:
    print(f'The raw event =======> $event')
    return event


def handler(event: dict, _: dict) -> None:
    csp_report = process_csp_report_event(event)

    # es = get_es_client(HOST, get_auth(get_credentials(), REGION, SERVICE))
    # index_document(es, get_index_with_date(INDEX_NAME), DOCTYPE, csp_report)
