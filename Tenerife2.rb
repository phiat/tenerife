require "rubygems"
require "gosu"   
require "GameHelper" 

class Cloud      
  attr_accessor :window,:image,:x,:y,:vX,:vY,:z
  def initialize(window,imagePath,x,y,vX,vY=0,z=2.0)       # redo to x,y,z
    @window = window  
    @image = Gosu::Image.new(@window,imagePath,false) 
    @x, @y = x,y
    @vX ,@vY= vX,vY                   
    @z = z 
  end   
  def update(dx)
    @x += @vX + dx 
  end
  def draw
     @image.draw(@x,@y,@z)  
  end
  
end

class Layer
  def initialize(window,imagePath,x,y,z,vX,vY,constX=0)
    @window = window
    @image = Gosu::Image.new(@window,imagePath,false) 
    @x,@y  = x, y
    @vX, @vY = vX, vY
    @z = z  
    @constX = constX
  end
  def update(dx)
    @x += @constX 
    @x += dx * @vX 
    @x = @x % 800
  end
  def draw
    @image.draw(@x,@y,@z) 
    @image.draw(@x-800,@y,@z) 
    @image.draw(@x+800,@y,@z)  
  end  
end
            
class ScrollMap 
  attr_accessor :window,:bg,:fg,:fg2,:bgx,:bgy,:fgx,:fgy,:fg2x,:fg2y, :clouds, :cloudsx , :layers,:frame
  def initialize(window)
    @window = window
    @bgx,@bgy = 0, 0
    @fgx,@fgy = 0, 0
    @fg2x,@fg2y = 0, 0 
    @frame = Gosu::Image.new(@window,"windowFrame.png",false)
    @bg = Layer.new(@window,"bg6.png",0,0,1,1,0)
    @fg = Layer.new(@window,"fg.png",0,0,2,1.1,0) 
    @fg2 = Layer.new(@window,"fg2.png",0,0,4,1.2,0) 
    @layers = [@bg,@fg,@fg2,
               Layer.new(@window,"fg3.png",0,0,3,1.3,0),
               Layer.new(@window,"fg4.png",0,0,4.5,1.4,0),
               Layer.new(@window,"fg5.png",0,0,5,2,0),
               Layer.new(@window,"fg6.png",0,0,5.5,2.4,0),
               Layer.new(@window,"fg7.png",0,0,6,1,0.3) , # mist 
               Layer.new(@window,"fg8.png",0,0,7,2,0,0.1),  # mist2 
               Layer.new(@window,"fg9.png",0,-400,2,0.5,0,0),
               Layer.new(@window,"fg10.png",0,-400,3,1.5,0,0) ]
    @clouds = [Cloud.new(@window,"cloud1.png",100,20,1), 
               Cloud.new(@window,"cloud2.png",200,100,2)]
    @cloudsx = 0 
    
  end                                                                                
  def updateClouds(dx)
    if @clouds.size < 5
      r = rand
      if r > 0.85                  
        if r > 0.98
          @clouds.push(Cloud.new(@window,"cloud1.png",-800,(rand*200)+50,(rand*1.5)+1,0,(rand*3)+1))
        elsif r > 0.96
          @clouds.push(Cloud.new(@window,"cloud2.png",-800,(rand*200)+50,(rand*1.5)+1,0,(rand*3)+1))
        elsif r > 0.94
          @clouds.push(Cloud.new(@window,"cloud2.png",-800,(rand*100)+20,(rand*1.5)+1,0,2))
        elsif r > 0.92
          @clouds.push(Cloud.new(@window,"cloud4.png",-800,(rand*100)+20,(rand*1.2)+1,0,2))
        elsif r > 0.90
          @clouds.push(Cloud.new(@window,"cloud4.png",-800,(rand*100)+20,(rand*1.2)+1,0,2))
        else
          @clouds.push(Cloud.new(@window,"cloud6.png",-800,(rand*200)+50,(rand*1.5)+1,0,(rand*3)+1))
        end
        
      end
    end
    @clouds.each {|i| i.update(dx) 
                      if i.x > 800
                        @clouds.delete_if {|c|  c == i}
                      end
                 }
    
  end
  def updateLayers(dx)
    @layers.each {|layer| layer.update(dx)  }
  end
  def update(dx)  
    updateClouds(dx)
    updateLayers(dx)                                 
        
  end
  def draw      
    if (@cloudsx > 800)
      @cloudsx = -800
    end
    @layers.each {|layer| layer.draw()}
    
    @clouds.each {|i| i.draw}
    @frame.draw(0,0,10)            
  end
end

