class ChannelsController < MbuilderApplicationController
  expose(:application) { current_user.applications.find params[:application_id] }
  expose(:channels) { application.channels }
  expose(:channel)
  before_filter do
    add_breadcrumb 'Channels', application_channels_path(application)
  end
  set_application_tab :channels

  def new
    add_breadcrumb 'New channel'
    if params[:kind].blank?
      render 'new_kind_choose'
    else
      @pigeon_channel = Pigeon::NuntiumChannel.new kind: params[:kind]
    end
  end

  def edit
    add_breadcrumb channel.name
    @pigeon_channel = Pigeon::NuntiumChannel.find(channel.pigeon_name)
  end

  def create
    @pigeon_channel = Pigeon::NuntiumChannel.new kind: params[:kind],
      at_rules: [{
        'matchings' => [],
        'actions' => [{ 'property' => 'mbuilder-application', 'value' => application.id }],
        'stop' => false
      }],
      restrictions:
        [{ 'name' => 'mbuilder-application', 'value' => application.id }],
      name: "mbuilder_#{Time.now.strftime("%Y%m%d%H%M%S")}"
    channel.pigeon_name = @pigeon_channel.name
    channel.kind = @pigeon_channel.kind

    if save_channels
      redirect_to application_channels_path(application)
    else
      render :new
    end
  end

  def update
    @pigeon_channel = Pigeon::NuntiumChannel.find(channel.pigeon_name)

    if save_channels
      redirect_to application_channels_path(application)
    else
      render :edit
    end
  end

  def destroy
    @pigeon_channel = Pigeon::NuntiumChannel.find(channel.pigeon_name)
    @pigeon_channel.destroy
    if @pigeon_channel.destroyed?
      channel.destroy
      redirect_to application_channels_path
    else
      redirect_to application_channels_path, alert: @pigeon_channel.errors.full_messages.join
    end
  end

  private

  def save_channels
    @pigeon_channel.assign_attributes params[:channel_data]
    channel.attributes = params[:channel]

    begin
      channel.transaction do
        @pigeon_channel.save!
        channel.save!
      end

      true
    rescue ActiveRecord::RecordInvalid, Pigeon::ChannelInvalid
      false
    end
  end
end
