(function() {
  var jQuery, props;

  jQuery = $;

  props = {
    'transform-origin': '50% 50%'
  };

  Map3D.Helpers = {
    epsilon: function(a) {
      if (Math.abs(a) < 0.000001) {
        return 0;
      } else {
        return a;
      }
    }
  };

  Map3D.Mapper = (function() {
    Mapper.prototype.vendors = ['-webkit-', '-moz-', '-ms-', '-o-'];

    function Mapper(camera, divCamera, divCanvas, displayWid, displayHei) {
      this.camera = camera;
      this.divCamera = $(divCamera);
      this.divCanvas = $(divCanvas);
      this.halfDisplayWid = displayWid / 2;
      this.halfDisplayHei = displayHei / 2;
      this.eleDom = null;
      this.eleThree = null;
      this.fov = 0.5 / Math.tan(camera.fov * Math.PI / 360) * displayHei;
    }

    Mapper.prototype.setMatrix = function(threeMat4, b) {
      var a, e, epsilon, f, _i, _len;
      epsilon = Map3D.Helpers.epsilon;
      a = threeMat4;
      f = null;
      if (b) {
        f = f = [a.n11, -a.n21, a.n31, a.n41, a.n12, -a.n22, a.n32, a.n42, a.n13, -a.n23, a.n33, a.n43, a.n14, -a.n24, a.n34, a.n44];
      } else {
        f = [a.n11, a.n21, a.n31, a.n41, a.n12, a.n22, a.n32, a.n42, a.n13, a.n23, a.n33, a.n43, a.n14, a.n24, a.n34, a.n44];
      }
      for (_i = 0, _len = f.length; _i < _len; _i++) {
        e = f[_i];
        f[e] = epsilon(f[e]);
      }
      return "matrix3d( " + (f.join(',')) + " )";
    };

    Mapper.prototype.setTransform = function(wid, hei, matrix) {
      var epsilon, scale, self;
      self = this;
      scale = 1.0;
      epsilon = Map3D.Helpers.epsilon;
      return [setMatrix(matrix, false), "scale3d(" + scale + ", -" + scale + ", " + scale + ")", "translate3d(" + (epsilon(-0.5 * wid)) + "px, " + (epsilon(-0.5 * hei)) + "px, 0 )"].join('');
    };

    Mapper.prototype.setup = function(eleDom, eleThree, offset) {
      var properties, self;
      self = this;
      this.eleDom = $(eleDom);
      this.eleThree = eleThree;
      offset = offset || 0;
      return properties = {
        '-moz-transform-origin': '50% 50%',
        '-webkit-transform-origin': '50% 50%',
        'transform-origin': '50% 50%',
        '-moz-transform': this.setTransform(200 + offset, 200, this.eleThree.matrix),
        '-webkit-transform': this.setTransform(200 + offset, 200, this.eleThree.matrix),
        'transform': this.setTransform(200 + offset, 200, this.eleThree.matrix)
      };
    };

    return Mapper;

  })();

}).call(this);
