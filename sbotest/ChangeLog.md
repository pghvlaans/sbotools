## ChangeLog.md

#### 1.1.1 - 2025-08-28
  * bin/test: Reflect changes in `get_all_available()` and use `in()`
  * bin/test: Arrange the testing list in build order
  * bin/test: Faster **\--dry-run**
  * bin/test: Cut out repetitive reverse queue calculations for archive rebuilds
  * bin/test: Fix **\--single** with already-installed packages

#### 1.1 - 2025-08-14
  * bin/test: Report test targets with failures in the build queue separately
  * bin/test: Add --archive-reverse
  * bin/test: Replace get_arch(), which is no longer exported by SBO::Lib::Util
  * bin/{test,pull}: More consistent trailing newline
  * bin/test: Check for missing shared objects upon build failure if SO_CHECK is TRUE

#### 1.0 - 2025-07-04
  * Initial release
