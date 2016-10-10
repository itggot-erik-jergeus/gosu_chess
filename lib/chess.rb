require 'gosu'

module ZOrder
  Background, Highlight, Piece, Cursor = *0..3
end

class Regular < Gosu::Window

  def initialize
    super 540, 540
    self.caption = "Chess"
    @background_image = Gosu::Image.new('./media/space.png', :tileable => true)
    @square_blue = Gosu::Image.new('./media/60x60_blue.jpg')
    @square_red =Gosu::Image.new('./media/60x60_red.jpg')
    @cursor = Gosu::Image.new(self, 'media/cursor-arrow.png')
    @pieces = []
    @board = spawn("8x8")
    @highlight = []
    @selected
    @turn = 0
  end

  def spawn(size)
    if size =="8x8"
      8.times do |i|
        @pieces << Warrior.new(i,1,0,0)
        @pieces << Warrior.new(i,0,0,0)
        @pieces << Warrior.new(i,7,180,1)
        @pieces << Warrior.new(i,6,180,1)
      end
    end
  end

  def update
    if Gosu::button_down?(Gosu::MsLeft) then
      p "#{(mouse_x/60).to_i},#{(mouse_y/60).to_i-1}"
      if @selected == nil
        @pieces.each do |piece|
          if (mouse_x/60).to_i == piece.x_value && (mouse_y/60).to_i-1 == piece.y_value
            @selected = piece
            p piece
            @highlight = []
            @selected.moves.each do |move|
              if @selected.x_value + move[0] <= 7 && @selected.x_value + move[0] >= 0 && @selected.y_value + move[1] <= 7 && @selected.y_value + move[1] >= 0
                @highlight << [@selected.x_value+move[0],@selected.y_value+move[1]+1,@selected.owner]
              end
              #ARBETA HÄR ??
              #dasdfasdfsadfsda
              #afdssfasfsda
            end
          end
        end
      else
        @highlight.each do |current|
          #skriv röra, attacker etc.
        end
      end
    end

    if Gosu::button_down?(Gosu::MsRight) || Gosu::button_down?(Gosu::KbEscape) then
      @selected = nil
      @highlight = []
    end

    # def button_down(id)
    #   if id == Gosu::KbEscape
    #     close
    #   end
    # end
    # @player.move
    # @player.collect_stars(@stars)
    #
    # if rand(100) < 4 and @stars.length < 25
    #   @stars << Star.new(@star_anim)
    # end
  end

  def draw
    for piece in @pieces
      piece.draw
    end
    for highlight in @highlight
      if highlight[2] == 0
        @square_blue.draw((highlight[0])*60,highlight[1]*60, ZOrder::Highlight)
      else
        @square_red.draw((highlight[0])*60,highlight[1]*60, ZOrder::Highlight)
      end
    end
    @cursor.draw(self.mouse_x, self.mouse_y, ZOrder::Cursor)
    @background_image.draw(0, 0, ZOrder::Background)
  end
end

class Piece
  def initialize(x, y, angle, owner)
    @x = x
    @y = y
    @angle = angle
    @owner = owner
  end

  def owner
    @owner
  end

  def x_value
    @x
  end

  def y_value
    @y
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def score
    @score
  end

  def draw
    self.image.draw_rot((@x+0.5)*60, (@y+1.5)*60, ZOrder::Piece, @angle)
  end

end

class Warrior < Piece
  def image
    @image = Gosu::Image.new("./media/falcon.png")
  end

  def moves
    [[-1*(Math.cos(@angle*Math::PI/180)),0],[-2*(Math.cos(@angle*Math::PI/180)),0],[-3*(Math.cos(@angle*Math::PI/180)),0],[1*(Math.cos(@angle*Math::PI/180)),0],[2*(Math.cos(@angle*Math::PI/180)),0],[3*(Math.cos(@angle*Math::PI/180)),0],[0,1*(Math.cos(@angle*Math::PI/180))],[0,2*(Math.cos(@angle*Math::PI/180))],[0,3*(Math.cos(@angle*Math::PI/180))]]
  end
end


# class Star
#   attr_reader :x, :y
#
#   def initialize(animation)
#     @animation = animation
#     @color = Gosu::Color.new(0xff_000000)
#     @color.red = rand(256 - 40) + 40
#     @color.green = rand(256 - 40) + 40
#     @color.blue = rand(256 - 40) + 40
#     @x = rand * 1366
#     @y = rand * 768
#   end
#
#   def draw
#     img = @animation[Gosu::milliseconds / 100 % @animation.size];
#     img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
#              ZOrder::Stars, 1, 1, @color, :add)
#   end
# end