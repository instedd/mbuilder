require "spec_helper"

describe User do
  describe 'telemetry' do
    it 'updates the user lifespan when created' do
      user = User.make_unsaved

      Telemetry::Lifespan.should_receive(:touch_user).with(user)

      user.save
    end

    it 'updates the user lifespan when updated' do
      user = User.make

      Telemetry::Lifespan.should_receive(:touch_user).with(user)

      user.touch
      user.save
    end

    it 'updates the user lifespan when destroyed' do
      user = User.make

      Telemetry::Lifespan.should_receive(:touch_user).with(user)

      user.destroy
    end
  end
end
