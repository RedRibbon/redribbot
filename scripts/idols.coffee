# Description:
#   Get random idol image.
#
# Commands:
#   hubot <name> (keyword) - get idol image based on keywords.
#   hubot idol - get random idol image.
#   hubot idol show - print saved names & keywords.
#   hubot idol add <name> - add name in firebase.
#   hubot idol addkey <keyword> - add keyword in firebase.
#   hubot idol del <name> - delete name in firebase.
#   hubot idol delkey <keyword> - detele keyword in firebase.
#
# Author:
#   chitacan

_  = require 'underscore'
FB = require 'firebase'
C  = require 'crypto'
B  = require 'redribbot-brain'

class Idol
  constructor: (@robot) ->

  getRegEx: () ->
    idols = _.values(@data.names).join '|'
    new RegExp "(#{idols})\\s?(.*)?", "i"

  removePreviousListener: () ->
    _lstnrs = @robot.listeners
    @robot.listeners = _.reject _lstnrs, (lstnr) => lstnr.callback == @query

  query: (msg) =>
    idol    = msg.match[1] ? msg.random _.values(@data.names)
    keyword = msg.match[2] ? msg.random _.values(@data.keywords)
    query   = "#{idol} #{keyword}"
    msg.send ":mag: #{query}... I have found the thing."
    imageMe msg, query, true, true, (url) -> msg.send url

  updateAll: (data) ->
    @removePreviousListener()
    @data = data
    @regex = @getRegEx()
    @robot.respond @regex, @query

  updateKeywords: (keywords) ->
    @data.keywords = keywords

  updateNames: (names) ->
    @removePreviousListener()
    @data.names = names
    @regex = @getRegEx()
    @robot.respond @regex, @query

  update: (key, data) ->
    switch key
      when 'all'      then @updateAll data
      when 'names'    then @updateNames data
      when 'keywords' then @updateKeywords data

module.exports = (robot) ->

  fb   = B.root.child 'scripts/idols'
  idol = new Idol robot

  nameRef = fb.child 'names'
  keyRef  = fb.child 'keywords'

  add = (ref, val, msg) ->
    ref.set val, (err) -> msg.send if err then err else ":pushpin: adding #{val}"

  del = (ref, val, msg) ->
    ref.remove (err) -> msg.send if err then err else ":pushpin: deleting #{val}"

  B.auth (auth) ->
    return unless auth
    fb.once 'value', (res) -> idol.update 'all', res.val() if res.exists()

  fb.on 'child_changed', (data) ->
    idol.update data.key(), data.val()

  robot.respond /idol$/i, (msg) -> idol.query msg

  robot.respond /idol show/i, (msg) ->
    names = _.values(idol.data.names)   .join()
    keys  = _.values(idol.data.keywords).join()
    msg.send ":name_badge: #{names}"
    msg.send ":key: #{keys}"

  robot.respond /idol (add|del) (.*)/i, (msg) ->
    cmd  = msg.match[1]
    name = msg.match[2]
    id   = sha name
    ref  = nameRef.child id
    if cmd is 'add' then add ref, name, msg else del ref, name, msg

  robot.respond /idol (addkey|delkey) (.*)/i, (msg) ->
    cmd = msg.match[1]
    key = msg.match[2]
    id  = sha key
    ref = keyRef.child id
    if cmd is 'addkey' then add ref, key, msg else del ref, key, msg

sha = (data) ->
  s = C.createHash 'sha1'
  s.update data
  s.digest('hex').slice 0, 10

imageMe = (msg, query, animated, faces, cb) ->
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
