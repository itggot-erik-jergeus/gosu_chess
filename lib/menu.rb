require 'gosu'
require_relative './chess'

module ZOrder
  Background, Layout, Highlight, Piece, Cursor = *0..4
end

class MenuWindow < Gosu::Window

    def initialize
      super 540, 540
      self.caption = "All your base are belong to us"
      # @background and @cursor are variables containing the media files used for the backgrounds and cursor respectively
      @background_image = Gosu::Image.new('./media/menu_background.png', :tileable => true)
      @cursor = Gosu::Image.new(self, './media/cursor-arrow.png')
      # Following variables contains delta x and delta y coordinates for named buttons
      @play = Button.new(247,297,227,259,"play")
      @rules = Button.new(246,300,291,316,"rules")
      @quit = Button.new(250,295,349,376,"quit")
      @back = Button.new(40,98,473,501,"back")
      @pieces = Button.new(432,503,471,498,"pieces")
      # Variable that tracks which instance you currently are in, serves to activate certain buttons
      @instance = "Menu"
    end

    def check(x_l,x_r,y_t,y_b)
      # Determines if the cursor is within the given area, made by the x and y coordinates
      if mouse_x >= x_l && mouse_x <= x_r && mouse_y >= y_t && mouse_y <= y_b
        true
      end
    end

    def update
      # Executes when left mouse button is pressed
      if Gosu::button_down?(Gosu::MsLeft) then
        # Executes if the cursor is within the area of a button and the @instance is what the player should be in
        if check(@play.x_left,@play.x_right,@play.y_top,@play.y_bottom) && @instance == "Menu"
          # Sets @instance to "Game" and opens the Game window
          @instance = "Game"
          GameWindow.new.show
        elsif check(@rules.x_left,@rules.x_right,@rules.y_top,@rules.y_bottom) && @instance == "Menu"
          # Sets @instance to "Rules" and changes the background to rules.background
          @instance = "Rules"
          @background_image = Gosu::Image.new('./media/rules_background.png', :tileable => true)
        elsif check(@quit.x_left,@quit.x_right,@quit.y_top,@quit.y_bottom) && @instance == "Menu"
          # Closes the window
          close
        elsif check(@back.x_left,@back.x_right,@back.y_top,@back.y_bottom) && @instance == "Rules"
          # Sets @instance to "Menu" and changes the background to menu.background
          @instance = "Menu"
          @background_image = Gosu::Image.new('./media/menu_background.png', :tileable => true)
        elsif check(@pieces.x_left,@pieces.x_right,@pieces.y_top,@pieces.y_bottom) && @instance == "Rules"
          # Sets @instance to "Pieces" and changes the background to pieces_background
          @instance = "Pieces"
          @background_image = Gosu::Image.new('./media/pieces_background.png', :tileable => true)
        end
      end
    end


    def draw
      # Draws the images to the window
      @background_image.draw(0, 0, ZOrder::Background)
      @cursor.draw(self.mouse_x, self.mouse_y, ZOrder::Cursor)
    end


  class Button
    def initialize(x_l,x_r,y_t,y_b,type)
      # Consists of delta x and delta y to define the area the button is occupying, may(?) not stack
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

