_viewport = 'user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width, height=device-height, target-densitydpi=device-dpi'
doctype 5
html ->
  head ->
    meta charset:'utf-8'
    meta name:'format-detection', content='telephone=no'
    meta name:'viewport', content:_viewport
    meta name:'msapplication-tap-highlight', content:'no'
    link rel:'stylesheet', type:'text/css', href:'css/index.css'
    title 'example'
  body ->
    div class:'app', ->
      div class:'main', ->
        div id:'logView', ->
          h1 'beacon log'

    script src:'cordova.js'
    script src:'js/main.js'
