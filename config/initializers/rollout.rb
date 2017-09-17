$redis = Redis.new
$rollout = Rollout.new($redis)

$rollout.define_group(:beta_testers) do |user|
  user.beta_tester?
end

$rollout.define_group(:admins) do |user|
  user.admin?
end
