class DcaAdmin < ActiveFedora::OmDatastream
  DCMI_TYPE = 'http://purl.org/dc/dcmitype/'
  DCA_ADMIN = 'http://nils.lib.tufts.edu/dcaadmin/'
  set_terminology do |t|
    t.root(:path => "admin", 'xmlns:local' => DCA_ADMIN, 'xmlns:ac' => DCMI_TYPE)

    t.template_name namespace_prefix: "local", index_as: :stored_searchable, path: 'templateName'
    t.steward namespace_prefix: "local", index_as: :stored_searchable
    t.name namespace_prefix: "ac", index_as: :stored_searchable
    t.comment namespace_prefix: "ac", index_as: :stored_searchable
    t.retentionPeriod namespace_prefix: "local", index_as: :stored_searchable
    t.displays namespace_prefix: "local", index_as: [:stored_sortable, :symbol]
    t.embargo namespace_prefix: "local", index_as: :dateable
    t.status namespace_prefix: "local", index_as: :stored_searchable
    t.startDate namespace_prefix: "local", index_as: :stored_searchable
    t.expDate namespace_prefix: "local", index_as: :stored_searchable
    t.qrStatus namespace_prefix: "local", index_as: [:stored_searchable, :facetable]
    t.rejectionReason namespace_prefix: "local", index_as: :stored_searchable
    t.note namespace_prefix: "local", index_as: :stored_searchable
    t.createdby namespace_prefix: "local"

    t.published_at namespace_prefix: "local", path: "publishedAt", type: :time, index_as: :stored_sortable
    t.edited_at namespace_prefix: "local", path: "editedAt", type: :time, index_as: :stored_sortable
    t.creatordept namespace_prefix: "local"
    t.batch_id namespace_prefix: "local", index_as: :symbol, :path => 'batchID'
  end

  # BUG?  Extra solr fields are generated when there is a default namespace (xmlns) declared on the root.
  #   compared to when the root has a namespace and the child elements do not have an namespace.

  def self.xml_template
    Nokogiri::XML("<admin xmlns:local=\"#{DCA_ADMIN}\" xmlns:ac=\"#{DCMI_TYPE}\"/>")
  end

  # This is the prefix for all of the generated solr fields
  def prefix
    ""
  end

  def term_values_append(opts={})
    ensure_local_namespace_exists!
    ensure_ac_namespace_exists!
    super
  end

  private

    # TDL staff decided to change from having a default namespace to a prefixed namespace.
    # This method ensures the prefixed namespace is added to the document
    def ensure_local_namespace_exists!
      unless ng_xml.namespaces.key? 'xmlns:local'
        ng_xml.root.add_namespace_definition('local', DCA_ADMIN)
      end
    end

    # TDL staff decided to add a namespace/terms that aren't on all existing documents.
    # This method ensures the prefixed namespace is added to the document
    def ensure_ac_namespace_exists!
      unless ng_xml.namespaces.key? 'xmlns:ac'
        ng_xml.root.add_namespace_definition('ac', DCMI_TYPE)
      end
    end

end
