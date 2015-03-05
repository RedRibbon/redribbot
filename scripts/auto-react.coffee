# Description:
#   React with user's swearing keyword on chat room
#
# Commands:
#   hubot react show              - Show registerd react keywords and responses.
#   hubot react add <keyword>     - Add react keyword in firebase.
#   hubot react del <keyword>     - Delete react keyword in firebase.
#   hubot react addres <keyword>  - Add response pattern in firebase.
#   hubot react delres <keyword>  - Delete response pattern in firebase.
#
# Author:
#   chitacan
#
# Contributor:
#   imazine

FB = require 'firebase'
_  = require 'underscore'
C  = require 'crypto'
B  = require 'redribbot-brain'

class React
  constructor: (@robot) ->

  getRegEx: () ->
    keywords = _.values(@data.keywords).join '|'
    new RegExp keywords, "i"

  removePreviousListener: () ->
    _lstnrs = @robot.listeners
    @robot.listeners = _.reject _lstnrs, (lstnr) => lstnr.callback == @react

  rnd: (basic) -> 
    Math.floor(Math.random() * 100) < basic

  react: (msg) =>
    keyword = msg.match[0]
    response = msg.random _.values(@data.responses)
    res = response.replace('{key}', keyword)
    query = "#{keyword} 웃긴짤"
    msg.reply "#{res}"
    if @rnd 50 then getImage msg, query, true, true, (url) -> msg.send url

  updateAll: (data) ->
    @removePreviousListener()
    @data = data
    @regex = @getRegEx()
    @robot.hear @regex, @react

  updateKeywords: (keywords) ->
    @removePreviousListener()
    @data.keywords = keywords
    @regex = @getRegEx()
    @robot.hear @regex, @react

  updateResponses: (responses) ->
    @data.responses = responses

  update: (key, data) ->
    switch key
      when 'all'       then @updateAll data
      when 'keywords'  then @updateKeywords data
      when 'responses' then @updateResponses data

module.exports = (robot) ->

  fb    = B.root.child 'scripts/react'
  react = new React robot

  keyRef = fb.child 'keywords'
  resRef = fb.child 'responses'

  add = (ref, val, msg) ->
    ref.set val, (err) -> msg.send if err then err else ":pushpin: adding #{val}"

  del = (ref, val, msg) ->
    ref.remove (err) -> msg.send if err then else ":pushpin: delete #{val}"

  B.auth (auth) ->
    return unless auth
    fb.once 'value', (res) -> react.update 'all', res.val() if res.exists()

  fb.on 'child_changed', (data) ->
    react.update data.key(), data.val()

  robot.respond /react show/i, (msg) ->
    keywords  = _.values(react.data.keywords).join()
    responses = _.values(react.data.responses).join()
    msg.send ":key: #{keywords}"
    msg.send ":name_badge: #{responses}"

  robot.respond /react (add|del) (.*)/i, (msg) ->
    cmd = msg.match[1]
    key = msg.match[2]
    id = sha key
    ref = keyRef.child id
    if cmd is 'add' then add ref, key, msg else del ref, key, msg

  robot.respond /react (addres|delres) (.*)/i, (msg) ->
    cmd = msg.match[1].replace('res', '')
    res = msg.match[2]
    id = sha res
    ref = resRef.child id
    if cmd is 'add' then add ref, res, msg else del ref, res, msg

sha = (data) ->
  s = C.createHash 'sha1'
  s.update data
  s.digest('hex').slice 0, 10

getImage = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  q = v: '1.0', rsz: '8', q: query, safe: 'active'
  q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
  q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get() (err, res, body) ->
      images = JSON.parse(body)
      images = images.responseData?.results
      if images?.length > 0
        image = msg.random images
        cb ensureImageExtension image.unescapedUrl

ensureImageExtension = (url) ->
  ext = url.split('.').pop()
  if /(png|jpe?g|gif)/i.test(ext)
    url
  else
    "#{url}#.png"
