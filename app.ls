Item = (data) ->
  title: m.prop data.title || '', {-redraw}
  completed: m.prop data.completed || false
  key: data.key || Date.now!

controller = !->
  @items = JSON.parse localStorage.getItem \m or [{title: 'Smallest TodoMVC', +completed}] |> _.map Item
  @allCompleted = m.prop false
  @title = m.prop ''

  @create = ~> if @title!trim! => @items.push Item {title: that}; @title ''
  @remove = ~> @items.splice (@items.indexOf it), 1

  @edit = ~> it.oldTitle = it.title!
  @cancel = ~> it.title it.oldTitle; it.oldTitle = ''
  @save = ~> it.oldTitle = ''; if !it.title!trim! => @remove it

  @completeAll = ~> for item in @items => item.completed not @allCompleted!
  @clearCompleted = ~> @items = _.reject (.completed!), @items

  @update = ~>
    @completed = _.filter (.completed!), @items
    @active = _.reject (.completed!), @items
    @filtered = if m.route.param \filter => @[that] else @items
    @allCompleted (@completed.length is @items.length)
    localStorage.m = JSON.stringify @items

view = (c) ->
  c.update!
  a do
    m \header#header m \h1 \todos
    m 'input#new-todo[placeholder=What needs to be done?]' {onenter: c.create, value: c.title, +autofocus}

    if c.items.length => m \section#main a do
      m 'input#toggle-all[type=checkbox]' {onclick: c.completeAll, checked: c.allCompleted!}
      m \ul#todo-list c.filtered.map (item) ->
        m \li {class: {completed: item.completed!, editing: item.oldTitle}, item.key} a do
          m \.view a do
            m 'input.toggle[type=checkbox]' {checked: item.completed}
            m \label {ondblclick: -> c.edit item} item.title!
            m \button.destroy {onclick: -> c.remove item}
          m \input.edit do
            value: item.title
            config: (.select!)
            onblur: -> c.save item
            onenter: -> c.save item
            onescape: -> c.cancel item

      m \footer#footer a do
        m \span#todo-count m \strong "#{c.active.length} item#{if c.active.length is 1 => '' else 's'} left"
        m \ul#filters a do
          m \li m \a {href: '/', config: m.route, class: {selected: not m.route.param \filter}} \All
          m \li m \a {href: '/active', config: m.route, class: {selected: m.route.param \filter is \active}} \Active
          m \li m \a {href: '/completed', config: m.route, class: {selected: m.route.param \filter is \completed}} \Completed
        if c.completed.length => m \button#clear-completed {onclick: c.clearCompleted} 'Clear completed'

m.route (document.getElementById \todoapp), '/', {'/': {controller, view}, '/:filter': {controller, view}}
