http      = require 'http'
crypto    = require 'crypto'
Github    = require 'github'
Q         = require 'q'
_         = require 'underscore'
{ spawn } = require 'child_process'

server = http.createServer (req, res) ->
  secret = process.env.WEBHOOK_SECRET
  body   = ''
  req.on 'data', (c) -> body += c.toString()
  req.on 'end' , () ->
    obj = JSON.parse body
    sig = req.headers['x-hub-signature']
    handle(obj) if req.url is '/webhook' and obj.repository.name is 'redribbot' and sig is getSignature body, secret
    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'OK';

handle = (obj) ->
  switch obj.action
    when 'closed' then update()
    when 'opened' then merge(obj)

update = () ->
  opt = { cwd : process.cwd() }
  child = spawn 'git', ['pull', '--rebase', 'origin', 'master'], opt
  child.stderr.on 'data', (data) ->
    console.error data?.toString()

getSignature = (body = '', secret = '') ->
  sha = crypto.createHmac('sha1', secret).update(body).digest('hex')
  "sha1=#{sha}"

merge = (obj) ->
  token = process.env.GITHUB_API_TOKEN
  return console.error 'GITHUB_API TOKEN is not available on your env.' unless token?

  api = new Github { version : '3.0.0' }
  api.authenticate
    type  : 'oauth'
    token : token

  user   = obj.sender.login # request user
  number = obj.pull_request.number #issue number

  org = org: 'redribbon'
  auto = 
    user: 'redribbon'
    repo: 'redribbot'
    body: "@#{user}!! what a contribute :lipstick:"
    number: number
  welcome = 
    user: 'redribbon'
    repo: 'redribbot'
    body: "Hi, @#{user}. Thanks to contribute redribbot. Someone will show up soon."
    number: number
  commit = 
    user: 'redribbon'
    repo: 'redribbot'
    number: number
    commit_message: ':shipit:'

  getMembers     = Q.nbind api.orgs.getMembers      ,api, org
  autoComment    = Q.nbind api.issues.createComment ,api, auto
  welcomeComment = Q.nbind api.issues.createComment ,api, welcome
  confirmMerge   = Q.nbind api.pullRequests.merge   ,api, commit

  getMembers()
    .then (members) ->
      _.pluck members, 'login'
    .then (members) ->
      throw {
        name    : "NotRedribbonMemeberError"
        message : "#{user} is not memeber in Redribbon Organization."
      } unless _.contains members, user
    .then ()        -> autoComment()
    .then ()        -> confirmMerge()
    .then ()        -> console.log 'OK Merged'
    .catch (error)  -> 
      return welcomeComment() if error.name is "NotRedribbonMemeberError"
      console.log error
    .done ()        -> console.log 'Finished'

server.listen 9599, () -> console.log 'webhook server started'
