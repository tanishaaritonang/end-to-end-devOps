from flask import Flask
import time

app = Flask(__name__)

@app.route('/')
def get_CurrentTime():
    return f"Current Server Time: {time.strftime('%Y-%m-%d %H:%M:%S')}"

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)

    # Run the Flask app on all available IPs on port 808000