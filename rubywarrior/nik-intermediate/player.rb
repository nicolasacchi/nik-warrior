class Player
  def play_turn(warrior)
    # add your code here
    @health ||= warrior.health
    @toccato_il_muro ||= false
    @toccato_il_muro = true if warrior.feel(:backward).wall?
    dont_rest = warrior.health < @health
#p warrior.look[1].to_s

    if warrior.enemy_vicini?
      dir,pos = warrior.where_enemy?
      case pos
        when 0
          if warrior.n_enemy_vicini > 1
            warrior.bind!(dir)
          elsif warrior.health < 15 and !dont_rest
            warrior.walk!(inverse_of(dir))
          else
            warrior.attack!(dir)
          end
        when 1,2
          warrior.shoot!(dir)
      end
    else
      if warrior.see_archer?
        dir,pos = warrior.see_archer?
        warrior.shoot!(dir)
      else
        if warrior.where_enemy?
          dir,pos = warrior.where_enemy?
          case pos
          when 0
            if warrior.health < 15 and !dont_rest
              warrior.walk!(inverse_of(dir))
            else
              warrior.attack!(dir)
            end
          when 1,2
            warrior.shoot!(dir)
          end
        else
          if warrior.health != 20 and !dont_rest
            warrior.rest!
          elsif warrior.health < 15
            warrior.walk!(:backward)
          else
            if warrior.captive_to_rescue?
              warrior.rescue!(warrior.captive_to_rescue?)
            else
              #if warrior.feel.wall?
              #  warrior.pivot!
              #else
              warrior.walk!(warrior.where_walk?)
              #end
            end
          end
        end
      end
    end
    @health = warrior.health
  end
  def inverse_of(dir)
    case dir
    when :backward
      return :forward
    when :forward
      return :backward
    end
  end
end
class RubyWarrior::Turn
  def look(dir)
    return [self.feel(dir)]
  end
  def directions
    [:forward, :backward, :right, :left]
  end
  def where_walk?
    list = self.listen
    if list.length > 0
      if self.feel(self.direction_of(list[0])).stairs?
        dirs = directions
        dirs.delete(self.direction_of(list[0]))
        return dirs[rand(0..2)]
      else
        return self.direction_of(list[0])
      end
    else
      return self.direction_of_stairs
    end
  end
  def captive_to_rescue?
    directions.each do |dir|
      return dir if self.feel(dir).captive?
    end
    return false
  end
  def where_enemy?
    (0..(self.look(:forward).length - 1)).each do |pos|
      directions.each do |dir|
        if self.look(dir)[pos].enemy?
          return dir,pos
        end
      end
    end
    return nil
  end
  def see_archer?
    (0..(self.look(:forward).length - 1)).each do |pos|
      directions.each do |dir|
        if self.look(dir)[pos].to_s == "Archer"
          return dir,pos
        end
      end
    end
    return nil
  end
  def enemy_vicini?
    dir,pos = self.where_enemy?
    return pos == 0
  end
  def n_enemy_vicini
    num = 0
    directions.each do |dir|
      if self.look(dir)[0].enemy?
        num += 1
      end
    end
    return num
  end
end
