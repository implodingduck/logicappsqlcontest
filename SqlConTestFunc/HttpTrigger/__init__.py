import logging

import azure.functions as func
import pyodbc
import os

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    connection_string = os.environ.get('PYODBC_CONNECTION_STRING')
    with pyodbc.connect(connection_string) as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT TOP 3 multiplier, multiplicand, product FROM multiplication")
            row = cursor.fetchone()
            while row:
                print(f'{row[0]} X {row[1]} = {row[2]}')
                row = cursor.fetchone()
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        return func.HttpResponse(f"Hello, {name}. This HTTP triggered function executed successfully.")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )
