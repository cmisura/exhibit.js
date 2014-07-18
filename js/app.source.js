(function() {
  var Leaf, Leaves;

  Leaves = (function() {
    function Leaves() {
      this.count = 0;
      this.list = [];
    }

    Leaves.prototype.counter = function(operation) {
      var self;
      self = this;
      switch (operation) {
        case '+':
          return self.count += 1;
        case '-':
          return self.count -= 1;
      }
    };

    Leaves.prototype.check = function(leaf) {
      var amount, exists, find, i, self, _i;
      self = this;
      amount = this.list.length - 1;
      exists = false;
      find = function(i) {
        if (self.list[i].ID === leaf.ID) {
          exists = true;
          return false;
        }
      };
      for (i = _i = 0; 0 <= amount ? _i <= amount : _i >= amount; i = 0 <= amount ? ++_i : --_i) {
        if (!exists) {
          find(i);
        }
      }
      return exists;
    };

    Leaves.prototype.add = function(leaf) {
      var amount, combine, self;
      self = this;
      amount = this.list.length;
      combine = function() {
        self.counter('+');
        leaf.index = self.count;
        self.list.push(leaf);
      };
      if (amount === 0) {
        combine();
      }
      if (amount > 0 && !this.check(leaf)) {
        return combine();
      }
    };

    Leaves.prototype.remove = function(leaf) {
      var amount, i, self, _i, _ref, _results;
      self = this;
      amount = this.list.length;
      if (amount === 0) {
        return;
      }
      this.counter('-');
      _results = [];
      for (i = _i = _ref = amount - 1; _i >= 0; i = _i += -1) {
        if (this.list[i] === leaf) {
          _results.push(this.list.splice(i, 1));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Leaves.prototype.render = function() {};

    return Leaves;

  })();

  Leaf = (function() {
    Leaf.prototype.ID = null;

    Leaf.prototype.element = null;

    Leaf.prototype.index = 0;

    /*
    -----------------------------------------------------------
    */


    Leaf.prototype.Note = console.log.bind(console, 'NOTE ==');

    function Leaf(element, count) {
      this.ID = "leaf-" + (Math.round(Math.random() * 9999999));
      this.element = element;
      this;
    }

    Leaf.prototype.build = function() {};

    Leaf.prototype.show = function() {};

    Leaf.prototype.hide = function() {};

    Leaf.prototype.update = function() {};

    Leaf.prototype.destroy = function() {};

    return Leaf;

  })();

  $(document).on('ready', function() {
    var leaf_0, leaf_1, leaf_2, leaves;
    leaf_0 = new Leaf('.one');
    leaf_1 = new Leaf('.two');
    leaf_2 = new Leaf('.three');
    leaves = new Leaves();
    leaves.add(leaf_0);
    leaves.add(leaf_1);
    leaves.add(leaf_2);
    leaves.add(leaf_1);
    leaves.add(leaf_0);
    return console.log(leaves);
  });

}).call(this);
