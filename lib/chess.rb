require 'gosu'

# module ZOrder
#   Background, Layout, Highlight, Piece, Cursor = *0..4
# end

# TODO Fix Paladin
# TODO Fix Models for background, all pieces, cursor and highlight
# TODO Fix Wrong turn window and code
# TODO Fix Confirm attack window and add the code for implementing it

class GameWindow < Gosu::Window

  def initialize
    super 540, 540
    self.caption = "Chess"
    # @background is a variable that contains the media file for the background used.
    @background_image = Gosu::Image.new('./media/space.png', :tileable => true)
    # @square_blue is a variable that contains the media file for the even player's @highlight image
    @square_blue = Gosu::Image.new('./media/60x60_blue.jpg')
    # @square_red is a variable that contains the media file for the odd player's @highlight image
    @square_red =Gosu::Image.new('./media/60x60_red.jpg')
    # @cursor is a variable that cointains the media file for the cursor
    @cursor = Gosu::Image.new(self, './media/cursor-arrow.png')
    # @pieces is an array that contains various Piece subclasses
    @pieces = []
    # @board is a temporary variable that says the size of the board ATM
    @board = spawn("8x8")
    # @selected is a variable that contains a Piece subclass of the targeted chess piece
    @selected = nil
    # @highlight is all your eligible moves for the @selected piece
    @highlight = []
    # @turn is the current turn, starting at 0. Will most often be used with %2 to figure out whose turn it is
    @turn = 0
  end

  def spawn(size)
    if size =="8x8"
      # Creating some pieces for both sides
      8.times do |i|
        @pieces << General.new(i,1,0,0)
        @pieces << Warrior.new(i,0,0,0)
        @pieces << Cavalry.new(i,7,180,1)
        @pieces << Cavalry.new(i,6,180,1)
      end
      @pieces << Archer.new(3,3,0,0)
      @pieces << Archer.new(4,4,180,1)
    end
  end

  def update
    if Gosu::button_down?(Gosu::MsLeft) then
      ### p "#{(mouse_x/60).to_i},#{(mouse_y/60).to_i-1}"
      # This happens if you don't have a selected piece. The purpose is to select a piece
      if @selected == nil
        # A loop to check which, if any, piece that will be selected. Would probably be better with an .any? method
        @pieces.each do |piece|
          # Checks if the mouse coordinates equal that of one of the pieces. No "else" statement
          if (mouse_x/60).to_i == piece.x_value && (mouse_y/60).to_i-1 == piece.y_value
            # Checks if the turn is equal to that of the piece that was clicked.
            if @turn%2 == piece.owner
              # Sets the piece to @selected, since it is in the right mouse coordinates and the right turn
              @selected = piece
              ### p @selected
              @highlight = []
              # Fix with the 3x2 arrays
              @selected.moves.each do |line|
                line.each do |move|
                  # Checks if the moves for the @selceted piece are eligible
                  if @selected.x_value + move[0] <= 7 && @selected.x_value + move[0] >= 0 && @selected.y_value + move[1] <= 7 && @selected.y_value + move[1] >= 0
                    # Sets @highlight if the move location is not obstructed by a friendly piece
                    if @pieces.any? { |occupied| [occupied.x_value,occupied.y_value,occupied.owner] == [@selected.x_value+move[0],@selected.y_value+move[1],@selected.owner] }
                      # Makes sure that the line of moves are "broken" (to fix object collision) unless the selected type of the piece is cavalry
                      unless @selected.class == Cavalry
                        break
                      end
                      ### p ["sel", @selected.x_value+move[0],@selected.y_value+move[1],@selected.owner]
                    # move[2] is to check if it's a move which isn't allowed to attack. The any? method doesn't contain the owner in that case since you aren't allowed to attack the opponent if move[2] == true
                    elsif move[2] && @pieces.any? { |occupied| [occupied.x_value,occupied.y_value] == [@selected.x_value+move[0],@selected.y_value+move[1]] }
                      break
                    else
                      ### p [@selected.x_value+move[0],@selected.y_value+move[1]+1,@selected.owner,move[2]]
                      @highlight << [@selected.x_value+move[0],@selected.y_value+move[1]+1,@selected.owner,move[2]]
                    end
                  end
                end
              end
              # @selected.moves.each_with_index do |move,i|
              #   # Checks if the moves for the @selceted piece are eligible
              #   if @selected.x_value + move[0] <= 7 && @selected.x_value + move[0] >= 0 && @selected.y_value + move[1] <= 7 && @selected.y_value + move[1] >= 0
              #     # Sets @highlight if the move location is not obstructed by a friendly piece
              #     unless @pieces.any? { |occupied| [occupied.x_value,occupied.y_value,occupied.owner] == [@selected.x_value+move[0],@selected.y_value+move[1],@selected.owner] }
              #       ### p ["sel", @selected.x_value+move[0],@selected.y_value+move[1],@selected.owner]
              #       @highlight << [@selected.x_value+move[0],@selected.y_value+move[1]+1,@selected.owner]
              #     end
              #   end
              # end
            else
              # TODO do something if it is the wrong turn
              #wrong turn
            end
          end
        end
      # This happens if you have a selected piece. The purpose is to move or attack a piece
      else
        # A loop to see if you clicked an eligible spot (an @highlight).
        @highlight.each do |current|
          if [(mouse_x/60).to_i,(mouse_y/60).to_i] == [current[0],current[1]]
            # Sets an @do variable for the move that you will make, that contains the coordinates and possibly the index of the attacked piece.
            @do = [true,current[0],(current[1]-1).to_i,nil,current[3]]
            @pieces.each_with_index do |piece, i|
              # Sees if the move is an attack or not
              if [piece.x_value,piece.y_value] == [@do[1],@do[2]]
                # Sets the index of the attacked piece to @do[3]
                @do[3] = i
              end
            end
          end
        end
      end
    end

    # Executes the @do-move when you press spacebar
    if Gosu::button_down?(Gosu::KbSpace) && @do[0] == true
      # Deletes the piece that was in the position where you move, if the @do-move it's an attack.
      if @do[3] != nil
        @pieces.delete_at(@do[3])
      end
      # Puts the @selected piece where you wanted it to move. The expression can't be simplified since 'nil != false'
      if @do[4] != false
        @selected.warp(@do[1],@do[2])
      end
      # Resets all temporary variables
      @selected = nil
      @highlight = []
      @do = [false,0,0,0]
      # Adds a turn
      @turn += 1
    end

    # Cancels the selection
    if Gosu::button_down?(Gosu::MsRight) || Gosu::button_down?(Gosu::KbEscape) then
      # Resets all temporary variables
      @selected = nil
      @highlight = []
      @do = [false,0,0,0]
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
    # Draws the piece via its own draw method
    for piece in @pieces
      piece.draw
    end
    # Draws the @highlight squares and checks which colour to draw with the @highlight[2], which is the owner of the @selected piece
    for highlight in @highlight
      if highlight[2] == 0
        @square_blue.draw((highlight[0])*60,highlight[1]*60, ZOrder::Highlight)
      else
        @square_red.draw((highlight[0])*60,highlight[1]*60, ZOrder::Highlight)
      end
    end
    # Draw explanation window if it is the wrong turn

    # Draw confirmation window if you press a piece

    # Draws cursor and background
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

  # Contains a bundle of methods that makes it possible to call the owner, x_value and y_value
  def owner
    @owner
  end

  def x_value
    @x
  end

  def y_value
    @y
  end

  # A method to switch places for the Piece
  def warp(x, y)
    @x = x
    @y = y
  end

  # A method that might be used in the future, but isn't currently
  # def score
  #   @score
  # end

  # The .draw method for the Piece, that uses the .image method in all subclasses
  def draw
    self.image.draw_rot((@x+0.5)*60, (@y+1.5)*60, ZOrder::Piece, @angle)
  end

