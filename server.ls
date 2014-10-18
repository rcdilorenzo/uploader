require! <[ express fs path ]>
uploadProgress = require 'node-upload-progress'

app = express!
app.set 'views' __dirname + '/public/'
app.set 'view engine' 'jade'
app.use express.static(__dirname + '/public')

uploadsPath = path.join __dirname, 'uploads'

uploadHandler = new uploadProgress.UploadHandler;
uploadHandler.configure ->
  this.uploadDir = uploadsPath
  this.onEnd = (req, res) ->
    res.status(201).send { success: true }


app.get '/' (req, res) ->
  res.render 'index'

require('./source/upload')(app, uploadHandler, uploadsPath)

app.get '/progress' (req, res) ->
  uploadHandler.progress req, res

app.all '/**' (req, res) ->
  res.send 'This is not the webpage you are looking for.'


module.exports = app
