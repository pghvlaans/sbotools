## ChangeLog.md

#### Post-Release
  * tools: Add a script to make a submission-ready archive.

#### 1.3.1 - 2026-08-13
  * Compatibility bump
  * Account for the new **IDLE_BUILD** setting; add **\--idle-build**
    * Thanks to shamefulCake1 for the sbotools request
  * *bin/test*: Correct the valid package types

#### 1.3 - 2026-08-07
  * Compatibility bump
  * Account for the new **NICENESS** setting; add **\--niceness**
    * Thanks to shamefulCake1 for the sbotools request
  * Show version and build number in the results summary where appropriate
  * *bin/test*: Add a **\--force** option to rebuild up-to-date packages with full repo and archive rebuilds
  * *bin/test*: Add a **\--series** option to test everything in a series
  * *bin/test*: More efficient queue score calculation
  * *bin/test*: Faster reusable package detection for dry runs

#### 1.2.3 - 2026-07-31
  * Compatibility bump
  * Document the manual download directory and symlink
  * Document the new **SBO_HOME** default of `/var/lib/sbotest`, etc.
  * Account for the **NO_SOCHECK** setting; replace **\--so-check** with **\--no-socheck**

#### 1.2.2 - 2026-05-06
  * Account for the new **NONET** setting
  * Compatibility bump

#### 1.2.1 - 2025-12-26
  * *bin/test*: Do not reuse log and test directories if called more than once in the same minute
  * *bin/test*: Use a separate `$TMP` directory for each script
  * *bin/test*: Run *sbopkglint* as packages are built, not at the end
  * *bin/test*: Report failed builds with more specific error types
  * Compatibility bump for new *SBO::Lib::Readme* user and group handling
  * *bin/test*: Show `useradd` and `groupadd` commands as they are performed
  * *bin/test*: Unlink outdated packages in archive unless the new build fails

#### 1.2 - 2025-11-20
  * *bin/test*: Use the **perl**, **python** and **ruby** package tests in case of failure
  * *bin/test*: Better protections for non-SBO packages
  * *bin/test*: Exit with invalid options
  * *bin/wrapper*: Running without options is handled better
  * *bin/test*: Properly rationalize the queue with **\--archive-rebuild**
  * *bin/test*: Add **\--test-everything**
    * Thanks to dchmelik for the feedback.
  * *bin/test*: Attempt to optimize test queues to reduce the number of package installations and removals
  * Compatibility bump for new *SBO::Lib::Build* queue handling
  * *bin/test*: Untargeted scripts in the queue also get a clean-build environment
  * *bin/test*: Unlink outdated packages in the archive only once all builds succeed

#### 1.1.2 - 2025-09-19
  * *bin/test*: Fix **\--single** with already-installed scripts

#### 1.1.1 - 2025-08-28
  * *bin/test*: Reflect changes in `get_all_available()` and use `in()`
  * *bin/test*: Arrange the testing list in build order
  * *bin/test*: Faster **\--dry-run**
  * *bin/test*: Cut out repetitive reverse queue calculations for archive rebuilds
  * *bin/test*: Fix **\--single** with already-installed packages

#### 1.1 - 2025-08-14
  * *bin/test*: Report test targets with failures in the build queue separately
  * *bin/test*: Add **\--archive-reverse**
  * *bin/test*: Replace *get_arch()*, which is no longer exported by *SBO::Lib::Util*
  * *bin/{test,pull}*: More consistent trailing newline
  * *bin/test*: Check for missing shared objects upon build failure if **SO_CHECK** is **TRUE**

#### 1.0 - 2025-07-04
  * Initial release
