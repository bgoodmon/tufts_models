class BatchesController < ApplicationController
  before_filter :build_batch, only: [:create]
  load_resource only: [:index, :show]
  authorize_resource

  def index
    @batches = @batches.order(created_at: :desc)
  end

  def create
    case params['batch']['type']
    when 'BatchPublish'
      handle_batch_publish
    when 'BatchTemplateUpdate'
      handle_apply_template
    else
      flash[:error] = 'Unable to handle batch request.'
      redirect_to (request.referer || root_path)
    end
  end

  def show
    @records_by_pid = ActiveFedora::Base.find(@batch.pids, cast: true).reduce({}) do |acc, record|
      acc.merge(record.id => record)
    end
  end


private

  def build_batch
    @batch = Batch.new(params.require(:batch).permit(:template_id, {pids: []}, :type))
  end

  def create_and_run_batch
    @batch.creator = current_user

    if @batch.save
      if @batch.run
        redirect_to batch_path(@batch)
      else
        flash[:error] = "Unable to run batch, please try again later."
        @batch.delete
        @batch = Batch.new @batch.attributes.except('id')
        render_new_or_redirect
      end
    else
      render_new_or_redirect  # form errors
    end
  end

  def render_new_or_redirect
    if @batch.type == 'BatchTemplateUpdate'
      render :new
    else
      redirect_to (request.referer || root_path)
    end
  end

  def no_pids_selected
    flash[:error] = 'Please select some records to do batch updates.'
    redirect_to (request.referer || root_path)
  end

  def handle_batch_publish
    if !@batch.pids.present?
      no_pids_selected
    else
      create_and_run_batch
    end
  end

  def handle_apply_template
    if !@batch.pids.present?
      no_pids_selected
    elsif params[:batch_form_page] == '1' && @batch.template_id.nil?
      render :new
    else
      create_and_run_batch
    end
  end

end
