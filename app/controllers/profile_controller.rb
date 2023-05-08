class ProfileController < PrivateController
  # GET profile/activity/:profile_id
  def activity
    if params[:profile_id]
      render json: [{ name: "created", count: 3, ids: [1, 6, 5] }]
    else
      render json: []
    end
  end
end
