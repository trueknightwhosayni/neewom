require 'rails_helper'

RSpec.describe Neewom::Collection do
  describe "self.serialize" do
    specify do
      expect(described_class.serialize(24.0)).to eq("neewom|value|24.0")
    end

    specify do
      expect(described_class.serialize(" my_name ", "strip.camelize")).to eq("neewom|value|\" my_name \"|mods:strip.camelize")
    end
  end

  describe "self.deserialize" do
    specify do
      expect(described_class.deserialize("neewom|value|24.0")).to eq(24.0)
    end

    specify do
      expect(described_class.deserialize("neewom|value|\" my_name \"|mods:strip.camelize")).to eq("MyName")
    end
  end

  describe "self.build_for_field" do
    class ViewContext
      def current_user
        'Bruce Wayne'
      end

      def render(field)
        field.build_collection(binding)
      end
    end

    class CollectionBuilder
      def self.called_method(*args)
        args
      end
    end

    context "when collection specified" do
      let(:field) do
        Neewom::AbstractField.new.tap do |f|
          f.collection = [1, 2, 3]
        end
      end

      it 'returns the collection data' do
        expect(ViewContext.new.render(field)).to eq([1, 2, 3])
      end
    end

    context "when collection dynamic" do
      let(:field) do
        Neewom::AbstractField.new.tap do |f|
          f.collection_klass = 'CollectionBuilder'
          f.collection_method = 'called_method'
          f.collection_params = ["neewom|value|24.0", :current_user]
        end
      end

      it 'uses the collection class to build the data' do
        expect(ViewContext.new.render(field)).to eq([24.0, 'Bruce Wayne'])
      end
    end
  end
end
