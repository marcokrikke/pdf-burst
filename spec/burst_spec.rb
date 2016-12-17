require "spec_helper"

describe PDF::Burst do
   
  context "page count" do

    it "generates the command" do
      burst = PDF::Burst.new("my.pdf")
      expect(burst.send(:page_count_command)).to eq("pdfinfo 'my.pdf' | grep 'Pages:' | grep -o '[0-9].*'")
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
    allow(burst).to receive(:page_count).and_return(5)
    expect(burst).to receive(:system).exactly(5).times
    expect(burst).to receive(:burst_command).exactly(5).times
    burst.run!
  end

  it "runs the ghostscript burst command with a page offset" do
    burst = PDF::Burst.new("file.pdf", :initial_page_number => 4)
    allow(burst).to receive(:page_count).and_return(1)
    expect(burst).to receive(:system).exactly(1).times
    expect(burst).to receive(:burst_command).with(1, 1, 4)
    burst.run!
  end

  it "runs the ghostscript burst command with a bundle size of 2 (e.g. double sided paper)" do
    burst = PDF::Burst.new("file.pdf", :bundle_size => 2)
    allow(burst).to receive(:page_count).and_return(2)
    expect(burst).to receive(:system).exactly(1).times
    expect(burst).to receive(:burst_command).with(1, 2, 1)
    burst.run!
  end

  it "runs the ghostscript burst command with a bundle size of 2" do
    burst = PDF::Burst.new("file.pdf", :bundle_size => 2)
    allow(burst).to receive(:page_count).and_return(4)
    expect(burst).to receive(:system).exactly(2).times
    expect(burst).to receive(:burst_command).with(1, 2, 1)
    expect(burst).to receive(:burst_command).with(3, 4, 2)
    burst.run!
  end

  it "runs the ghostscript burst command with a bundle size larger than the number of pages" do
    burst = PDF::Burst.new("file.pdf", :bundle_size => 20)
    allow(burst).to receive(:page_count).and_return(1)
    expect(burst).to receive(:system).exactly(1).times
    expect(burst).to receive(:burst_command).with(1, 1, 1)
    burst.run!
  end

  it "runs the ghostscript burst command with a bundle size of 3 and 8 pages" do
    burst = PDF::Burst.new("file.pdf", :bundle_size => 3)
    allow(burst).to receive(:page_count).and_return(8)
    expect(burst).to receive(:system).exactly(3).times
    expect(burst).to receive(:burst_command).with(1, 3, 1)
    expect(burst).to receive(:burst_command).with(4, 6, 2)

    # Last page is double page
    expect(burst).to receive(:burst_command).with(7, 8, 3)
    burst.run!
  end

end
