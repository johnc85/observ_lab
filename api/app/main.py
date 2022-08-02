from fastapi import FastAPI
import random
import logging
from starlette_prometheus import metrics, PrometheusMiddleware


app = FastAPI()
app.add_middleware(PrometheusMiddleware)
app.add_route("/metrics", metrics)


@app.get("/")
def health():
    return {"Alive"}


@app.get("/number")
def randon_number():
    logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)
    logging.info('Should I log 2xx??')
    number = random.randint(0, 999)
    return {"Number": number}
