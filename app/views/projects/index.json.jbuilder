json.array!(@projects) do |project|
  json.extract! project, :id, :name, :comment, :m_z_start, :m_z_end, :m_z_interval
  json.url project_url(project, format: :json)
end
