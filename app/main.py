from flask import Flask, jsonify

app = Flask(__name__)

ORDERS = [
    {"id": 1, "item": "Kubernetes cluster", "status": "shipped"},
    {"id": 2, "item": "Helm chart", "status": "processing"},
    {"id": 3, "item": "CI/CD pipeline", "status": "processing"},
]


@app.route("/")
def root():
    return jsonify({"service": "orders-api", "status": "ok"})


@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/orders")
def orders():
    return jsonify(ORDERS)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
# trigger
