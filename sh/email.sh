#!/usr/bin/bash

# ======================================================================================
#
#         FILE:  email.sh
#
#        USAGE:  source email.sh
#
#  DESCRIPTION:  Change the inline sections and source it to send email using the CLI.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  --attach file does not working.
#        NOTES:  ---
#       AUTHOR:  Tan Duc Mai, tan.duc.work@gmail.com
#      COMPANY:  Eynesbury Institute of Business and Technology (EIBT)
#      VERSION:  1.0
#      CREATED:  May 17, 2022
#     REVISION:  ---
#
# ======================================================================================

 xdg-email 'tan.duc.work@gmail.com' \
           --cc exampleCC@gmail.com \
           --bcc exampleBCC@gmail.com \
           --subject 'Test email subject' \
           --body 'Test email body'