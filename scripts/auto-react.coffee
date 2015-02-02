# Description:
#   React with user's swearing keyword on chat room
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Author:
#   chitacan

R = 
  keyword  : ['씨발','시발','좆같','젖같','개새','새끼','새퀴','호로','썅']
  response : [
    '이색기가?',
    '씨발 싸우자!!',
    '짐 뭐라고 햇냐?',
    '입으로 똥싸지 마라..',
    '좃밥새퀴 ㅋ'
  ]
  image    : [
    'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRfH3n7uYzulAbjsxdvdbjal-QXsOscutiCzNsLDacJXZmujUgR',
    'http://cfile6.uf.tistory.com/image/15562D365165493E0375EB',
    'http://cfile25.uf.tistory.com/image/2315004D52C0FF3B27451A',
    'http://cfile28.uf.tistory.com/image/20327040509B9ED80966D9',
    'http://img.ezmember.co.kr/cache/board/2012/08/02/0c7931fbeeef5fa770cf7d6870aae2e1.jpg'
  ]

module.exports = (robot) ->
  selector = (percentage) ->
    Math.floor(Math.random() * 100) < percentage

  key   = R.keyword.join '|'
  regex = new RegExp key, 'i'
  robot.hear regex, (msg) ->
    res = if selector 70 then msg.random R.response else ''
    img = if selector 40 then msg.random R.image    else ''
    result = "#{res} #{img}".trim()
    msg.reply result if !!result
