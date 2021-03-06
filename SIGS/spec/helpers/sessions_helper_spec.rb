require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do

  describe "Testing SessionsHelper methods" do

    before(:each) do
      @user = User.create(name: 'teste123', cpf: '05365052170', registration: '1234567' , email: 'test@unb.br', password: '123123', active: true)
      @user1 = User.create(name: 'teste1234', cpf: '05365052171', registration: '1234568', email: 'test1@unb.br', password: '1231234', active: true)
      @department = Department.create(code:"123",name:"departmentTest")
      @course = Course.create(code:"123",name:"courseTest",department_id: @department.id)
      @coordinator = Coordinator.create(course_id: @course.id, user_id: @user.id)
      @user2 = User.create(name: 'teste12345', cpf: '05365052172', registration: '1234569', email: 'test2@unb.br', password: '12312345', active: true)
      @department_assistant = DepartmentAssistant.create(department_id: @department.id,user_id: @user1.id)
      @administrative_assistant = AdministrativeAssistant.create(user_id: @user2.id)
    end

    it "Should assign a user_id to session" do
      sign_in(@user)
      expect(session[:user_id]).to eq(@user.id)
    end

    it "Should find and assign a user to current_user" do
      sign_in(@user)
      current_user
      expect(@current_user).to eq(@user)
    end

    it "Should unassign a current_user, user_id and permission from session " do
      sign_in(@user)
      sign_out
      expect(session[:user_id]).to eq(nil)
      expect(@current_user).to eq(nil)
      expect(@permission).to eq(nil)
    end

    it "Should return a level of permission to current_user" do
      sign_in(@user)
      permission
      expect(@permission[:level]).to eq(1)
      sign_out
      sign_in(@user1)
      permission
      expect(@permission[:level]).to eq(2)
      sign_out
      sign_in(@user2)
      permission
      expect(@permission[:level]).to eq(3)
    end

    
 end
end
