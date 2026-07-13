namespace :puma do
  desc 'Restart puma via its control app (no sudo needed)'
  task :restart do
    on roles(:web) do
      within current_path do
        execute :bundle, :exec, :pumactl, '-S', fetch(:puma_state_path), 'restart'
      end
    end
  end
end

after 'deploy:finished', 'puma:restart'
