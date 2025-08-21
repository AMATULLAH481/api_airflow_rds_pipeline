from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import psycopg2
from airflow.models import Variable
from api_data_source import fetch_books_data

RDS_HOST = Variable.get("rds_endpoint")
RDS_PORT = Variable.get ("rds_port")
RDS_DB = Variable.get("db_name")
RDS_USER = Variable.get ("db_username")
RDS_PASSWORD = Variable.get ("db_password")

def upload_books_to_rds():
    conn = psycopg2.connect(
        host=RDS_HOST,
        port=RDS_PORT,
        dbname=RDS_DB,
        user=RDS_USER,
        password=RDS_PASSWORD,
    )
    cur = conn.cursor()

    create_data_table = """
    CREATE TABLE IF NOT EXISTS books (
        id SERIAL PRIMARY KEY,
        title TEXT,
        subjects TEXT[],
        authors TEXT[]
    )
    """
    cur.execute(create_data_table)

    books = fetch_books_data()

    insert_sql = """
    INSERT INTO books (title, subjects, authors)
    VALUES (%s, %s, %s)
    """
    cur.executemany(insert_sql, books)

    conn.commit()
    cur.close()
    conn.close()

with DAG(
    dag_id="books_to_rds",
    start_date=datetime(2025, 8, 20),
    schedule_interval="@daily"
) as dag:

    upload_task = PythonOperator(
        task_id="fetch_and_upload_books_data",
        python_callable=upload_books_to_rds,
    )