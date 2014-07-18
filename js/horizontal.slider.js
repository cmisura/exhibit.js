(function() {
  (function($, window, document) {
    var Plugin, defaults, pluginName;
    pluginName = 'exhibit';
    defaults = {
      speed: 60,
      slide: ['100%', '100%']
    };
    Plugin = (function() {
      function Plugin(element, options) {
        this.viewport = $(window);
        this.settings = $.extend({}, defaults, options);
        this._ID = Math.round(Math.random() * 99999);
        this._element = $(element);
        this._defaults = defaults;
        this._name = pluginName;
        this._chapters = [];
        this._state = {
          loaded: false,
          menu: false,
          scale: 1
        };
        this.index = 0;
        this.commands = {};
        this.init();
      }

      Plugin.prototype.state = function(state, value) {
        if (value === void 0) {
          return this._state[state];
        } else {
          return this._state[state] = value;
        }
      };

      Plugin.prototype.init = function() {
        var self;
        self = this;
        this.setup().init();
        this.event().init();
        this.viewport.on('resize', _.debounce(this.event().view.resize.bind(this), 500));
        this.state('loaded', true);
        return this;
      };

      Plugin.prototype.setup = function() {
        var add, amount, build, chapters, container, coords, dimensions, init, resize, self, setCoords, total;
        self = this;
        container = this._element.find("." + pluginName + "-chapters");
        chapters = this._element.find("." + pluginName + "-chapter");
        amount = chapters.length - 1;
        total = 0;
        add = function(index, chapter) {
          var id, name;
          chapter = $(chapter);
          total += chapter.width();
          if (index === 0 && !self.state(self._stateLoaded)) {
            chapter.addClass('state-active');
          }
          if (chapter.attr('data-chapter')) {
            name = chapter.attr('data-chapter');
            id = index;
            self._chapters.push("<a href='#'' data-chapter-ID='" + id + "'>" + name + "</a>");
          }
          return chapter.attr('data-id', "" + index);
        };
        coords = function(index, chapter) {
          var location;
          chapter = $(chapter);
          location = chapter.position().left;
          return chapter.attr('data-location', location);
        };
        dimensions = function() {
          var hei, wid;
          if (self.settings.slide === null) {
            return false;
          } else {
            hei = self.settings.slide[1];
            wid = self.settings.slide[0];
            if (hei !== '100%') {
              chapters.height(hei);
            }
            if (wid !== '100%') {
              chapters.width(wid);
            }
            chapters.width(self.viewport.width());
            return chapters.height(self.viewport.height());
          }
        };
        setCoords = function() {
          return $.each(chapters, coords);
        };
        build = function() {
          var defer, fn;
          defer = $.Deferred();
          fn = function() {
            dimensions();
            $.each(chapters, add);
            container.width(total);
            return defer.resolve();
          };
          fn();
          return defer;
        };
        resize = function() {
          dimensions();
          $.each(chapters, add);
          container.width(total);
          return setCoords();
        };
        init = function() {
          return $.when(build()).done(setCoords);
        };
        return {
          resize: resize,
          init: init
        };
      };

      Plugin.prototype.duration = function(destination, start) {
        var pixelsPerSecond;
        pixelsPerSecond = this.settings.speed;
        return Math.round(Math.abs((destination - start) / pixelsPerSecond)) / 100;
      };

      Plugin.prototype.distance = function(distance, scale) {
        return distance * scale;
      };

      Plugin.prototype.event = function() {
        var amount, chapters, container, menu, move, self, view;
        self = this;
        view = {};
        menu = {};
        move = {};
        container = self._element.find("." + pluginName + "-chapters");
        chapters = self._element.find("." + pluginName + "-chapter");
        amount = chapters.length - 1;
        view.resize = function() {
          if (!self.state('menu')) {
            self.setup().resize();
          }
          return move.port(self.index);
        };
        move.current = null;
        move.destination = null;
        move.bulk = function(input) {
          var location, start;
          location = null;
          move.current = container.find('.state-active');
          if (input === 'next' && self.index < amount) {
            move.destination = move.current.next();
            self.index += 1;
          }
          if (input === 'prev' && self.index > 0) {
            move.destination = move.current.prev();
            self.index -= 1;
          }
          if (typeof input === 'number') {
            move.destination = chapters.eq(input);
            self.index = input;
          }
          start = self.distance(move.current.attr('data-location'), self.state('scale'));
          location = self.distance(move.destination.attr('data-location'), self.state('scale'));
          chapters.removeClass('state-active').removeClass('state-next').removeClass('state-prev');
          return [start, location];
        };
        move.next = function() {
          return move.tween(move.bulk('next'));
        };
        move.prev = function() {
          return move.tween(move.bulk('prev'));
        };
        move.port = function(index) {
          return move.tween(move.bulk(index));
        };
        move.tween = function(locations) {
          var duration, props;
          duration = self.state('menu') ? 0.4 : self.duration(locations[1], locations[0]);
          console.log(duration);
          props = {
            x: "-" + locations[1] + "px",
            y: 0,
            z: 0,
            ease: Power3.easeOut,
            onStart: move.start,
            onComplete: move.done
          };
          return TweenMax.to(container, duration, props);
        };
        move.start = function() {
          return chapters.addClass('overflow-hidden');
        };
        move.done = function() {
          var current, remove;
          current = chapters.eq(self.index);
          current.addClass('state-active');
          current.nextAll().addClass('state-next');
          current.prevAll().addClass('state-prev');
          remove = function() {
            return chapters.removeClass('overflow-hidden');
          };
          return setTimeout(remove, 350);
        };
        move.init = function() {
          return console.log('move init');
        };
        menu.open = function() {
          var props;
          props = {
            x: 0,
            scale: 0.25,
            transformOrigin: 'center left',
            onComplete: menu.openDone
          };
          return TweenMax.to(container, 0.4, props);
        };
        menu.openDone = function() {
          var num;
          num = this.vars.css.scale;
          chapters.addClass('overflow-hidden');
          container.addClass('menu-open');
          self.state('menu', true);
          self.state('scale', num);
          return move.port(self.index);
        };
        menu.exit = function(i) {
          var props;
          i = i || self.index;
          props = {
            x: 0,
            scale: 1,
            transformOrigin: 'center left',
            onCompleteParams: [i],
            onComplete: menu.exitDone
          };
          return TweenMax.to(container, 0.4, props);
        };
        menu.exitDone = function() {
          var num;
          num = this.vars.css.scale;
          chapters.removeClass('overflow-hidden');
          container.removeClass('menu-open');
          self.state('menu', false);
          self.state('scale', num);
          return move.port(arguments[0]);
        };
        menu.click = function() {
          var body, handleClick;
          body = $('body');
          handleClick = function(e) {
            var ID, slide;
            e.stopPropagation();
            if (container.hasClass('menu-open')) {
              slide = $(this);
              ID = parseInt(slide.attr('data-id'));
              console.log(slide, ID);
              if (ID !== void 0) {
                return menu.exit(ID);
              }
            } else {
              return false;
            }
          };
          body.off('click.loadChapter');
          return body.on('click.loadChapter', '.exhibit-chapter', handleClick);
        };
        menu.init = function() {
          self.contents();
          return menu.click();
        };
        this.commands.moveNext = move.next;
        this.commands.movePrev = move.prev;
        this.commands.moveTo = move.port;
        this.commands.menuOpen = menu.open;
        this.commands.menuExit = menu.exit;
        return {
          move: move,
          menu: menu,
          view: view,
          init: function() {
            this.move.init();
            return this.menu.init();
          }
        };
      };

      Plugin.prototype.contents = function() {
        var body, handleClick, menu, self;
        self = this;
        menu = $('.exhibit-chapters-menu');
        body = $('body');
        menu.append(this._chapters.join(''));
        handleClick = function(e) {
          var ID, link;
          e.preventDefault();
          e.stopPropagation();
          link = $(this);
          ID = link.attr('data-chapter-ID');
          ID = parseInt(ID);
          return self.event().move.port(ID);
        };
        body.off('click.viewChapter');
        return body.on('click.viewChapter', '.exhibit-chapters-menu a', handleClick);
      };

      return Plugin;

    })();
    return $.fn[pluginName] = function(options) {
      return this.each(function() {
        var commander;
        if (typeof options === 'object' || !options) {
          if (!$.data(this, "plugin_" + pluginName)) {
            return $.data(this, "plugin_" + pluginName, new Plugin(this, options));
          }
        } else {
          commander = $.data(this, "plugin_" + pluginName);
          if (commander.commands[options]) {
            return commander.commands[options]();
          } else {
            throw new Error('Method Doesnt Exist');
          }
        }
      });
    };
  })(jQuery, window, document);

}).call(this);
