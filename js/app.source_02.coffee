jQuery = $ 

props = 
    'transform-origin' : '50% 50%'

Map3D.Helpers = 
    epsilon : ( a )->
        if Math.abs( a ) < 0.000001
            return 0 
        else
            return a


class Map3D.Mapper 
    vendors : [ '-webkit-', '-moz-', '-ms-', '-o-' ]

    constructor : ( camera, divCamera, divCanvas, displayWid, displayHei )->
        @camera             = camera 
        @divCamera          = $ divCamera
        @divCanvas          = $ divCanvas
        @halfDisplayWid     = displayWid / 2
        @halfDisplayHei     = displayHei / 2
        @eleDom             = null
        @eleThree           = null 

        @fov                = 0.5 / Math.tan( camera.fov * Math.PI / 360 ) * displayHei  


    setMatrix : ( threeMat4, b )->
        epsilon = Map3D.Helpers.epsilon 
        a       = threeMat4
        f       = null 

        if b 
            f =  f = [a.n11, -a.n21, a.n31, a.n41, a.n12, -a.n22, a.n32, a.n42, a.n13, -a.n23, a.n33, a.n43, a.n14, -a.n24, a.n34, a.n44, ]
        else 
            f = [a.n11, a.n21, a.n31, a.n41, a.n12, a.n22, a.n32, a.n42, a.n13, a.n23, a.n33, a.n43, a.n14, a.n24, a.n34, a.n44, ]

        for e in f 
            f[e] = epsilon( f[e] )

        return "matrix3d( #{f.join( ',' )} )"


    setTransform : ( wid, hei, matrix )->
        self    = this
        scale   = 1.0 
        epsilon = Map3D.Helpers.epsilon 

        return [ setMatrix( matrix, false ),
        "scale3d(#{scale}, -#{scale}, #{scale})",
        "translate3d(#{epsilon( -0.5 * wid )}px, #{epsilon( -0.5 * hei )}px, 0 )"
        ].join( '' )

    setup : ( eleDom, eleThree, offset )->
        self        = this 
        @eleDom     = $ eleDom
        @eleThree   = eleThree 
        offset      = offset or 0 
    
        properties =
            '-moz-transform-origin'    : '50% 50%'
            '-webkit-transform-origin' : '50% 50%'
            'transform-origin'         : '50% 50%'
            '-moz-transform'           : @setTransform( 200 + offset, 200, @eleThree.matrix )
            '-webkit-transform'        : @setTransform( 200 + offset, 200, @eleThree.matrix )
            'transform'                : @setTransform( 200 + offset, 200, @eleThree.matrix )



      
        # setPosition =->
        #     self.eleThree.updateMatrix() 
        #     self.eleDom.css 'position', 'absolute'

















# class Diamond.Events extends Diamond.Kit  






