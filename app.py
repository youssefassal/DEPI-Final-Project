# Import the tools we need
from flask import Flask, request, jsonify, redirect, send_file
from flask_cors import CORS
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import sqlite3
import hashlib
import time

# Create Flask app
app = Flask(__name__)
CORS(app)

# Database file name
DATABASE = 'urls.db'

# ===== METRICS SETUP =====
urls_created = Counter('urls_shortened_total', 'How many URLs we shortened')
successful_redirects = Counter('redirects_total', 'How many times we redirected users')
not_found_errors = Counter('failed_lookups_total', 'How many 404 errors happened')
response_time = Histogram('request_latency_seconds', 'How fast we respond', ['endpoint', 'method'])


# ===== DATABASE HELPERS =====
def connect_to_database():
    """Open connection to SQLite database"""
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row 
    return conn


def setup_database():
    """Create the database table if it doesn't exist"""
    conn = connect_to_database()
    conn.execute('''
        CREATE TABLE IF NOT EXISTS urls (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            short_code TEXT UNIQUE NOT NULL,
            long_url TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    conn.close()


def make_short_code(url):
    """Turn a long URL into a short 8-character code"""
    hash_result = hashlib.md5(url.encode())
    return hash_result.hexdigest()[:8]


# ===== WEB PAGES =====
@app.route('/', methods=['GET'])
def home_page():
    """Show the main web page"""
    try:
        return send_file('index.html')
    except:
        return jsonify({
            "service": "URL Shortener API",
            "version": "1.0.0",
            "how_to_use": {
                "shorten_url": "POST /shorten with {url: 'https://example.com'}",
                "use_short_url": "GET /<short_code> to redirect",
                "check_health": "GET /health",
                "view_stats": "GET /stats"
            }
        })


@app.route('/health', methods=['GET'])
def health_check():
    """Check if the service is running - Returns 'healthy' status"""
    return jsonify({"status": "healthy"}), 200


# ===== MAIN FEATURES =====
@app.route('/shorten', methods=['POST'])
def shorten_url():
    """Create a short URL from a long URL"""
    start_time = time.time()
    
    try:
        data = request.get_json()
        if not data or 'url' not in data:
            return jsonify({"error": "Please provide a URL"}), 400
        
        long_url = data['url']
        
        short_code = make_short_code(long_url)
        
        conn = connect_to_database()
        try:
            conn.execute('INSERT INTO urls (short_code, long_url) VALUES (?, ?)',
                        (short_code, long_url))
            conn.commit()
        except sqlite3.IntegrityError:
            pass
        conn.close()
        
        urls_created.inc()
        
        short_url = f"{request.host_url}{short_code}"
        
        return jsonify({
            "short_code": short_code,
            "short_url": short_url,
            "long_url": long_url
        }), 201
    
    finally:
        elapsed = time.time() - start_time
        response_time.labels(endpoint='/shorten', method='POST').observe(elapsed)


@app.route('/<short_code>', methods=['GET'])
def use_short_url(short_code):
    """Redirect user from short URL to the original long URL"""
    start_time = time.time()
    
    try:
        conn = connect_to_database()
        cursor = conn.execute('SELECT long_url FROM urls WHERE short_code = ?',
                            (short_code,))
        result = cursor.fetchone()
        conn.close()
        
        if result:
            successful_redirects.inc()
            long_url = result['long_url']
            return redirect(long_url, code=302)
        else:
            not_found_errors.inc()
            return jsonify({"error": "Short code not found"}), 404
    
    finally:
        elapsed = time.time() - start_time
        response_time.labels(endpoint='/<short_code>', method='GET').observe(elapsed)


# ===== MONITORING ENDPOINTS =====
@app.route('/stats', methods=['GET'])
def get_stats():
    """Show how many URLs have been shortened"""
    conn = connect_to_database()
    cursor = conn.execute('SELECT COUNT(*) as count FROM urls')
    count = cursor.fetchone()['count']
    conn.close()
    
    return jsonify({"total_urls": count}), 200


@app.route('/metrics', methods=['GET'])
def prometheus_metrics():
    """Provide metrics for Prometheus monitoring"""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


# ===== START THE APP =====
if __name__ == '__main__':
    setup_database()
    app.run(host='0.0.0.0', port=5000, debug=False)
