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
          if warrior.health < 15 and !dont_rest
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
              if warrior.feel.wall?
                warrior.pivot!
              else
                if !@toccato_il_muro
                  warrior.walk!(:backward)
                else
                  warrior.walk!
                end
              end
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
  def directions
    [:forward, :backward, :right, :left]
  end
  def captive_to_rescue?
    directions.each do |dir|
      return dir if self.feel(dir).captive?
    end
    return false
  end
  def where_enemy?
    (0..2).each do |pos|
      [:forward, :backward].each do |dir|
        if self.look(dir)[pos].enemy?
          return dir,pos
        end
      end
    end
    return nil
  end
  def see_archer?
    (0..2).each do |pos|
      [:forward, :backward].each do |dir|
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
end
