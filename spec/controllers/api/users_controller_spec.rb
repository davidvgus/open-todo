require 'spec_helper'

describe Api::UsersController do

  before do
    User.destroy_all
  end

  describe "create" do
    it "creates and returns a new user from username and password params" do
      params = { 'new_user' => { 'username' => 'testuser', 'password' => 'testpass' } }
      request.headers["CONTENT_TYPE"] = "application/json"
      request.headers["ACCEPT"] = "application/json"

      expect{ post :create, params }.to change{ User.where(params['user']).count }.by 1

      JSON.parse(response.body).should == params
    end

    it "returns an error when not given a username" do
      params = { 'new_user' => { 'password' => 'testpass' } }
      request.headers["CONTENT_TYPE"] = "application/json"
      request.headers["ACCEPT"] = "application/json"

      post :create, params
      response.should be_error
    end

    it "returns an error when not given a password" do
      pending
      post :create, {new_user: { username: 'testname' }}
      response.should be_error
    end
  end

  describe "index" do

    before do
      pending
      (1..3).each{ |n| User.create( id: n, username: "name#{n}", password: "pass#{n}" ) }
    end

    it "lists all usernames and ids" do
      get :index

      JSON.parse(response.body).should ==
        { 'users' =>
          [
            { 'id' => 1, 'username' => 'name1' },
            { 'id' => 2, 'username' => 'name2' },
            { 'id' => 3, 'username' => 'name3' }
          ]
        }
    end
  end
end
