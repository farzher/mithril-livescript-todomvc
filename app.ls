Task = (data) !->
  @key = data.key || _.rand Number.MAX_VALUE
  @title = m.prop data.title || ''
  @completed = m.prop data.completed || false
  @editing = m.prop data.editing || false

controller = !->
  @tasks = (JSON.parse localStorage.getItem 'mithril' or []) |> _.map -> new Task it
  @allCompleted = m.prop false
  @title = m.prop ''; @title.redraw = false

  @create = !~>
    if @title!trim!
      @tasks.push new Task {title: that}
      @title ''
  @remove = (task) !~> @tasks.splice (@tasks.indexOf task), 1

  @edit = (task) !~>
    task.bufferedTitle = m.prop task.title!; task.bufferedTitle.redraw = false
    task.editing true
  @doneEditing = (task) !~>
    return m.redraw.strategy 'none' if not task.editing!
    task.editing false
    task.title task.bufferedTitle!trim!
    if !task.title! => @tasks.splice (@tasks.indexOf task), 1
  @cancelEditing = (task) !~> task.editing false

  @completeAll = !~> for task in @tasks => task.completed not @allCompleted!
  @clearCompleted = !~> @tasks = @tasks |> _.reject (.completed!)

  @update = !~>
    @completed = @tasks |> _.filter (.completed!)
    @active = @tasks |> _.reject (.completed!)
    @filtered = if m.route.param 'filter' => @[that] else @tasks
    @allCompleted (@completed.length is @tasks.length)
    localStorage.setItem 'mithril', JSON.stringify @tasks

view = (ctrl) ->
  ctrl.update!
  a do
    m 'header#header' a do
      m 'h1' 'todos'
      m 'input#new-todo' {placeholder: 'What needs to be done?', onenter: ctrl.create, value: ctrl.title, +autofocus}

    if ctrl.tasks.length => a do
      m 'section#main' a do
        m 'input#toggle-all[type=checkbox]' {onclick: ctrl.completeAll, checked: ctrl.allCompleted!}
        m 'ul#todo-list' a do
          ctrl.filtered.map (task) ->
            m 'li' {task.key, class: {completed: task.completed!, editing: task.editing!}} a do
              m '.view' a do
                m 'input.toggle[type=checkbox]' {checked: task.completed}
                m 'label' {ondblclick: -> ctrl.edit task} task.title!
                m 'button.destroy' {onclick: -> ctrl.remove task}
              if task.editing!
                m 'input.edit' {
                  value: task.bufferedTitle
                  onenter: -> ctrl.doneEditing task
                  onescape: -> ctrl.cancelEditing task
                  onblur: -> ctrl.doneEditing task
                  config: configInit !-> it.select!
                }

      m 'footer#footer' a do
        m 'span#todo-count' a do
          m 'strong' "#{ctrl.active.length} task#{if ctrl.active.length is 1 => '' else 's'} left"
        m 'ul#filters' a do
          m 'li' m 'a' {href: '/', config: m.route, class: {selected: not m.route.param 'filter'}} 'All'
          m 'li' m 'a' {href: '/active', config: m.route, class: {selected: m.route.param 'filter' is 'active'}} 'Active'
          m 'li' m 'a' {href: '/completed', config: m.route, class: {selected: m.route.param 'filter' is 'completed'}} 'Completed'
        if ctrl.completed.length => m 'button#clear-completed' {onclick: ctrl.clearCompleted} "Clear completed (#{ctrl.completed.length})"

m.route.mode = 'hash'
m.route (document.getElementById 'todoapp'), '/', {'/': {controller, view}, '/:filter': {controller, view}}
