class UsersController < ApplicationController

  load_and_authorize_resource
  before_filter :find_user, :only => [:show, :edit, :update, :destroy, :save]
  skip_before_filter :current_zookeeper, :zookeepers

  def index
    @users = User.all
  end

  def show
    @tables = BlurTable.all
    @preferences = current_user.saved_cols
    @filters = current_user.saved_filters
    
    puts @filters.inspect
    
    @choices = []
    BlurTable.all.each do |table|
      @choices << table.schema.keys
    end
    @choices.flatten!.uniq!
    
    puts @preferences.inspect
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_path, :notice => "Successfully Created User"
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to @user, :notice  => "Successfully updated user."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, :notice => "Successfully destroyed user."
  end

  private

  def find_user
    @user = User.find(params[:id])
  end
end
