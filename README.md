# GoSweep

The script does automatic checking on a Go package and its sub-packages, including:

1. [gofmt][gofmt]
2. [goimports][goimports]
3. [golint][golint]
4. [go vet][go_vet]
5. [race detector][race_detector]
6. [test coverage][test_coverage] on package and its sub-packages.

Migrated from my [Gist](https://gist.github.com/hailiang/0f22736320abe6be71ce).

[gofmt]:	http://golang.org/cmd/gofmt/	"gofmt"
[goimports]:	https://godoc.org/golang.org/x/tools/cmd/goimports	"golang.org/x/tools/cmd/goimports"
[golint]:	https://github.com/golang/lint	"golang/lint"
[go_vet]:	http://golang.org/cmd/vet	"go vet"
[race_detector]:	http://blog.golang.org/race-detector	"race detector"
[test_coverage]:	http://blog.golang.org/cover	"test coverage"
