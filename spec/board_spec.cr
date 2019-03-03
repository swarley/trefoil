require "./spec_helper"

describe Trefoil::Client do
  board_json = load_json("boards.json")
  describe "#boards" do
    WebMock.stub(:get, "https://a.4cdn.org/boards.json").to_return(status: 200, body: board_json)

    it "loads Boards from json" do
      board_client = Trefoil::Client.new
      boards = board_client.boards
      boards["a"].title.should eq "Anime & Manga"
    end

    it "loads troll flags from json" do
      flag_client = Trefoil::Client.new
      flags = flag_client.troll_flags
      flags["KN"].should eq "Kekistani"
    end

    it "caches troll flags and boards at the same time" do
      client = Trefoil::Client.new
      client.boards
      WebMock.reset
      # Requests are no longer stubbed
      client.boards["a"].title.should eq "Anime & Manga"
      client.troll_flags["KN"].should eq "Kekistani"
    end

    WebMock.reset
  end

  describe "#board" do
    WebMock.stub(:get, "https://a.4cdn.org/boards.json").to_return(status: 200, body: board_json)

    client = Trefoil::Client.new
    # Precache boards
    client.boards

    it "returns a Board object" do
      client.board("a").should be_a Trefoil::Board
    end

    it "uses cached board data for information if available" do
      board = client.board("a")
      board.info.should be_a Trefoil::BoardInfo
      info = board.info
      info.as(Trefoil::BoardInfo).name.should eq "a"
    end

    it "delegates getters to `@info`" do
      board = client.board("a")
      info = board.info
      raise "Error" if info.nil?

      info.title.should eq "Anime & Manga"
    end

    it "does not define `@info` if no board information is available" do
      board = client.board("foo")
      board.info.should be_nil
    end
  end
end

WebMock.reset
