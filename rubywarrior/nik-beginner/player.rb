class Player
  def play_turn(warrior)
    # add your code here
    @health ||= warrior.health
    dont_rest = warrior.health < @health
    if warrior.feel.enemy?
      warrior.attack!
    else
      if warrior.health != 20 and !dont_rest
        warrior.rest!
      else
        if warrior.feel.captive?
          warrior.rescue!
        else
          warrior.walk!
        end
      end
    end
    @health = warrior.health
  end
end
