require 'spec_helper'

describe AdminDashboardData do

  describe "rails_env_check" do
    subject { AdminDashboardData.new.rails_env_check }

    it 'returns nil when running in production mode' do
      Rails.stubs(:env).returns('production')
      subject.should be_nil
    end

    it 'returns a string when running in development mode' do
      Rails.stubs(:env).returns('development')
      subject.should_not be_nil
    end

    it 'returns a string when running in test mode' do
      Rails.stubs(:env).returns('test')
      subject.should_not be_nil
    end
  end

  describe 'host_names_check' do
    subject { AdminDashboardData.new.host_names_check }

    it 'returns nil when host_names is set' do
      Discourse.stubs(:current_hostname).returns('something.com')
      subject.should be_nil
    end

    it 'returns a string when host_name is localhost' do
      Discourse.stubs(:current_hostname).returns('localhost')
      subject.should_not be_nil
    end

    it 'returns a string when host_name is production.localhost' do
      Discourse.stubs(:current_hostname).returns('production.localhost')
      subject.should_not be_nil
    end
  end

  describe 'gc_checks' do
    subject { AdminDashboardData.new.gc_checks }

    it 'returns nil when gc params are set' do
      ENV.stubs(:[]).with('RUBY_GC_MALLOC_LIMIT').returns(90000000)
      subject.should be_nil
    end

    it 'returns a string when gc params are not set' do
      ENV.stubs(:[]).with('RUBY_GC_MALLOC_LIMIT').returns(nil)
      subject.should_not be_nil
    end
  end

  describe 'clockwork_check' do
    subject { AdminDashboardData.new.clockwork_check }

    it 'returns nil when clockwork is running' do
      Jobs::ClockworkHeartbeat.stubs(:is_clockwork_running?).returns(true)
      subject.should be_nil
    end

    it 'returns a string when clockwork is not running' do
      Jobs::ClockworkHeartbeat.stubs(:is_clockwork_running?).returns(false)
      subject.should_not be_nil
    end
  end

  describe 'sidekiq_check' do
    subject { AdminDashboardData.new.sidekiq_check }

    it 'returns nil when sidekiq processed a job recently' do
      Jobs.stubs(:last_job_performed_at).returns(1.minute.ago)
      Jobs.stubs(:queued).returns(0)
      subject.should be_nil
    end

    it 'returns nil when last job processed was a long time ago, but no jobs are queued' do
      Jobs.stubs(:last_job_performed_at).returns(7.days.ago)
      Jobs.stubs(:queued).returns(0)
      subject.should be_nil
    end

    it 'returns nil when no jobs have ever been processed, but no jobs are queued' do
      Jobs.stubs(:last_job_performed_at).returns(nil)
      Jobs.stubs(:queued).returns(0)
      subject.should be_nil
    end

    it 'returns a string when no jobs were processed recently and some jobs are queued' do
      Jobs.stubs(:last_job_performed_at).returns(20.minutes.ago)
      Jobs.stubs(:queued).returns(1)
      subject.should_not be_nil
    end

    it 'returns a string when no jobs have ever been processed, and some jobs are queued' do
      Jobs.stubs(:last_job_performed_at).returns(nil)
      Jobs.stubs(:queued).returns(1)
      subject.should_not be_nil
    end
  end

  describe 'ram_check' do
    subject { AdminDashboardData.new.ram_check }

    it 'returns nil when total ram is 1 GB' do
      MemInfo.any_instance.stubs(:mem_total).returns(1025272)
      subject.should be_nil
    end

    it 'returns nil when total ram cannot be determined' do
      MemInfo.any_instance.stubs(:mem_total).returns(nil)
      subject.should be_nil
    end

    it 'returns a string when total ram is less than 1 GB' do
      MemInfo.any_instance.stubs(:mem_total).returns(512636)
      subject.should_not be_nil
    end
  end

end