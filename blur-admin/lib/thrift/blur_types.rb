#
# Autogenerated by Thrift Compiler (0.7.0)
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#


module Blur
    module ScoreType
      # During a multi Record match, a calculation of the best match
      # Record plus how often it occurs within the match Row produces
      # the score that is used in the scoring of the SuperQuery.
      SUPER = 0
      # During a multi Record match, the aggregate score of all the
      # Records within a ColumnFamily is used in the scoring of the
      # SuperQuery.
      AGGREGATE = 1
      # During a multi Record match, the best score of all the
      # Records within a ColumnFamily is used in the scoring of the
      # SuperQuery.
      BEST = 2
      # A constant score of 1 is used in the scoring of the SuperQuery.
      CONSTANT = 3
      VALUE_MAP = {0 => "SUPER", 1 => "AGGREGATE", 2 => "BEST", 3 => "CONSTANT"}
      VALID_VALUES = Set.new([SUPER, AGGREGATE, BEST, CONSTANT]).freeze
    end

    module QueryState
      # Query is running.
      RUNNING = 0
      # Query has been interrupted.
      INTERRUPTED = 1
      # Query is complete.
      COMPLETE = 2
      VALUE_MAP = {0 => "RUNNING", 1 => "INTERRUPTED", 2 => "COMPLETE"}
      VALID_VALUES = Set.new([RUNNING, INTERRUPTED, COMPLETE]).freeze
    end

    module RowMutationType
      # Indicates that the entire Row is to be deleted.
      DELETE_ROW = 0
      # Indicates that the entire Row is to be deleted, and then a new
      # Row with the same id is to be added.
      REPLACE_ROW = 1
      # Indicates that mutations of the underlying Records will be
      # processed individually.
      UPDATE_ROW = 2
      VALUE_MAP = {0 => "DELETE_ROW", 1 => "REPLACE_ROW", 2 => "UPDATE_ROW"}
      VALID_VALUES = Set.new([DELETE_ROW, REPLACE_ROW, UPDATE_ROW]).freeze
    end

    module RecordMutationType
      # Indicates the Record with the given recordId in the given Row
      # is to be deleted.
      DELETE_ENTIRE_RECORD = 0
      # Indicates the Record with the given recordId in the given Row
      # is to be deleted, and a new Record with the same id is to be added.
      REPLACE_ENTIRE_RECORD = 1
      # Replace the columns that are specified in the Record mutation.
      REPLACE_COLUMNS = 2
      # Append the columns in the Record mutation to the Record that
      # could already exist.
      APPEND_COLUMN_VALUES = 3
      VALUE_MAP = {0 => "DELETE_ENTIRE_RECORD", 1 => "REPLACE_ENTIRE_RECORD", 2 => "REPLACE_COLUMNS", 3 => "APPEND_COLUMN_VALUES"}
      VALID_VALUES = Set.new([DELETE_ENTIRE_RECORD, REPLACE_ENTIRE_RECORD, REPLACE_COLUMNS, APPEND_COLUMN_VALUES]).freeze
    end

    # BlurException that carries a message plus the original stack
    # trace (if any).
    class BlurException < ::Thrift::Exception
      include ::Thrift::Struct, ::Thrift::Struct_Union
      MESSAGE = 1
      STACKTRACESTR = 2

      FIELDS = {
        # The message in the exception.
        MESSAGE => {:type => ::Thrift::Types::STRING, :name => 'message'},
        # The original stack trace (if any).
        STACKTRACESTR => {:type => ::Thrift::Types::STRING, :name => 'stackTraceStr'}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    # Column is the lowest storage element in Blur, it stores a single name and value pair.
    class Column
      include ::Thrift::Struct, ::Thrift::Struct_Union
      NAME = 1
      VALUE = 2

      FIELDS = {
        # The name of the column.
        NAME => {:type => ::Thrift::Types::STRING, :name => 'name'},
        # The value to be indexed and stored.
        VALUE => {:type => ::Thrift::Types::STRING, :name => 'value'}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    # Records contain a list of columns, multiple columns with the same name are allowed.
    class Record
      include ::Thrift::Struct, ::Thrift::Struct_Union
      RECORDID = 1
      FAMILY = 2
      COLUMNS = 3

      FIELDS = {
        # Record id uniquely identifies a record within a single row.
        RECORDID => {:type => ::Thrift::Types::STRING, :name => 'recordId'},
        # The family in which this record resides.
        FAMILY => {:type => ::Thrift::Types::STRING, :name => 'family'},
        # A list of columns, multiple columns with the same name are allowed.
        COLUMNS => {:type => ::Thrift::Types::LIST, :name => 'columns', :element => {:type => ::Thrift::Types::STRUCT, :class => ::Blur::Column}}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    # Rows contain a list of records.
    class Row
      include ::Thrift::Struct, ::Thrift::Struct_Union
      ID = 1
      RECORDS = 2
      RECORDCOUNT = 3

      FIELDS = {
        # The row id.
        ID => {:type => ::Thrift::Types::STRING, :name => 'id'},
        # The list records within the row.  If paging is used this list will only
        # reflect the paged records from the selector.
        RECORDS => {:type => ::Thrift::Types::LIST, :name => 'records', :element => {:type => ::Thrift::Types::STRUCT, :class => ::Blur::Record}},
        # The total record count for the row.  If paging is used in a selector to page
        # through records of a row, this count will reflect the entire row.
        RECORDCOUNT => {:type => ::Thrift::Types::I32, :name => 'recordCount'}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class Selector
      include ::Thrift::Struct, ::Thrift::Struct_Union
      RECORDONLY = 1
      LOCATIONID = 2
      ROWID = 3
      RECORDID = 4
      COLUMNFAMILIESTOFETCH = 5
      COLUMNSTOFETCH = 6
      ALLOWSTALEDATA = 7

      FIELDS = {
        RECORDONLY => {:type => ::Thrift::Types::BOOL, :name => 'recordOnly'},
        LOCATIONID => {:type => ::Thrift::Types::STRING, :name => 'locationId'},
        ROWID => {:type => ::Thrift::Types::STRING, :name => 'rowId'},
        RECORDID => {:type => ::Thrift::Types::STRING, :name => 'recordId'},
        COLUMNFAMILIESTOFETCH => {:type => ::Thrift::Types::SET, :name => 'columnFamiliesToFetch', :element => {:type => ::Thrift::Types::STRING}},
        COLUMNSTOFETCH => {:type => ::Thrift::Types::MAP, :name => 'columnsToFetch', :key => {:type => ::Thrift::Types::STRING}, :value => {:type => ::Thrift::Types::SET, :element => {:type => ::Thrift::Types::STRING}}},
        ALLOWSTALEDATA => {:type => ::Thrift::Types::BOOL, :name => 'allowStaleData'}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class FetchRowResult
      include ::Thrift::Struct, ::Thrift::Struct_Union
      ROW = 1

      FIELDS = {
        ROW => {:type => ::Thrift::Types::STRUCT, :name => 'row', :class => ::Blur::Row}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class FetchRecordResult
      include ::Thrift::Struct, ::Thrift::Struct_Union
      ROWID = 1
      RECORD = 2

      FIELDS = {
        ROWID => {:type => ::Thrift::Types::STRING, :name => 'rowid'},
        RECORD => {:type => ::Thrift::Types::STRUCT, :name => 'record', :class => ::Blur::Record}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class FetchResult
      include ::Thrift::Struct, ::Thrift::Struct_Union
      EXISTS = 1
      DELETED = 2
      TABLE = 3
      ROWRESULT = 4
      RECORDRESULT = 5

      FIELDS = {
        EXISTS => {:type => ::Thrift::Types::BOOL, :name => 'exists'},
        DELETED => {:type => ::Thrift::Types::BOOL, :name => 'deleted'},
        TABLE => {:type => ::Thrift::Types::STRING, :name => 'table'},
        ROWRESULT => {:type => ::Thrift::Types::STRUCT, :name => 'rowResult', :class => ::Blur::FetchRowResult},
        RECORDRESULT => {:type => ::Thrift::Types::STRUCT, :name => 'recordResult', :class => ::Blur::FetchRecordResult}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class SimpleQuery
      include ::Thrift::Struct, ::Thrift::Struct_Union
      QUERYSTR = 1
      SUPERQUERYON = 2
      TYPE = 3
      POSTSUPERFILTER = 4
      PRESUPERFILTER = 5

      FIELDS = {
        QUERYSTR => {:type => ::Thrift::Types::STRING, :name => 'queryStr'},
        SUPERQUERYON => {:type => ::Thrift::Types::BOOL, :name => 'superQueryOn', :default => true},
        TYPE => {:type => ::Thrift::Types::I32, :name => 'type', :default =>         0, :enum_class => ::Blur::ScoreType},
        POSTSUPERFILTER => {:type => ::Thrift::Types::STRING, :name => 'postSuperFilter'},
        PRESUPERFILTER => {:type => ::Thrift::Types::STRING, :name => 'preSuperFilter'}
      }

      def struct_fields; FIELDS; end

      def validate
        unless @type.nil? || ::Blur::ScoreType::VALID_VALUES.include?(@type)
          raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Invalid value of field type!')
        end
      end

      ::Thrift::Struct.generate_accessors self
    end

    class ExpertQuery
      include ::Thrift::Struct, ::Thrift::Struct_Union
      QUERY = 1
      FILTER = 2

      FIELDS = {
        QUERY => {:type => ::Thrift::Types::STRING, :name => 'query', :binary => true},
        FILTER => {:type => ::Thrift::Types::STRING, :name => 'filter', :binary => true}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class Facet
      include ::Thrift::Struct, ::Thrift::Struct_Union
      QUERYSTR = 1
      MINIMUMNUMBEROFBLURRESULTS = 2

      FIELDS = {
        QUERYSTR => {:type => ::Thrift::Types::STRING, :name => 'queryStr'},
        MINIMUMNUMBEROFBLURRESULTS => {:type => ::Thrift::Types::I64, :name => 'minimumNumberOfBlurResults', :default => 9223372036854775807}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class BlurQuery
      include ::Thrift::Struct, ::Thrift::Struct_Union
      SIMPLEQUERY = 1
      EXPERTQUERY = 2
      FACETS = 3
      SELECTOR = 4
      ALLOWSTALEDATA = 5
      USECACHEIFPRESENT = 6
      START = 7
      FETCH = 8
      MINIMUMNUMBEROFRESULTS = 9
      MAXQUERYTIME = 10
      UUID = 11
      USERCONTEXT = 12
      CACHERESULT = 13
      STARTTIME = 14
      MODIFYFILECACHES = 15

      FIELDS = {
        SIMPLEQUERY => {:type => ::Thrift::Types::STRUCT, :name => 'simpleQuery', :class => ::Blur::SimpleQuery},
        EXPERTQUERY => {:type => ::Thrift::Types::STRUCT, :name => 'expertQuery', :class => ::Blur::ExpertQuery},
        FACETS => {:type => ::Thrift::Types::LIST, :name => 'facets', :element => {:type => ::Thrift::Types::STRUCT, :class => ::Blur::Facet}},
        SELECTOR => {:type => ::Thrift::Types::STRUCT, :name => 'selector', :class => ::Blur::Selector},
        ALLOWSTALEDATA => {:type => ::Thrift::Types::BOOL, :name => 'allowStaleData', :default => false},
        USECACHEIFPRESENT => {:type => ::Thrift::Types::BOOL, :name => 'useCacheIfPresent', :default => true},
        START => {:type => ::Thrift::Types::I64, :name => 'start', :default => 0},
        FETCH => {:type => ::Thrift::Types::I32, :name => 'fetch', :default => 10},
        MINIMUMNUMBEROFRESULTS => {:type => ::Thrift::Types::I64, :name => 'minimumNumberOfResults', :default => 9223372036854775807},
        MAXQUERYTIME => {:type => ::Thrift::Types::I64, :name => 'maxQueryTime', :default => 9223372036854775807},
        UUID => {:type => ::Thrift::Types::I64, :name => 'uuid'},
        USERCONTEXT => {:type => ::Thrift::Types::STRING, :name => 'userContext'},
        CACHERESULT => {:type => ::Thrift::Types::BOOL, :name => 'cacheResult', :default => true},
        STARTTIME => {:type => ::Thrift::Types::I64, :name => 'startTime', :default => 0},
        MODIFYFILECACHES => {:type => ::Thrift::Types::BOOL, :name => 'modifyFileCaches', :default => true}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class BlurResult
      include ::Thrift::Struct, ::Thrift::Struct_Union
      LOCATIONID = 1
      SCORE = 2
      FETCHRESULT = 3

      FIELDS = {
        LOCATIONID => {:type => ::Thrift::Types::STRING, :name => 'locationId'},
        SCORE => {:type => ::Thrift::Types::DOUBLE, :name => 'score'},
        FETCHRESULT => {:type => ::Thrift::Types::STRUCT, :name => 'fetchResult', :class => ::Blur::FetchResult}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class BlurResults
      include ::Thrift::Struct, ::Thrift::Struct_Union
      TOTALRESULTS = 1
      SHARDINFO = 2
      RESULTS = 3
      FACETCOUNTS = 4
      EXCEPTIONS = 5
      QUERY = 6

      FIELDS = {
        TOTALRESULTS => {:type => ::Thrift::Types::I64, :name => 'totalResults', :default => 0},
        SHARDINFO => {:type => ::Thrift::Types::MAP, :name => 'shardInfo', :key => {:type => ::Thrift::Types::STRING}, :value => {:type => ::Thrift::Types::I64}},
        RESULTS => {:type => ::Thrift::Types::LIST, :name => 'results', :element => {:type => ::Thrift::Types::STRUCT, :class => ::Blur::BlurResult}},
        FACETCOUNTS => {:type => ::Thrift::Types::LIST, :name => 'facetCounts', :element => {:type => ::Thrift::Types::I64}},
        EXCEPTIONS => {:type => ::Thrift::Types::LIST, :name => 'exceptions', :element => {:type => ::Thrift::Types::STRUCT, :class => ::Blur::BlurException}},
        QUERY => {:type => ::Thrift::Types::STRUCT, :name => 'query', :class => ::Blur::BlurQuery}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class RecordMutation
      include ::Thrift::Struct, ::Thrift::Struct_Union
      RECORDMUTATIONTYPE = 1
      RECORD = 2

      FIELDS = {
        RECORDMUTATIONTYPE => {:type => ::Thrift::Types::I32, :name => 'recordMutationType', :enum_class => ::Blur::RecordMutationType},
        RECORD => {:type => ::Thrift::Types::STRUCT, :name => 'record', :class => ::Blur::Record}
      }

      def struct_fields; FIELDS; end

      def validate
        unless @recordMutationType.nil? || ::Blur::RecordMutationType::VALID_VALUES.include?(@recordMutationType)
          raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Invalid value of field recordMutationType!')
        end
      end

      ::Thrift::Struct.generate_accessors self
    end

    class RowMutation
      include ::Thrift::Struct, ::Thrift::Struct_Union
      TABLE = 1
      ROWID = 2
      WAL = 3
      ROWMUTATIONTYPE = 4
      RECORDMUTATIONS = 5

      FIELDS = {
        TABLE => {:type => ::Thrift::Types::STRING, :name => 'table'},
        ROWID => {:type => ::Thrift::Types::STRING, :name => 'rowId'},
        WAL => {:type => ::Thrift::Types::BOOL, :name => 'wal', :default => true},
        ROWMUTATIONTYPE => {:type => ::Thrift::Types::I32, :name => 'rowMutationType', :enum_class => ::Blur::RowMutationType},
        RECORDMUTATIONS => {:type => ::Thrift::Types::LIST, :name => 'recordMutations', :element => {:type => ::Thrift::Types::STRUCT, :class => ::Blur::RecordMutation}}
      }

      def struct_fields; FIELDS; end

      def validate
        unless @rowMutationType.nil? || ::Blur::RowMutationType::VALID_VALUES.include?(@rowMutationType)
          raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Invalid value of field rowMutationType!')
        end
      end

      ::Thrift::Struct.generate_accessors self
    end

    class CpuTime
      include ::Thrift::Struct, ::Thrift::Struct_Union
      CPUTIME = 1
      REALTIME = 2

      FIELDS = {
        CPUTIME => {:type => ::Thrift::Types::I64, :name => 'cpuTime'},
        REALTIME => {:type => ::Thrift::Types::I64, :name => 'realTime'}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class BlurQueryStatus
      include ::Thrift::Struct, ::Thrift::Struct_Union
      QUERY = 1
      CPUTIMES = 2
      COMPLETESHARDS = 3
      TOTALSHARDS = 4
      STATE = 5
      UUID = 6

      FIELDS = {
        QUERY => {:type => ::Thrift::Types::STRUCT, :name => 'query', :class => ::Blur::BlurQuery},
        CPUTIMES => {:type => ::Thrift::Types::MAP, :name => 'cpuTimes', :key => {:type => ::Thrift::Types::STRING}, :value => {:type => ::Thrift::Types::STRUCT, :class => ::Blur::CpuTime}},
        COMPLETESHARDS => {:type => ::Thrift::Types::I32, :name => 'completeShards'},
        TOTALSHARDS => {:type => ::Thrift::Types::I32, :name => 'totalShards'},
        STATE => {:type => ::Thrift::Types::I32, :name => 'state', :enum_class => ::Blur::QueryState},
        UUID => {:type => ::Thrift::Types::I64, :name => 'uuid'}
      }

      def struct_fields; FIELDS; end

      def validate
        unless @state.nil? || ::Blur::QueryState::VALID_VALUES.include?(@state)
          raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Invalid value of field state!')
        end
      end

      ::Thrift::Struct.generate_accessors self
    end

    class TableStats
      include ::Thrift::Struct, ::Thrift::Struct_Union
      TABLENAME = 1
      BYTES = 2
      RECORDCOUNT = 3
      ROWCOUNT = 4
      QUERIES = 5

      FIELDS = {
        TABLENAME => {:type => ::Thrift::Types::STRING, :name => 'tableName'},
        BYTES => {:type => ::Thrift::Types::I64, :name => 'bytes'},
        RECORDCOUNT => {:type => ::Thrift::Types::I64, :name => 'recordCount'},
        ROWCOUNT => {:type => ::Thrift::Types::I64, :name => 'rowCount'},
        QUERIES => {:type => ::Thrift::Types::I64, :name => 'queries'}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class Schema
      include ::Thrift::Struct, ::Thrift::Struct_Union
      TABLE = 1
      COLUMNFAMILIES = 2

      FIELDS = {
        TABLE => {:type => ::Thrift::Types::STRING, :name => 'table'},
        COLUMNFAMILIES => {:type => ::Thrift::Types::MAP, :name => 'columnFamilies', :key => {:type => ::Thrift::Types::STRING}, :value => {:type => ::Thrift::Types::SET, :element => {:type => ::Thrift::Types::STRING}}}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class AlternateColumnDefinition
      include ::Thrift::Struct, ::Thrift::Struct_Union
      ANALYZERCLASSNAME = 1

      FIELDS = {
        ANALYZERCLASSNAME => {:type => ::Thrift::Types::STRING, :name => 'analyzerClassName'}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class ColumnDefinition
      include ::Thrift::Struct, ::Thrift::Struct_Union
      ANALYZERCLASSNAME = 1
      FULLTEXTINDEX = 2
      ALTERNATECOLUMNDEFINITIONS = 3

      FIELDS = {
        ANALYZERCLASSNAME => {:type => ::Thrift::Types::STRING, :name => 'analyzerClassName'},
        FULLTEXTINDEX => {:type => ::Thrift::Types::BOOL, :name => 'fullTextIndex'},
        ALTERNATECOLUMNDEFINITIONS => {:type => ::Thrift::Types::MAP, :name => 'alternateColumnDefinitions', :key => {:type => ::Thrift::Types::STRING}, :value => {:type => ::Thrift::Types::STRUCT, :class => ::Blur::AlternateColumnDefinition}}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class ColumnFamilyDefinition
      include ::Thrift::Struct, ::Thrift::Struct_Union
      DEFAULTDEFINITION = 1
      COLUMNDEFINITIONS = 2

      FIELDS = {
        DEFAULTDEFINITION => {:type => ::Thrift::Types::STRUCT, :name => 'defaultDefinition', :class => ::Blur::ColumnDefinition},
        COLUMNDEFINITIONS => {:type => ::Thrift::Types::MAP, :name => 'columnDefinitions', :key => {:type => ::Thrift::Types::STRING}, :value => {:type => ::Thrift::Types::STRUCT, :class => ::Blur::ColumnDefinition}}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class AnalyzerDefinition
      include ::Thrift::Struct, ::Thrift::Struct_Union
      DEFAULTDEFINITION = 1
      FULLTEXTANALYZERCLASSNAME = 2
      COLUMNFAMILYDEFINITIONS = 3

      FIELDS = {
        DEFAULTDEFINITION => {:type => ::Thrift::Types::STRUCT, :name => 'defaultDefinition', :class => ::Blur::ColumnDefinition},
        FULLTEXTANALYZERCLASSNAME => {:type => ::Thrift::Types::STRING, :name => 'fullTextAnalyzerClassName'},
        COLUMNFAMILYDEFINITIONS => {:type => ::Thrift::Types::MAP, :name => 'columnFamilyDefinitions', :key => {:type => ::Thrift::Types::STRING}, :value => {:type => ::Thrift::Types::STRUCT, :class => ::Blur::ColumnFamilyDefinition}}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class TableDescriptor
      include ::Thrift::Struct, ::Thrift::Struct_Union
      ISENABLED = 1
      ANALYZERDEFINITION = 2
      SHARDCOUNT = 3
      TABLEURI = 4
      COMPRESSIONCLASS = 5
      COMPRESSIONBLOCKSIZE = 6
      CLUSTER = 7
      NAME = 8

      FIELDS = {
        ISENABLED => {:type => ::Thrift::Types::BOOL, :name => 'isEnabled', :default => true},
        ANALYZERDEFINITION => {:type => ::Thrift::Types::STRUCT, :name => 'analyzerDefinition', :class => ::Blur::AnalyzerDefinition},
        SHARDCOUNT => {:type => ::Thrift::Types::I32, :name => 'shardCount', :default => 1},
        TABLEURI => {:type => ::Thrift::Types::STRING, :name => 'tableUri'},
        COMPRESSIONCLASS => {:type => ::Thrift::Types::STRING, :name => 'compressionClass', :default => %q"org.apache.hadoop.io.compress.DefaultCodec"},
        COMPRESSIONBLOCKSIZE => {:type => ::Thrift::Types::I32, :name => 'compressionBlockSize', :default => 32768},
        CLUSTER => {:type => ::Thrift::Types::STRING, :name => 'cluster'},
        NAME => {:type => ::Thrift::Types::STRING, :name => 'name'}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

  end
