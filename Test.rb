require "rubygems"
require "gosu"

class Actor 
  attr_accessor :window,:x,:y,:z,:angle,:image,:width,:height
  def initialize(window,x,y,z,angle,image,width,height)
    @window = window
    @x,@y,@z = x,y,z
    @angle = angle
    @image = image
    @width = width
    @height = height
  end
  def update
    
  end
  def draw
    @image.draw_rot(@x,@y,@z,@angle)
  end
end


class Game < Gosu::Window
  def initialize
    super(800,600,false)
    #@bg = Gosu::Image.new(self,"bg.png")
    #@fg = Gosu::Image.new(self,"fg.png")
    @scoreLabel = Gosu::Font.new(self,"Courier",12)
    @actors = []
  end           
  def update                                       
    if button_down? Gosu::Button::KbUp
    end
    if button_down? Gosu::Button::KbDown
    end
    if button_down? Gosu::Button::KbRight
    end
    if button_down? Gosu::Button::KbLeft
    end
    if button_down? Gosu::Button::MsLeft
    end 
    @actors.each {|actor| actor.update}
  end
  def draw      
    @actors.each {|actor| actor.draw}
  end
end

g = Game.new
g.show