http      = require 'http'
crypto    = require 'crypto'
Github    = require 'github'
Q         = require 'q'
_         = require 'underscore'
{ spawn } = require 'child_process'

server = http.createServer (req, res) ->
  secret = process.env.WEBHOOK_SECRET
  body   = ''
  cache = []
  req.on 'data', (c) -> cache.push c
  req.on 'end' , ()  ->
    buf  = Buffer.concat cache
    obj  = JSON.parse buf.toString()
    sig  = req.headers['x-hub-signature']
    repo = obj.repository.name
    gsig = getSignature buf.toString('binary'), secret

    if req.url is '/webhook' and repo is 'redribbot' and sig is gsig
      handle(buf)
    else
      handleError(repo, sig, gsig)

    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'OK';

handle = (obj) ->
  switch obj.action
    when 'closed' then update()
    when 'opened' then merge(obj)

handleError = (repo, sig, gsig) ->
  console.error "#{new Date()} cannot handle github webhooks"
  console.error "x-hub-signature : #{sig}"
  console.error "genereated      : #{gsig}"
  console.error "from repo       : #{repo}"

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
  error =
    user: 'redribbon'
    repo: 'redribbot'
    body: "Oops, your request cannot be merged. :alien:"
    number: number

  getMembers     = Q.nbind api.orgs.getMembers      ,api, org
  autoComment    = Q.nbind api.issues.createComment ,api, auto
  welcomeComment = Q.nbind api.issues.createComment ,api, welcome
  errorComment   = Q.nbind api.issues.createComment ,api, error
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
      console.log error
      return errorComment()   if error.code is 405
      return welcomeComment() if error.name is "NotRedribbonMemeberError"
    .done ()        -> console.log 'Finished'

server.listen 9599, () -> console.log 'webhook server started'
