class ListSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_id, :user_name

  def user_name
    User.find(user_id).username
  end
end
