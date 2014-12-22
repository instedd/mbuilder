require "spec_helper"

describe "pills" do
  let(:context) { nil }

  describe "literal pills" do
    subject(:pill) { Pills::LiteralPill.new('lorem', 'ipsum') }

    it "value_in to text" do
      expect(pill.value_in(context)).to eq(pill.text)
    end

    it ".as_json" do
      expect(pill.as_json).to eq({kind: 'literal', guid: 'lorem', text: 'ipsum'})
    end
  end

  shared_examples "can be restored from json" do
    it "pills_from_hash_of_pills" do
      plain_hash = hash.as_json.with_indifferent_access
      expect(Actions::Hub.pills_from_hash_of_pills(plain_hash)).to eq(hash)
    end
  end

  describe "hash of pills" do
    subject(:hash) {
      { "a" => Pills::LiteralPill.new('lorem', 'ipsum'),
        "b" => {
          "c" => Pills::LiteralPill.new('dolor', 'sit')
        }
      }
    }

    it "value_in to text" do
      expect(hash.value_in(context)).to eq({"a" => 'ipsum', "b" => { "c" => 'sit'}})
    end

    it ".as_json" do
      expect(hash.as_json).to eq({"a" => {kind: 'literal', guid: 'lorem', text: 'ipsum'}, "b" => { "c" => {kind: 'literal', guid: 'dolor', text: 'sit'}}})
    end

    it_behaves_like "can be restored from json"
  end

  describe "hash of pills empty" do
    # sample of initially empty open struct
    subject(:hash) {
      {
         "phone" => Pills::LiteralPill.new('lorem', 'ipsum'),
         "extra" =>{}
      }
    }

    it_behaves_like "can be restored from json"
  end
end
