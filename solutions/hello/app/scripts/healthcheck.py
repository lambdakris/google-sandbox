import httpx

res = httpx.get("http://0.0.0.0:8080?name=HealthCheck")

assert res.status_code == 200