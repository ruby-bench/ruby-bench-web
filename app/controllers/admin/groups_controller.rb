class Admin::GroupsController < ApplicationController
  http_basic_authenticate_with(
    name: 'admin',
    password: Rails.application.secrets.admin_password
  ) unless Rails.env.test?

  layout 'admin'

  before_action :set_repos, :set_admin
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def edit
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to admin_groups_url, notice: "#{@group.name} group was successfully created."
    else
      render :new
    end
  end

  def update
    if @group.update(group_params)
      redirect_to admin_groups_url, notice: "#{@group.name} group was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to admin_groups_url, notice: "#{@group.name} group was successfully destroyed."
  end

  private

  def set_repos
    @repos = Repo.all
  end

  def set_admin
    session['admin'] = true unless session['admin']
  end

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :description, :benchmark_types)
  end
end
