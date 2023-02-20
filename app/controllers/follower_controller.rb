class FollowerController < ApplicationController

  before_action :set_follow_record
  def follow_user
    # Another to do this would be always to create.
    # Then on exception unique exception,
    if @follow_record.nil?
      @follow_record = Follower.new(follower_id: @follower, followee_id: @followee, active: 1)
      if @follow_record.save
        render json:@follow_record.to_json, status: 201
      else
        render json: {error: @follow_record.errors.full_messages}, status: 400
      end
    else
      @follow_record.update(active: 1)
      render json:@follow_record.to_json, status: 200
    end
  end

  def delete_follow
    if @follow_record.nil?
      render json: { error: "You weren't following this user!" }, status: 400
    else
      @follow_record.update(active: 0)
      render json:@follow_record.to_json, status: 200
    end
  end

  private

  def set_follow_record
    params.require([:follower_id, :followee_id])
    @follower = params[:follower_id]
    @followee = params[:followee_id]
    @follow_record = Follower.where(follower_id:@follower, followee_id: @followee).first
  rescue ActionController::ParameterMissing => e
    render json: { error: "#{e.param} parameter is missing" }, status: 400
  end


end
