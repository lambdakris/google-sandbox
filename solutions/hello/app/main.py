from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def hello(name: str = "World"):
    greeting = f"Hello {name}!"
    return greeting