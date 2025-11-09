## ChangeLog.md

#### Post-Release
  * *bin/test*: Use the **perl**, **python** and **ruby** package tests in case of failure
  * *bin/test*: Better protections for non-SBO packages
  * *bin/test*: Exit with invalid options
  * *bin/wrapper*: Running without options is handled better
  * *bin/test*: Properly rationalize the queue with **\--archive-rebuild**
  * *bin/test*: Add **\--test-everything**
    * Thanks to dchmelik for the feedback.
  * *bin/test*: Attempt to optimize test queues to reduce the number of package installations and removals
  * Compatibility bump for new *SBO::Lib::Build* queue handling

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
