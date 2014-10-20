class ProposalsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_character
  before_filter :check_valid_owner, :except => :show
  
  def index
    @new_proposals = []
    @world = @character.world

    sent_proposals = @character.sent_proposals.where(:turn => @world.turn).sort_by(&:created_at)
    new_sent_proposals = sent_proposals.select{|proposal| !proposal.viewed_by?(@character)}
    sent_proposals -= new_sent_proposals

    received_proposals = @character.received_proposals.where(:turn => @world.turn).sort_by(&:created_at)
    new_received_proposals = received_proposals.select{|proposal| !proposal.viewed_by?(@character)}
    received_proposals -= new_received_proposals

    previous_sent_proposals = @character.sent_proposals.where(:turn => (@world.turn-1)).sort_by(&:created_at)
    previous_received_proposals = @character.received_proposals.where(:turn => (@world.turn-1)).sort_by(&:created_at)

    @proposals_hash = [
      {:label => 'Newly Received or Updated', :proposals => new_sent_proposals+new_received_proposals},
      {:label => 'Received', :proposals => received_proposals},
      {:label => 'Sent', :proposals => sent_proposals},
      {:label => 'Previous Proposals', :proposals => previous_sent_proposals+previous_received_proposals}
    ]

    new_sent_proposals.each do |proposal|
      proposal.mark_read_for(@character)
    end

    new_received_proposals.each do |proposal|
      proposal.mark_read_for(@character)
    end
  end

  # When we know the proposal type, but not who to send it to yet
  def new_target
    @proposal_type = params[:proposal_type]
    @other_characters = @character.world.characters.reject{|other_character| other_character==@character}
  end

  # For assigning the details of a proposal after we identify a target
  def new_details
    @proposal_type = params[:proposal_type]
    @target = Character.find(params[:target_id])
    if(@proposal_type == 'Trade')
      @sender_possessions = @character.possessions_list
      @receiver_possessions = @target.possessions_list
      
      # Remove already known knowledge from the teachables lists
      sender_knowledges = @character.knowledges.map(&:get)
      receiver_knowledges = @target.knowledges.map(&:get)
      @sender_teachables = sender_knowledges - receiver_knowledges
      @receiver_teachables = receiver_knowledges - sender_knowledges
      # Add information on remaining lessons required
      @sender_teachables.map! do |knowledge|
        attributes = {:id => knowledge.id, :name => knowledge.name}
        attributes[:progress] = @target.knowledge_progress(knowledge.id)
        attributes[:remaining_progress] = knowledge.components - attributes[:progress]
        attributes
      end
      @receiver_teachables.map! do |knowledge|
        attributes = {:id => knowledge.id, :name => knowledge.name}
        attributes[:progress] = @character.knowledge_progress(knowledge.id)
        attributes[:remaining_progress] = knowledge.components - attributes[:progress]
        attributes
      end
    elsif(@proposal_type == 'Interaction')
      @activities = Activity.all
    elsif(@proposal_type == 'Message')
      if(@character.knows?('gestures') && @target.knows?('gestures'))
        @gestures = Gesture.all
      end
    end
  end

  def create
    target = Character.find(params[:target_id])
    proposal_type = params[:proposal_type]
    errors = []
    success = false
    proposal = nil
    begin
      ActiveRecord::Base.transaction do
        if(proposal_type == 'Trade')
          possessions = params[:possessions] || []
          logger.error possessions.inspect
          asked_knowledge_ids = params[:asked_knowledge_ids] || []
          offered_knowledge_ids = params[:offered_knowledge_ids] || []
          
          possessions_traded = false
          possessions.each do |offer_type, possession_details|
            possession_details.each do |possession_id, variant_details|
              variant_details.each do |variant_id, quantity|
                if(quantity && !quantity.empty? && quantity.to_i > 0)
                  possessions_traded = true
                end
              end
            end
          end

          knowledges_traded = false
          asked_knowledge_ids.each do |knowledge_id, attributes|
            if(attributes && attributes[:duration] && attributes[:duration].to_i > 0)
              knowledges_traded
            end
          end
          offered_knowledge_ids.each do |knowledge_id, attributes|
            if(attributes && attributes[:duration] && attributes[:duration].to_i > 0)
              knowledges_traded
            end
          end

          if(possessions_traded || !asked_knowledge_ids.empty? || !offered_knowledge_ids.empty?)
            trade = Trade.new()
            # Make trade possession entries
            possessions.each do |offer_type, possession_details|
              offered = (offer_type == "offered")
              possession_details.each do |possession_id, variant_details|
                variant_details.each do |variant_id, quantity|
                  TradePossession.new(
                    :trade => trade,
                    :offered => offered,
                    :possession_id => possession_id,
                    :possession_variant_id => variant_id,
                    :quantity => quantity.to_i
                  ).save!
                end
              end
            end

            asked_knowledge_ids.each do |knowledge_id, attributes|
              if(attributes && attributes[:duration] && attributes[:duration].to_i > 0)
                if(@character.knows?(knowledge_id) || !target.knows?(knowledge_id))
                  errors << "You can't learn #{knowledge_id}"
                end
                TradeAskedKnowledge.new(:trade => trade, :knowledge_id => knowledge_id, :duration => attributes[:duration]).save!
              end
            end
            offered_knowledge_ids.each do |knowledge_id, attributes|
              if(attributes && attributes[:duration] && attributes[:duration].to_i > 0)
                if(!@character.knows?(knowledge_id) || target.knows?(knowledge_id))
                  errors << "You can't teach #{knowledge_id}"
                end
                TradeOfferedKnowledge.new(:trade => trade, :knowledge_id => knowledge_id, :duration => attributes[:duration]).save!
              end
            end
            trade.save!
            proposal = Proposal.new(:sender => @character, :receiver => target, :content => trade)
            success = proposal.save!
          else
            errors << " No asked or offered items."
          end
        elsif(proposal_type == 'Interaction')
          activity = Activity.find(params[:activity])
          if(activity)
            interaction = Interaction.new(:activity_id => activity.id)
            interaction.save!
            proposal = Proposal.new(:sender => @character, :receiver => target, :content => interaction)
            success = proposal.save!
          else
            errors << " Could not find an activity with the given id."
          end
       else
          errors << " Invalid proposal type."
        end
        if(!errors.empty?)
          raise "Proposal failed."
        end
      end
    rescue => e
      errors = [e.to_s, "Could not make this proposal."].concat(errors)
      if(proposal && !proposal.errors.empty?)
        errors = errors.concat(proposal.errors)
      end
      success = false
    end
    respond_to do |format|
      if(success)
        format.html { redirect_to proposals_path, :notice => "Proposal sent." }
      else
        format.html { redirect_to new_proposal_details_path, :alert => errors.join(" ")}
      end
    end
  end

  def create_message
    begin
      ActiveRecord::Base.transaction do
        components = params[:message_components]
        if(components && !components.empty?)
          target = Character.find(params[:target_id])
          proposal = Proposal.new(:sender => @character, :receiver => target)
          message = Message.new(:proposal => proposal)
          message.save!
          components.each do |index, component|
            if(component[:type]=="speech")
              is_speech = true
              body = component[:value]
            elsif(component[:type]=="gesture")
              body = Gesture.find(component[:value]).result(@character, target, target)
            else
              raise "Unrecognized message component type."
            end
            MessageComponent.new(:is_speech => is_speech, :body => body, :message => message).save!
          end
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to proposals_path, :notice => "Proposal sent." }
    end
  end

  def show
    @proposal = Proposal.find(params[:proposal_id])
    if(@proposal.content_type == "Trade")
      if(@proposal.receiver  == @character)
        @proposal.mark_read_for(@character)
        @character_gets = @proposal.content.trade_possessions.offered
        @character_loses = @proposal.content.trade_possessions.asked
        @character_learns = @proposal.content.trade_offered_knowledges
        @character_teaches = @proposal.content.trade_asked_knowledges
      elsif(@proposal.sender  == @character)
        @character_loses = @proposal.content.trade_possessions.offered
        @character_gets = @proposal.content.trade_possessions.asked
        @character_teaches = @proposal.content.trade_offered_knowledges
        @character_learns = @proposal.content.trade_asked_knowledges
      else
        raise "This character is not involved with this proposal."
      end
    end
  end

  def accept
    @proposal = Proposal.find(params[:proposal_id])
    if(@character.received_proposals.include?(@proposal))
      success = @proposal.accept
      respond_to do |format|
        if(success)
          format.html { redirect_to character_overview_path, :notice => "Proposal accepted." }
        else
          format.html { redirect_to character_overview_path, :alert => @proposal.errors.full_messages.to_sentence}
        end
      end
    else
      redirect_to :proposals, :alert => "You cannot accept a proposal that is not yours."
    end
  end

  def decline
    @proposal = Proposal.find(params[:proposal_id])
    if(@proposal.receiver == @character)
      success = @proposal.decline
      respond_to do |format|
        if(success)
          format.html { redirect_to proposals_path, :notice => "Proposal declined." }
        else
          format.html { redirect_to proposals_path, :alert => @proposal.errors.full_messages.to_sentence}
        end
      end
    else
      redirect_to :proposals, :alert => "You cannot decline a proposal that is not yours."
    end
  end

  def cancel 
    @proposal = Proposal.find(params[:proposal_id])
    if(@proposal.sender == @character)
      success = @proposal.cancel
      respond_to do |format|
        if(success)
          format.html { redirect_to proposals_path, :notice => "Proposal declined." }
        else
          format.html { redirect_to proposals_path, :alert => @proposal.errors.full_messages.to_sentence}
        end
      end
    else
      redirect_to :proposals, :alert => "You cannot decline a proposal that is not yours."
    end
  end

private
  def find_character
    @character = Character.find(params[:id])
  end

  def check_valid_owner
    if(!current_user.characters.include?(@character))
      redirect_to :action => :show
    end
  end
end
