require 'rspec'
require_relative 'lib/active_record_object'
require_relative 'lib/database'

describe ActiveRecordObject do
  before(:each) { Database.reset }
  before(:each) do
    class User < ActiveRecordObject
      has_many :conversations, :foreign_key => :sender_id
      self.finalize
    end
    class Conversation < ActiveRecordObject
      belongs_to :sender, :foreign_key => :sender_id, class_name: 'User'
      belongs_to :recipient, :foreign_key => :recipient_id, class_name: 'User'
      has_many :messages
      self.finalize
    end
    class Message < ActiveRecordObject
      belongs_to :conversation
      belongs_to :user
      self.finalize
    end
  end
  after(:each) { Database.reset }

  describe '::initialize' do
    it 'correctly sets attributes' do
      @user = User.new(:username => "Elliott")
      expect(@user.username).to eq "Elliott"
    end
  end

  describe '::finalize' do
      it "correctly implements getter" do
        @user = User.new
        @user.username = "Elliott"
        expect(@user.username).to eq "Elliott"
      end
      it "defines getters" do
        @user = User.new
        @user.username = "Elliott"
        expect(@user).to respond_to :username
      end
  end

  describe '#attributes' do
    it "doesn't return an empty attributes hash" do
      @user = User.new
      @user.username = "Elliott"
      expect(@user.attributes).to_not be_empty
    end
  end

  describe '::columns' do
    it "doesn't return an empty columns symbol array" do
      expect(User.columns.length).to be 5
    end
  end

  describe '::find' do
    it 'finds the second user' do
      user = User.find(2).first
      expect(user.username).to eq "Rafael"
    end
  end

  describe '::all' do
    it 'returns all rows' do
      all_users = User.all
      expect(all_users.length).to eq 3
    end
  end

  describe '#insert' do
    it 'inserts new user' do
      user_4 = User.new(:username => "Andy")
      user_4.save
      all_users = User.all
      expect(all_users.length).to eq 4
      expect(user_4.id).to eq 4
    end
  end

  describe '#update' do
    it 'updates first user' do
      user = User.find(1).first
      expect(user.username).to eq "Roger"
      user.username = "Elliott"
      expect(user.username).to eq "Elliott"
      user.save
      saved_user = User.find(1).first
      expect(saved_user.username).to eq "Elliott"
    end
  end

  describe '::where' do
    it 'finds Djokovic' do
      djokovic = User.where(:username => "Novak").first
      expect(djokovic.id).to eq 3
    end
  end

  describe 'Associations' do
    it 'returns the user for a given message' do
      nadal_message = Message.where(:body => "Rafa to Roger").first
      expect(nadal_message.user.username).to eq "Rafael"
    end
    it 'returns the messages of a conversation' do
      conversation = Conversation.find(1).first
      expect(conversation.messages.length).to eq 2
      expect(conversation.messages.first.body). to eq "Roger to Rafa"
    end
  end
end
