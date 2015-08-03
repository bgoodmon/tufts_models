class TuftsDatastream < ActiveFedora::OmDatastream
#  include TuftsFileAssetsHelper

  def datastream_content
    begin
      options = {:pid => pid, :dsid => dsid}
      options[:asOfDateTime] = asOfDateTime if asOfDateTime

      @content ||= File.open(LocalPathService.local_datastream_path(self)).read

        #repository.datastream_dissemination options
    rescue RestClient::ResourceNotFound
    end

    content = @content.read and @content.rewind if @content.kind_of? IO
    content ||= @content
  end
end
