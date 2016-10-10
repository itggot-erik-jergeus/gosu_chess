require 'gosu'

module ZOrder
  Background, Layout, Text, Cursor = *0..3
end

class MenuWindow < Gosu::Window

    def initialize
      super 540, 540
      self.caption = "All your base are belong to us"
      @background = Gosu::Image.new('./media/space.png', :tileable => true)
      
    end

end