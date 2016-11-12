require 'gosu'

module ZOrder
  Background, Layout, Cursor = *0..2
end

class MenuWindow < Gosu::Window

    def initialize
      super 540, 540
      self.caption = "All your base are belong to us"
      @background_image = Gosu::Image.new('./media/Menu_background.png', :tileable => true)
      @cursor = Gosu::Image.new(self, './media/cursor-arrow.png')
      @play = Button.new(247,297,227,259,"play")
      @rules = Button.new(246,300,291,316,"rules")
      @quit = Button.new(250,295,349,376,"quit")

    end

    def check(x_l,x_r,y_t,y_b)
      if mouse_x >= x_l && mouse_x <= x_r && mouse_y >= y_t && mouse_y <= y_b
        return true
      end
    end

    def update
      if Gosu::button_down?(Gosu::MsLeft) then
        if check(@play.x_left,@play.x_right,@play.y_top,@play.y_bottom) == true
          @background_image = Gosu::Image.new('./media/space.png', :tileable => true)
          #Går till CHOOSE GAMEMODE
        elsif check(@rules.x_left,@rules.x_right,@rules.y_top,@rules.y_bottom)== true
          @background_image = Gosu::Image.new('./')
          #Går till RULES
        elsif check(@quit.x_left,@quit.x_right,@quit.y_top,@quit.y_bottom) == true
          close
        end
    end

    def draw
      @background_image.draw(0, 0, ZOrder::Background)
      @cursor.draw(self.mouse_x, self.mouse_y, ZOrder::Cursor)
    end

end

class Button
  def initialize(x_l,x_r,y_t,y_b,type)
    @x_left = x_l
    @x_right = x_r
    @y_top = y_t
    @y_bottom = y_b
    @type = type
  end

  def x_left
    @x_left
  end

  def x_right
    @x_right
  end

  def y_top
    @y_top
  end

  def y_bottom
    @y_bottom
  end

  def type
    @type
  end

  end
end

