class ProposalsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_character
  before_filter :check_valid_owner, :except => :show
  
  def index
    @sent_proposals = @character.sent_proposals
    @received_proposals = @character.received_proposals
  end

  # When we know the proposal type, but not who to send it to yet
  def new_target
    @other_characters = @character.world.characters.reject{|other_character| other_character==@character}
  end

  # For assigning the details of a proposal after we identify a target
  def new_details
    @target = Character.find(params[:target_id])
  end

  def create
    proposal = Proposal.new(:sender_id => @character.id, :receiver_id => params[:target_id], :status => 'new')
    respond_to do |format|
      if(proposal.save)
        format.html { redirect_to proposals_path, :notice => "Proposal sent." }
      else
        format.html { redirect_to proposals_path, :alert => character_action.errors.full_messages.to_sentence}
      end
    end
  end

  def show
  end

  def accept
  end

  def decline
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
