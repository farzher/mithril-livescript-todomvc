app =
  storage:
    get: -> JSON.parse localStorage.getItem 'mithril' or []
    set: (list) !-> localStorage.setItem 'mithril', JSON.stringify list

  controller: !->
    @list = app.storage.get! |> _.map -> new app.Item it
    @allCompleted = m.prop false
    @title = m.prop ''
    @title.redraw = false
    @filter = m.route.param 'filter'

    @create = !~>
      title = @title!trim!
      if title
        @list.push new app.Item {title}
        @title ''
    @remove = (item) !~> @list.splice (@list.indexOf item), 1

    @edit = (item) !~>
      item.bufferedTitle = m.prop item.title!
      item.bufferedTitle.redraw = false
      item.editing true
    @doneEditing = (item) !~>
      return if not item.editing!
      item.editing false
      item.title item.bufferedTitle!trim!
      if !item.title! => @list.splice (@list.indexOf item), 1
    @cancelEditing = (item) !~> item.editing false

    @completeAll = !~> for item in @list => item.completed not @allCompleted!
    @clearCompleted = !~> @list = @list |> _.reject (.completed!)

    @update = !~>
      @completed = @list |> _.filter (.completed!)
      @active = @list |> _.reject (.completed!)
      @filtered = switch @filter
        | 'active' => @active
        | 'completed' => @completed
        | otherwise => @list
      @allCompleted (@completed.length is @list.length)
      app.storage.set @list


  view: (ctrl) ->
    console.log 'redraw'
    ctrl.update!

    a do
      m 'header#header' a do
        m 'h1' 'todos'
        m 'input#new-todo' {
          placeholder: 'What needs to be done?'
          onenter: ctrl.create
          value: ctrl.title
          +autofocus
        }

      if ctrl.list.length => a do
        m 'section#main' a do
          m 'input#toggle-all[type=checkbox]' {onclick: ctrl.completeAll, checked: ctrl.allCompleted!}
          m 'ul#todo-list' a do
            ctrl.filtered.map (item) ->
              m 'li' {item.key, class: {completed: item.completed!, editing: item.editing!}} a do
                m '.view' a do
                  m 'input.toggle[type=checkbox]' {checked: item.completed}
                  m 'label' {ondblclick: -> ctrl.edit item} item.title!
                  m 'button.destroy' {onclick: -> ctrl.remove item}
                if item.editing!
                  m 'input.edit' {
                    value: item.bufferedTitle
                    onenter: -> ctrl.doneEditing item
                    onescape: -> ctrl.cancelEditing item
                    onblur: -> ctrl.doneEditing item
                    config: configInit !-> it.select!
                  }

        m 'footer#footer' a do
          m 'span#todo-count' a do
            m 'strong' "#{ctrl.active.length} item#{if ctrl.active.length is 1 => '' else 's'} left"
          m 'ul#filters' a do
            m 'li' m 'a' {href: '/', config: m.route, class: {selected: not ctrl.filter}} 'All'
            m 'li' m 'a' {href: '/active', config: m.route, class: {selected: ctrl.filter is 'active'}} 'Active'
            m 'li' m 'a' {href: '/completed', config: m.route, class: {selected: ctrl.filter is 'completed'}} 'Completed'
          if ctrl.completed.length => m 'button#clear-completed' {onclick: ctrl.clearCompleted} "Clear completed (#{ctrl.completed.length})"


app.Item = class
  (o) ->
    @key = _.rand Number.MAX_VALUE
    @title = m.prop o.title || ''
    @completed = m.prop o.completed || false
    @editing = m.prop o.editing || false


m.route.mode = 'hash'
m.route (document.getElementById 'todoapp'), '/',
  '/': app
  '/:filter': app
