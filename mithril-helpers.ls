do !->
  keyTrue = 0

  customAtts =
    onenter: (cb) !->
      @config = monkeypatch @config, configInit ->
        it.addEventListener 'keyup', (e) ->
          if e.keyCode is 13 => cb!; m.redraw!
    onescape: (cb) !->
      @config = monkeypatch @config, configInit ->
        it.addEventListener 'keyup', (e) ->
          if e.keyCode is 27 => cb!; m.redraw!
    value: (prop) !->
      if typeof prop is 'function'
        @value = prop!
        @config = monkeypatch @config, configInit ->
          it.addEventListener 'input', multi do
            m.withAttr 'value', prop
            !-> if prop.redraw isnt false => m.redraw!
    checked: (prop) !->
      if typeof prop is 'function'
        @checked = prop!
        @config = monkeypatch @config, configInit ->
          it.addEventListener 'click', multi do
            m.withAttr 'checked', prop
            !-> if prop.redraw isnt false => m.redraw!
    class: (obj) !->
      if typeof! obj is 'Object'
        classes = for key, value of obj when value => key
        @class = classes.join ' '
    key: (value) !->
      if value is true
        @key = "__key:true__#{keyTrue++}"

  mithril = m
  window.m = (selector, atts, children) ->
    if typeof! atts is 'Object'
      for key, att of atts
        if customAtts[key] => that.call atts, att
    mithril selector, atts, children
  m.__proto__ = mithril


  window.configInit = (f) ->
    (ele, init) ->
      if not init => f ...

  # monkeypatch
  ``function monkeypatch(n,t){return function(){var o,u;return"function"==typeof n&&(o=n.apply(this,arguments)),"function"==typeof t&&(u=t.apply(this,arguments)),o===!1||u===!1?!1:void 0}}``

  # multi
  ``window.multi=function(){var n=Array.prototype.slice;return function(){var t=n.call(arguments);return function(){var r=n.call(arguments),a=this;t.map(function(n){n instanceof Function&&n.apply(a,r)})}}}();``
