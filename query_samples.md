curl dockerhost:9200/tests/_search?pretty -d '{ "query": {"bool":{ "must": [{"match":{"age":35}}, {"has_child": {"type": "row", "query":{ "match":{"test": "1"}}}}]}}}'

curl dockerhost:9200/tests/_search?pretty -d '{ "query": {"match":{"age":35}}, "filter": {"has_child": {"type": "row", "query":{ "match":{"test": "1"}}}}}}'

curl dockerhost:9200/tests/_search?pretty -d '{ "query": {"has_child": {"type": "row", "query":{ "match":{"test": "1"}}}}, "filter": {"term":{"age":35}}}'

```json
{
  "aggs": {
    "top": {
      "filter": {
        "and": [
          {
            "regexp": {
              "properties.app_package_name": ".*gingersoftware.*"
            }
          },
          {
            "has_child": {
              "type": "events",
              "query": {
                "terms": {
                  "event_name": [
                    "Swipe Distance",
                    "Emojie Used"
                  ]
                }
              }
            }
          }
        ]
      },
      "aggs": {
        "devices": {
          "terms": {
            "field": "properties.device_id",
            "order": {
              "total_emojies": "desc",
              "total_swipe": "desc"
            },
            "size": 1000
          },
          "aggs": {
            "total_swipe": {
              "filter": {
                "and": [
                  {
                    "term": {
                      "events.event_name": "Swipe Distance"
                    }
                  },
                  {
                    "range": {
                      "events.event_date": {
                        "lte": "2015-05-15"
                      }
                    }
                  }
                ]
              },
              "aggs": {
                "sum_swipe": {
                  "sum": {
                    "field": "events.numeric_value"
                  }
                }
              }
            },
            "total_emojies": {
              "filter": {
                "and": [
                  {
                    "term": {
                      "event_name": "Emojie Used"
                    }
                  },
                  {
                    "range": {
                      "event_date": {
                        "gte": "2015-04-15"
                      }
                    }
                  }
                ]
              },
              "aggs": {
                "count_emogies": {
                  "value_count": {
                    "field": "events.event_name"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```