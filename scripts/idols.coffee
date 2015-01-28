# Description:
#   Get random idol image.
#
# Commands:
#   hubot (효성|아이유|IU|크리스탈|수지|혜리|현아|태연|윤아) (keyword)
#
# Author:
#   chitacan

keywords = ["슴가","움짤","가슴","섹시","헉","레전드","육덕"]
idols    = ["효성","아이유","크리스탈","수지","혜리","현아","태연","윤아"].join '|'

module.exports = (robot) ->
  name_regex = new RegExp("#{robot.name}:?\\s?(#{idols})\\s?(.*)?", "i")

  robot.hear name_regex, (msg) ->
    idol    = msg.match[1]
    keyword = msg.match[2] ? msg.random keywords
    query   = "#{idol} #{keyword}"
    msg.send ":mag: #{query}... I have found the thing."
    imageMe msg, query, true, true, (url) -> msg.send url

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
