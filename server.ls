require! <[ express fs multiparty path ]>

tokens = <[ nick ]>
uploadsPath = path.join __dirname, 'uploads'

app = express!
app.set 'views' __dirname + '/public/'
app.set 'view engine' 'jade'
app.use express.static(__dirname + '/public')

validToken = (token) ->
  return false if !token
  tokens.indexOf(token.toLowerCase!) != -1


app.post '/upload', (req, res, next) ->
  form = new multiparty.Form!
  valid = false
  didUpload = false

  form.on 'error' (err) ->
    console.log 'Error parsing form: ' + err.stack

  form.on 'field' (name, value) ->
    unless validToken(value)
      req.error = 'Proper validation required.'
      req.errorCode = 401
      next!

  form.on 'progress' (received, expected) ->
    console.log 'Uploading: ' + (received / expected) * 100 + '%'

  form.on 'part' (part) ->
    return part.resume! if part.filename and part.name != 'file'
    return if !part.filename or res.headersSent

    targetPath = path.join uploadsPath, part.filename
    stream = fs.createWriteStream targetPath

    part.on 'end' (err) ->
      res.status(201).send { success: true, filename: part.filename } unless res.headersSent

    part.pipe stream

  form.on 'close' ->
    res.status(400).send { success: false, error: 'No file uploaded.' } unless res.headersSent

  form.parse req

app.use (req, res, next) ->
  return next! unless req.error && req.errorCode
  res.status(req.errorCode).send { success: false, error: req.error }

app.get '/' (req, res) ->
  res.render 'index'

app.all '/**' (req, res) ->
  res.send 'This is not the webpage you are looking for.'

module.exports = app
