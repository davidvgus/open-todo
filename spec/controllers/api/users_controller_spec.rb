require 'spec_helper'

describe Api::UsersController do

  before do
    User.destroy_all
    request.headers["CONTENT_TYPE"] = "application/json"
    request.headers["ACCEPT"] = "application/json"
  end

  describe "create" do
    it " returns a new user from username and password params" do
      params = { 'user' => { 'username' => 'testuser', 'password' => 'testpass' } }

      expect{ post :create, params }.to change{ User.count }.by 1

      expect(JSON.parse(response.body)).to eql(params)
    end

    it "returns an error when not given a username" do
      params = { 'user' => { 'password' => 'testpass' } }

      post :create, params
      expect(response).to be_error
    end

    it "returns an error when not given a password" do
      params = { 'user' => { 'username' => 'testname' } }

      post :create, params
      expect(response).to be_error
    end
  end

  describe "index" do

    before do
      (1..3).each{ |n| User.create( id: n, username: "name#{n}", password: "pass#{n}" ) }
    end

    it "lists all usernames and ids" do
      get :index

      #JSON.parse(response.body).should ==
      expect(JSON.parse(response.body)).to eql(
        { 'users' =>
          [
            { 'username' => 'name1', 'password' => 'pass1' },
            { 'username' => 'name2', 'password' => 'pass2' },
            { 'username' => 'name3', 'password' => 'pass3' }
          ]
        })
    end
  end

  describe "update" do
    it "allows username and password change" do
      user = FactoryGirl.create(:user, username: "beforename", password: "before_password")
      params = {id: user.id, username: "after_name", password: "after_password"}
      put :update, params

      user_after = User.find(user.id)
      user_params_after_update = {id: user.id, username: user_after[:username], password: user_after[:password]}
      expect(user_params_after_update).to eql(params)
    end
  end

  describe "destroy" do
    it "deletes and returns the user" do

      user = FactoryGirl.create(:user)
      user_hash = {"id" => user.id, "username" => user.username, "password" => user.password}
      delete :destroy, {id: user.id}

      returned_deleted_user = JSON.parse(response.body)["deleted_user"]
      expect(returned_deleted_user).to eql( user_hash )
    end
  end

end
