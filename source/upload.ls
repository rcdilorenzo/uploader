require! <[ path mkdirp fs ]>

infoFilePath = './uploads/info.json'

module.exports = (app, uploadHandler, uploadsPath) ->

  app.post '/upload' (req, res) ->
    name = ''
    if !req.query.name or !req.query.email
      return res.status(400).send { success: false, error: 'Name and email are required.' }

    info = fs.readFileSync infoFilePath |> JSON.parse
    info.push {
      name: req.query.name,
      email: req.query.email
      filename: req.query.filename
    }
    fs.writeFileSync infoFilePath, JSON.stringify(info)

    name = req.query.name.replace(/ /g, '-').toLowerCase!
    uploadNamePath = path.join uploadsPath, name

    mkdirp uploadNamePath, (err) ->
      console.log('error create dir', err) if err
      uploadHandler.configure ->
        this.uploadDir = uploadNamePath
        console.log 'upload dir', this.uploadDir
      uploadHandler.upload req, res
