import os

from opentelemetry.sdk.resources import Resource

import logging
from opentelemetry._logs import set_logger_provider
from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter

from opentelemetry.trace import set_tracer_provider, get_tracer
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

from opentelemetry.propagate import set_global_textmap
from opentelemetry.propagators.cloud_trace_propagator import CloudTraceFormatPropagator

from fastapi import FastAPI

otel_endpoint = os.environ["OTEL_COLLECTOR_ENDPOINT"]

service_name = "hello-app"
service_instance = os.uname().nodename

resource = Resource(
    attributes = { 
        "service.name": service_name,
        "service.instance.id": service_instance
    }
)

def setup_logging():
    provider = LoggerProvider(
        resource=resource,
        multi_log_record_processor=BatchLogRecordProcessor(OTLPLogExporter(otel_endpoint, True))
    )
    set_logger_provider(provider)

    logging.basicConfig(level=logging.INFO, handlers=[LoggingHandler(logging.INFO, provider)])

def setup_tracing():
    provider = TracerProvider(
        resource=resource,
        active_span_processor=BatchSpanProcessor(OTLPSpanExporter(otel_endpoint, True))
    )
    set_tracer_provider(provider)

setup_logging()
setup_tracing()

set_global_textmap(CloudTraceFormatPropagator())

logger = logging.getLogger(__name__)
tracer = get_tracer(__name__)

app = FastAPI()

@app.get("/")
@app.get("/hello")
def get_hello(name: str = "World"):
    with tracer.start_as_current_span("get_hello") as span:
        greeting = f"Hello {name}!"
        logger.info("Saying hello", extra={ "hello.name": name, "hello.greeting": greeting })
        return greeting