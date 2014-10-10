require! <[ express fs multiparty path ]>

tokens = <[ nick ]>
uploadsPath = path.join __dirname, 'uploads'

app = express!

validToken = (token) ->
  tokens.indexOf(token.toLowerCase!) != -1


app.post '/upload', (req, res, next) ->
  form = new multiparty.Form!
  didUpload = false
  unless validToken(req.query.token)
    return res.status(401).send { success: false, error: 'Unauthorized' }

  form.on 'error' (err) ->
    console.log 'Error parsing form: ' + err.stack

  form.on 'progress' (received, expected) ->
    console.log 'Uploading: ' + (received / expected) * 100 + '%'

  form.on 'part' (part) ->
    return part.resume! if !part.filename or part.name != 'file'

    targetPath = path.join uploadsPath, part.filename
    stream = fs.createWriteStream targetPath

    part.on 'end' (err) ->
      didUpload := true
      if err
        res.status(500).send { success: false, error: 'File upload error: ' + err }
      else
        res.status(201).send { success: true, filename: part.filename }
    part.pipe stream

  form.on 'close' ->
    res.status(400).send { success: false, error: 'No file uploaded.' } unless didUpload

  form.parse req


app.all '/**' (req, res) ->
  res.send 'This is not the webpage you are looking for.'

module.exports = app
