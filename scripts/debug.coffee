# Description:
#   Print useful debug information about redribbot
#
# Commands:
#   hubot debug listener - print redribbot's regex listners.
#   hubot debug hubotrc - print redribbot's hubotrc.
#   hubot debug fb <path> - print firebase data.
#
# Author:
#   chitacan

_     = require 'underscore'
fs    = require 'fs'
path  = require 'path'
https = require 'https'
url   = require 'url'

module.exports = (robot) ->
  prettify = (msg) -> "```#{msg}```"

  robot.respond /debug listener$/i, (msg) ->
    lstnr = _.pluck(robot.listeners, 'regex').join '\n'
    msg.send prettify lstnr

  robot.respond /debug hubotrc$/i, (msg) ->
    isWin   = process.platform is 'win32'
    home    = if isWin then process.env.USERPROFILE else process.env.HOME 
    path    = path.resolve home, '.hubotrc'
    hubotrc = fs.readFileSync path
    msg.send prettify hubotrc

  robot.respond /debug fb\s?(.*)?/i, (msg) ->
    pathParam = msg.match[1] ? 'scripts'
    endPoint  = "#{url.resolve 'https://redribbot.firebaseio.com', pathParam}.json"
    https.get endPoint, (res) ->
      result = ''
      res.setEncoding('utf8')
      res.on 'data', (c) -> result += c.toString()
      res.on 'end' , ( ) ->
        if result? and result isnt 'null'
          p = JSON.parse result
          msg.send prettify JSON.stringify p, null, 4
        else
          msg.send ":interrobang: R U sure ??"
