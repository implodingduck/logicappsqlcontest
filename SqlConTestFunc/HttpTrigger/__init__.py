import logging

import azure.functions as func
import pyodbc
import os

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    connection_string = os.environ.get('PYODBC_CONNECTION_STRING')

    print(f'{req.get_body()}')
    new_item = req.get_body()["value"]
    print(f'{new_item}')
    print(f'ID: {new_item["ID"]}')
    print(f'multiplier: {new_item["multiplier"]}')
    print(f'multiplicand: {new_item["multiplicand"]}')
    with pyodbc.connect(connection_string) as conn:
        with conn.cursor() as cursor:
            cursor.execute(f'UPDATE multiplication SET product={new_item["multiplier"] * new_item["multiplicand"]}, updatedDate=GETDATE() WHERE ID={new_item["ID"]}')
           
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
