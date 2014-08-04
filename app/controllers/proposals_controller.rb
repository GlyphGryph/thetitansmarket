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
    @proposal_type = params[:proposal_type]
    @other_characters = @character.world.characters.reject{|other_character| other_character==@character}
  end

  # For assigning the details of a proposal after we identify a target
  def new_details
    @proposal_type = params[:proposal_type]
    @target = Character.find(params[:target_id])
  end

  def create
    @target = Character.find(params[:target_id])
    if(params[:proposal_type] == 'Trade')
      trade = Trade.new()
      trade.save!
      proposal = Proposal.new(:sender_id => @character.id, :receiver => @target, :status => 'new', :content => trade)
      success = proposal.save
    else
      success = false
    end
    respond_to do |format|
      if(success)
        format.html { redirect_to proposals_path, :notice => "Proposal sent." }
      else
        format.html { redirect_to proposals_path, :alert => "Could not make this proposal."}
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
