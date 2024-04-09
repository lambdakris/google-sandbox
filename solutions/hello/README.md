A basic hello world app, but with iac, apm, and cicd

## Structure

- hello/
  - app/
  - tests/

## Instructions

### Setup
1. Using the terminal, execute the following commands
    ```
    source .venv/bin/activate

    pip install -r app/requirements.txt -r tests/requirements.txt 
    ```

### Running
1. Using the terminal, execute the following commands
    ```
    docker compose build

    docker compose watch --no-up & docker compose up
    ```

### Debugging
1. Follow instructions for [Running](#running)
1. Using VS Code, execute the `Hello Debugger` configuration using either the Run and Debug Explorer or the Command Palette

### Testing
1. Follow instructions for [Setup](#setup)
1. Using VS Code, execute the desired test(s) using either the Testing Explorer or the Command Palette