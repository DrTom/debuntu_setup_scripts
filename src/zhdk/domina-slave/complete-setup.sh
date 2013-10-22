# domina_ci_executor
debuntu_jvm_open_jdk_install
adduser --disabled-password -gecos "" domina
debuntu_zhdk_domina-ci-executor_setup

# pg
debuntu_database_postgresql_install_9.2
debuntu_database_postgresql_add_superuser domina

debuntu_ci_tightvnc_install
debuntu_invoke_as_user domina debuntu_zhdk_complete-setup-as-user