class Player
  attr_accessor :window,:x,:y,:yV,:yA,:image,:images ,:score , :words
  def initialize(window,x,y,z=2)
    @window = window
    @y = y                                    
    @x = x
    @z = z
    @yV = 0
    @yA = 3.9                                
    @jumping = false
    @images = [Gosu::Image.new(@window,"slickcat_r.png"),Gosu::Image.new(@window,"slickcat_l.png")]
    @image = @images[0]
    @score = 0     
    @words = [] 
    @popSound = Gosu::Sample.new(@window,"pop.wav")
  end  
  def playPop
    @popSound.play
  end
  def update
   dx = 0                   
    
    if @window.button_down? Gosu::Button::KbRight
      @image = @images[0]
      dx += -4
      if @window.button_down? Gosu::Button::KbLeftShift
         dx -= 1
      end
    end
    if @window.button_down? Gosu::Button::KbLeft
      @image = @images[1]
      dx += 4                                   
      if @window.button_down? Gosu::Button::KbLeftShift
         dx += 1
      end
    end  
    if @window.button_down? Gosu::Button::KbUp
       
      if @jumping 
        @yV += 3
        if (@y < 0)
          @y = 0
        end
      else
        @jumping = true
        @yV = 35        
      end
    end      
    if @jumping
      @yV -= @yA
      if (@yV < 0)
        @y -= @yV / 2.0
      else
        @y -= @yV
      end
    end 
    if @y >= 300
      @jumping = false
      @vY = 300
    end
    if @window.button_down? Gosu::Button::KbQ
      @window.quit
    end                       
    
    @window.map.update(dx) 
    @window.boxes.each {|box| box.update(dx) 
                              if spriteCollide(box,self)
                                @window.boxes.delete_if {|i| i == box}
                                word = randSay
                                if @window.wordList.in?(word)
                                  p "found word #{word}"
                                end               
                                @score += word.size
                                playPop
                                                                
                              end
                              
                        }    
  end                     
  def draw
    @image.draw(@x,@y,@z)
  end                                    
  def randSay               
    cons = "bcdfghjklmnpqrstvwyxz"
    vowels = "aeiou"
    s = ""
    patterns =  [%w[C V C V],%w[V C V V C],%w[C V V C V],%w[C V C C V],
                  %w[C V C C],%w[V C V C C V]]    
    pattern = patterns[rand*patterns.size]
    #pattern = %w[C V C]
    pattern.each {|i| 
    
            case i
            when 'C'
              s.concat(cons[(rand*21).to_i])
            when 'V'                                         
              s.concat(vowels[(rand*5).to_i])                 
            end
          }
     @words.push(s) 
     return s   
  end                        
    
  def wordHistory
    s = ""
    @words.each {|i| s += i +" "}
    return  s
  end
end          

class Box   
   attr_accessor :state, :x,:y,:z  ,:image
  def initialize(window,imagePath,x,y,z=2,state="solid")
    @window = window
    @x,@y,@z = x,y,z
    @state = state
    @image = Gosu::Image.new(@window,imagePath,false)
    
  end
  def update(dx)
    @x += dx 
  end
  def draw
    @image.draw(@x,@y,@z)
  end 
end

class Hud       
  attr_accessor :window,:player
  def initialize (window)
    @scoreLabel = Gosu::Font.new(window,"Helvetica", 20)
    @window = window
    @player = @window.player
  end
  def update
    if @player.score > 125
      @window.quitting = true
    end
  end
  def draw
    @scoreLabel.draw("#{@player.score}", 30, 20, 11, factor_x=2, factor_y=2, color=0xFF000000, mode=:default)
    @scoreLabel.draw("#{@player.words[-1]}", 30, 60, 11, factor_x=1.5, factor_y=1.5, color=0xFF000000, mode=:default)
    @scoreLabel.draw("#{@player.wordHistory}", 30, 90, 11, factor_x=1, factor_y=1, color=0x69000000, mode=:default)    
  end
end

class WorldList  
  attr_reader :file
  def initialize
    @file = File.new("/usr/share/dict/words","r")
  end
  def in?(word)
    p "searching word #{word}..."
    while (line = @file.gets)       
        if line.chomp == word
          p "found!"
          return true
        end
    end    
    return false
  end  
end



class Tenerife < Gosu::Window
  attr_accessor :map,:player,:bullets,:boxes,:hud, :quitting, :wordList
  def initialize  
    super(800,600,false)
    @map = ScrollMap.new(self)   
    @player = Player.new(self,400,300)
    @wordList = WorldList.new
    populateBoxes(30)
    @windSound = Gosu::Song.new(self,"windy.wav").play(true)
    @hud = Hud.new(self) 
    @endImage = Gosu::Image.new(self,"endImage.png",false)
    @quitting = false
  end
  def populateBoxes(i)   
    @boxes = []
    i.times { @boxes.push(Box.new(self,"box3.png",rand*5000 - 2500,rand*400 + 20))}
  end
  def update
    @hud.update       
    @player.update              
  end
  def draw
    @map.draw      
    @hud.draw         
    @boxes.each{|box| box.draw }
    @player.draw         
    if @quitting
        @endImage.draw(0,0,30)
        s = ""           
        p  `say you have acquirred the words,`    
        @player.words.each {|i| s += "#{i}, "}
        p `say #{s}`
        quit
      end    
  end
  def quit                                     
    @endImage.draw(0,0,30)    
    exit
  end
end  

g = Tenerife.new
g.show
