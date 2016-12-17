require "spec_helper"

describe PDF::Burst do
   
  context "page count" do

    it "generates the command" do
      burst = PDF::Burst.new("my.pdf")
      expect(burst.send(:page_count_command)).to eq("pdfinfo 'my.pdf' | grep 'Pages:' | grep -oP '\\d+'")
    end
    
    it "is the correct number" do
      burst = PDF::Burst.new("my.pdf")
      expect(burst).to receive(:page_count_command) {"echo '128'"}
      expect(burst.page_count).to eq(128)
    end

  end

  context "page filename" do
    
    it "has a default" do
      burst = PDF::Burst.new("my.pdf")
      expect(burst.send(:page_filename, 11)).to eq("page_11.pdf")
    end

    it "is customizable" do
      burst = PDF::Burst.new("my.pdf", :filename => "my_pages.%04d")
      expect(burst.send(:page_filename, 13)).to eq("my_pages.0013.pdf")
    end

  end
  
  context "output file" do

    it "has a default path" do
      burst = PDF::Burst.new("my.pdf")
      expect(burst.send(:output_file_path, 2)).to eq("#{FileUtils.pwd}/page_2.pdf")
    end

    it "is customizable" do
      burst = PDF::Burst.new("magazine.pdf", :output => "/tmp/")
      expect(burst.send(:output_file_path, 4)).to eq("/tmp/page_4.pdf")
    end

  end

  it "runs the ghostscript burst command for each page" do
    burst = PDF::Burst.new("file.pdf")
    allow(burst).to receive(:page_count) { 5 }
    expect(burst).to receive(:system).exactly(5).times
    expect(burst).to receive(:burst_command).exactly(5).times
    burst.run!
  end

end
