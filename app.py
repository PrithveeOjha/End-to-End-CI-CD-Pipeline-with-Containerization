from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello, World! This is version 1.0!"

if __name__ == "__main__":
    # Get port from environment variable or default to 5000
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=True, host='0.0.0.0', port=port)