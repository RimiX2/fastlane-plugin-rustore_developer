describe Fastlane::Actions::RuStoreDeveloperAuthAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The ru_store_developer plugin is working!")

      Fastlane::Actions::RuStoreDeveloperAuthAction.run(nil)
    end
  end
end