end

class Warrior < Piece
  # Returns the media file for the current subclass
  def image
    Gosu::Image.new("./media/sword.png")
  end

  # Returns all moves for the current subclass. It also uses a multiplier Degree -> Radian conversion multiplier, because gosu and ruby uses different systems. This is only needed when the piece can't move symmetrically in X and Y, such as this case
  def moves
    [[[-1*(Math.cos(@angle*Math::PI/180)),0],[-2*(Math.cos(@angle*Math::PI/180)),0],[-3*(Math.cos(@angle*Math::PI/180)),0]],[[1*(Math.cos(@angle*Math::PI/180)),0],[2*(Math.cos(@angle*Math::PI/180)),0],[3*(Math.cos(@angle*Math::PI/180)),0]],[[0,1*(Math.cos(@angle*Math::PI/180))],[0,2*(Math.cos(@angle*Math::PI/180))],[0,3*(Math.cos(@angle*Math::PI/180))]]]
  end
end

class Cavalry < Piece
  # Returns the media file for the current subclass
  def image
    Gosu::Image.new("./media/horse-icon.png")
  end

  # Returns all moves for the current subclass.
  def moves
    [[[-2,-2],[-3,-3],[-4,-4]],
     [[2,2],[3,3],[4,4]],
     [[-2,2],[-3,3],[-4,4]],
     [[2,-2], [3,-3],[4,-4]]]
  end
end

class General < Piece
  # Returns the media file for the current subclass
  def image
    Gosu::Image.new("./media/general.png")
  end

  # Returns all moves for the current subclass.
  def moves
    [[[-1,0],[-2,0]],
     [[1,0],[2,0]],
     [[0,1],[0,2]],
     [[0,-1],[0,-2]]]
  end
end

class Archer < Piece
  # Returns the media file for the current subclass
  def image
    Gosu::Image.new("./media/falcon.png")
  end

  # Returns all moves for the current subclass. Also specifies if it is a only moving move(true), or a only attacking move (false).
  def moves
    [[[-1,0,true]],[[1,0,true]],[[0,1,true]],[[0,-1,true]],
     [[-3,0,false]],[[3,0,false]],[[0,3,false]],[[0,-3,false]],
     [[1,-3,false]],[[-1,-3,false]],[[1,3,false]],[[-1,3,false]],
     [[3,-1,false]],[[-3,-1,false]],[[3,1,false]],[[-3,1,false]],
     [[2,-2,false]],[[-2,-2,false]],[[2,2,false]],[[-2,2,false]]]
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