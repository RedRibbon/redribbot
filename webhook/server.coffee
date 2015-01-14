http      = require 'http'
crypto    = require 'crypto'
{ spawn } = require 'child_process'

server = http.createServer (req, res) ->
  secret = process.env['WEBHOOK_SECRET']
  body   = ''
  req.on 'data', (c) -> body += c.toString()
  req.on 'end' , () ->
    obj = JSON.parse body
    sig = req.headers['x-hub-signature']
    update() if req.url is '/webhook' and obj.action is 'closed' and obj.repository.name is 'redribbot' and sig is getSignature body, secret
    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'OK';

update = () ->
  opt = { cwd : process.cwd() }
  child = spawn 'git', ['pull', '--rebase', 'origin', 'master'], opt
  child.stderr.on 'data', (data) ->
    console.error data?.toString()

getSignature = (body, secret) ->
  sha = crypto.createHmac('sha1', secret).update(body).digest('hex')
  "sha1=#{sha}"

server.listen 9599
