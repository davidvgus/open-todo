
def with_authentication
  Api::UsersController.any_instance.stub(:authenticated?) { true }
  Api::ListsController.any_instance.stub(:authenticated?) { true }
  Api::ItemsController.any_instance.stub(:authenticated?) { true }
end
