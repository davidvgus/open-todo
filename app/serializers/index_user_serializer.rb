class IndexUserSerializer < ActiveModel::Serializer
  attributes :id, :username, :password
end
