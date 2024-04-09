import pytest
from starlette.testclient import TestClient
from app.main import app

@pytest.fixture
def app_client():
    app_client = TestClient(app)
    return app_client

def test_get_root_default(app_client):
    response = app_client.get("/")

    assert response.status_code == 200
    assert response.text == '"Hello World!"'

@pytest.mark.parametrize(
    "name",
    ["Kristoffer", "Garcia", "", None]
)
def test_get_root_name(app_client, name):
    response = app_client.get(f"/?name={name}")

    assert response.status_code == 200
    assert response.text == f'"Hello {name}!"'