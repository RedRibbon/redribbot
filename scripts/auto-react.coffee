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
  keyword  : ['씨발','좆같','젖같','개새']
  response : ['이색기가?', '씨발 싸우자!!', '짐 뭐라고 햇냐?', '입으로 똥싸지 마라..']
  image    : [
    'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRfH3n7uYzulAbjsxdvdbjal-QXsOscutiCzNsLDacJXZmujUgR',
    'https://www.google.co.kr/url?sa=i&rct=j&q=&esrc=s&source=images&cd=&cad=rja&uact=8&ved=0CAcQjRw&url=http%3A%2F%2Fsunghoon27.tistory.com%2F30&ei=hSzLVOzyMcG_mAWQs4DIBw&bvm=bv.84607526,d.dGY&psig=AFQjCNHqa-bXB4xnEv8lxlZ-BOfYKmLnQQ&ust=1422687659045813',
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
