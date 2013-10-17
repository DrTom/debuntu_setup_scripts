# Detect if it's Ubuntu so we know if we have to do any Ubuntu-specific extrawursts
function debuntu_system_is_ubuntu {
        if [ "$(lsb_release -is)" = "Ubuntu" ]; then
                echo "this shit is ubuntu"
                return 0
        else
                echo "this shit ain't ubuntu"
                return 1
        fi
}
