class AgentsController < ApplicationController

  def index
    @agents = Agent.all
  end

  def show
    @agent = Agent.find(params[:id])
  end

  def update
    @agent = Agent.find(params[:id])
    if @agent.update_attributes(params[:agent])
      redirect_to agents_path, :notice => "Agent updated."
    else
      redirect_to agents_path, :alert => "Unable to update agent."
    end
  end

  def destroy
    agent = Agent.find(params[:id])
    agent.destroy
    redirect_to agents_path, :notice => "Agent deleted."
  end
end