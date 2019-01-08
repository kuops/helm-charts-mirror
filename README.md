# helm-charts-mirror

[![Build Status](https://travis-ci.com/kuops/helm-charts-mirror.svg?branch=master)](https://travis-ci.com/kuops/helm-charts-mirror)

使用 github pages 做了一个 charts 仓库的镜像，由于默认的 googleapi.com 容易被墙 ， 每天更新一次

用法

```
helm  repo remove stable
helm  repo add stable https://kuops.com/helm-charts-mirror/
helm  repo update
helm  search  mysql
```
