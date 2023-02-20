class SchedulerController < ApplicationController
  before_action :set_user
  def register_schedule
    # TODO: do not allow users to register duplicate hours in the same day?
    # Let's just keep it simple, they can register whatever they want.
    params.require([:slept_at, :woke_at])

    @slept_at = parse_date(params[:slept_at])
    @woke_at = parse_date(params[:woke_at])
    if @slept_at.nil? or @woke_at.nil?
      render json: { error: "Invalid slept at or woke up values" }, status: 400
      return
    end
    @new_schedule = SleepSchedule.new(
      slept_at: @slept_at,
      woke_up_at: @woke_at,
      user_id: @user.id,
      total_slept_seconds: ((@woke_at - @slept_at) * 24 * 60 * 60).to_i
    )

    unless @new_schedule.valid?
      render json: { error: "Invalid schedule" }, status: 400
      return
    end
    @new_schedule.save
    render json: @new_schedule.to_json(:except => [:updated_at]), status: 201
  rescue ActionController::ParameterMissing => e
    render json: { error: "#{e.param} parameter is missing" }, status: 400
  end

  #TODO: Use devise for handling the user auth.
  def get_schedule
    @limit = params[:limit] || 10
    @offset = params[:offset] || 0
    @response = SleepSchedule.where(user_id: @user.id).order(created_at: :desc).limit(@limit).offset(@offset)
    render json: @response.to_json(:except => [:updated_at])
  end

  def get_followers_schedule
    #TODO: for the past week. Needs an update
    @limit = params[:limit] || 10
    @offset = params[:offset] || 0
    @records = SleepSchedule
                 .joins("JOIN followers ON sleep_schedules.user_id = followers.followee_id")
                 .where(followers: { follower_id: @user.id, active: 1 } )
                 # See the sleep records over the past week for their friends = let's assume created_at
                 .where("sleep_schedules.created_at >= ?", 1.week.ago.to_date)
                 .order(total_slept_seconds: :desc, id: :desc)
                 .limit(@limit)
                 .offset(@offset)
    render json: @records.to_json(:except => [:updated_at])
  end

  private
  def parse_date(val)
    DateTime.parse(val)
  rescue ArgumentError
    nil
  end
  def set_user
    @user = User.find_by_id(params[:id])
    if @user.nil?
      render json: {error: "Invalid user id"}, status: 400
    end
  end
end
