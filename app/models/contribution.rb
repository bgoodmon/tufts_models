class Contribution
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  

  ATTRIBUTES = [:title, :abstract, :creator, :contributor, :bibliographic_citation, :subject, :attachment, :other_authors, :license]
  attr_accessor *ATTRIBUTES


  validates :title, presence: true, length: {maximum: 250}
  validates :abstract, presence: true, length: {maximum: 2000}
  validates :creator, presence: true
  validates :attachment, presence: true

  SELFDEP = 'selfdep'.freeze

  def persisted?
    false
  end

  def tufts_pdf
    return @tufts_pdf if @tufts_pdf
    @tufts_pdf = TuftsPdf.new(pid: Sequence.next_val)
    (ATTRIBUTES - [:attachment, :other_authors]).each do |attribute|
      @tufts_pdf.send("#{attribute}=", send(attribute))
    end
    @tufts_pdf.note = "#{creator} self-deposited on #{Time.now.strftime('%Y-%m-%d at %H:%M:%S %Z')} using the Deposit Form for the Tufts Digital Library"
    @tufts_pdf.creator += [other_authors] if other_authors
    @tufts_pdf.createdby = SELFDEP
    @tufts_pdf.steward = 'dca'
    @tufts_pdf.displays = 'dl'
    @tufts_pdf.publisher = 'Digital Collections and Archives, Tufts University'
    @tufts_pdf.rights = 'http://dca.tufts.edu/ua/access/rights-creator.html'
    @tufts_pdf.format = 'application/pdf'
    @tufts_pdf.date_available = @tufts_pdf.date_submitted = Time.now.to_s

    @tufts_pdf
  end

  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end

  def save
    return false unless valid?
    tufts_pdf.save!
    tufts_pdf.store_archival_file('Archival.pdf', attachment)
    tufts_pdf.save!
    tufts_pdf
  end

  def self.create(attrs)
    form = self.new(attrs)
    form.save
  end

end
