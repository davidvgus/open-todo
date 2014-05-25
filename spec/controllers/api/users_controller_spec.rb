require 'spec_helper'

describe Api::UsersController do

  before do
    User.destroy_all
  end

  describe "create" do

    it "requires authentication" do
      params = {'user' => { username: 'foo', password: 'secret'}}
      post :create, params
      expect(response.status).to eql 403 # forbidden
    end

    context "with authentication" do

      before do
        with_authentication
      end

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
  end

  describe "index" do

    before do
      (1..3).each{ |n| User.create( id: n, username: "name#{n}", password: "pass#{n}" ) }
    end

    it "requires authentication" do
      get :index
      expect(response.status).to eql 403 # forbidden
    end

    context "with authentication" do

      it "lists all usernames and ids" do
        with_authentication
        get :index

        expect(JSON.parse(response.body)).to eql(
          { 'users' =>
            [
              {'id' => 1, 'username' => 'name1', 'password' => 'pass1' },
              {'id' => 2, 'username' => 'name2', 'password' => 'pass2' },
              {'id' => 3, 'username' => 'name3', 'password' => 'pass3' }
            ]
        })
      end
    end
  end

  describe "update" do
    it "fails without authentication" do
      user = FactoryGirl.create(:user, username: "beforename", password: "before_password")
      params = {id: user.id, username: "after_name", password: "after_password"}
      put :update, params
      expect(response.status).to eql 403 # forbidden

    end

    context "with authentication " do
      it "allows username and password change" do
        with_authentication
        request.headers["CONTENT_TYPE"] = "application/json"
        request.headers["ACCEPT"] = "application/json"
        user = FactoryGirl.create(:user, username: "beforename", password: "before_password")
        params = {id: user.id, username: "after_name", password: "after_password"}
        put :update, params

        user_after = User.find(user.id)
        user_params_after_update = {id: user.id, username: user_after[:username], password: user_after[:password]}
        expect(user_params_after_update).to eql(params)
      end
    end
  end

  describe "destroy" do
    it "fails without authentication" do
      user = FactoryGirl.create(:user)
      delete :destroy, {id: user.id}
      expect(response.status).to eql 403 # forbidden
    end

    it "deletes and returns the user" do
      with_authentication
      user = FactoryGirl.create(:user)
      user_hash = {"id" => user.id, "username" => user.username, "password" => user.password}
      delete :destroy, {id: user.id}

      returned_deleted_user = JSON.parse(response.body)["deleted_user"]
      expect(returned_deleted_user).to eql( user_hash )
    end
  end

end
