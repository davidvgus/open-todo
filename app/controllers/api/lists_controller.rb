class Api::ListsController < ApiController
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :set_list, only: [:edit, :update, :destroy]
  before_action :check_auth

  def show
  end

  def index
    lists = List.where(permissions: "viewable")

    if params.has_key?(:user_id)
      render json: {:test => "this is a test"}.to_json
    else
      if lists
        render json: lists, each_serializer: IndexListSerializer
      end
    end
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_list
    @list = List.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name, :user_id, :permissions)
  end
end
