set :scm,                 :passthrough
set :repository,          '.'
set :deploy_via,          :improved_rsync_with_remote_cache
set :rsync_options,       '-azF --delete --delete-excluded'
set :local_cache,         '.'
