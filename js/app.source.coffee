class Leaves
   

    constructor : -> 
        @count = 0
        @list  = []
    
    counter : ( operation )->
        self = this 

        switch operation 
            when '+' then self.count += 1
            when '-' then self.count -= 1

    check : ( leaf )->
        self    = this 
        amount  = @list.length - 1 
        exists  = false 

        find = ( i )->
            if self.list[i].ID is leaf.ID
                exists = true
                return false 
        
        for i in [0..amount] then find( i ) if not exists

        return exists 
      
    add : ( leaf )->
        self     = this 
        amount   = @list.length

        combine =->
            self.counter( '+' )
            leaf.index = self.count
            self.list.push( leaf )
            return
         
        if amount is 0 then combine() 
        if amount > 0 and not @check( leaf ) then combine()
     
    remove : ( leaf )->
        self   = this
        amount = @list.length

        if amount is 0 then return 

        @counter( '-' )

        for i in [amount-1..0] by -1
            if @list[i] is leaf then @list.splice( i, 1 )

    render: ->


class Leaf
    ID      : null
    element : null 
    index   : 0

    ###
    -----------------------------------------------------------
    ###
    Note : console.log.bind( console, 'NOTE ==' )   

    constructor : ( element, count )-> 
        @ID      = "leaf-#{Math.round(Math.random()*9999999)}"
        @element = element 


        this 
      

    build :->
    show :->
    hide :->
    update:->
    destroy:->
       
        
$( document ).on 'ready', ->

    leaf_0 = new Leaf( '.one' )
    leaf_1 = new Leaf( '.two' )
    leaf_2 = new Leaf( '.three' )
    leaves = new Leaves()

    leaves.add( leaf_0 )
    leaves.add( leaf_1 )
    leaves.add( leaf_2 )
    leaves.add( leaf_1 )
    leaves.add( leaf_0 )
    # leaves.add( leaf_0 )
    # leaves.remove( leaf_1 )
    console.log leaves 
