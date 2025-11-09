# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/naming/method_name_get_prefix'

RSpec.describe RuboCop::Cop::Naming::MethodNameGetPrefix do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when method has get_ prefix with arguments' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def get_user(id)
            ^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `user_for` or `find_user` instead.
        end
      RUBY
    end

    it 'auto-corrects to _for pattern' do
      new_source = autocorrect_source(<<~RUBY)
        def get_user(id)
          User.find(id)
        end
      RUBY

      expect(new_source).to eq(<<~RUBY)
        def user_for(id)
          User.find(id)
        end
      RUBY
    end
  end

  context 'when method has get_ prefix without arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def get_user
          @user
        end
      RUBY
    end
  end

  context 'when method makes HTTP GET requests' do
    it 'does not register an offense for connection.get' do
      expect_no_offenses(<<~RUBY)
        def get_user(id)
          connection.get("/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for HTTP.get' do
      expect_no_offenses(<<~RUBY)
        def get_user(id)
          HTTP.get("https://api.example.com/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for Net::HTTP::Get.new' do
      expect_no_offenses(<<~RUBY)
        def get_checkout(id)
          request = Net::HTTP::Get.new(uri)
          http.request(request)
        end
      RUBY
    end

    it 'does not register an offense for http.request' do
      expect_no_offenses(<<~RUBY)
        def get_user(id)
          request = Net::HTTP::Get.new(uri)
          https.request(request)
        end
      RUBY
    end

    it 'does not register an offense for RestClient.get' do
      expect_no_offenses(<<~RUBY)
        def get_user(id)
          RestClient.get("https://api.example.com/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for Faraday.get' do
      expect_no_offenses(<<~RUBY)
        def get_user(id)
          Faraday.get("https://api.example.com/users/#{id}")
        end
      RUBY
    end
  end

  context 'when method is in API client file and calls get()' do
    it 'does not register an offense for client file' do
      expect_no_offenses(<<~RUBY, 'app/clients/user_client.rb')
        def get_user(id)
          get("/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for api_client file' do
      expect_no_offenses(<<~RUBY, 'lib/api_client.rb')
        def get_user(id)
          get("/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for controller file' do
      expect_no_offenses(<<~RUBY, 'app/controllers/users_controller.rb')
        def get_user(id)
          get("/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for file in /api/ directory' do
      expect_no_offenses(<<~RUBY, 'app/api/v1/users.rb')
        def get_user(id)
          get("/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for file in /clients/ directory' do
      expect_no_offenses(<<~RUBY, 'lib/clients/sendbird_client.rb')
        def get_user(id)
          get("/users/#{id}")
        end
      RUBY
    end
  end

  context 'when method has multiple arguments' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def get_db_line_item(order_id, line_item_id)
            ^^^^^^^^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `db_line_item_for` or `find_db_line_item` instead.
        end
      RUBY
    end

    it 'auto-corrects correctly' do
      new_source = autocorrect_source(<<~RUBY)
        def get_db_line_item(order_id, line_item_id)
          # implementation
        end
      RUBY

      expect(new_source).to eq(<<~RUBY)
        def db_line_item_for(order_id, line_item_id)
          # implementation
        end
      RUBY
    end
  end

  context 'when method has keyword arguments' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def get_user(id:, name:)
            ^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `user_for` or `find_user` instead.
        end
      RUBY
    end
  end

  context 'when method has block argument' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def get_user(id, &block)
            ^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `user_for` or `find_user` instead.
        end
      RUBY
    end
  end

  context 'edge cases' do
    it 'handles nested method definitions' do
      expect_offense(<<~RUBY)
        class UserService
          def get_user(id)
              ^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `user_for` or `find_user` instead.
            def helper_method
            end
          end
        end
      RUBY
    end

    it 'handles methods with complex bodies' do
      expect_offense(<<~RUBY)
        def get_user(id)
            ^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `user_for` or `find_user` instead.
          return nil if id.nil?
          User.find_by(id: id) || User.create(id: id)
        end
      RUBY
    end
  end
end
