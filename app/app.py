import time
from flask import Flask, render_template, request, make_response
from selenium import webdriver

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/screenshot', methods=['POST','GET'])
def screenshot():
    if request.method == 'POST':
        url = request.form['url']
    else:
        url = request.args.get('url')
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--window-size=1920,1080')
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--disable-gpu')
    chrome_options.add_argument('--disable-dev-shm-usage')
    driver = webdriver.Chrome(chrome_options=chrome_options)
    driver.set_page_load_timeout(60)
    driver.get(url)
    screenshot = driver.get_screenshot_as_png()
    driver.quit()
    response = make_response(screenshot)
    response.headers['Content-Type'] = 'image/png'
    return response

if __name__ == '__main__':
    from gunicorn.app.base import Application

    class FlaskApplication(Application):
        def init(self, parser, opts, args):
            return {
                'bind': '0.0.0.0:5000',
                'workers': 4
            }

        def load(self):
            return app

    FlaskApplication().run()
