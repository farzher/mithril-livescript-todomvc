// Generated by LiveScript 1.2.0
var Task, controller, view;
Task = function(data){
  this.title = m.prop(data.title || '');
  this.title.redraw = false;
  this.completed = m.prop(data.completed || false);
  this.editing = m.prop(data.editing || false);
  this.key = data.key || Date.now();
};
controller = function(){
  var this$ = this;
  this.tasks = _.map(function(it){
    return new Task(it);
  })(
  JSON.parse(localStorage.getItem('mithril')) || []);
  this.allCompleted = m.prop(false);
  this.title = m.prop('');
  this.title.redraw = false;
  this.create = function(){
    var that;
    if (that = this$.title().trim()) {
      this$.tasks.push(new Task({
        title: that
      }));
      this$.title('');
    }
  };
  this.remove = function(task){
    this$.tasks.splice(this$.tasks.indexOf(task), 1);
  };
  this.edit = function(task){
    task.editing(true);
    task.oldTitle = task.title();
  };
  this.cancelEditing = function(task){
    task.editing(false);
    task.title(task.oldTitle);
  };
  this.doneEditing = function(task){
    task.editing(false);
    if (!task.title()) {
      this$.tasks.splice(this$.tasks.indexOf(task), 1);
    }
  };
  this.completeAll = function(){
    var i$, ref$, len$, task;
    for (i$ = 0, len$ = (ref$ = this$.tasks).length; i$ < len$; ++i$) {
      task = ref$[i$];
      task.completed(!this$.allCompleted());
    }
  };
  this.clearCompleted = function(){
    this$.tasks = _.reject(function(it){
      return it.completed();
    })(
    this$.tasks);
  };
  this.update = function(){
    var that;
    this$.completed = _.filter(function(it){
      return it.completed();
    })(
    this$.tasks);
    this$.active = _.reject(function(it){
      return it.completed();
    })(
    this$.tasks);
    this$.filtered = (that = m.route.param('filter'))
      ? this$[that]
      : this$.tasks;
    this$.allCompleted(this$.completed.length === this$.tasks.length);
    localStorage.setItem('mithril', JSON.stringify(this$.tasks));
  };
};
view = function(ctrl){
  ctrl.update();
  return a(m('header#header', a(m('h1', 'todos'), m('input#new-todo', {
    placeholder: 'What needs to be done?',
    onenter: ctrl.create,
    value: ctrl.title,
    autofocus: true
  }))), ctrl.tasks.length ? m('section#main', a(m('input#toggle-all[type=checkbox]', {
    onclick: ctrl.completeAll,
    checked: ctrl.allCompleted()
  }), m('ul#todo-list', ctrl.filtered.map(function(task){
    return m('li', {
      'class': {
        completed: task.completed(),
        editing: task.editing()
      },
      key: task.key
    }, a(m('.view', a(m('input.toggle[type=checkbox]', {
      checked: task.completed
    }), m('label', {
      ondblclick: function(){
        return ctrl.edit(task);
      }
    }, task.title()), m('button.destroy', {
      onclick: function(){
        return ctrl.remove(task);
      }
    }))), m('input.edit', {
      value: task.title,
      onenter: function(){
        return ctrl.doneEditing(task);
      },
      onescape: function(){
        return ctrl.cancelEditing(task);
      },
      onblur: function(){
        return ctrl.doneEditing(task);
      },
      config: function(it){
        it.select();
      }
    })));
  })), m('footer#footer', a(m('span#todo-count', m('strong', ctrl.active.length + " task" + (ctrl.active.length === 1 ? '' : 's') + " left")), m('ul#filters', a(m('li', m('a', {
    href: '/',
    config: m.route,
    'class': {
      selected: !m.route.param('filter')
    }
  }, 'All')), m('li', m('a', {
    href: '/active',
    config: m.route,
    'class': {
      selected: m.route.param('filter') === 'active'
    }
  }, 'Active')), m('li', m('a', {
    href: '/completed',
    config: m.route,
    'class': {
      selected: m.route.param('filter') === 'completed'
    }
  }, 'Completed')))), ctrl.completed.length ? m('button#clear-completed', {
    onclick: ctrl.clearCompleted
  }, "Clear completed") : void 8)))) : void 8);
};
m.route(document.getElementById('todoapp'), '/', {
  '/': {
    controller: controller,
    view: view
  },
  '/:filter': {
    controller: controller,
    view: view
  }
});