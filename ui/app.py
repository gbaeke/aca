from flask import Flask, render_template, request
import requests, os
 
app = Flask(__name__, template_folder='./templates')

# this is the FQDN to the backend
# this can be the internal ACA ingress URL
backend = os.environ.get('BACKEND')

@app.route('/')
def form():
    form_data = {}
    return render_template('form.html', form_data=form_data)

@app.route('/data', methods=['POST'])
def data():
    posted_data = request.form
    
    payload = {
        "key": posted_data['name'],
        "data": posted_data['amount']
    }

    r = requests.post(backend + "/savestate", json=payload)
    
    form_data = posted_data.copy()
    form_data['status'] = r.status_code

    return render_template('form.html', form_data=form_data)
    



# main driver function
if __name__ == '__main__':
 
    app.run(host='0.0.0.0', port=8080, debug=False)