class Api::ListsController < ApiController
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :set_list, only: [:edit, :update, :destroy]
  before_action :check_auth

  def show
  end

  def index

    if params.has_key?(:user_id)
      lists = List.where("user_id = ? OR permissions = ? OR permissions = ?", params[:user_id], "open", "viewable").order("id ASC")
      render json: lists, each_serializer: IndexListSerializer
    else
      lists = List.where(permissions: "viewable")
      render json: lists, each_serializer: IndexListSerializer
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
