debuntu_ci_domina-ci-executor_install "6b03ebd632ea31f8f81b157a69834ee5bda9357c"

cat <<'EOF' > ~/domina_ci_executor/domina_conf.clj
{
 :shared { :working-dir "/tmp/domina_working_dir"
           :git-repos-dir "/tmp/domina_git_repos" 
          }

 :reporter {:max-retries 10
            :retry-ms-factor 3000}

 :nrepl {:port 7888
         :bind "0.0.0.0"
         :enabled true}

 :web {:host "0.0.0.0"
       :port 8088
       :ssl-port 8443}
}
EOF

debuntu_jvm_leiningen_install
