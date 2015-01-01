class DrawPool
  def initialize
    @pool = {}
    @total = 0
  end
  
  def add_tickets(id, amount=1)
    if(@pool[id])
      @pool[id]+=amount
    else
      @pool[id]=amount
    end
    @total += amount
  end

  def draw
    if(@total <= 0)
      return nil
    else
      pick = rand(1..@total)
      chosen = nil
      @pool.each_pair do |key, value|
        if(pick <= value)
          chosen = key
          @pool[key] = value-1
          break
        else
          pick -= value
        end
      end
      return chosen
    end
  end
end
