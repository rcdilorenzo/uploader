require! <[ path mkdirp ]>

module.exports = (app, uploadHandler, uploadsPath) ->

  app.post '/upload' (req, res) ->
    name = ''
    if !req.query.name
      return res.status(400).send { success: false, error: 'Name is required.' }

    name = req.query.name.replace(/ /g, '-').toLowerCase!
    uploadNamePath = path.join uploadsPath, name

    mkdirp uploadNamePath, (err) ->
      console.log('error create dir', err) if err
      uploadHandler.configure ->
        this.uploadDir = uploadNamePath
        console.log 'upload dir', this.uploadDir
      uploadHandler.upload req, res
