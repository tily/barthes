class Rdb
  def action(params)
    result = []
    response = execute_query(params['query'])
    if response
      response.each do |row|
        result << row
      end
    end
    result
  end
end
