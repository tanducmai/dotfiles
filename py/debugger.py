#!/usr/bin/python3
# -*- coding: utf-8 -*-

# =============================================================================
#
#        FILE:  debugger.py
#      AUTHOR:  Tan Duc Mai
#       EMAIL:  tan.duc.work@gmail.com
#     CREATED:  25-Apr-2022
# DESCRIPTION:  Search for the error found with stackoverflow.
#       USAGE:  Paste the code snippet which contains an error into the
#               code_with_error() function.
#               To see the error in beautiful tracebacks, uncomment line 32 and
#               comment out the last 4 lines.
#   I hereby declare that I completed this work without any improper help
#   from a third party and without using any aids other than those cited.
#
# =============================================================================

# ------------------------------- Module Imports ------------------------------
import webbrowser
from rich.traceback import install; install(show_locals=True)


# ---------------------------- Function Definition ----------------------------
def code_with_error():
    pass


# --------------------------- Call the Main Function --------------------------
if __name__ == '__main__':
    # code_with_error()
    try:
        code_with_error()
    except Exception as e:
        webbrowser.open('http://stackoverflow.com/search?q=[python] ' + str(e))
