module PDF
  class Burst
    def initialize(pdf_path, options={})
      @pdf_path = pdf_path
      @output_path = options[:output] || "."
      @page_name = options[:filename] || "page_%d"
      @initial_page_number = options[:initial_page_number] || 1
    end
    
    def run!
      page_count.times do |i|
        system burst_command(@initial_page_number + i)
      end
    end
    
    def page_count
      `#{page_count_command}`.to_i
    end
    
    private
    
    def page_count_command
      "pdfinfo '#{@pdf_path}' | grep 'Pages:' | grep -oP '\\d+'"
    end
    
    def burst_command(page_number)
      "gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dFirstPage=#{page_number} -dAutoFilterColorImages=false -dAutoFilterGrayImage=false -dColorImageFilter=/FlateEncode -dLastPage=#{page_number} -sOutputFile='#{output_file_path(page_number)}' '#{@pdf_path}'"
    end    
    
    def page_filename(page_number, extension="pdf")
      @page_name % page_number + ".#{extension}"
    end
    
    def output_file_path(page_number, extension="pdf")
      File.expand_path("#{@output_path}/#{page_filename(page_number, extension)}")
    end
  end
end
