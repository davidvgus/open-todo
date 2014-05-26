class Api::ListsController < ApiController
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :set_list, only: [:edit, :update, :destroy]
  before_action :check_auth

  def show
  end

  def index
    render json: {bleh: "boo"}.to_json
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
