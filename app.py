from flask import Flask, render_template

app = Flask(__name__)


@app.route('/')
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


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8050, debug=True) 