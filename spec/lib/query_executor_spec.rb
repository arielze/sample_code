require 'spec_helper'
require './lib/query_executor'


describe QueryExecutor do


  context ".extract_aggregated_events_fields" do
    it "should handle single aggregations" do
      data = '{
                "aggregations": {
                  "aab": {
                    "doc_count": 0,
                    "aab_inner": {
                      "value": 10
                    }
                  }
                }
              }'
      data = JSON.parse data
      result = {'aab' => 10}
      expect(QueryExecutor.extract_aggregated_events_fields(data['aggregations'])).to eq result
    end

    it "should handle single aggregations" do
      data = '{
                "aggregations": {
                  "aab": {
                    "doc_count": 0,
                    "aab_inner": {
                      "value": 10
                    }
                  },

                  "aac": {
                    "doc_count": 0,
                    "aac_inner": {
                      "value": 13
                    }
                  }
                }
              }'
      data = JSON.parse data
      result = {'aab' => 10, 'aac' => 13}
      expect(QueryExecutor.extract_aggregated_events_fields(data['aggregations'])).to eq result
    end
  end

  context ".extract_device_data" do
    it "should parse the result" do
      device_fields = {'time' => 0, 'device_id' => '089ff228-57a2-4218-bedb-5903e3c39cda', 'app_installation_time' => 123456}
      data = '
              {
                "aggregations": {
                  "aab": {
                    "doc_count": 0,
                    "aab_inner": {
                      "value": 10
                    }
                  },

                  "aac": {
                    "doc_count": 0,
                    "aac_inner": {
                      "value": 13
                    }
                  }
                }
              }'
      data = JSON.parse data
      result = {'aab' => 10, 'aac' => 13, 'time' => 0, "app_installation_time" => 123456, 'device_id' => '089ff228-57a2-4218-bedb-5903e3c39cda'}
      expect(QueryExecutor.extract_device_data(device_fields, data['aggregations'])).to eql result 

    end

  end

  context ".parse_result" do
    it "should parse the result" do
      device_fields = {'time' => '0', 'device_id' => '089ff228-57a2-4218-bedb-5903e3c39cda', 'app_installation_time' => 123456}
      data = '
      {
        "took": 108701,
        "timed_out": false,
        "_shards": {
        "total": 6,
        "successful": 5

        },
        "hits": {
        "total": 50121073,
        "max_score": 0,
        "hits": [ ]
        },
        "aggregations": {
          "aab": {
            "doc_count": 0,
            "aab_inner": {
              "value": 10
            }
          },

          "aac": {
            "doc_count": 0,
            "aac_inner": {
              "value": 13
            }
          }
        }
      }'
      data = JSON.parse data
      post_process = "((aab < 15) and (aac > 10))"
      result = {:result=>true, :data_bject=>{"time"=>"0", "device_id"=>"089ff228-57a2-4218-bedb-5903e3c39cda", "app_installation_time"=>123456, "aab"=>10, "aac"=>13}}
      expect(QueryExecutor.parse_result(device_fields, data, post_process)).to eql result 

    end

  end

  context ".apply_logic" do
    it "should return true" do
      data_obj = {'aab' => 10, 'aac' => 13, 'time' => '0', 'device_id' => '089ff228-57a2-4218-bedb-5903e3c39cda'}
      post_process = "((aab < 15) and (aac > 10))"
      expect(QueryExecutor.apply_logic(post_process, data_obj)).to be true
    end

    it "should return false" do
      data_obj = {'aab' => 10, 'aac' => 13, 'time' => '0', 'device_id' => '089ff228-57a2-4218-bedb-5903e3c39cda'}
      post_process = "((aab < 15) and (aac < 10))"
      expect(QueryExecutor.apply_logic(post_process, data_obj)).to be false
    end
  end
end

