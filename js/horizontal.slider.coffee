do($ = jQuery, window, document) ->

    pluginName = 'exhibit'     

    defaults =
        speed       : 60
        slide       : [ '100%', '100%' ]
      

    class Plugin
        constructor: ( element, options )->
            @viewport        = $ window 
            @settings        = $.extend {}, defaults, options
            @_ID             = Math.round( Math.random()*99999 )
            @_element        = $ element 
            @_defaults       = defaults
            @_name           = pluginName
            @_chapters       = []

            # States 
            @_state = 
                loaded      : false
                menu        : false  
                scale       : 1 
    

            @index           = 0 
    
            @commands        = {}

            # Initialize 
            @init()

        state: ( state, value )-> 
            if value is undefined
                return @_state[state] 
            else 
                @_state[state] = value 
   
        init: ->
            self   = this
    
            @setup().init()
            @event().init()

            @viewport.on 'resize', _.debounce @event().view.resize.bind( @ ), 500   

            @state( 'loaded', true  )

            return @

        setup:->
            self        = this 
            container   = @_element.find ".#{pluginName}-chapters"
            chapters    = @_element.find ".#{pluginName}-chapter"
            amount      = chapters.length - 1
            total       = 0
    
            ## Helper 

            add =( index, chapter )->
                chapter = $ chapter 

                total += chapter.width()

                if index is 0 and not self.state( self._stateLoaded )
                    chapter.addClass 'state-active'

                if chapter.attr( 'data-chapter' )
                    name    = chapter.attr 'data-chapter'
                    id      = index
                    
                    self._chapters.push "<a href='#'' data-chapter-ID='#{id}'>#{name}</a>"
                   
                chapter.attr 'data-id', "#{index}"
          

            coords =( index, chapter )->
                chapter  = $ chapter 
                location = chapter.position().left
              
                chapter.attr 'data-location', location 

            dimensions =->

                if self.settings.slide is null
                    return false 
                
                else 
                    hei = self.settings.slide[1]
                    wid = self.settings.slide[0]

                    if hei isnt '100%' then chapters.height( hei )
                    if wid isnt '100%' then chapters.width( wid )
             
                    chapters.width( self.viewport.width() )
                    chapters.height( self.viewport.height() )

            setCoords =->
                $.each chapters, coords

            ## Create

            build =->
                defer = $.Deferred()

                fn =->
                    dimensions()
                    $.each chapters, add
                    container.width( total ) 
                    defer.resolve()

                fn()

                return defer 

            resize =->
                dimensions()
                $.each chapters, add
                container.width( total ) 
                setCoords()
               
            init =->
                $.when( build() ).done setCoords
               
            return {}=
                resize : resize
                init   : init

        duration : ( destination, start )->
            pixelsPerSecond = @settings.speed 

            return Math.round( Math.abs( ( destination - start ) / pixelsPerSecond ) ) / 100 

        distance : ( distance, scale )->

            return distance * scale 
 
        event : ->
            self      = this 
            view      = {}
            menu      = {}
            move      = {}
            container = self._element.find ".#{pluginName}-chapters"
            chapters  = self._element.find ".#{pluginName}-chapter"  
            amount    = chapters.length - 1

            # View Events
            view.resize =->
                if not self.state( 'menu' ) then self.setup().resize() 
                move.port( self.index )               

            # Move Events
            move.current        = null
            move.destination    = null

            move.bulk =( input )-> 
                location = null

                move.current = container.find '.state-active'

                if input is 'next' and self.index < amount 
                    move.destination = move.current.next()
                 
                    self.index += 1

                if input is 'prev' and self.index > 0 
                    move.destination = move.current.prev()
                
                    self.index -= 1

                if typeof input is 'number'
                    move.destination = chapters.eq( input )
            
                    self.index = input 
                
                start       = self.distance( move.current.attr( 'data-location' ), self.state('scale' ) )
                location    = self.distance( move.destination.attr( 'data-location' ), self.state('scale' ) )  

                chapters
                .removeClass( 'state-active' )
                .removeClass( 'state-next' )
                .removeClass( 'state-prev' )

                return [ start, location ]
        
            move.next =->
                move.tween( move.bulk( 'next' ) )

            move.prev =->
                move.tween( move.bulk( 'prev' ) )

            move.port =( index )->
                move.tween( move.bulk( index ) )

            move.tween = ( locations )->
                duration = if self.state( 'menu' ) then 0.4 else self.duration( locations[1], locations[0] )
                console.log duration 
                props = 
                    x           : "-#{locations[1]}px"
                    y           : 0
                    z           : 0
                    ease        : Power3.easeOut
                    onStart     : move.start 
                    onComplete  : move.done    

                TweenMax.to container, duration, props 
            
            move.start =->
                chapters.addClass 'overflow-hidden'

            move.done =->
        
                current = chapters.eq( self.index )

                current.addClass 'state-active'     
                current.nextAll().addClass 'state-next'
                current.prevAll().addClass 'state-prev'

                # Delay
                remove =-> 
                    chapters.removeClass 'overflow-hidden'

                setTimeout remove, 350

            move.init =->
                console.log 'move init'      
                  
            # Menu Events
            menu.open =->
                props =
                    x                   : 0 
                    scale               : 0.25
                    transformOrigin     : 'center left'
                    onComplete          : menu.openDone 

                TweenMax.to container, 0.4, props 

            menu.openDone =->
                num = this.vars.css.scale 
                
                chapters.addClass 'overflow-hidden'
                container.addClass 'menu-open'

                self.state( 'menu', true )
                self.state( 'scale', num )

                # Move to current location
                move.port( self.index )
              
            menu.exit = ( i )->
                i = i or self.index 
    
                props =
                    x                   : 0 
                    scale               : 1
                    transformOrigin     : 'center left'
                    onCompleteParams    : [ i ]
                    onComplete          : menu.exitDone 

                TweenMax.to container, 0.4, props

            menu.exitDone = ->
                num  = this.vars.css.scale 
              
                chapters.removeClass 'overflow-hidden'
                container.removeClass 'menu-open'

                self.state( 'menu', false )
                self.state( 'scale', num )

                # Move to current location
                move.port( arguments[0] ) 

            menu.click =->
                body = $ 'body'

                handleClick =( e )->
                    e.stopPropagation()

                    if container.hasClass 'menu-open'

                        slide   = $ this
                        ID      = parseInt slide.attr 'data-id'

                        console.log slide, ID

                        if ID isnt undefined then menu.exit( ID )

                    else 
                        return false 

               
                body.off 'click.loadChapter'
                body.on  'click.loadChapter', '.exhibit-chapter', handleClick 


            menu.init =->
                self.contents()
                menu.click()

            # Export public commands
            @commands.moveNext = move.next 
            @commands.movePrev = move.prev
            @commands.moveTo   = move.port 
            @commands.menuOpen = menu.open
            @commands.menuExit = menu.exit 

            # Expose the events interface
            return {}=
                move : move 
                menu : menu
                view : view 
                init : ->
                    this.move.init()
                    this.menu.init()


        contents : ->
            self = this 
            menu = $ '.exhibit-chapters-menu'
            body = $ 'body'

            menu.append( @_chapters.join( '' ) )

            handleClick =( e )->
                e.preventDefault()
                e.stopPropagation()

                link = $ this 
                ID   = link.attr 'data-chapter-ID'
                ID   = parseInt ID 

                self.event().move.port( ID )

            body.off 'click.viewChapter'
            body.on  'click.viewChapter', '.exhibit-chapters-menu a', handleClick 




    $.fn[pluginName] = ( options ) ->
      
        this.each ->
            if typeof options is 'object' or not options
                if not $.data( this, "plugin_#{pluginName}" )
                    $.data( this, "plugin_#{pluginName}", new Plugin( this, options ) )
            else
                commander = $.data( this, "plugin_#{pluginName}" )

                if commander.commands[options] then commander.commands[options]()
                
                else throw new Error( 'Method Doesnt Exist' )
                 

                
         













