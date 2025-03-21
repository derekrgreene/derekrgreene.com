from flask import Flask, render_template, Response
from flask_caching import Cache
import datetime

app = Flask(__name__)

app.config['CACHE_TYPE'] = 'simple'
cache = Cache(app)

@app.route('/error')
def trigger_error():
    raise Exception("This is a test error!")

@app.errorhandler(404)
def notFound(error):
    return render_template('404.html'), 404


@app.errorhandler(500)
def internalError(error):
    return render_template('500.html'), 500


@app.route('/')
@cache.cached(timeout=3600) # 1 hour
def index():      
    return render_template('index.html')


@app.route('/DCV-Dependencies')
def DCVDependencies():
    return render_template('dv.html')


@app.route('/domainScout')
def domainScout():
    return render_template('domainscout.html')


@app.route('/gardenPlanter')
def gardenPlanter():
    return render_template('gardenplanter.html')


@app.route('/inventoryTracker')
def inventoryTracker():
    return render_template('inventorytracker.html')


@app.route('/lowLevelIO')
def lowLevelIO():
    return render_template('lowlevelio.html')


@app.route('/OTP')
def OTP():
    return render_template('otp.html')


@app.route('/randomNumGen')
def randomNumGen():
    return render_template('randomnumgen.html')


@app.route('/smallSH')
def smallSH():
    return render_template('smallsh.html')


@app.route('/snakeGame')
def snakeGame():
    return render_template('snakegame.html')


@app.route('/virtualPantry')
def virtualPantry():
    return render_template('virtualpantry.html')


@app.route('/robots.txt')
def robots():
    return Response("User-agent: *\nAllow: /\nSitemap: https://derekrgreene.com/sitemap.xml",mimetype="text/plain")


@app.route('/sitemap.xml')
def sitemap():
    baseUrl = "https://derekrgreene.com"
    today = datetime.datetime.now().strftime('%Y-%m-%d')
    
    urls = [
        {"loc": f"{baseUrl}/", "priority": "1.0"},
        {"loc": f"{baseUrl}/domainScout", "priority": "0.8"},
        {"loc": f"{baseUrl}/OTP", "priority": "0.8"},
        {"loc": f"{baseUrl}/inventoryTracker", "priority": "0.8"},
        {"loc": f"{baseUrl}/snakeGame", "priority": "0.8"},
        {"loc": f"{baseUrl}/virtualPantry", "priority": "0.8"},
        {"loc": f"{baseUrl}/gardenPlanter", "priority": "0.8"},
        {"loc": f"{baseUrl}/smallSH", "priority": "0.8"},
        {"loc": f"{baseUrl}/lowLevelIO", "priority": "0.8"},
        {"loc": f"{baseUrl}/randomNumGen", "priority": "0.8"},
        {"loc": f"{baseUrl}/DCV-Dependencies", "priority": "0.9"},
    ]
    
    xml_content = '<?xml version="1.0" encoding="UTF-8"?>\n'
    xml_content += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
    
    for url in urls:
        xml_content += '  <url>\n'
        xml_content += f'    <loc>{url["loc"]}</loc>\n'
        xml_content += f'    <lastmod>{today}</lastmod>\n'
        xml_content += '    <changefreq>monthly</changefreq>\n'
        xml_content += f'    <priority>{url["priority"]}</priority>\n'
        xml_content += '  </url>\n'
    xml_content += '</urlset>'
    
    return Response(xml_content, mimetype='application/xml')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8050, debug=False) 