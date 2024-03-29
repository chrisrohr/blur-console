class Search < ActiveRecord::Base
  belongs_to :blur_table
  belongs_to :user

  before_save :marshal_columns

  attr_accessor :column_object

  def blur_query
    b = Blur::BlurQuery.new( :simpleQuery  => Blur::SimpleQuery.new(:queryStr => query,
                      :superQueryOn => super_query?),
                      :fetch        => fetch,
                      :start        => offset,
                      :uuid         => Time.now.to_i*1000 + rand(1000),
                      :selector     => selector,
                      :userContext  => User.find(user_id).username)
    b.simpleQuery.postSuperFilter = post_filter if !post_filter.blank?
    b.simpleQuery.preSuperFilter = pre_filter if !pre_filter.blank?
    b
  end

  def column_object
    @column_object = @column_object || (columns ? JSON.parse(columns) : [])
  end

  def column_families
    column_object.collect{|value| value.split('_-sep-_')[1] if value.starts_with?('family')}.compact
  end

  def columns_hash
    # hash with key = column_family and value = array of columns
    # just columns without column families, and with 'recordId' added in
    families = column_families
    cols = {}
    column_object.each do |raw_column|
      parts = raw_column.split('_-sep-_')
      if parts[0] == 'column' and !families.include?(parts[1])
        cols[parts[1]] ||= ['recordId']
        cols[parts[1]] << parts[2]
      end
    end
    cols
  end

  def selector
    Blur::Selector.new  :columnFamiliesToFetch => column_families,
                        :columnsToFetch        => columns_hash,
                        :recordOnly            => record_only?
  end
  def fetch_results(table_name, blur_urls)
    BlurThriftClient.client(blur_urls).query(table_name, blur_query)
  end

  def schema(blur_table)
    tmp_schema = columns_hash
    tmp_schema.clone.each do |family,cols|
      cols.collect!{|v| {"name" => v}}
      tmp_schema[family] = {"name" => family, "columns" => cols}
    end
    column_families.each do |family|
      col_fam = blur_table.schema.select{|v| v['name'] == family}.first
      col_fam['columns'].insert(0,{"name" => 'recordId'})
      tmp_schema[family] = col_fam
    end
    tmp_schema.sort
  end

  private
  def marshal_columns
    write_attribute(:columns, column_object.to_json) if column_object
  end
end
