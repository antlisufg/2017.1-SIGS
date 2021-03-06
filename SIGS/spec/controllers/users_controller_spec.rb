require 'rails_helper'
include SessionsHelper

RSpec.describe UsersController, type: :controller do

  describe 'User new and create methods' do

    it 'should return new view' do
      get :new
      expect(response).to have_http_status(200)
    end

    it 'should create a new user' do
      post :create, params:{user: {name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'05601407380', active: true}}
      expect(flash[:notice]).to eq('Solicitação de cadastro efetuado com sucesso!')
      expect(User.count).to be(1)
    end

    it 'should not create a new user (wrong name)' do
      post :create, params:{user: {name: 'joao', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'05601407380', active: true}}
      expect(User.count).to be(0)
    end

    it 'should not create a new user (invalid unb email)' do
      post :create, params:{user: {name: 'joao silva', email: 'joaosilva@gmail.com',
        password: '123456', registration:'1100061', cpf:'05601407380', active: true}}
      expect(User.count).to be(0)
    end

    it 'should not create a new user (short password)' do
      post :create, params:{user: {name: 'joao silva', email: 'joaosilva@unb.br',
        password: '12345', registration:'1100061', cpf:'05601407380', active: true}}
      expect(User.count).to be(0)
    end

    it 'should not create a new user (invalid registration)' do
      post :create, params:{user: {name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'110006100', cpf:'05601407380', active: true}}
      expect(User.count).to be(0)
    end

    it 'should not create a new user (invalid cpf)' do
      post :create, params:{user: {name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'0560140738000', active: true}}
      expect(User.count).to be(0)
    end

    it 'should create a new department assistent user' do
      @department = Department.create(name: 'Departamento de Computação')
      post :create, params:{user: {name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'01505038137', active: false, department_assistant_attributes: {department_id: @department.id}}, type: 'department_assistant'}
      expect(User.count).to be(1)
      expect(DepartmentAssistant.count).to be(1)
    end

    it 'should create a new coordinator user' do
      @department = Department.create(name: 'Departamento de Computação')
      @course = Course.create(name: 'Engenharia de Software', department: @department)
      post :create, params:{user: {name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'01505038137', active: false, coordinator_attributes: {course_id: @course.id}}, type: 'coordinator'}
      expect(User.count).to be(1)
      expect(Coordinator.count).to be(1)
    end

    it 'should create a new administrarive assistant user' do
      post :create, params:{user: {name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'01505038137', active: false}, type: 'administrative_assistant'}
      expect(User.count).to be(1)
      expect(AdministrativeAssistant.count).to be(1)
    end
  end

  describe 'Edit method' do

    before(:each) do
      @user_edit = User.create(name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'05601407380', active: true)
      @user_adm = User.create(name: 'Luiz Guilherme', email: 'luiz@unb.br',
        password: '123456', registration:'1103061', cpf:'05601407350', active: true)
      @administrative_assistant = AdministrativeAssistant.create(user_id: @user_adm.id)
    end

    it 'should return edit user' do
      sign_in(@user_edit)
      get :edit, params:{id: @user_edit.id}
      expect(response).to have_http_status(200)
    end

    it 'should return to show current user if edit user id differ current user' do
      sign_in(@user_edit)
      get :edit, params:{id: @user_adm}
      expect(response).to redirect_to(current_user)
    end

  end

  describe 'Show methods' do

    before(:each) do
      @user = User.create(name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'05601407380', active: true)
      @department = Department.create(name: 'Departamento de Computação')
      @department_assistant = DepartmentAssistant.create(department_id: @department.id,user_id: @user.id)
      @user_adm = User.create(name: 'Luiz Guilherme', email: 'luiz@unb.br',
        password: '123456', registration:'1103061', cpf:'05601407350', active: true)
      @administrative_assistant = AdministrativeAssistant.create(user_id: @user_adm.id)
    end

    it 'should return current user show' do
      sign_in(@user)
      get :show, params:{id: @user.id}
      expect(response).to have_http_status(200)
    end

    it 'should return user show when administrative assistant access' do
      sign_in(@user_adm)
      get :show, params:{id: @user.id}
      expect(response).to have_http_status(200)
    end

    it 'should return current user show if show user id differ current user and current user isn\'t administrative asssistant' do
      sign_in(@user)
      get :show, params:{id: @user_adm.id}
      expect(response).to redirect_to(current_user)
    end

    it 'should return actives users' do
      sign_in(@user_adm)
      get :index
      expect(response).to have_http_status(200)
    end

    it 'should return to current user show if current user isn\'t administrative assistant ' do
      sign_in(@user)
      get :index
      expect(response).to redirect_to(current_user)
    end
  end


  describe 'Destroy method' do

    before(:each) do
      @user_1 = User.create(name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'05601407380', active: true)
      @department = Department.create(name: 'Departamento de Computação')
      @department_assistant = DepartmentAssistant.create(department_id: @department.id,user_id: @user_1.id)
      @user_2 = User.create(name: 'José Azevedo', email: 'jose@unb.br',
        password: '123456', registration:'1103361', cpf:'05603307380', active: true)
      @department_assistant = DepartmentAssistant.create(department_id: @department.id,user_id: @user_2.id)
      @user_adm = User.create(name: 'Luiz Guilherme', email: 'luiz@unb.br',
        password: '123456', registration:'1103061', cpf:'05601407350', active: true)
      @administrative_assistant = AdministrativeAssistant.create(user_id: @user_adm.id)
    end

    it 'should return current user show if user destroy id isn\'t current user' do
      sign_in(@user_1)
      get :destroy, params:{id: @user_2.id}
      expect(flash[:error]).to eq('Acesso Negado')
      expect(response).to redirect_to(current_user)
    end

    it 'should destroy user' do
      sign_in(@user_1)
      get :destroy, params:{id: @user_1.id}
      expect(flash[:success]).to eq('Usuário excluído com sucesso')
      expect(response).to redirect_to(sign_in_path)
    end

    it 'should destroy administrative user when it isn\'t unique' do
      @user_adm_2 = User.create(name: 'Lucas Carvalho', email: 'lucas@unb.br',
        password: '123456', registration:'2203061', cpf:'22601407350', active: true)
      @administrative_assistant = AdministrativeAssistant.create(user_id: @user_adm_2.id)
      sign_in(@user_adm)
      get :destroy, params:{id: @user_adm.id}
      expect(flash[:success]).to eq('Usuário excluído com sucesso')
      expect(response).to redirect_to(sign_in_path)
    end

    it 'should not destroy administrative user when it is unique' do
      sign_in(@user_adm)
      get :destroy, params:{id: @user_adm.id}
      expect(flash[:error]).to eq('Não é possível excluir o único Assistente Administrativo')
      expect(response).to redirect_to(current_user)
    end
  end

  describe 'Update method' do

    before(:each) do
      @user = User.create(name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'05601407380', active: true)
    end

    it "should update a user" do
      sign_in(@user)
      post :update, params:{id: @user.id,user: {name: 'Wallacy Braz'}}
      expect(flash.now[:success]).to eq('Dados atualizados com sucesso')
    end

    it "should not update a user" do
      sign_in(@user)
      post :update, params:{id: @user.id,user: {name: ''}}
      expect(response).to redirect_to(user_edit_path)
      expect(flash[:warning]).to eq("Dados não foram atualizados")
    end
  end
end
