def with_env(env)
  old_env = {}
  env.each do |var, val|
    old_env[var] = ENV[var]
    ENV[var] = val
  end
  yield
  old_env.each do |var, val|
    ENV[var] = val
  end
end
