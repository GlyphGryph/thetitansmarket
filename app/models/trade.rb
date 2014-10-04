class Trade < ActiveRecord::Base
  has_one :proposal, :as => :content

  has_many :trade_possessions, :dependent => :destroy

  has_many :trade_asked_knowledges, :dependent => :destroy
  has_many :trade_offered_knowledges, :dependent => :destroy

  has_one :sender, :through => :proposal, :class_name => "Character"
  has_one :receiver, :through => :proposal, :class_name => "Character"

  def acceptable?
    return true
  end

  def accept
    # The possessions offered are the ones we gain, the proffessions asked are the ones we lose
    asked_knowledges = self.trade_asked_knowledges
    offered_knowledges = self.trade_offered_knowledges
    sender_message = ["You tried to trade with #{receiver.name}."]
    receiver_message = ["You tried to trade with #{sender.name}."]
    errors = []
    success = true
    # We want to do this as a transaction - if there's an error changing any of these, we want to roll them all back
    begin
      ActiveRecord::Base.transaction do
        sender = proposal.sender
        receiver = proposal.receiver
        sender_items = sender.possessions_list
        receiver_items = receiver.possessions_list

        # Insure all items are valid tradeables
        
        self.trade_possessions.offered.each do |trade_possession|
          found_item = sender_items.select do |item|
            (trade_possession.possession_id == item.id) &&
            (trade_possession.possession_variant == item.variant)
          end
          found_item = found_item.first
          if(!found_item)
            errors << "#{sender.name} offered #{trade_possession.get_name}, but does not possess any of that item."
          elsif(found_item.quantity < trade_possession.quantity)
            errors << "#{sender.name} offered #{trade_possession.quantity}x #{trade_possession.get_name}, but only possess #{found_item.quantity}x #{found_item.get_name}."
          end
        end

        self.trade_possessions.asked.each do |trade_possession|
          found_item = receiver_items.select do |item|
            (trade_possession.possession_id == item.id) &&
            (trade_possession.possession_variant == item.variant)
          end
          found_item = found_item.first
          if(!found_item)
            errors << "#{sender.name} asked for #{trade_possession.get_name}, but #{receiver.name} does not possess any of that item."
          elsif(found_item.quantity < trade_possession.quantity)
            errors << "#{sender.name} asked for #{trade_possession.quantity}x #{trade_possession.get_name}, but #{receiver.name} only possess #{found_item.quantity}x #{found_item.get_name}."
          end
        end
     
        # Insure all knowledges can be taught
        # Insure characters have enough vigor remaining to teach and learn all knowledges
        vigor_cost = 0
        asked_knowledges.each do |trade_knowledge|
          vigor_cost += trade_knowledge.duration
          # Fails if sender already has requested knowledge
          if(sender.knows?(trade_knowledge.get.id))
            errors << "#{sender.name} asked to be taught #{trade_knowledge.get.name}, but #{sender.name} already knows this."
          end
          # Fails is receiver does not know this
          if(!receiver.knows?(trade_knowledge.get.id))
            errors << "#{sender.name} asked to be taught #{trade_knowledge.get.name}, but #{receiver.name} does not know this."
          end
        end

        offered_knowledges.each do |trade_knowledge|
          vigor_cost += trade_knowledge.duration
          # Fails if receiver already has requested knowledge
          if(receiver.knows?(trade_knowledge.get.id))
            errors << "#{sender.name} offered to teach #{trade_knowledge.get.name}, but #{receiver.name} already knows this."
          end
          # Fails is sender does not know this
          if(!sender.knows?(trade_knowledge.get.id))
            errors << "#{sender.name} offered to teach #{trade_knowledge.get.name}, but #{sender.name} does not know this."
          end
        end

        if(sender.vigor < vigor_cost)
          errors << "#{sender.name} did not have enough vigor to participate in the lessons."
        end
        if(receiver.vigor < vigor_cost)
          errors << "#{receiver.name} did not have enough vigor to participate in the lessons."
        end

        # If there were any problems found, abort now
        if(!errors.empty?)
          raise "Could not conduct this trade."
        end

        # Otherwise, actually execute the trade
        self.trade_possessions.each do |trade_possession|
          if(trade_possession.offered?)
            origin = sender
            target = receiver
          else
            origin = receiver
            target = sender
          end
          character_possessions = CharacterPossession.where(
            :character => origin, 
            :possession_id => trade_possession.possession_id, 
            :possession_variant => trade_possession.possession_variant
          ).to_a
          trade_possession.quantity.times do
            character_possession = character_possessions.pop
            character_possession.character = target
            character_possession.save!
          end
          sender_message << "#{origin.name} gave #{trade_possession.quantity} #{trade_possession.possession_variant.plural_name} to #{target.name}."
          receiver_message << "#{origin.name} gave #{trade_possession.quantity} #{trade_possession.possession_variant.plural_name} to #{target.name}."
        end

        # Conduct Knowledges
        asked_knowledges.each do |trade_knowledge|
          knowledge_id = trade_knowledge.knowledge_id
          sender.learn(knowledge_id, trade_knowledge.duration)
          sender.change_vigor(-trade_knowledge.duration)
          receiver.change_vigor(-trade_knowledge.duration)
          sender_message << "You learned #{trade_knowledge.get.name}."
          receiver_message << "You taught #{trade_knowledge.get.name}."
        end

        offered_knowledges.each do |trade_knowledge|
          knowledge_id = trade_knowledge.knowledge_id
          receiver.learn(knowledge_id, trade_knowledge.duration)
          sender.change_vigor(-trade_knowledge.duration)
          receiver.change_vigor(-trade_knowledge.duration)
          sender_message << "You taught #{trade_knowledge.get.name}."
          receiver_message << "You learned #{trade_knowledge.get.name}."
        end
      end
    rescue => e      
      errors = [e.to_s].concat(errors)
      if(proposal && !proposal.errors.empty?)
        errors = errors.concat(proposal.errors)
      end
      success = false
    end
    if(!success)
      sender_message = sender_message+errors
      receiver_message = receiver_message+errors
    end
    sender.recent_history << sender_message.join(" ")
    sender.save!
    receiver.recent_history << receiver_message.join(" ")
    receiver.save!
    return success
  end

  def decline
    return true
  end

  def cancel
    return true
  end

  def name_for_sender
    return "Trade Offer to "+self.receiver.name
  end

  def name_for_receiver
    return "Trade Offer from "+self.sender.name
  end
end
